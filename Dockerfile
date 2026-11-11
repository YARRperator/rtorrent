# syntax=docker/dockerfile:1

ARG ALPINE_VERSION=3.24
FROM docker.io/alpine:${ALPINE_VERSION}

RUN apk add --no-cache \
    rtorrent \
    && addgroup -g 1000 rtorrent \
    && adduser -u 1000 -G rtorrent -H -s /sbin/nologin -D rtorrent \
    && mkdir -p /etc/rtorrent

USER rtorrent

ENTRYPOINT ["rtorrent"]
CMD ["-n", "-o", "import=/etc/rtorrent/rtorrent.rc"]
