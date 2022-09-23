#!/bin/bash

i="all"

while getopts ":t:e:i::" flag; do
  case $flag in
    t) t=${OPTARG} ;;
    e) e=${OPTARG} ;;
    i) i=${OPTARG} ;;
  esac
done

set -a

source ./$e

set +a

BRANCH=$(git symbolic-ref --short -q HEAD)

if [ "$BRANCH" != "main" ]; then

  FINBIF_ACCESS_TOKEN=$FINBIF_DEV_ACCESS_TOKEN
  FINBIF_API_URL=$FINBIF_DEV_API_URL

fi

if [ $i = "build" ]; then

  ITEM=".items[0]"

elif [ $i = "image" ]; then

  ITEM=".items[1]"

elif [ $i = "deploy" ]; then

  ITEM=".items[2]"

elif [ $i = "volume" ]; then

  ITEM=".items[3]"

elif [ $i = "service" ]; then

  ITEM=".items[4]"

elif [ $i = "route" ]; then

  ITEM=".items[5]"

elif [ $i = "job" ]; then

  ITEM=".items[6]"

else

  ITEM=""

fi

oc process -f $t \
  -p BRANCH=$BRANCH \
  -p DB_PORT=$DB_PORT \
  -p DB_NAME=$DB_NAME \
  -p DB_USER=$DB_USER \
  -p DB_PRIMARY_USER=$DB_PRIMARY_USER \
  -p DB_SUPER_USER=$DB_SUPER_USER \
  -p HOST=$HOST \
  -p FINBIF_ACCESS_TOKEN=$FINBIF_ACCESS_TOKEN \
  -p FINBIF_API_URL=$FINBIF_API_URL \
  -p FINBIF_EMAIL=$FINBIF_EMAIL \
  -p FINBIF_WAREHOUSE=$FINBIF_WAREHOUSE \
  -p N_SUBSETS=$N_SUBSETS \
  | jq $ITEM
