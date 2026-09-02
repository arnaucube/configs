package main

import (
	"fmt"
	"sort"
	"strings"
	"time"
)

// Item is the subset of Jellyfin item metadata needed by a digest.
type Item struct {
	Type           string
	Name           string
	SeriesID       string
	SeriesName     string
	SeasonNumber   *int
	EpisodeNumber  *int
	ProductionYear *int
}

// Labels contains every translatable phrase used in generated recap text.
type Labels struct {
	WeeklyUpdate   string
	MonthlyUpdate  string
	Movies         string
	Shows          string
	Season         string
	Specials       string
	Episode        string
	Episodes       string
	UnknownShow    string
	NoWeeklyItems  string
	NoMonthlyItems string
}

func DefaultLabels() Labels {
	return Labels{
		WeeklyUpdate:   "jellyfin weekly update",
		MonthlyUpdate:  "jellyfin monthly update",
		Movies:         "Movies",
		Shows:          "Shows",
		Season:         "Season",
		Specials:       "Specials",
		Episode:        "episode",
		Episodes:       "episodes",
		UnknownShow:    "Unknown show",
		NoWeeklyItems:  "No new movies or show episodes this week.",
		NoMonthlyItems: "No new movies or show episodes last month.",
	}
}

// FormatWeek creates a plain-text weekly message suitable for copying and sharing.
func FormatWeek(start, end time.Time, items []Item, labels Labels) string {
	title := start.Format("2006-01-02") + " - " + end.Format("2006-01-02") + " " + labels.WeeklyUpdate + ":"
	return format(title, labels.NoWeeklyItems, items, labels)
}

// FormatMonth creates a recap for a calendar month.
func FormatMonth(month time.Time, items []Item, labels Labels) string {
	return format(month.Format("2006-01")+" "+labels.MonthlyUpdate+":", labels.NoMonthlyItems, items, labels)
}

func format(title, emptyMessage string, items []Item, labels Labels) string {
	movies := make([]Item, 0)
	type seasonKey struct {
		seriesID, seriesName string
		season               int
	}
	seasons := make(map[seasonKey]map[int]struct{})

	for _, item := range items {
		switch item.Type {
		case "Movie":
			movies = append(movies, item)
		case "Episode":
			if item.SeasonNumber == nil || item.EpisodeNumber == nil {
				continue
			}
			name := strings.TrimSpace(item.SeriesName)
			if name == "" {
				name = labels.UnknownShow
			}
			key := seasonKey{seriesID: item.SeriesID, seriesName: name, season: *item.SeasonNumber}
			if seasons[key] == nil {
				seasons[key] = make(map[int]struct{})
			}
			seasons[key][*item.EpisodeNumber] = struct{}{}
		}
	}

	sort.Slice(movies, func(i, j int) bool {
		return strings.ToLower(movies[i].Name) < strings.ToLower(movies[j].Name)
	})
	keys := make([]seasonKey, 0, len(seasons))
	for key := range seasons {
		keys = append(keys, key)
	}
	sort.Slice(keys, func(i, j int) bool {
		a, b := strings.ToLower(keys[i].seriesName), strings.ToLower(keys[j].seriesName)
		if a == b {
			return keys[i].season < keys[j].season
		}
		return a < b
	})

	var out strings.Builder
	out.WriteString(title)
	out.WriteByte('\n')
	if len(movies) == 0 && len(keys) == 0 {
		out.WriteByte('\n')
		out.WriteString(emptyMessage)
		return out.String()
	}
	if len(movies) > 0 {
		fmt.Fprintf(&out, "\n%s:\n", labels.Movies)
		for _, movie := range movies {
			fmt.Fprintf(&out, "• %s", movie.Name)
			if movie.ProductionYear != nil {
				fmt.Fprintf(&out, " (%d)", *movie.ProductionYear)
			}
			out.WriteByte('\n')
		}
	}
	if len(keys) > 0 {
		fmt.Fprintf(&out, "\n%s:\n", labels.Shows)
		for _, key := range keys {
			episodes := make([]int, 0, len(seasons[key]))
			for episode := range seasons[key] {
				episodes = append(episodes, episode)
			}
			sort.Ints(episodes)
			season := fmt.Sprintf("%s %d", labels.Season, key.season)
			if key.season == 0 {
				season = labels.Specials
			}
			label := labels.Episodes
			if len(episodes) == 1 {
				label = labels.Episode
			}
			fmt.Fprintf(&out, "• %s — %s, %s %s\n", key.seriesName, season, label, ranges(episodes))
		}
	}
	return strings.TrimRight(out.String(), "\n")
}

func ranges(numbers []int) string {
	parts := make([]string, 0)
	for i := 0; i < len(numbers); {
		j := i
		for j+1 < len(numbers) && numbers[j+1] == numbers[j]+1 {
			j++
		}
		if i == j {
			parts = append(parts, fmt.Sprint(numbers[i]))
		} else {
			parts = append(parts, fmt.Sprintf("%d-%d", numbers[i], numbers[j]))
		}
		i = j + 1
	}
	return strings.Join(parts, ", ")
}
