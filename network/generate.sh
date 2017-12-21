#!/bin/sh

export PATH=$GOPATH/src/github.com/hyperledger/fabric/build/bin:${PWD}/../bin:${PWD}:$PATH
export FABRIC_CFG_PATH=${PWD}
CHANNEL_NAME=chainedbidschannel

# remove previous crypto material and channel-artifacts transactions
rm -fr channel-artifacts/
rm -fr crypto-config/

mkdir channel-artifacts
mkdir crypto-config

# generate crypto material
cryptogen generate --config=./crypto-config.yaml
if [ "$?" -ne 0 ]; then
  echo "Failed to generate crypto material..."
  exit 1
fi

# generate genesis block for orderer
configtxgen -profile TwoOrgsOrdererGenesis -outputBlock ./channel-artifacts/genesis.block
if [ "$?" -ne 0 ]; then
  echo "Failed to generate orderer genesis block..."
  exit 1
fi

# generate channel configuration transaction
configtxgen -profile TwoOrgsChannel -outputCreateChannelTx ./channel-artifacts/channel.tx -channelID $CHANNEL_NAME
if [ "$?" -ne 0 ]; then
  echo "Failed to generate channel configuration transaction..."
  exit 1
fi

# generate anchor peer transaction
configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/PeopleMSPanchors.tx -channelID $CHANNEL_NAME -asOrg PeopleMSP
if [ "$?" -ne 0 ]; then
  echo "Failed to generate anchor peer update for PeopleMSP..."
  exit 1
fi

configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/FirmsMSPanchors.tx -channelID $CHANNEL_NAME -asOrg FirmsMSP
if [ "$?" -ne 0 ]; then
  echo "Failed to generate anchor peer update for FirmsMSP..."
  exit 1
fi
