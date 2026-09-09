package main

import (
	"context"
	"fmt"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
	"time"
)

type fakeSource struct {
	start time.Time
	end   time.Time
	items []Item
	err   error
}

func (f *fakeSource) AddedBetween(_ context.Context, start, end time.Time) ([]Item, error) {
	f.start, f.end = start, end
	return f.items, f.err
}

func testApp(source *fakeSource) *app {
	return &app{
		jellyfin: source,
		location: time.UTC,
		labels:   DefaultLabels(),
		now: func() time.Time {
			return time.Date(2026, 9, 2, 12, 0, 0, 0, time.UTC)
		},
	}
}

func TestCurrentWeek(t *testing.T) {
	source := &fakeSource{}
	request := httptest.NewRequest(http.MethodGet, "/api/current-week", nil)
	response := httptest.NewRecorder()
	testApp(source).routes().ServeHTTP(response, request)

	if response.Code != http.StatusOK {
		t.Fatalf("status = %d, body = %q", response.Code, response.Body.String())
	}
	if got := response.Body.String(); !strings.HasPrefix(got, "2026-08-31 - 2026-09-02 jellyfin weekly update:") {
		t.Fatalf("body = %q", got)
	}
	wantStart := time.Date(2026, 8, 31, 0, 0, 0, 0, time.UTC)
	if !source.start.Equal(wantStart) || !source.end.Equal(testApp(source).now()) {
		t.Fatalf("range = %v to %v", source.start, source.end)
	}
}

func TestStartOfWeekUsesMondayMidnight(t *testing.T) {
	location := time.FixedZone("test", 2*60*60)
	now := time.Date(2026, 9, 6, 23, 45, 0, 0, location) // Sunday
	want := time.Date(2026, 8, 31, 0, 0, 0, 0, location)
	if got := startOfWeek(now); !got.Equal(want) {
		t.Fatalf("startOfWeek() = %v, want %v", got, want)
	}
}

func TestSelectedWeek(t *testing.T) {
	source := &fakeSource{}
	request := httptest.NewRequest(http.MethodGet, "/api/week?offset=-2", nil)
	response := httptest.NewRecorder()
	testApp(source).routes().ServeHTTP(response, request)

	if response.Code != http.StatusOK {
		t.Fatalf("status = %d, body = %q", response.Code, response.Body.String())
	}
	if got := response.Body.String(); !strings.HasPrefix(got, "2026-08-17 - 2026-08-24 jellyfin weekly update:") {
		t.Fatalf("body = %q", got)
	}
}

func TestSelectedWeekRejectsInvalidOffset(t *testing.T) {
	request := httptest.NewRequest(http.MethodGet, "/api/week?offset=0", nil)
	response := httptest.NewRecorder()
	testApp(&fakeSource{}).routes().ServeHTTP(response, request)
	if response.Code != http.StatusBadRequest {
		t.Fatalf("status = %d", response.Code)
	}
}

func TestSelectedMonth(t *testing.T) {
	source := &fakeSource{}
	request := httptest.NewRequest(http.MethodGet, "/api/month?offset=-2", nil)
	response := httptest.NewRecorder()
	testApp(source).routes().ServeHTTP(response, request)

	if response.Code != http.StatusOK {
		t.Fatalf("status = %d, body = %q", response.Code, response.Body.String())
	}
	if got := response.Body.String(); !strings.HasPrefix(got, "2026-07 jellyfin monthly update:") {
		t.Fatalf("body = %q", got)
	}
	if source.start.Month() != time.July || source.end.Month() != time.August {
		t.Fatalf("range = %v to %v", source.start, source.end)
	}
}

func TestSelectedMonthRejectsInvalidOffset(t *testing.T) {
	request := httptest.NewRequest(http.MethodGet, "/api/month?offset=0", nil)
	response := httptest.NewRecorder()
	testApp(&fakeSource{}).routes().ServeHTTP(response, request)
	if response.Code != http.StatusBadRequest {
		t.Fatalf("status = %d", response.Code)
	}
}

func TestIndex(t *testing.T) {
	request := httptest.NewRequest(http.MethodGet, "/", nil)
	response := httptest.NewRecorder()
	testApp(&fakeSource{}).routes().ServeHTTP(response, request)
	if response.Code != http.StatusOK || !strings.Contains(response.Body.String(), "Jellyfin updates") {
		t.Fatalf("status = %d, body = %q", response.Code, response.Body.String())
	}
}

type fakeWatched struct {
	start, end time.Time
	err        error
}

func (f *fakeWatched) WatchedBetween(_ context.Context, start, end time.Time) ([]WatchedTitle, error) {
	f.start, f.end = start, end
	return []WatchedTitle{{ID: "movie", Name: "Example", Type: "Movie", Users: 2}}, f.err
}

func TestWatchedPeriods(t *testing.T) {
	for _, tc := range []struct{ query, start, end string }{
		{"period=current-week", "2026-08-31T00:00:00Z", "2026-09-02T12:00:00Z"},
		{"period=week&offset=-2", "2026-08-17T00:00:00Z", "2026-08-24T00:00:00Z"},
		{"period=month&offset=-1", "2026-08-01T00:00:00Z", "2026-09-01T00:00:00Z"},
	} {
		t.Run(tc.query, func(t *testing.T) {
			a := testApp(&fakeSource{})
			source := &fakeWatched{}
			a.jellystat = source
			response := httptest.NewRecorder()
			a.routes().ServeHTTP(response, httptest.NewRequest("GET", "/api/watched?"+tc.query, nil))
			if response.Code != 200 || !strings.Contains(response.Body.String(), "Example — 2 users") {
				t.Fatalf("response: %d %s", response.Code, response.Body.String())
			}
			if source.start.Format(time.RFC3339) != tc.start || source.end.Format(time.RFC3339) != tc.end {
				t.Fatalf("range: %v to %v", source.start, source.end)
			}
			if response.Header().Get("Cache-Control") != "no-store" {
				t.Fatal("missing no-store")
			}
		})
	}
}

func TestWatchedErrors(t *testing.T) {
	for _, tc := range []struct {
		query  string
		source watchedSource
		status int
	}{
		{"period=current-week", nil, 503},
		{"period=week&offset=0", nil, 400},
		{"period=invalid", nil, 400},
		{"period=current-week", &fakeWatched{err: fmt.Errorf("upstream failure")}, 502},
	} {
		a := testApp(&fakeSource{})
		a.jellystat = tc.source
		response := httptest.NewRecorder()
		a.routes().ServeHTTP(response, httptest.NewRequest("GET", "/api/watched?"+tc.query, nil))
		if response.Code != tc.status {
			t.Fatalf("status = %d, want %d", response.Code, tc.status)
		}
	}
}

func TestWatchedButtonEscapesTranslation(t *testing.T) {
	a := testApp(&fakeSource{})
	a.labels.WatchedButton = "<Watch & copy>"
	response := httptest.NewRecorder()
	a.routes().ServeHTTP(response, httptest.NewRequest("GET", "/", nil))
	if !strings.Contains(response.Body.String(), "&lt;Watch &amp; copy&gt;") {
		t.Fatal("button translation not escaped")
	}
}
