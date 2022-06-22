# This is a multi-stage Dockerfile (build and run)
FROM golang:1.17-alpine as builder

# Git repo
ENV GIT=https://github.com/qjvtenkroode/homelab-prometheus-shelly-exporter

WORKDIR /app
RUN apk add --no-cache git \
    && git clone ${GIT} \
    && cd homelab-prometheus-shelly-exporter \
    && go mod download \
    && CGO_ENABLED=0 go build -v -o ../prometheus-shelly-exporter

# Stage 2 - grab some basic things from alpine
FROM alpine as alpine
RUN apk add --no-cache tzdata

# Stage 3 - scratch container setup
FROM scratch
EXPOSE 8080
WORKDIR /
COPY --from=alpine /etc/passwd /etc/group /etc/
COPY --from=alpine /usr/share/zoneinfo /usr/share/zoneinfo
COPY --from=builder /app/prometheus-shelly-exporter /prometheus-shelly-exporter
USER nobody
CMD ["/prometheus-shelly-exporter"]
