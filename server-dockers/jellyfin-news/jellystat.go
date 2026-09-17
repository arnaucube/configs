package main

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"net/url"
	"sort"
	"strconv"
	"strings"
	"time"
)

type JellystatClient struct {
	baseURL, apiKey string
	http            *http.Client
}

// NewJellystat validates the optional playback-history connection.
func NewJellystat(baseURL, apiKey string) (*JellystatClient, error) {
	u, err := url.Parse(strings.TrimRight(strings.TrimSpace(baseURL), "/"))
	if err != nil || u.Host == "" || (u.Scheme != "http" && u.Scheme != "https") || u.User != nil || u.RawQuery != "" || u.Fragment != "" {
		return nil, fmt.Errorf("invalid JELLYSTAT_URL")
	}
	if strings.TrimSpace(apiKey) == "" {
		return nil, fmt.Errorf("JELLYSTAT_API_KEY is required when JELLYSTAT_URL is set")
	}
	return &JellystatClient{u.String(), strings.TrimSpace(apiKey), &http.Client{Timeout: 30 * time.Second, CheckRedirect: func(*http.Request, []*http.Request) error { return http.ErrUseLastResponse }}}, nil
}

type playback struct {
	UserID  string     `json:"UserId"`
	ItemID  string     `json:"NowPlayingItemId"`
	Date    string     `json:"ActivityDateInserted"`
	Results []playback `json:"results"`
}

type WatchedTitle struct {
	ID, Type, Name string
	Users          int
}

// request keeps upstream bodies and connection details out of errors and logs.
func (c *JellystatClient) request(ctx context.Context, path string, body []byte, dst any) error {
	method := http.MethodGet
	if body != nil {
		method = http.MethodPost
	}
	req, err := http.NewRequestWithContext(ctx, method, c.baseURL+path, bytes.NewReader(body))
	if err != nil {
		return fmt.Errorf("create Jellystat request")
	}
	req.Header.Set("x-api-token", c.apiKey)
	if body != nil {
		req.Header.Set("Content-Type", "application/json")
	}
	resp, err := c.http.Do(req)
	if err != nil {
		return fmt.Errorf("Jellystat request failed")
	}
	defer resp.Body.Close()
	if resp.StatusCode != http.StatusOK {
		return fmt.Errorf("Jellystat returned HTTP %d", resp.StatusCode)
	}
	if err := json.NewDecoder(resp.Body).Decode(dst); err != nil {
		return fmt.Errorf("invalid Jellystat response")
	}
	return nil
}

// WatchedBetween checks individual plays, because date filters on getHistory apply
// to the latest play in each group and can hide earlier repeat viewings.
func (c *JellystatClient) WatchedBetween(ctx context.Context, start, end time.Time) ([]WatchedTitle, error) {
	users := map[string]map[string]bool{}
	fallback := map[string][]playback{}
	for page := 1; ; page++ {
		var response struct {
			Pages   int        `json:"pages"`
			Results []playback `json:"results"`
		}
		params := url.Values{"page": {strconv.Itoa(page)}, "size": {"200"}, "sort": {"ActivityDateInserted"}, "desc": {"true"}}
		if err := c.request(ctx, "/api/getHistory?"+params.Encode(), nil, &response); err != nil {
			return nil, err
		}
		if response.Results == nil {
			return nil, fmt.Errorf("Jellystat history is missing results")
		}
		for _, group := range response.Results {
			plays := group.Results
			if len(plays) == 0 {
				// Some Jellystat versions omit nested movie plays. Fetch the
				// ungrouped item history instead of treating the latest play as complete.
				if group.ItemID == "" {
					return nil, fmt.Errorf("Jellystat playback is missing item ID")
				}
				var ok bool
				plays, ok = fallback[group.ItemID]
				if !ok {
					var err error
					plays, err = c.itemHistory(ctx, group.ItemID, start, end)
					if err != nil {
						return nil, err
					}
					fallback[group.ItemID] = plays
				}
			}
			for _, play := range plays {
				date, err := time.Parse(time.RFC3339Nano, play.Date)
				if err != nil {
					return nil, fmt.Errorf("invalid Jellystat playback timestamp")
				}
				if date.Before(start) || !date.Before(end) {
					continue
				}
				id, user := play.ItemID, play.UserID
				if id == "" {
					id = group.ItemID
				}
				if user == "" {
					user = group.UserID
				}
				if id == "" || user == "" {
					return nil, fmt.Errorf("Jellystat playback is missing item or user ID")
				}
				if users[id] == nil {
					users[id] = map[string]bool{}
				}
				users[id][user] = true
			}
		}
		if page >= response.Pages {
			break
		}
		if len(response.Results) == 0 {
			return nil, fmt.Errorf("incomplete Jellystat history pagination")
		}
	}
	var titles []WatchedTitle
	for id, viewers := range users {
		body, _ := json.Marshal(map[string]string{"Id": id})
		var details []struct{ Name, Type string }
		if err := c.request(ctx, "/api/getItemDetails", body, &details); err != nil {
			return nil, err
		}
		if len(details) == 0 {
			return nil, fmt.Errorf("Jellystat item metadata is missing")
		}
		item := details[0]
		if item.Type != "Movie" && item.Type != "Series" {
			continue
		}
		titles = append(titles, WatchedTitle{id, item.Type, item.Name, len(viewers)})
	}
	return titles, nil
}

