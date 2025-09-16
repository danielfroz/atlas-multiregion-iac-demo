#!/bin/sh
#
# This simple script runs deno with the MONGODB_URL
# This is meant for little adjustments. Use `docker compose up -d` instead
#

if [ ! -f ./.env ]; then
  echo ".env file does not exist"
  exit 1
fi

export $(cat ./.env | xargs)

deno run --watch -A ./src/app.ts