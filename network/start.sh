#!/bin/sh

export PATH=${PWD}/../bin:${PWD}:$PATH
export FABRIC_CFG_PATH=${PWD}

COUCHDB=false

while getopts "c" opt; do
  case "$opt" in
    c)  COUCHDB=true
    ;;
  esac
done

if [ "${COUCHDB}" == false ]; then
    echo "Starting using LevelDB..."
    CHANNEL_NAME=chainedbidschannel TIMEOUT=10 DELAY=3 docker-compose -f docker-compose.yaml up -d
else
    echo "Starting using CouchDB..."
    CHANNEL_NAME=chainedbidschannel TIMEOUT=10 DELAY=3 docker-compose -f docker-compose.yaml -f docker-compose-couch.yaml -f docker-compose-cas.yaml up -d
fi

docker logs -f cli
