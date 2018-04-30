#!/bin/bash

set -e

SCRIPT_PATH=`dirname $0`

source $SCRIPT_PATH/env.sh


function main {
   log "Registering CA identities ..."

   enrollCAAdmin
   registerOrdererIdentities
   registerOrganizationAdmin

   # getCACerts

   # log "Building channel artifacts ..."
   # makeConfigTxYaml
   # generateChannelArtifacts
   # log "Finished building channel artifacts"
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
}

main
