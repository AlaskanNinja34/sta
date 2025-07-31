#!/bin/bash

# ref: https://stackoverflow.com/a/29913462
TIMESTAMP=$(date --utc --iso-8601=seconds | tr -d :)
podman exec -t sta_devcontainer-dev-db-1 pg_dumpall -c -U sta-development-admin | gzip > ./storage/backups/dev-db_$TIMESTAMP.sql.gz
