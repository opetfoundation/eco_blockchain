#!/bin/bash

set -e

source $(dirname "$0")/env.sh

CHAINCODE_VERSION=1.1

ORDERER_HOST=orderer.fabric.opetbot.com
ORDERER_PORT_ARGS="-o $ORDERER_HOST:7050 --tls --cafile $FABRIC_CA_CLIENT_TLS_CERTFILES --clientauth"
ORDERER_CONN_ARGS="$ORDERER_PORT_ARGS --keyfile $CORE_PEER_TLS_CLIENTKEY_FILE --certfile $CORE_PEER_TLS_CLIENTCERT_FILE"

# Switch following peer commands to admin.
# export CORE_PEER_MSPCONFIGPATH=$CA_ADMIN_HOME/msp
export CORE_PEER_MSPCONFIGPATH=$ORG_ADMIN_HOME/msp

# # Install chaincode
log "Installing chaincode on $PEER_HOST ..."
# note: the install adds /opt/gopath/src before the path we specify here
peer chaincode install -n opet -v $CHAINCODE_VERSION -p chaincode/opetbot

# Upgrading chaincode
log "Upgrading chaincode on $PEER_HOST ..."
# Upgrade the chaincode to the new version.
peer chaincode upgrade -C $CHANNEL_NAME -n opet -v $CHAINCODE_VERSION -c '{"Args":["init","initLedger"]}' $ORDERER_CONN_ARGS
