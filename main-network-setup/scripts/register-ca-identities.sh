#!/bin/bash

set -e

SCRIPT_PATH=`dirname $0`

source $SCRIPT_PATH/env.sh


function main {
   log "Registering CA identities ..."

   enrollCAAdmin
   registerOrdererIdentities
   registerOrganizationAdmin
   registerPeerIdentities $PEER0_USER $PEER0_PASS
   registerPeerIdentities $PEER1_USER $PEER1_PASS
   registerPeerIdentities $PEER2_USER $PEER2_PASS

   getOrgCACerts
}


# Enroll (login) the CA administrator
function enrollCAAdmin {
   log "Enrolling with $CA_NAME as bootstrap identity ..."
   export FABRIC_CA_CLIENT_HOME=$HOME/cas/$CA_NAME
   # We use the value from the environment (specified in docker config)
   export FABRIC_CA_CLIENT_TLS_CERTFILES=$FABRIC_CA_CLIENT_TLS_CERTFILES
   fabric-ca-client enroll -d -u https://$CA_ADMIN_USER:$CA_ADMIN_PASS@$CA_HOST:7054
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
   if [ $# -ne 2 ]; then
      echo "Usage: registerPeerIdentities <peer user> <peer pass>: $*"
      exit 1
   fi
   PEER_USER=$1
   PEER_PASS=$2
   log "Registering $PEER_USER with $CA_NAME"
   fabric-ca-client register -d --id.name $PEER_USER --id.secret $PEER_PASS --id.type peer
}


main
