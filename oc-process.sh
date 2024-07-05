#!/bin/bash

i="all"
f="template.yml"
e=".env"

while getopts ":f:e:i::" flag; do
  case $flag in
    f) f=${OPTARG} ;;
    e) e=${OPTARG} ;;
    i) i=${OPTARG} ;;
  esac
done

set -a

source ./$e

set +a

BRANCH=$(git symbolic-ref --short -q HEAD)

if [ "$BRANCH" != "main" ]; then

  FINBIF_ACCESS_TOKEN=$FINBIF_ACCESS_TOKEN_DEV
  FINBIF_API_URL=$FINBIF_API_URL_DEV
  DB_PASSWORD=$DB_PASSWORD_DEV
  ELY_ACCESS_TOKEN=$ELY_ACCESS_TOKEN_DEV
  MH_ACCESS_TOKEN=$MH_ACCESS_TOKEN_DEV
  STORAGE=$STORAGE_DEV
  SMALL_STORAGE=$SMALL_STORAGE_DEV
  HOST=$HOST_DEV
  JOB_SECRET=$JOB_SECRET_DEV
  MEMORY=$MEMORY_DEV
  N_SUBSETS=$N_SUBSETS_DEV

fi

if [ $i = "volume-db" ]; then

  ITEM=".items[0]"

elif [ $i = "volume-app" ]; then

  ITEM=".items[1]"

elif [ $i = "config" ]; then

  ITEM=".items[2]"

elif [ $i = "secrets" ]; then

  ITEM=".items[3]"

elif [ $i = "deploy-db" ]; then

  ITEM=".items[4]"

elif [ $i = "deploy-app" ]; then

  ITEM=".items[5]"

elif [ $i = "service-db" ]; then

  ITEM=".items[6]"

elif [ $i = "service-app" ]; then

  ITEM=".items[7]"

elif [ $i = "route" ]; then

  ITEM=".items[8]"

elif [ $i = "job" ]; then

  ITEM=".items[9]"

elif [ $i = "all" ]; then

  ITEM=""

else

  echo "Object not found"
  exit 1

fi

DB_PASSWORD=$(echo -n $DB_PASSWORD | base64)
ELY_ACCESS_TOKEN=$(echo -n $ELY_ACCESS_TOKEN | base64)
MH_ACCESS_TOKEN=$(echo -n $MH_ACCESS_TOKEN | base64)
FINBIF_ACCESS_TOKEN=$(echo -n $FINBIF_ACCESS_TOKEN | base64)
RCLONE_ACCESS_KEY_ID=$(echo -n $RCLONE_ACCESS_KEY_ID | base64)
RCLONE_SECRET_ACCESS_KEY=$(echo -n $RCLONE_SECRET_ACCESS_KEY | base64)
JOB_SECRET=$(echo -n $JOB_SECRET | base64)

echo "# $(oc project ely-center-gis)"

oc process -f $f \
  -p BRANCH="$BRANCH" \
  -p DB_PASSWORD="$DB_PASSWORD" \
  -p ELY_ACCESS_TOKEN="$ELY_ACCESS_TOKEN" \
  -p MH_ACCESS_TOKEN="$MH_ACCESS_TOKEN" \
  -p HOST="$HOST" \
  -p FINBIF_ACCESS_TOKEN="$FINBIF_ACCESS_TOKEN" \
  -p FINBIF_API_URL="$FINBIF_API_URL" \
  -p FINBIF_EMAIL="$FINBIF_EMAIL" \
  -p FINBIF_WAREHOUSE="$FINBIF_WAREHOUSE" \
  -p STORAGE="$STORAGE" \
  -p SMALL_STORAGE="$SMALL_STORAGE" \
  -p SMTP_SERVER="$SMTP_SERVER" \
  -p SMTP_PORT="$SMTP_PORT" \
  -p ERROR_EMAIL_FROM="$ERROR_EMAIL_FROM" \
  -p OBJECT_STORE="$OBJECT_STORE" \
  -p RCLONE_ACCESS_KEY_ID="$RCLONE_ACCESS_KEY_ID" \
  -p RCLONE_SECRET_ACCESS_KEY="$RCLONE_SECRET_ACCESS_KEY" \
  -p JOB_SECRET="$JOB_SECRET" \
  -p MEMORY="$MEMORY" \
  -p N_SUBSETS="$N_SUBSETS"
  | jq $ITEM
