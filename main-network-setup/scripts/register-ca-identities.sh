#!/bin/bash

set -e

SCRIPT_PATH=`dirname $0`

source $SCRIPT_PATH/env.sh


function main {
   log "Registering CA identities ..."

   enrollCAAdmin
   registerOrdererIdentities
   registerOrganizationAdmin
   registerPeerIdentities

   getOrgCACerts
}


# Register orderer identity
function registerOrdererIdentities {
   log "Registering orderer with $CA_NAME"
   fabric-ca-client register -d --id.name $ORDERER_USER --id.secret $ORDERER_PASS --id.type orderer
}


# Register organization admin
function registerOrganizationAdmin {
   log "Registering organization admin identity with $CA_NAME"
   # The admin identity has the "admin" attribute which is added to ECert by default
   fabric-ca-client register -d --id.name $ORG_ADMIN_USER --id.secret $ORG_ADMIN_PASS --id.attrs "admin=true:ecert"

   # The peer organization admin
   # fabric-ca-client register -d --id.name $ADMIN_NAME --id.secret $ADMIN_PASS --id.attrs "hf.Registrar.Roles=client,hf.Registrar.Attributes=*,hf.Revoker=true,hf.GenCRL=true,admin=true:ecert,abac.init=true:ecert"

   # log "Registering user identity with $CA_NAME"
   # fabric-ca-client register -d --id.name $USER_NAME --id.secret $USER_PASS
}


# Register any identities associated with a peer
function registerPeerIdentities {
   PEER_NAME=peer0_opet
   PEER_USER=$PEER0_USER
   PEER_PASS=$PEER0_PASS
   log "Registering $PEER_NAME with $CA_NAME"
   fabric-ca-client register -d --id.name $PEER_NAME --id.secret $PEER_PASS --id.type peer
}


main
