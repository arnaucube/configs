package main

import (
	"context"
	_ "embed"
	"errors"
	"flag"
	"log"
	"net/http"
	"os"
	"strconv"
	"strings"
	"time"
)

//go:embed index.html
var indexHTML []byte

type itemSource interface {
	AddedBetween(context.Context, time.Time, time.Time) ([]Item, error)
}

type app struct {
	jellyfin itemSource
	location *time.Location
	labels   Labels
	now      func() time.Time
}

func main() {
	listen := flag.String("listen", env("LISTEN_ADDR", ":8080"), "HTTP listen address")
	flag.Parse()

	location, err := time.LoadLocation(env("TZ", "Local"))
	if err != nil {
		log.Fatalf("invalid TZ: %v", err)
	}
	client, err := New(os.Getenv("JELLYFIN_URL"), os.Getenv("JELLYFIN_API_KEY"), os.Getenv("JELLYFIN_USER_ID"), nil)
	if err != nil {
		log.Fatalf("configuration error: %v", err)
	}

	application := &app{jellyfin: client, location: location, labels: loadLabels(), now: time.Now}
	server := &http.Server{
		Addr:              *listen,
		Handler:           application.routes(),
		ReadHeaderTimeout: 5 * time.Second,
		ReadTimeout:       15 * time.Second,
		WriteTimeout:      60 * time.Second,
		IdleTimeout:       60 * time.Second,
	}
	log.Printf("Jellyfin updates available at http://%s", displayAddress(*listen))
	if err := server.ListenAndServe(); !errors.Is(err, http.ErrServerClosed) {
		log.Fatal(err)
	}
}

func (a *app) routes() http.Handler {
	mux := http.NewServeMux()
	mux.HandleFunc("GET /{$}", a.index)
	mux.HandleFunc("GET /api/current-week", a.currentWeek)
	mux.HandleFunc("GET /api/week", a.week)
	mux.HandleFunc("GET /api/month", a.month)
	return mux
}

func (a *app) index(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "text/html; charset=utf-8")
	w.Write(indexHTML)
}

func (a *app) currentWeek(w http.ResponseWriter, r *http.Request) {
	now := a.now().In(a.location)
	start := startOfWeek(now)
	a.writeWeek(w, r, start, now)
}

func (a *app) week(w http.ResponseWriter, r *http.Request) {
	offset, ok := readOffset(w, r)
	if !ok {
		return
	}
	currentWeek := startOfWeek(a.now().In(a.location))
	start := currentWeek.AddDate(0, 0, offset*7)
	a.writeWeek(w, r, start, start.AddDate(0, 0, 7))
}

func (a *app) month(w http.ResponseWriter, r *http.Request) {
	offset, ok := readOffset(w, r)
	if !ok {
		return
	}
	a.writeMonth(w, r, offset)
}

func (a *app) writeWeek(w http.ResponseWriter, r *http.Request, start, end time.Time) {
	items, err := a.jellyfin.AddedBetween(r.Context(), start, end)
	if err != nil {
		log.Printf("Jellyfin weekly query failed: %v", err)
		http.Error(w, "Could not query Jellyfin. Check the server logs.", http.StatusBadGateway)
		return
	}
	writeText(w, FormatWeek(start, end, items, a.labels))
}

func (a *app) writeMonth(w http.ResponseWriter, r *http.Request, offset int) {
	now := a.now().In(a.location)
	currentMonth := time.Date(now.Year(), now.Month(), 1, 0, 0, 0, 0, a.location)
	start := currentMonth.AddDate(0, offset, 0)
	end := start.AddDate(0, 1, 0)
	items, err := a.jellyfin.AddedBetween(r.Context(), start, end)
	if err != nil {
		log.Printf("Jellyfin monthly query failed: %v", err)
		http.Error(w, "Could not query Jellyfin. Check the server logs.", http.StatusBadGateway)
		return
	}
	writeText(w, FormatMonth(start, items, a.labels))
}

func writeText(w http.ResponseWriter, text string) {
	w.Header().Set("Content-Type", "text/plain; charset=utf-8")
	w.Header().Set("Cache-Control", "no-store")
	w.Write([]byte(text))
}

func readOffset(w http.ResponseWriter, r *http.Request) (int, bool) {
	offset, err := strconv.Atoi(r.URL.Query().Get("offset"))
	if err != nil || offset < -1200 || offset > -1 {
		http.Error(w, "offset must be an integer between -1200 and -1", http.StatusBadRequest)
		return 0, false
	}
	return offset, true
}

func startOfWeek(now time.Time) time.Time {
	daysSinceMonday := (int(now.Weekday()) - int(time.Monday) + 7) % 7
	return time.Date(now.Year(), now.Month(), now.Day()-daysSinceMonday, 0, 0, 0, 0, now.Location())
}

func env(name, fallback string) string {
	if value := strings.TrimSpace(os.Getenv(name)); value != "" {
		return value
	}
	return fallback
}

func loadLabels() Labels {
	defaults := DefaultLabels()
	return Labels{
		WeeklyUpdate:   env("TEXT_WEEKLY_UPDATE", defaults.WeeklyUpdate),
		MonthlyUpdate:  env("TEXT_MONTHLY_UPDATE", defaults.MonthlyUpdate),
		Movies:         env("TEXT_MOVIES", defaults.Movies),
		Shows:          env("TEXT_SHOWS", defaults.Shows),
		Season:         env("TEXT_SEASON", defaults.Season),
		Specials:       env("TEXT_SPECIALS", defaults.Specials),
		Episode:        env("TEXT_EPISODE", defaults.Episode),
		Episodes:       env("TEXT_EPISODES", defaults.Episodes),
		UnknownShow:    env("TEXT_UNKNOWN_SHOW", defaults.UnknownShow),
		NoWeeklyItems:  env("TEXT_NO_WEEKLY_ITEMS", defaults.NoWeeklyItems),
		NoMonthlyItems: env("TEXT_NO_MONTHLY_ITEMS", defaults.NoMonthlyItems),
	}
}

func displayAddress(address string) string {
	if strings.HasPrefix(address, ":") {
		return "localhost" + address
	}
	return address
}