// itemHistory retrieves raw plays when a grouped response omits its history.
func (c *JellystatClient) itemHistory(ctx context.Context, id string, start, end time.Time) ([]playback, error) {
	body, _ := json.Marshal(map[string]string{"itemid": id})
	filters, _ := json.Marshal([]map[string]string{{"field": "ActivityDateInserted", "min": start.UTC().Format(time.RFC3339Nano), "max": end.UTC().Format(time.RFC3339Nano)}})
	var plays []playback
	for page := 1; ; page++ {
		params := url.Values{"page": {strconv.Itoa(page)}, "size": {"200"}, "filters": {string(filters)}}
		var response struct {
			Pages   int        `json:"pages"`
			Results []playback `json:"results"`
		}
		if err := c.request(ctx, "/api/getItemHistory?"+params.Encode(), body, &response); err != nil {
			return nil, err
		}
		if response.Results == nil {
			return nil, fmt.Errorf("Jellystat item history is missing results")
		}
		plays = append(plays, response.Results...)
		if page >= response.Pages {
			return plays, nil
		}
		if len(response.Results) == 0 {
			return nil, fmt.Errorf("incomplete Jellystat item history pagination")
		}
	}
}

// FormatWatched groups comma-separated titles without disclosing account identities.
func FormatWatched(start, end time.Time, monthly bool, titles []WatchedTitle, labels Labels) string {
	period := start.Format("2006-01-02") + " - " + end.Format("2006-01-02")
	if monthly {
		period = start.Format("2006-01")
	}
	var out strings.Builder
	fmt.Fprintf(&out, "%s %s:\n", period, labels.WatchedUpdate)
	if len(titles) == 0 {
		return out.String() + "\n" + labels.NoWatchedItems
	}
	sorted := append([]WatchedTitle(nil), titles...)
	sort.Slice(sorted, func(i, j int) bool {
		a, b := strings.ToLower(sorted[i].Name), strings.ToLower(sorted[j].Name)
		if a == b {
			return sorted[i].ID < sorted[j].ID
		}
		return a < b
	})
	for _, section := range []struct{ kind, label string }{{"Movie", labels.Movies}, {"Series", labels.Shows}} {
		heading := false
		for _, title := range sorted {
			if title.Type != section.kind {
				continue
			}
			if !heading {
				fmt.Fprintf(&out, "\n%s: ", section.label)
				heading = true
			} else {
				out.WriteString(", ")
			}
			out.WriteString(title.Name)
			if title.Users > 1 {
				fmt.Fprintf(&out, " (%d %s)", title.Users, labels.Users)
			}
		}
		if heading {
			out.WriteByte('\n')
		}
	}
	return strings.TrimRight(out.String(), "\n")
}
