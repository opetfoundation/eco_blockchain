#!/bin/bash

set -e

source $(dirname "$0")/env.sh
# initOrdererVars ${OORGS[0]} 1
ORDERER_HOST=orderer.fabric.opetbot.com
ORDERER_PORT_ARGS="-o $ORDERER_HOST:7050 --tls --cafile $FABRIC_CA_CLIENT_TLS_CERTFILES --clientauth"
ORDERER_CONN_ARGS="$ORDERER_PORT_ARGS --keyfile $CORE_PEER_TLS_CLIENTKEY_FILE --certfile $CORE_PEER_TLS_CLIENTCERT_FILE"

# Join peer to the channel
switchToAdminIdentity
log "Peer $PEER_HOST is attempting to join channel '$CHANNEL_NAME' (attempt #${COUNT}) ..."
peer channel join -b $CHANNEL_NAME.block
