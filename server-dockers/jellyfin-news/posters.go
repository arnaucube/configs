package main

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"regexp"
	"sort"
	"strconv"
	"strings"
	"time"
)

type posterTitle struct {
	Name string `json:"name"`
	Kind string `json:"kind"`
	URL  string `json:"url"`
}

type extraTitle struct {
	name string
	kind string
	year int
}

var movieYear = regexp.MustCompile(`^(.*) \(([0-9]{4})\)$`)

// parseExtraTitles accepts the headings and bullet entries used in added recaps.
func parseExtraTitles(text string, labels Labels) ([]extraTitle, error) {
	var titles []extraTitle
	kind := ""
	for _, raw := range strings.Split(text, "\n") {
		line := strings.TrimSpace(strings.TrimSuffix(raw, "\r"))
		switch line {
		case "":
			continue
		case labels.Movies + ":":
			kind = "Movie"
			continue
		case labels.Shows + ":":
			kind = "Series"
			continue
		}
		if !strings.HasPrefix(line, "• ") {
			// A pasted recap can include its date and title above the list.
			if kind == "" && !strings.HasPrefix(line, "•") {
				continue
			}
			return nil, fmt.Errorf("Invalid extra title: %s", line)
		}
		if kind == "" {
			return nil, errors.New("Add a Movies: or Shows: heading before extra titles.")
		}
		name := strings.TrimSpace(strings.TrimPrefix(line, "• "))
		if kind == "Series" {
			name, _, _ = strings.Cut(name, " — ")
		}
		year := 0
		if kind == "Movie" {
			if match := movieYear.FindStringSubmatch(name); match != nil {
				name = strings.TrimSpace(match[1])
				year, _ = strconv.Atoi(match[2])
			}
		}
		if name == "" || len(titles) >= 50 {
			return nil, errors.New("Enter 1 to 50 named movies or shows.")
		}
		titles = append(titles, extraTitle{name: name, kind: kind, year: year})
	}
	return titles, nil
}

// posters uses the same added-date boundaries as the selected text recap.
func (a *app) posters(w http.ResponseWriter, r *http.Request) {
	var extras []extraTitle
	if r.Method == http.MethodPost {
		body, err := io.ReadAll(io.LimitReader(r.Body, 32*1024+1))
		if err != nil || len(body) > 32*1024 {
			http.Error(w, "Extra titles are too long.", http.StatusBadRequest)
			return
		}
		extras, err = parseExtraTitles(string(body), a.labels)
		if err != nil || len(extras) == 0 {
			http.Error(w, "Use Movies: and Shows: headings with bullet entries, up to 50 titles.", http.StatusBadRequest)
			return
		}
	}
	now := a.now().In(a.location)
	start, end := a.weekStart.start(now), now
	switch r.URL.Query().Get("period") {
	case "current-week":
	case "week", "month":
		offset, ok := readOffset(w, r)
		if !ok {
			return
		}
		if r.URL.Query().Get("period") == "month" {
			start = time.Date(now.Year(), now.Month(), 1, 0, 0, 0, 0, a.location).AddDate(0, offset, 0)
			end = start.AddDate(0, 1, 0)
		} else {
			start = start.AddDate(0, 0, offset*7)
			end = start.AddDate(0, 0, 7)
		}
	default:
		http.Error(w, "Invalid report period.", http.StatusBadRequest)
		return
	}
	items, err := a.jellyfin.AddedBetween(r.Context(), start, end)
	if err != nil {
		http.Error(w, "Could not query Jellyfin for posters.", http.StatusBadGateway)
		return
	}
	titles := make([]posterTitle, 0)
	seen := make(map[string]bool)
	for _, item := range items {
		id, name, kind := item.ID, item.Name, a.labels.Movies
		switch item.Type {
		case "Movie":
			if item.ProductionYear != nil {
				name = fmt.Sprintf("%s (%d)", name, *item.ProductionYear)
			}
		case "Episode":
			id, name, kind = item.SeriesID, item.SeriesName, a.labels.Shows
			if strings.TrimSpace(name) == "" {
				name = a.labels.UnknownShow
			}
		default:
			continue
		}
		key := item.Type + ":" + id
		if id == "" {
			key += name
		}
		if seen[key] {
			continue
		}
		seen[key] = true
		imageURL := ""
		if validPosterID.MatchString(id) {
			imageURL = "/api/poster/" + url.PathEscape(id)
		}
		titles = append(titles, posterTitle{Name: name, Kind: kind, URL: imageURL})
	}
	if len(extras) > 0 {
		searcher, ok := a.jellyfin.(interface {
			FindPosterTitle(context.Context, string, string, int) (string, error)
		})
		for _, extra := range extras {
			kind := a.labels.Movies
			if extra.kind == "Series" {
				kind = a.labels.Shows
			}
			name := extra.name
			if extra.year != 0 {
				name = fmt.Sprintf("%s (%d)", name, extra.year)
			}
			key := strings.ToLower(kind + ":" + name)
			duplicate := false
			for _, title := range titles {
				if strings.ToLower(title.Kind+":"+title.Name) == key ||
					(extra.kind == "Movie" && extra.year == 0 && title.Kind == kind &&
						movieYear.MatchString(title.Name) && strings.EqualFold(movieYear.FindStringSubmatch(title.Name)[1], name)) {
					duplicate = true
					break
				}
			}
			if duplicate {
				continue
			}
			imageURL := ""
			if ok {
				id, err := searcher.FindPosterTitle(r.Context(), extra.kind, extra.name, extra.year)
				if err != nil {
					http.Error(w, "Could not query Jellyfin for extra posters.", http.StatusBadGateway)
					return
				}
				if validPosterID.MatchString(id) {
					imageURL = "/api/poster/" + url.PathEscape(id)
				}
			}
			titles = append(titles, posterTitle{Name: name, Kind: kind, URL: imageURL})
		}
	}
	sort.Slice(titles, func(i, j int) bool {
		if titles[i].Kind != titles[j].Kind {
			return titles[i].Kind < titles[j].Kind
		}
		return strings.ToLower(titles[i].Name) < strings.ToLower(titles[j].Name)
	})
	w.Header().Set("Content-Type", "application/json")
	w.Header().Set("Cache-Control", "no-store")
	title := a.labels.WeeklyUpdate
	if r.URL.Query().Get("period") == "month" {
		title = a.labels.MonthlyUpdate
	}
	json.NewEncoder(w).Encode(struct {
		Start  string        `json:"start"`
		End    string        `json:"end"`
		Title  string        `json:"title"`
		Titles []posterTitle `json:"titles"`
	}{start.Format("2006-01-02"), end.Format("2006-01-02"), title, titles})
}

