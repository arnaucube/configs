package main

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
	"time"
)

func TestJellystatHistoryRepeatsPaginationAndTypes(t *testing.T) {
	start := time.Date(2026, 8, 1, 0, 0, 0, 0, time.UTC)
	end := start.AddDate(0, 1, 0)
	play := func(id, user, date string) playback { return playback{ItemID: id, UserID: user, Date: date} }
	calls := map[string]int{}
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.Header.Get("x-api-token") != "test-key" {
			t.Error("missing API key")
		}
		if r.URL.Path == "/api/getHistory" {
			if r.URL.Query().Get("filters") != "" {
				t.Error("date filtering would hide historical repeats")
			}
			var rows []playback
			switch r.URL.Query().Get("page") {
			case "1":
				rows = []playback{
					{ItemID: "movie", UserID: "private-user-a", Date: end.Format(time.RFC3339), Results: []playback{play("movie", "private-user-a", end.Format(time.RFC3339)), play("movie", "private-user-a", start.Format(time.RFC3339))}},
					play("show", "private-user-a", "2026-08-10T12:00:00Z"),
					play("excluded", "private-user-a", end.Format(time.RFC3339)),
				}
			case "2":
				rows = []playback{play("movie", "private-user-b", "2026-08-15T12:00:00Z"), play("show", "private-user-a", "2026-08-11T12:00:00Z"), play("music", "private-user-a", "2026-08-10T12:00:00Z")}
			default:
				t.Error("unexpected page")
			}
			for i := range rows {
				if rows[i].Results == nil {
					rows[i].Results = []playback{rows[i]}
				}
			}
			json.NewEncoder(w).Encode(map[string]any{"pages": 2, "results": rows})
			return
		}
		if r.Method != http.MethodPost || r.URL.Path != "/api/getItemDetails" {
			t.Errorf("unexpected request %s", r.URL.Path)
		}
		var body map[string]string
		json.NewDecoder(r.Body).Decode(&body)
		id := body["Id"]
		calls[id]++
		kind := map[string]string{"movie": "Movie", "show": "Series", "music": "Audio"}[id]
		json.NewEncoder(w).Encode([]map[string]string{{"Type": kind, "Name": id}})
	}))
	defer server.Close()
	client, err := NewJellystat(server.URL, "test-key")
	if err != nil {
		t.Fatal(err)
	}
	titles, err := client.WatchedBetween(context.Background(), start, end)
	if err != nil {
		t.Fatal(err)
	}
	got := FormatWatched(start, end, true, titles, DefaultLabels())
	want := "2026-08 jellyfin watched recap:\n\nMovies: movie (2 users)\n\nShows: show"
	if got != want {
		t.Fatalf("got %q, want %q", got, want)
	}
	if calls["show"] != 1 || calls["excluded"] != 0 {
		t.Fatalf("metadata calls = %v", calls)
	}
}

func TestJellystatFailures(t *testing.T) {
	for _, tc := range []struct {
		name, body string
		status     int
	}{
		{"unauthorized", "secret upstream body", 401},
		{"invalid JSON", "not JSON", 200},
		{"missing results", `{}`, 200},
		{"bad timestamp", `{"pages":1,"results":[{"ActivityDateInserted":"bad"}]}`, 200},
		{"incomplete pagination", `{"pages":2,"results":[]}`, 200},
	} {
		t.Run(tc.name, func(t *testing.T) {
			server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) { w.WriteHeader(tc.status); fmt.Fprint(w, tc.body) }))
			defer server.Close()
			client, _ := NewJellystat(server.URL, "test-key")
			_, err := client.WatchedBetween(context.Background(), time.Now().Add(-time.Hour), time.Now())
			if err == nil || strings.Contains(err.Error(), "secret") {
				t.Fatalf("error = %v", err)
			}
		})
	}
}

func TestWatchedTranslations(t *testing.T) {
	labels := DefaultLabels()
	labels.WatchedUpdate = "Vistos"
	labels.Users = "usuarios"
	labels.Movies = "Películas"
	labels.NoWatchedItems = "Nada"
	now := time.Now()
	got := FormatWatched(now, now, false, []WatchedTitle{{Name: "Example", Type: "Movie", Users: 2}}, labels)
	for _, text := range []string{"Vistos:", "Películas:", "2 usuarios"} {
		if !strings.Contains(got, text) {
			t.Fatal(got)
		}
	}
	if got := FormatWatched(now, now, false, nil, labels); !strings.HasSuffix(got, "\n\nNada") {
		t.Fatal(got)
	}
}

func TestJellystatMissingGroupedHistory(t *testing.T) {
	start := time.Date(2026, 8, 1, 0, 0, 0, 0, time.UTC)
	end := start.AddDate(0, 1, 0)
	pages := 0
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		switch r.URL.Path {
		case "/api/getHistory":
			fmt.Fprint(w, `{"pages":1,"results":[{"NowPlayingItemId":"movie","UserId":"a","ActivityDateInserted":"2026-09-02T00:00:00Z","results":null}]}`)
		case "/api/getItemHistory":
			pages++
			if r.Method != "POST" || !strings.Contains(r.URL.Query().Get("filters"), "ActivityDateInserted") {
				t.Error("missing raw history filters")
			}
			switch r.URL.Query().Get("page") {
			case "1":
				fmt.Fprint(w, `{"pages":2,"results":[{"NowPlayingItemId":"movie","UserId":"a","ActivityDateInserted":"2026-08-01T00:00:00Z"}]}`)
			case "2":
				fmt.Fprint(w, `{"pages":2,"results":[{"NowPlayingItemId":"movie","UserId":"b","ActivityDateInserted":"2026-08-15T00:00:00Z"},{"NowPlayingItemId":"movie","UserId":"c","ActivityDateInserted":"2026-09-01T00:00:00Z"}]}`)
			default:
				t.Error("unexpected page")
			}
		case "/api/getItemDetails":
			fmt.Fprint(w, `[{"Name":"Movie","Type":"Movie"}]`)
		default:
			t.Error("unexpected endpoint")
		}
	}))
	defer server.Close()
	client, _ := NewJellystat(server.URL, "test-key")
	titles, err := client.WatchedBetween(context.Background(), start, end)
	if err != nil {
		t.Fatal(err)
	}
	if len(titles) != 1 || titles[0].Users != 2 || pages != 2 {
		t.Fatalf("titles=%v pages=%d", titles, pages)
	}
}

func TestWatchedTitlesInline(t *testing.T) {
	start := time.Date(2026, 8, 1, 0, 0, 0, 0, time.UTC)
	titles := []WatchedTitle{
		{Name: "Severance", Type: "Series", Users: 2},
		{Name: "Dune", Type: "Movie", Users: 3},
		{Name: "Arrival", Type: "Movie", Users: 1},
		{Name: "Andor", Type: "Series", Users: 1},
	}
	got := FormatWatched(start, start.AddDate(0, 1, 0), true, titles, DefaultLabels())
	want := "2026-08 jellyfin watched recap:\n\nMovies: Arrival, Dune (3 users)\n\nShows: Andor, Severance (2 users)"
	if got != want {
		t.Fatalf("got %q, want %q", got, want)
	}
}
