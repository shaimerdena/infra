FROM postgres:17

RUN groupadd --gid 1001 devopfall2026_user \
    && useradd --uid 1001 --gid 1001 --no-create-home --shell /usr/sbin/nologin devopfall2026_user \
    && chown 1001:1001 /var/lib/postgresql/data \
    && chmod 700 /var/lib/postgresql/data

USER devopfall2026_user