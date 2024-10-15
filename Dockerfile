FROM golang@sha256:5dbae0a41feefa0d9e0e455ddf82672bf439baac577650e6c6b81e98b6efe97a as builder

RUN apk update && apk add --no-cache git ca-certificates tzdata && update-ca-certificates

WORKDIR $GOPATH/src/tutor/go-docker-simple
COPY . .

RUN echo $PWD && ls -la

RUN go mod download
RUN go mod verify
 
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-w -s" -a -installsuffix cgo -o /go/bin/go-docker-simple .

FROM alpine:3.16

RUN apk update

COPY --from=builder /usr/share/zoneinfo /usr/share/zoneinfo
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /etc/passwd /etc/passwd

COPY --from=builder /go/bin/go-docker-simple /go/bin/go-docker-simple
COPY --from=builder /go/src/tutor/go-docker-simple/config.json /go/bin/config.json

ENTRYPOINT ["/go/bin/go-docker-simple", "-conf", "/go/bin/config.json"]
