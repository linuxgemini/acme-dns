FROM golang:1-alpine AS builder
LABEL maintainer="acmedns+fork@iye.be"

RUN apk add --update gcc musl-dev git

RUN mkdir -p /tmp/acme-dns
COPY . /tmp/acme-dns/

ENV GOPATH       /tmp/buildcache
ENV CGO_ENABLED  1
WORKDIR /tmp/acme-dns
RUN go build -ldflags="-extldflags=-static"

# assemble the release ready to copy to the image.
RUN mkdir -p /tmp/release/bin
RUN mkdir -p /tmp/release/etc/acme-dns
RUN mkdir -p /tmp/release/var/lib/acme-dns
RUN cp /tmp/acme-dns/acme-dns /tmp/release/bin/acme-dns


FROM gcr.io/distroless/static

WORKDIR /
COPY --from=builder /tmp/release .

VOLUME ["/etc/acme-dns", "/var/lib/acme-dns"]
ENTRYPOINT ["/bin/acme-dns"]
EXPOSE 53 80 443
EXPOSE 53/udp
