# Multi-platform support
# Syntax directive for buildx
# syntax=docker/dockerfile:1.4

# Build stage

FROM --platform=$BUILDPLATFORM golang:1.23-alpine AS builder
LABEL org.opencontainers.image.source=https://github.com/jmcarbo/traefik-forward-auth

# Setup
RUN mkdir -p /app
WORKDIR /app

# Add libraries
RUN apk add --no-cache git

# Copy source files and build binary for target platform
ADD . /app
ARG TARGETOS
ARG TARGETARCH
RUN CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH GO111MODULE=on go build -a -installsuffix nocgo -o /traefik-forward-auth /app/cmd

# Final stage
FROM --platform=$TARGETPLATFORM scratch
LABEL org.opencontainers.image.source=https://github.com/jmcarbo/traefik-forward-auth

COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /traefik-forward-auth ./
ENTRYPOINT ["./traefik-forward-auth"]

