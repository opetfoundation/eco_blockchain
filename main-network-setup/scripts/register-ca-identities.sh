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
   log "Registering $ORDERER_NAME with $CA_NAME"
   fabric-ca-client register -d --id.name $ORDERER_USER --id.secret $ORDERER_PASS --id.type orderer
}


# Register organization admin
function registerOrganizationAdmin {
   log "Registering organization admin identity with $CA_NAME"
   # The admin identity has the "admin" attribute which is added to ECert by default
   fabric-ca-client register -d --id.name $ADMIN_NAME --id.secret $ADMIN_PASS --id.attrs "admin=true:ecert"

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


# Get Organization CA certificates
function getOrgCACerts {
   ORG=$ORDERER_ORG
   ORG_MSP_DIR=/data/fabric.opetbot.com/msp
   ORG_ADMIN_HOME=/data/fabric.opetbot.com/admin
   ORG_ADMIN_CERT=${ORG_MSP_DIR}/admincerts/cert.pem
   ORG_ADMIN_HOME=/data/fabric.opetbot.com/admin

   log "Getting CA certs for organization $ORG and storing in $ORG_MSP_DIR"
   export FABRIC_CA_CLIENT_TLS_CERTFILES=$CA_CERTFILE

   fabric-ca-client getcacert -d -u https://$CA_HOST:7054 -M $ORG_MSP_DIR
   finishMSPSetup $ORG_MSP_DIR
   # If ADMINCERTS is true, we need to enroll the admin now to populate the admincerts directory
   if [ $ADMINCERTS ]; then
      # switchToAdminIdentity
      export FABRIC_CA_CLIENT_HOME=$ORG_ADMIN_HOME
      # export FABRIC_CA_CLIENT_TLS_CERTFILES=$CA_CERTFILE
      export FABRIC_CA_CLIENT_TLS_CERTFILES=$ORG_MSP_DIR/tlsca/tlsca.fabric.opetbot.com-cert.pem
      fabric-ca-client enroll -d -u https://$ORG_ADMIN_USER:$ORG_ADMIN_PASS@$CA_HOST:7054
      # If admincerts are required in the MSP, copy the cert there now and to my local MSP also
      mkdir -p $(dirname "${ORG_ADMIN_CERT}")
      cp $ORG_ADMIN_HOME/msp/signcerts/* $ORG_ADMIN_CERT
      mkdir $ORG_ADMIN_HOME/msp/admincerts
      cp $ORG_ADMIN_HOME/msp/signcerts/* $ORG_ADMIN_HOME/msp/admincerts
   fi
}


main
