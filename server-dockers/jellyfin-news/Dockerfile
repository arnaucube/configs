FROM golang:1.23-alpine AS build
WORKDIR /src
COPY go.mod *.go index.html ./
RUN CGO_ENABLED=0 go build -trimpath -ldflags="-s -w" -o /jellyfin-news .

FROM alpine:3.22
RUN apk add --no-cache ca-certificates tzdata && adduser -D -u 10001 app
USER app
COPY --from=build /jellyfin-news /usr/local/bin/jellyfin-news
EXPOSE 8080
ENTRYPOINT ["jellyfin-news"]
