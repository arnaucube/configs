package main

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"net/url"
	"strconv"
	"strings"
	"time"
)

type Client struct {
	baseURL string
	apiKey  string
	userID  string
	http    *http.Client
}

func New(baseURL, apiKey, userID string, httpClient *http.Client) (*Client, error) {
	baseURL = strings.TrimRight(strings.TrimSpace(baseURL), "/")
	if _, err := url.ParseRequestURI(baseURL); err != nil || !(strings.HasPrefix(baseURL, "http://") || strings.HasPrefix(baseURL, "https://")) {
		return nil, fmt.Errorf("invalid JELLYFIN_URL %q", baseURL)
	}
	if strings.TrimSpace(apiKey) == "" {
		return nil, fmt.Errorf("JELLYFIN_API_KEY is required")
	}
	if httpClient == nil {
		httpClient = &http.Client{Timeout: 30 * time.Second}
	}
	return &Client{baseURL: baseURL, apiKey: apiKey, userID: strings.TrimSpace(userID), http: httpClient}, nil
}

type response struct {
	Items            []item `json:"Items"`
	TotalRecordCount int    `json:"TotalRecordCount"`
}

type item struct {
	ID                string `json:"Id"`
	Type              string `json:"Type"`
	Name              string `json:"Name"`
	SeriesID          string `json:"SeriesId"`
	SeriesName        string `json:"SeriesName"`
	ParentIndexNumber *int   `json:"ParentIndexNumber"`
	IndexNumber       *int   `json:"IndexNumber"`
	ProductionYear    *int   `json:"ProductionYear"`
	DateCreated       string `json:"DateCreated"`
}

// AddedBetween returns movies and episodes whose Jellyfin DateCreated is in [start, end).
func (c *Client) AddedBetween(ctx context.Context, start, end time.Time) ([]Item, error) {
	const pageSize = 200
	var result []Item
	for offset := 0; ; offset += pageSize {
		params := url.Values{
			"IncludeItemTypes":       {"Movie,Episode"},
			"Recursive":              {"true"},
			"Fields":                 {"DateCreated"},
			"SortBy":                 {"DateCreated"},
			"SortOrder":              {"Descending"},
			"EnableImages":           {"false"},
			"EnableUserData":         {"false"},
			"EnableTotalRecordCount": {"true"},
			"StartIndex":             {strconv.Itoa(offset)},
			"Limit":                  {strconv.Itoa(pageSize)},
		}
		if c.userID != "" {
			params.Set("UserId", c.userID)
		}
		req, err := http.NewRequestWithContext(ctx, http.MethodGet, c.baseURL+"/Items?"+params.Encode(), nil)
		if err != nil {
			return nil, err
		}
		req.Header.Set("X-Emby-Token", c.apiKey)
		resp, err := c.http.Do(req)
		if err != nil {
			return nil, fmt.Errorf("query Jellyfin: %w", err)
		}
		var page response
		decodeErr := json.NewDecoder(resp.Body).Decode(&page)
		resp.Body.Close()
		if resp.StatusCode < 200 || resp.StatusCode >= 300 {
			return nil, fmt.Errorf("Jellyfin returned HTTP %d", resp.StatusCode)
		}
		if decodeErr != nil {
			return nil, fmt.Errorf("decode Jellyfin response: %w", decodeErr)
		}
		pastStart := false
		for _, raw := range page.Items {
			created, err := time.Parse(time.RFC3339Nano, raw.DateCreated)
			if err != nil {
				continue
			}
			if created.Before(start) {
				pastStart = true
				continue
			}
			if !created.Before(end) {
				continue
			}
			result = append(result, Item{
				ID:   raw.ID,
				Type: raw.Type, Name: raw.Name, SeriesID: raw.SeriesID,
				SeriesName: raw.SeriesName, SeasonNumber: raw.ParentIndexNumber,
				EpisodeNumber: raw.IndexNumber, ProductionYear: raw.ProductionYear,
			})
		}
		if pastStart || len(page.Items) < pageSize || (page.TotalRecordCount > 0 && offset+len(page.Items) >= page.TotalRecordCount) {
			break
		}
	}
	return result, nil
}
