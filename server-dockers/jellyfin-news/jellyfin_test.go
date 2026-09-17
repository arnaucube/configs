package main

import (
	"context"
	"io"
	"net/http"
	"strings"
	"testing"
	"time"
)

type roundTripFunc func(*http.Request) (*http.Response, error)

func (f roundTripFunc) RoundTrip(r *http.Request) (*http.Response, error) { return f(r) }

func TestAddedBetween(t *testing.T) {
	httpClient := &http.Client{Transport: roundTripFunc(func(r *http.Request) (*http.Response, error) {
		if r.Header.Get("X-Emby-Token") != "secret" {
			t.Error("missing API key")
		}
		if r.URL.Query().Get("IncludeItemTypes") != "Movie,Episode" {
			t.Error("wrong item filter")
		}
		body := `{"Items":[
            {"Id":"new","Type":"Movie","Name":"New","DateCreated":"2026-08-24T10:00:00Z"},
            {"Id":"old","Type":"Movie","Name":"Old","DateCreated":"2026-08-17T09:00:00Z"}
        ],"TotalRecordCount":2}`
		return &http.Response{StatusCode: http.StatusOK, Body: io.NopCloser(strings.NewReader(body)), Header: make(http.Header)}, nil
	})}
	c, err := New("http://jellyfin.test", "secret", "", httpClient)
	if err != nil {
		t.Fatal(err)
	}
	start := time.Date(2026, 8, 18, 0, 0, 0, 0, time.UTC)
	end := time.Date(2026, 8, 25, 0, 0, 0, 0, time.UTC)
	items, err := c.AddedBetween(context.Background(), start, end)
	if err != nil {
		t.Fatal(err)
	}
	if len(items) != 1 || items[0].Name != "New" || items[0].ID != "new" {
		t.Fatalf("items = %#v", items)
	}
}

func TestFindPosterTitleMatchesKindNameAndYear(t *testing.T) {
	client, err := New("http://jellyfin.test", "secret", "user", &http.Client{Transport: roundTripFunc(func(r *http.Request) (*http.Response, error) {
		q := r.URL.Query()
		if r.URL.Path != "/Items" || (q.Get("SearchTerm") != "Dune" && q.Get("SearchTerm") != "Missing") || q.Get("IncludeItemTypes") != "Movie" || q.Get("Recursive") != "true" || q.Get("UserId") != "user" || r.Header.Get("X-Emby-Token") != "secret" {
			t.Errorf("unexpected search request: %s", r.URL)
		}
		body := `{"Items":[{"Id":"series","Type":"Series","Name":"Dune"},{"Id":"old","Type":"Movie","Name":"Dune","ProductionYear":1984},{"Id":"new","Type":"Movie","Name":"Dune","ProductionYear":2021}]}`
		return &http.Response{StatusCode: 200, Body: io.NopCloser(strings.NewReader(body)), Header: make(http.Header)}, nil
	})})
	if err != nil {
		t.Fatal(err)
	}
	id, err := client.FindPosterTitle(context.Background(), "Movie", "Dune", 2021)
	if err != nil || id != "new" {
		t.Fatalf("match = %q, %v", id, err)
	}
	id, err = client.FindPosterTitle(context.Background(), "Movie", "Missing", 2021)
	if err != nil || id != "" {
		t.Fatalf("missing = %q, %v", id, err)
	}
}
