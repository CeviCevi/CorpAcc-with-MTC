#!/usr/bin/env bash

set -e

podman rm -f postgresql 2>/dev/null || true
podman volume rm postgres_data 2>/dev/null || true

podman build --no-cache -t database .

podman volume create postgres_data

podman run -d \
  --name postgresql \
  -p 5432:5432 \
  -v postgres_data:/var/lib/postgresql/data \
  database

