#!/bin/sh
#
# Author: Daniel Froz <daniel.froz@mongodb.com>
#
# loads env variables and/or secrets...
#

if [ ! -f ./.env.sh ]; then
  echo ".env.sh file not found!"
  exit 1
fi

. ./.env.sh

if [ -z $ARM_CLIENT_ID ]; then
  echo ARM_CLIENT_ID not defined
  exit 1
fi

if [ -z $ARM_CLIENT_SECRET ]; then
  echo ARM_CLIENT_SECRET not defined
  exit 1
fi

if [ -z $ARM_TENANT_ID ]; then
  echo ARM_TENANT_ID not defined
  exit 1
fi

if [ -z $ARM_SUBSCRIPTION_ID ]; then
  echo ARM_SUBSCRIPTION_ID not defined
  exit 1
fi

if [ -z $MONGODB_ATLAS_PUBLIC_KEY ]; then
  echo MONGODB_ATLAS_PUBLIC_KEY not defined
  exit 1
fi

if [ -z $MONGODB_ATLAS_PRIVATE_KEY ]; then
  echo MONGODB_ATLAS_PRIVATE_KEY not defined
  exit 1
fi

terraform init -input=false -reconfigure || exit 1
terraform plan -input=false -refresh -out=terraform.plan