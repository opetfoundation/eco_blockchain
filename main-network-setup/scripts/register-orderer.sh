#!/bin/bash

set -e

SCRIPT_PATH=`dirname $0`

source $SCRIPT_PATH/env.sh


function main {
   log "Registering CA identities ..."
   initOrgVars $ORDERER_ORG

   enrollCAAdmin
   registerOrdererIdentities
   registerOrganizationAdmin
   getCACerts

   # log "Building channel artifacts ..."
   # makeConfigTxYaml
   # generateChannelArtifacts
   # log "Finished building channel artifacts"
}


# Register orderer identity
function registerOrdererIdentities {
   initOrdererVars $ORDERER_ORG
   log "Registering $ORDERER_NAME with $CA_NAME"
   fabric-ca-client register -d --id.name $ORDERER_USER --id.secret $ORDERER_PASS --id.type orderer
}


# Register organization admin
function registerOrganizationAdmin {
   log "Registering organization admin identity with $CA_NAME"
   # The admin identity has the "admin" attribute which is added to ECert by default
   fabric-ca-client register -d --id.name $ADMIN_NAME --id.secret $ADMIN_PASS --id.attrs "admin=true:ecert"
}


function initOrdererVars {
   initOrgVars $1
   MYHOME=$ORDERER_HOME

   export FABRIC_CA_CLIENT=$MYHOME
   export ORDERER_GENERAL_LOGLEVEL=debug
   export ORDERER_GENERAL_LISTENADDRESS=0.0.0.0
   export ORDERER_GENERAL_GENESISMETHOD=file
   export ORDERER_GENERAL_GENESISFILE=$GENESIS_BLOCK_FILE
   export ORDERER_GENERAL_LOCALMSPID=$ORG_MSP_ID
   export ORDERER_GENERAL_LOCALMSPDIR=$MYHOME/msp
   # enabled TLS
   export ORDERER_GENERAL_TLS_ENABLED=true
   TLSDIR=$MYHOME/tls
   export ORDERER_GENERAL_TLS_PRIVATEKEY=$TLSDIR/server.key
   export ORDERER_GENERAL_TLS_CERTIFICATE=$TLSDIR/server.crt
   export ORDERER_GENERAL_TLS_ROOTCAS=[$CA_CHAINFILE]
}
