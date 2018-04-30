#!/bin/bash

CA_HOST=ca.fabric.opetbot.com
CA_NAME=ca_opet
# CA_SERVER_HOME=/etc/hyperledger/fabric-ca
CA_CERTFILE=$FABRIC_CA_SERVER_HOME/ca-cert.pem

ORDERER_HOST=orderer.fabric.opetbot.com
ORDERER_NAME=orderer_opet
ORDERER_HOME=/etc/hyperledger/orderer

ORDERER_ORG="opet"

# Enroll the CA administrator
function enrollCAAdmin {
   log "Enrolling with $CA_NAME as bootstrap identity ..."
   export FABRIC_CA_CLIENT_HOME=$HOME/cas/$CA_NAME
   export FABRIC_CA_CLIENT_TLS_CERTFILES=$CA_CERTFILE
   fabric-ca-client enroll -d -u https://$CA_ADMIN_USER:$CA_ADMIN_PASS@$CA_HOST:7054
}


# Get CA certificates
function getCACerts {
   log "Getting CA certificates ..."
   for ORG in $ORGS; do
      log "Getting CA certs for organization $ORG and storing in $ORG_MSP_DIR"
      export FABRIC_CA_CLIENT_TLS_CERTFILES=$CA_CHAINFILE
      fabric-ca-client getcacert -d -u https://$CA_HOST:7054 -M $ORG_MSP_DIR
      finishMSPSetup $ORG_MSP_DIR
      # If ADMINCERTS is true, we need to enroll the admin now to populate the admincerts directory
      if [ $ADMINCERTS ]; then
         switchToAdminIdentity
      fi
   done
}


# log a message
function log {
   if [ "$1" = "-n" ]; then
      shift
      echo -n "##### `date '+%Y-%m-%d %H:%M:%S'` $*"
   else
      echo "##### `date '+%Y-%m-%d %H:%M:%S'` $*"
   fi
}

# fatal a message
function fatal {
   log "FATAL: $*"
   exit 1
}
