FROM golang:1-alpine AS builder
LABEL maintainer="acmedns+fork@iye.be"

RUN apk add -U --no-cache ca-certificates gcc musl-dev git

COPY . /tmp/acme-dns/

ENV GOPATH       /tmp/buildcache
ENV CGO_ENABLED  1

WORKDIR /tmp/acme-dns

RUN go build -ldflags="-extldflags=-static" -tags sqlite_omit_load_extension

# assemble the release ready to copy to the image.
RUN mkdir -p /tmp/release/bin
RUN mkdir -p /tmp/release/etc/acme-dns
RUN mkdir -p /tmp/release/etc/ssl/certs
RUN mkdir -p /tmp/release/var/lib/acme-dns
RUN cp /tmp/acme-dns/acme-dns /tmp/release/bin/acme-dns
RUN cp /etc/ssl/certs/ca-certificates.crt /tmp/release/etc/ssl/certs/


FROM gcr.io/distroless/static

WORKDIR /
COPY --from=builder /tmp/release .

VOLUME ["/etc/acme-dns", "/var/lib/acme-dns"]
ENTRYPOINT ["/bin/acme-dns"]
EXPOSE 53 80 443
EXPOSE 53/udp
