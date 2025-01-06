# Go build
FROM golang:1.23 AS builder

WORKDIR /workspace

COPY go.mod go.sum .
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-w -s" -o config-reloader-sidecar .

# UPX compression
FROM backplane/upx:latest AS upx

COPY --from=builder /workspace/config-reloader-sidecar .

RUN upx --best --lzma /config-reloader-sidecar

# Runtime
FROM gcr.io/distroless/static-debian12:latest

COPY --from=upx /config-reloader-sidecar .

CMD ["/config-reloader-sidecar"]
