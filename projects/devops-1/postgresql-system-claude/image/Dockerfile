# Minimal PostgreSQL image (target: < 100 MB). Server runs as a fixed non-root user.
ARG ALPINE_VERSION=3.22
FROM alpine:${ALPINE_VERSION}

ARG PG_PKG=postgresql17
ARG PG_UID=1001
ARG PG_USER=devopfall2026_user

RUN set -eux; \
    apk add --no-cache "${PG_PKG}" "${PG_PKG}-client"; \
    addgroup -g "${PG_UID}" "${PG_USER}"; \
    adduser -D -H -u "${PG_UID}" -G "${PG_USER}" -h /var/lib/postgresql -s /sbin/nologin "${PG_USER}"; \
    install -d -m 0700 -o "${PG_USER}" -g "${PG_USER}" /var/lib/postgresql/data; \
    install -d -m 0755 -o "${PG_USER}" -g "${PG_USER}" /run/postgresql; \
    rm -rf /usr/share/doc /usr/share/man /usr/share/info /var/cache/apk/* /tmp/*

COPY --chmod=0755 entrypoint.sh /usr/local/bin/entrypoint.sh

ENV PGDATA=/var/lib/postgresql/data/pgdata \
    LANG=C
USER ${PG_UID}:${PG_UID}
VOLUME /var/lib/postgresql/data
EXPOSE 5432
STOPSIGNAL SIGINT
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
