package main

import (
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"image"
	"image/png"
	"io"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
)

type searchableSource struct {
	*fakeSource
	calls []extraTitle
}

func (s *searchableSource) FindPosterTitle(_ context.Context, kind, name string, year int) (string, error) {
	s.calls = append(s.calls, extraTitle{name: name, kind: kind, year: year})
	if name == "Old Film" {
		return "old-film", nil
	}
	if name == "Old Show" {
		return "old-show", nil
	}
	return "", nil
}

func TestPosterExtrasUseRecapFormatAndDeduplicate(t *testing.T) {
	year := 2025
	source := &searchableSource{fakeSource: &fakeSource{items: []Item{{ID: "new-film", Type: "Movie", Name: "New Film", ProductionYear: &year}}}}
	a := testApp(source.fakeSource)
	a.jellyfin = source
	body := "2026-08-31 - 2026-09-02 jellyfin weekly update:\n\nMovies:\n• New Film\n• Old Film (2022)\n• Missing Film\n\nShows:\n• Old Show — Season 3, episodes 1-12\n• Old Show — Season 4, episode 1"
	r := httptest.NewRecorder()
	a.routes().ServeHTTP(r, httptest.NewRequest(http.MethodPost, "/api/posters?period=current-week", strings.NewReader(body)))
	if r.Code != http.StatusOK {
		t.Fatalf("response = %d %s", r.Code, r.Body)
	}
	var data struct{ Titles []posterTitle }
	if err := json.Unmarshal(r.Body.Bytes(), &data); err != nil {
		t.Fatal(err)
	}
	if len(data.Titles) != 4 {
		t.Fatalf("titles = %+v", data.Titles)
	}
	want := map[string]string{"New Film (2025)": "/api/poster/new-film", "Old Film (2022)": "/api/poster/old-film", "Missing Film": "", "Old Show": "/api/poster/old-show"}
	for _, title := range data.Titles {
		if title.URL != want[title.Name] {
			t.Fatalf("title = %+v", title)
		}
		delete(want, title.Name)
	}
	if len(want) != 0 || len(source.calls) != 3 || source.calls[0] != (extraTitle{name: "Old Film", kind: "Movie", year: 2022}) || source.calls[2].name != "Old Show" {
		t.Fatalf("unmatched titles = %+v, searches = %+v", want, source.calls)
	}
}

func TestPosterExtrasRejectMalformedAndOversizedInput(t *testing.T) {
	for _, body := range []string{"• Film", "Movies:\n• ", "Movies:\n• Film\n•", strings.Repeat("x", 32*1024+1)} {
		r := httptest.NewRecorder()
		testApp(&fakeSource{}).routes().ServeHTTP(r, httptest.NewRequest(http.MethodPost, "/api/posters?period=current-week", strings.NewReader(body)))
		if r.Code != http.StatusBadRequest {
			t.Fatalf("input %q: response = %d", body[:min(len(body), 30)], r.Code)
		}
	}
}

func TestPosterPeriodsAndGrouping(t *testing.T) {
	for _, tc := range []struct{ query, start, end string }{
		{"period=current-week", "2026-08-31", "2026-09-02"},
		{"period=week&offset=-2", "2026-08-17", "2026-08-24"},
		{"period=month&offset=-1", "2026-08-01", "2026-09-01"},
	} {
		t.Run(tc.query, func(t *testing.T) {
			source := &fakeSource{items: []Item{
				{ID: "movie", Type: "Movie", Name: "Film"},
				{ID: "movie", Type: "Movie", Name: "Film"},
				{ID: "episode1", Type: "Episode", SeriesID: "series", SeriesName: "Show"},
				{ID: "episode2", Type: "Episode", SeriesID: "series", SeriesName: "Show"},
				{ID: "music", Type: "Audio", Name: "Song"},
			}}
			r := httptest.NewRecorder()
			testApp(source).routes().ServeHTTP(r, httptest.NewRequest("GET", "/api/posters?"+tc.query, nil))
			var data struct {
				Start, End, Title string
				Titles            []posterTitle
			}
			if r.Code != 200 || json.Unmarshal(r.Body.Bytes(), &data) != nil {
				t.Fatalf("response = %d %s", r.Code, r.Body)
			}
			if data.Start != tc.start || data.End != tc.end || source.start.Format("2006-01-02") != tc.start || source.end.Format("2006-01-02") != tc.end {
				t.Fatalf("wrong boundaries: %+v, %v to %v", data, source.start, source.end)
			}
			if len(data.Titles) != 2 || data.Titles[0].URL != "/api/poster/movie" || data.Titles[1].URL != "/api/poster/series" {
				t.Fatalf("titles = %+v", data.Titles)
			}
			if strings.Contains(tc.query, "month") && data.Title != DefaultLabels().MonthlyUpdate {
				t.Fatalf("wrong monthly title: %s", data.Title)
			}
		})
	}
}

