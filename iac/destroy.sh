#!/bin/sh
#
# ONLY EXECUTE THIS ONCE YOU'RE DONE WITH THE TESTS
#

if [ ! -f ./.env.sh ]; then
  echo ".env.sh file not found!"
  exit 1
fi

. ./.env.sh

terraform destroy -auto-approve