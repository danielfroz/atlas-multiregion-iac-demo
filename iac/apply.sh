#!/bin/sh

if [ ! -f ./.env.sh ]; then
  echo ".env.sh file not found!"
  exit 1
fi

. ./.env.sh

terraform apply terraform.plan