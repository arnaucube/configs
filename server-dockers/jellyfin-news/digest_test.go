package main

import (
	"testing"
	"time"
)

func intp(n int) *int { return &n }

func TestFormatGroupsEpisodes(t *testing.T) {
	items := []Item{
		{Type: "Movie", Name: "Dune", ProductionYear: intp(2021)},
		{Type: "Episode", SeriesID: "a", SeriesName: "Example Show", SeasonNumber: intp(3), EpisodeNumber: intp(12)},
		{Type: "Episode", SeriesID: "a", SeriesName: "Example Show", SeasonNumber: intp(3), EpisodeNumber: intp(1)},
		{Type: "Episode", SeriesID: "a", SeriesName: "Example Show", SeasonNumber: intp(3), EpisodeNumber: intp(2)},
		{Type: "Episode", SeriesID: "a", SeriesName: "Example Show", SeasonNumber: intp(3), EpisodeNumber: intp(3)},
		{Type: "Episode", SeriesID: "a", SeriesName: "Example Show", SeasonNumber: intp(3), EpisodeNumber: intp(5)},
	}
	start := time.Date(2026, 8, 18, 0, 0, 0, 0, time.UTC)
	end := time.Date(2026, 8, 25, 0, 0, 0, 0, time.UTC)
	want := "2026-08-18 - 2026-08-25 jellyfin weekly update:\n\nMovies:\n• Dune (2021)\n\nShows:\n• Example Show — Season 3, episodes 1-3, 5, 12"
	if got := FormatWeek(start, end, items, DefaultLabels()); got != want {
		t.Fatalf("FormatWeek() = %q, want %q", got, want)
	}
}

func TestFormatEmpty(t *testing.T) {
	start := time.Date(2026, 8, 18, 0, 0, 0, 0, time.UTC)
	end := time.Date(2026, 8, 25, 0, 0, 0, 0, time.UTC)
	want := "2026-08-18 - 2026-08-25 jellyfin weekly update:\n\nNo new movies or show episodes this week."
	if got := FormatWeek(start, end, nil, DefaultLabels()); got != want {
		t.Fatalf("FormatWeek() = %q, want %q", got, want)
	}
}

func TestFormatMonth(t *testing.T) {
	want := "2026-07 jellyfin monthly update:\n\nNo new movies or show episodes last month."
	if got := FormatMonth(time.Date(2026, 7, 1, 0, 0, 0, 0, time.UTC), nil, DefaultLabels()); got != want {
		t.Fatalf("FormatMonth() = %q, want %q", got, want)
	}
}

func TestFormatWithTranslatedLabels(t *testing.T) {
	labels := Labels{
		WeeklyUpdate:   "actualización semanal",
		MonthlyUpdate:  "actualización mensual",
		Movies:         "Películas",
		Shows:          "Series",
		Season:         "Temporada",
		Specials:       "Especiales",
		Episode:        "episodio",
		Episodes:       "episodios",
		UnknownShow:    "Serie desconocida",
		NoWeeklyItems:  "No hay novedades esta semana.",
		NoMonthlyItems: "No hay novedades el mes pasado.",
	}
	items := []Item{
		{Type: "Movie", Name: "Una película"},
		{Type: "Episode", SeriesName: "Una serie", SeasonNumber: intp(2), EpisodeNumber: intp(4)},
	}
	start := time.Date(2026, 8, 18, 0, 0, 0, 0, time.UTC)
	end := time.Date(2026, 8, 25, 0, 0, 0, 0, time.UTC)
	want := "2026-08-18 - 2026-08-25 actualización semanal:\n\nPelículas:\n• Una película\n\nSeries:\n• Una serie — Temporada 2, episodio 4"
	if got := FormatWeek(start, end, items, labels); got != want {
		t.Fatalf("FormatWeek() = %q, want %q", got, want)
	}
}
