#!/bin/bash

# ref: https://stackoverflow.com/a/29913462
TIMESTAMP=$(date --utc --iso-8601=seconds | tr -d :)
podman exec -t sta_STA-DB_1 pg_dumpall -c -U sta-production-admin | gzip > ./storage/backups/prod-db_$TIMESTAMP.sql.gz
