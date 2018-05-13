#!/bin/bash
#
# Common settings and functions for the Hyperledger Fabric network setup.

SCRIPT_PATH=`dirname $0`

CA_HOST=ca.fabric.opetbot.com
CA_NAME=ca_opet

ORDERER_ORG="opet"

ORG=$ORDERER_ORG
ORG_MSP_DIR=/data/fabric.opetbot.com/msp
ORG_ADMIN_HOME=/data/fabric.opetbot.com/admin
ORG_ADMIN_CERT=${ORG_MSP_DIR}/admincerts/cert.pem

# The path to the genesis block
GENESIS_BLOCK_FILE=/data/genesis.block
# The path to a channel transaction
CHANNEL_TX_FILE=/data/channel.tx
ANCHOR_TX_FILE=/data/fabric.opetbot.com/anchors.tx
# Name of the channel
CHANNEL_NAME=opetchannel


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


# Get Organization CA certificates
function getOrgCACerts {
   log "Getting CA certs for organization $ORG and storing in $ORG_MSP_DIR"
   fabric-ca-client getcacert -d -u https://$CA_HOST:7054 -M $ORG_MSP_DIR
   finishMSPSetup $ORG_MSP_DIR

   switchToAdminIdentity
}


# Enroll the organization admin user
function switchToAdminIdentity {
   export FABRIC_CA_CLIENT_HOME=$ORG_ADMIN_HOME
   export FABRIC_CA_CLIENT_TLS_CERTFILES=$ORG_MSP_DIR/tlscacerts/ca-fabric-opetbot-com-7054.pem
   fabric-ca-client enroll -d -u https://$ORG_ADMIN_USER:$ORG_ADMIN_PASS@$CA_HOST:7054

   # Copy admincerts to local MSP
   mkdir -p $(dirname "${ORG_ADMIN_CERT}")
   cp $ORG_ADMIN_HOME/msp/signcerts/* $ORG_ADMIN_CERT
   mkdir -p $ORG_ADMIN_HOME/msp/admincerts
   cp $ORG_ADMIN_HOME/msp/signcerts/* $ORG_ADMIN_HOME/msp/admincerts
}


# Copy the org's admin cert into some target MSP directory
# This is only required if ADMINCERTS is enabled.
# To generate the admin certificates, call getOrgCACerts first.
function copyAdminCert {
   if [ $# -ne 1 ]; then
      fatal "Usage: copyAdminCert <targetMSPDIR>"
   fi
   dstDir=$1/admincerts
   mkdir -p $dstDir
   cp $ORG_ADMIN_CERT $dstDir
}


# Generate the genesis block and channel configuration transaction.
function generateChannelArtifacts() {
  ORG=$ORDERER_ORG

  which configtxgen
  if [ "$?" -ne 0 ]; then
    fatal "configtxgen tool not found. exiting"
  fi

  log "Generating orderer genesis block at $GENESIS_BLOCK_FILE"
  # Note: For some unknown reason (at least for now) the block file can't be
  # named orderer.genesis.block or the orderer will fail to launch!
  configtxgen -profile OpetOrdererGenesis -outputBlock $GENESIS_BLOCK_FILE
  if [ "$?" -ne 0 ]; then
    fatal "Failed to generate orderer genesis block"
  fi

  log "Generating channel configuration transaction at $CHANNEL_TX_FILE"
  configtxgen -profile OpetChannel -outputCreateChannelTx $CHANNEL_TX_FILE -channelID $CHANNEL_NAME
  if [ "$?" -ne 0 ]; then
    fatal "Failed to generate channel configuration transaction"
  fi

  log "Generating anchor peer update transaction for $ORG at $ANCHOR_TX_FILE"
  configtxgen -profile OpetChannel -outputAnchorPeersUpdate $ANCHOR_TX_FILE \
              -channelID $CHANNEL_NAME -asOrg $ORG
  if [ "$?" -ne 0 ]; then
     fatal "Failed to generate anchor peer update for $ORG"
  fi
}


# Generate the certificates for TLS communication.
function genClientTLSCert {
   if [ $# -ne 4 ]; then
      echo "Usage: genClientTLSCert <enrollment url> <host name> <cert file> <key file>: $*"
      exit 1
   fi

   ENROLLMENT_URL=$1
   HOST_NAME=$2
   CERT_FILE=$3
   KEY_FILE=$4

   rm -r /tmp/tls || true

   # Get a client cert
   fabric-ca-client enroll -d --enrollment.profile tls -u $ENROLLMENT_URL -M /tmp/tls --csr.hosts $HOST_NAME

   mkdir /data/tls || true
   cp /tmp/tls/signcerts/* $CERT_FILE
   cp /tmp/tls/keystore/* $KEY_FILE
   rm -rf /tmp/tls
}


# Log a message
function log {
   if [ "$1" = "-n" ]; then
      shift
      echo -n "##### `date '+%Y-%m-%d %H:%M:%S'` $*"
   else
      echo "##### `date '+%Y-%m-%d %H:%M:%S'` $*"
   fi
}


# Log fatal message and exit
function fatal {
   log "FATAL: $*"
   exit 1
}
