# Jellyfin update webpage

A small Go web server for generating copyable Jellyfin movie and episode recaps. It provides both: newly added movies and shows, and recently watched movies and shows. It serves one embedded `index.html` page, a database, or third-party Go dependencies.

The page provides:

- **Current week**: from Monday at 00:00 through now.
- **Selected week**: `-1` means last week, `-2` means two weeks ago, and so on.
- **Selected month**: `-1` means last month, `-2` means two months ago, and so on.
- **Copy to clipboard**: copies the generated plain-text recap.

Weekly output looks like:

```text
2026-08-15 - 2026-08-22 jellyfin weekly update:

Movies:
• Dune (2021)

Shows:
• Example Show — Season 3, episodes 1-12
```

## Configuration

Copy the example and edit it:

```sh
cp .env.example .env
```

## Run with Docker Compose

```sh
docker compose up -d --build
docker compose logs -f
```

Then open:

```text
http://<home-server-ip>:8080
```

## Run as a local binary

Go 1.23 or newer is required.

```sh
go test ./...
go build -o jellyfin-news .
set -a
. ./.env
set +a
./jellyfin-news
```

The API key remains on the server and is never sent to the browser. The browser only receives formatted recap text. This app has no authentication, so keep port 8080 limited to your trusted home LAN and do not expose it directly to the internet.

