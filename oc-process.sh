#!/bin/bash

i="all"

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

  FINBIF_ACCESS_TOKEN=$FINBIF_DEV_ACCESS_TOKEN
  FINBIF_API_URL=$FINBIF_DEV_API_URL

fi

if [ $i = "build" ]; then

  ITEM=".items[0]"

elif [ $i = "image" ]; then

  ITEM=".items[1]"

elif [ $i = "deploy-db" ]; then

  ITEM=".items[2]"

elif [ $i = "deploy-svr" ]; then

  ITEM=".items[3]"

elif [ $i = "volume-db" ]; then

  ITEM=".items[4]"

elif [ $i = "volume-svr" ]; then

  ITEM=".items[5]"

elif [ $i = "service-db" ]; then

  ITEM=".items[6]"

elif [ $i = "route-db" ]; then

  ITEM=".items[7]"

elif [ $i = "service-svr" ]; then

  ITEM=".items[8]"

elif [ $i = "route-svr" ]; then

  ITEM=".items[9]"

elif [ $i = "job" ]; then

  ITEM=".items[10]"

else

  ITEM=""

fi

oc process -f $f \
  -p BRANCH=$BRANCH \
  -p DB_PORT=$DB_PORT \
  -p DB_NAME=$DB_NAME \
  -p DB_USER=$DB_USER \
  -p DB_PRIMARY_USER=$DB_PRIMARY_USER \
  -p DB_SUPER_USER=$DB_SUPER_USER \
  -p DB_USER_PASSWORD=$DB_USER_PASSWORD \
  -p DB_PRIMARY_PASSWORD=$DB_PRIMARY_PASSWORD \
  -p DB_SUPER_PASSWORD=$DB_SUPER_PASSWORD \
  -p SVR_PORT=$SVR_PORT \
  -p HOST=$HOST \
  -p FINBIF_ACCESS_TOKEN=$FINBIF_ACCESS_TOKEN \
  -p FINBIF_API_URL=$FINBIF_API_URL \
  -p FINBIF_EMAIL=$FINBIF_EMAIL \
  -p FINBIF_WAREHOUSE=$FINBIF_WAREHOUSE \
  -p N_SUBSETS=$N_SUBSETS \
  | jq $ITEM
