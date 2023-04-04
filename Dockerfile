ARG POSTGRES_VERSION=14
FROM ghcr.io/cloudnative-pg/postgresql:${POSTGRES_VERSION}
ARG POSTGRES_VERSION

USER root

RUN apt-get update && apt-get install -qq -y \
    postgresql-${POSTGRES_VERSION}-cron \
    postgresql-${POSTGRES_VERSION}-partman \
    && rm -rf /var/lib/apt/lists/*

USER postgres