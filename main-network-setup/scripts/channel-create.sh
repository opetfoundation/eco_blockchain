#!/bin/bash
#
# Create the channel, join the peer to the channel, install the chaincode.
# See the ../Makefile for usage example.

set -e

source $(dirname "$0")/env.sh
ORDERER_HOST=orderer.fabric.opetbot.com
ORDERER_PORT_ARGS="-o $ORDERER_HOST:7050 --tls --cafile $FABRIC_CA_CLIENT_TLS_CERTFILES --clientauth"
ORDERER_CONN_ARGS="$ORDERER_PORT_ARGS --keyfile $CORE_PEER_TLS_CLIENTKEY_FILE --certfile $CORE_PEER_TLS_CLIENTCERT_FILE"

# Create the channel

# Switch following peer commands to admin.
export CORE_PEER_MSPCONFIGPATH=$ORG_ADMIN_HOME/msp

# export FABRIC_CA_CLIENT=$PEER_HOME
log "Creating channel '$CHANNEL_NAME' on $ORDERER_HOST ..."
peer channel create --logging-level=DEBUG -c $CHANNEL_NAME -f $CHANNEL_TX_FILE $ORDERER_CONN_ARGS

# Join peer to the channel
log "Peer $PEER_HOST is attempting to join channel '$CHANNEL_NAME' (attempt #${COUNT}) ..."
peer channel join -b $CHANNEL_NAME.block

log "Updating anchor peers for $PEER_HOST ..."
peer channel update -c $CHANNEL_NAME -f $ANCHOR_TX_FILE $ORDERER_CONN_ARGS

# Install chaincode
log "Installing chaincode on $PEER_HOST ..."
# note: the install adds /opt/gopath/src before the path we specify here
peer chaincode install -n opet -v 1.0 -p chaincode/opetbot

# Instantiate chaincode
log "Instantiating chaincode on $PEER_HOST ..."
# By default fabric will generate an endorsement policy equivalent to 
# "any member from the organizations currently in the channel"
peer chaincode instantiate -C $CHANNEL_NAME -n opet -v 1.0 -c '{"Args":["init","initLedger"]}' $ORDERER_CONN_ARGS
