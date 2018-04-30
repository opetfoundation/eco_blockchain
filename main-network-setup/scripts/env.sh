#!/bin/bash

CA_HOST=ca.fabric.opetbot.com
CA_NAME=ca_opet
# CA_SERVER_HOME=/etc/hyperledger/fabric-ca
CA_CERTFILE=$FABRIC_CA_SERVER_HOME/ca-cert.pem

ORDERER_HOST=orderer.fabric.opetbot.com
ORDERER_NAME=orderer_opet
ORDERER_HOME=/etc/hyperledger/orderer

ORDERER_ORG="opet"

# The path to the genesis block
GENESIS_BLOCK_FILE=/data/genesis.block
# The path to a channel transaction
CHANNEL_TX_FILE=/data/channel.tx
# Name of test channel
CHANNEL_NAME=opet_channel

# Enroll (login) the CA administrator
function enrollCAAdmin {
   log "Enrolling with $CA_NAME as bootstrap identity ..."
   export FABRIC_CA_CLIENT_HOME=$HOME/cas/$CA_NAME
   export FABRIC_CA_CLIENT_TLS_CERTFILES=$CA_CERTFILE
   fabric-ca-client enroll -d -u https://$CA_ADMIN_USER:$CA_ADMIN_PASS@$CA_HOST:7054
}


# Create the TLS directories of the MSP folder if they don't exist.
# The fabric-ca-client should do this.
function finishMSPSetup {
   if [ $# -ne 1 ]; then
      fatal "Usage: finishMSPSetup <targetMSPDIR>"
   fi
   if [ ! -d $1/tlscacerts ]; then
      mkdir $1/tlscacerts
      cp $1/cacerts/* $1/tlscacerts
      if [ -d $1/intermediatecerts ]; then
         mkdir $1/tlsintermediatecerts
         cp $1/intermediatecerts/* $1/tlsintermediatecerts
      fi
   fi
}


function generateChannelArtifacts() {
  ORG=$ORDERER_ORG

  which configtxgen
  if [ "$?" -ne 0 ]; then
    fatal "configtxgen tool not found. exiting"
  fi

  log "Generating orderer genesis block at $GENESIS_BLOCK_FILE"
  # Note: For some unknown reason (at least for now) the block file can't be
  # named orderer.genesis.block or the orderer will fail to launch!
  configtxgen -profile OrgsOrdererGenesis -outputBlock $GENESIS_BLOCK_FILE
  if [ "$?" -ne 0 ]; then
    fatal "Failed to generate orderer genesis block"
  fi

  log "Generating channel configuration transaction at $CHANNEL_TX_FILE"
  configtxgen -profile OrgsChannel -outputCreateChannelTx $CHANNEL_TX_FILE -channelID $CHANNEL_NAME
  if [ "$?" -ne 0 ]; then
    fatal "Failed to generate channel configuration transaction"
  fi

  log "Generating anchor peer update transaction for $ORG at $ANCHOR_TX_FILE"
  configtxgen -profile OrgsChannel -outputAnchorPeersUpdate $ANCHOR_TX_FILE \
              -channelID $CHANNEL_NAME -asOrg $ORG
  if [ "$?" -ne 0 ]; then
     fatal "Failed to generate anchor peer update for $ORG"
  fi
}


# log a message
function log {
   if [ "$1" = "-n" ]; then
      shift
      echo -n "##### `date '+%Y-%m-%d %H:%M:%S'` $*"
   else
      echo "##### `date '+%Y-%m-%d %H:%M:%S'` $*"
   fi
}

# fatal a message
function fatal {
   log "FATAL: $*"
   exit 1
}
