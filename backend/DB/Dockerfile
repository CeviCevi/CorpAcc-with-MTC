FROM docker.io/library/postgres:17

env POSTGRES_DB=db
env POSTGRES_USER=postgres
env POSTGRES_PASSWORD=postgres

copy init.sql /docker-entrypoint-initdb.d/01-init.sql

EXPOSE 5432

VOLUME ["/var/lib/postgresql/data"]