func TestPostersInvalidSelectionAndQueryFailure(t *testing.T) {
	for _, query := range []string{"", "period=years", "period=week", "period=week&offset=0", "period=month&offset=-1201"} {
		source := &fakeSource{}
		r := httptest.NewRecorder()
		testApp(source).routes().ServeHTTP(r, httptest.NewRequest("GET", "/api/posters?"+query, nil))
		if r.Code != 400 || !source.start.IsZero() {
			t.Fatalf("%s: status %d, queried %v", query, r.Code, source.start)
		}
	}
	r := httptest.NewRecorder()
	testApp(&fakeSource{err: errors.New("private upstream details")}).routes().ServeHTTP(r, httptest.NewRequest("GET", "/api/posters?period=current-week", nil))
	if r.Code != 502 || strings.Contains(r.Body.String(), "private") {
		t.Fatalf("response = %d %s", r.Code, r.Body)
	}
}

func TestPostersEmptyAndMissingIDs(t *testing.T) {
	for _, items := range [][]Item{nil, {{Type: "Movie", Name: "No poster"}, {Type: "Episode", SeriesName: "No series ID"}}} {
		r := httptest.NewRecorder()
		testApp(&fakeSource{items: items}).routes().ServeHTTP(r, httptest.NewRequest("GET", "/api/posters?period=current-week", nil))
		var data struct{ Titles []posterTitle }
		if err := json.Unmarshal(r.Body.Bytes(), &data); err != nil || data.Titles == nil || len(data.Titles) != len(items) {
			t.Fatalf("response = %s, error = %v", r.Body, err)
		}
		for _, title := range data.Titles {
			if title.URL != "" {
				t.Fatalf("missing ID should use a placeholder: %+v", title)
			}
		}
	}
}

func TestPosterProxy(t *testing.T) {
	var artwork bytes.Buffer
	if err := png.Encode(&artwork, image.NewRGBA(image.Rect(0, 0, 2, 3))); err != nil {
		t.Fatal(err)
	}
	for _, tc := range []struct {
		name           string
		upstream, want int
		body           []byte
	}{
		{"image", 200, 200, artwork.Bytes()},
		{"missing", 404, 404, nil},
		{"upstream error", 500, 502, []byte("private error")},
		{"invalid content", 200, 502, []byte("<html>not an image</html>")},
		{"oversized", 200, 502, make([]byte, (5<<20)+1)},
	} {
		t.Run(tc.name, func(t *testing.T) {
			client, err := New("http://jellyfin.test/base", "secret", "", &http.Client{Transport: roundTripFunc(func(r *http.Request) (*http.Response, error) {
				if r.URL.Path != "/base/Items/movie/Images/Primary" || r.Header.Get("X-Emby-Token") != "secret" || r.URL.Query().Get("maxWidth") != "480" {
					t.Errorf("wrong poster request path, credentials, or size")
				}
				return &http.Response{StatusCode: tc.upstream, Body: io.NopCloser(bytes.NewReader(tc.body)), Header: make(http.Header)}, nil
			})})
			if err != nil {
				t.Fatal(err)
			}
			a := testApp(&fakeSource{})
			a.jellyfin = client
			r := httptest.NewRecorder()
			a.routes().ServeHTTP(r, httptest.NewRequest("GET", "/api/poster/movie", nil))
			if r.Code != tc.want || strings.Contains(r.Body.String(), "private error") {
				t.Fatalf("unexpected response status %d", r.Code)
			}
			if tc.want == 200 && (r.Header().Get("Content-Type") != "image/png" || !bytes.Equal(r.Body.Bytes(), artwork.Bytes())) {
				t.Fatal("image was not preserved")
			}
			if _, err := client.Poster(context.Background(), "../bad"); !errors.Is(err, errNoPoster) {
				t.Fatalf("invalid ID accepted: %v", err)
			}
		})
	}
}
