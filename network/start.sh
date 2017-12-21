#!/bin/sh

export PATH=${PWD}/../bin:${PWD}:$PATH
export FABRIC_CFG_PATH=${PWD}

CHANNEL_NAME=chainedbidschannel TIMEOUT=10 DELAY=3 docker-compose -f docker-compose.yaml up -d
docker logs -f cli
