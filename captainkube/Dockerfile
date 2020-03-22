# Build
FROM golang:1.14.1-alpine3.11 as builder

WORKDIR /build
COPY main.go go.mod go.sum ./
RUN go get -d -v
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o app .

# Run
FROM alpine:3.11.3

RUN apk --no-cache add ca-certificates
WORKDIR /root/
COPY --from=builder /build/app .
CMD ["./app"]