var validPosterID = regexp.MustCompile(`^[a-zA-Z0-9-]{1,64}$`)
var errNoPoster = errors.New("poster unavailable")

// Poster fetches bounded, resized artwork while keeping Jellyfin credentials on the server.
func (c *Client) Poster(ctx context.Context, id string) ([]byte, error) {
	if !validPosterID.MatchString(id) {
		return nil, errNoPoster
	}
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, c.baseURL+"/Items/"+id+"/Images/Primary?maxWidth=480&maxHeight=720&format=Jpg", nil)
	if err != nil {
		return nil, err
	}
	req.Header.Set("X-Emby-Token", c.apiKey)
	resp, err := c.http.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()
	if resp.StatusCode == http.StatusNotFound {
		return nil, errNoPoster
	}
	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("Jellyfin poster returned HTTP %d", resp.StatusCode)
	}
	const maxSize = 5 << 20
	data, err := io.ReadAll(io.LimitReader(resp.Body, maxSize+1))
	if err != nil {
		return nil, err
	}
	if len(data) > maxSize {
		return nil, errors.New("poster exceeds size limit")
	}
	switch http.DetectContentType(data) {
	case "image/jpeg", "image/png", "image/webp":
		return data, nil
	default:
		return nil, errors.New("invalid poster image")
	}
}

// poster serves same-origin artwork so the browser can export a canvas without exposing the API key.
func (a *app) poster(w http.ResponseWriter, r *http.Request) {
	id := r.PathValue("id")
	if !validPosterID.MatchString(id) {
		http.Error(w, "Invalid poster ID.", http.StatusBadRequest)
		return
	}
	source, ok := a.jellyfin.(interface {
		Poster(context.Context, string) ([]byte, error)
	})
	if !ok {
		http.Error(w, "Posters unavailable.", http.StatusServiceUnavailable)
		return
	}
	data, err := source.Poster(r.Context(), id)
	if errors.Is(err, errNoPoster) {
		http.NotFound(w, r)
		return
	}
	if err != nil {
		http.Error(w, "Could not load poster.", http.StatusBadGateway)
		return
	}
	w.Header().Set("Content-Type", http.DetectContentType(data))
	w.Header().Set("Cache-Control", "private, max-age=3600")
	w.Header().Set("X-Content-Type-Options", "nosniff")
	w.Write(data)
}
