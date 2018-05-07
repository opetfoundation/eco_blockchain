#!/bin/bash

set -e

source $(dirname "$0")/env.sh
# initOrdererVars ${OORGS[0]} 1
ORDERER_HOST=orderer.fabric.opetbot.com
ORDERER_PORT_ARGS="-o $ORDERER_HOST:7050 --tls --cafile $FABRIC_CA_CLIENT_TLS_CERTFILES --clientauth"
ORDERER_CONN_ARGS="$ORDERER_PORT_ARGS --keyfile $CORE_PEER_TLS_CLIENTKEY_FILE --certfile $CORE_PEER_TLS_CLIENTCERT_FILE"

# Create the channel
# CA_MSP_DIR=/data/ca.fabric.opetbot.com/msp
# CA_ADMIN_HOME=/data/ca.fabric.opetbot.com/admin
# CA_ADMIN_CERT=${CA_MSP_DIR}/admincerts/cert.pem
# switchToAdminIdentity
# export FABRIC_CA_CLIENT_HOME=$CA_ADMIN_HOME
# export FABRIC_CA_CLIENT_TLS_CERTFILES=$ORG_MSP_DIR/tlscacerts/ca-fabric-opetbot-com-7054.pem
# fabric-ca-client enroll -d -u https://$CA_ADMIN_USER:$CA_ADMIN_PASS@$CA_HOST:7054
# mkdir -p $CA_ADMIN_HOME/msp/admincerts
# cp $CA_ADMIN_HOME/msp/signcerts/* $CA_ADMIN_HOME/msp/admincerts
# Switch following peer commands to admin.
# export CORE_PEER_MSPCONFIGPATH=/data/ca.org/admin/msp
# Switch following peer commands to admin.
# export CORE_PEER_MSPCONFIGPATH=$CA_ADMIN_HOME/msp
export CORE_PEER_MSPCONFIGPATH=$ORG_ADMIN_HOME/msp

# export FABRIC_CA_CLIENT=$PEER_HOME
log "Creating channel '$CHANNEL_NAME' on $ORDERER_HOST ..."
peer channel create --logging-level=DEBUG -c $CHANNEL_NAME -f $CHANNEL_TX_FILE $ORDERER_CONN_ARGS

# # Join peer to the channel
log "Peer $PEER_HOST is attempting to join channel '$CHANNEL_NAME' (attempt #${COUNT}) ..."
peer channel join -b $CHANNEL_NAME.block

log "Updating anchor peers for $PEER_HOST ..."
peer channel update -c $CHANNEL_NAME -f $ANCHOR_TX_FILE $ORDERER_CONN_ARGS

# # Install chaincode
# log "Installing chaincode on $PEER_HOST ..."
# peer chaincode install -n opet -v 1.0 -p /chaincode/opetbot

# # Instantiate chaincode
# makePolicy
# log "Instantiating chaincode on $PEER_HOST ..."
# peer chaincode instantiate -C $CHANNEL_NAME -n opet -v 1.0 -c '{"Args":["init","initLedger"]}' -P "'OpetMSP.peer')" $ORDERER_CONN_ARGS

# # # Query chaincode
# # switchToUserIdentity
# # chaincodeQuery 100


# $ ../fabric-samples/bin/configtxgen -inspectBlock ../data/genesis.block > ../block.json
