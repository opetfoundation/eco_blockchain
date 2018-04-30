#!/bin/bash

CA_HOST=ca.fabric.opetbot.com
CA_NAME=ca_opet
CA_SERVER_HOME=/etc/hyperledger/fabric-ca
CA_CERTFILE=/$CA_SERVER_HOME/ca-cert.pem

ORDERER_HOST=orderer.fabric.opetbot.com
ORDERER_NAME=orderer_opet
ORDERER_HOME=/etc/hyperledger/orderer

ORDERER_ORG="opet"

# Enroll the CA administrator
function enrollCAAdmin {
   log "Enrolling with $CA_NAME as bootstrap identity ..."
   export FABRIC_CA_CLIENT_HOME=$HOME/cas/$CA_NAME
   export FABRIC_CA_CLIENT_TLS_CERTFILES=$CA_CERTFILE
   fabric-ca-client enroll -d -u https://$CA_ADMIN_USER_PASS@$CA_HOST:7054
}


# initOrgVars <ORG>
function initOrgVars {
   if [ $# -ne 1 ]; then
      echo "Usage: initOrgVars <ORG>"
      exit 1
   fi
   ORG=$1
   ORG_CONTAINER_NAME=${ORG//./-}
   # Admin identity for the org
   ADMIN_NAME=admin-${ORG}
   ADMIN_PASS=${ADMIN_NAME}pw
   # Typical user identity for the org
   USER_NAME=user-${ORG}
   USER_PASS=${USER_NAME}pw

   CA_CERTFILE=/${DATA}/${ORG}-ca-cert.pem
   ANCHOR_TX_FILE=/${DATA}/orgs/${ORG}/anchors.tx
   ORG_MSP_ID=${ORG}MSP
   ORG_MSP_DIR=/${DATA}/orgs/${ORG}/msp
   ORG_ADMIN_CERT=${ORG_MSP_DIR}/admincerts/cert.pem
   ORG_ADMIN_HOME=/${DATA}/orgs/$ORG/admin
}
