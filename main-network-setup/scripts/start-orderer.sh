#!/bin/bash
#
# Copyright IBM Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#

set -e

source $(dirname "$0")/env.sh


function setupOrderer {
  # setupHosts

  echo Enroll to get orderer TLS cert using the tls profile
  ENROLLMENT_URL=https://$ORDERER_USER:$ORDERER_PASS@$CA_HOST:7054
  ORDERER_HOST=orderer.fabric.opetbot.com

  export FABRIC_CA_CLIENT_HOME=/etc/hyperledger/orderer
  export FABRIC_CA_CLIENT_TLS_CERTFILES=/data/opet-ca-cert.pem
  # Enroll (login) 'orderer' user to CA
  fabric-ca-client enroll -d --enrollment.profile tls -u $ENROLLMENT_URL -M /tmp/tls --csr.hosts $ORDERER_HOST

  # Copy the TLS key and cert to the appropriate place
  TLSDIR=$ORDERER_HOME/tls
  mkdir -p $TLSDIR
  cp /tmp/tls/keystore/* $ORDERER_GENERAL_TLS_PRIVATEKEY
  cp /tmp/tls/signcerts/* $ORDERER_GENERAL_TLS_CERTIFICATE
  rm -rf /tmp/tls

  # Enroll again to get the orderer's enrollment certificate (default profile)
  fabric-ca-client enroll -d -u $ENROLLMENT_URL -M $ORDERER_GENERAL_LOCALMSPDIR

  # Finish setting up the local MSP for the orderer
  finishMSPSetup $ORDERER_GENERAL_LOCALMSPDIR

  # export FABRIC_CA_CLIENT_HOME=/etc/hyperledger/orderer
  # export FABRIC_CA_CLIENT_TLS_CERTFILES=/data/opet-ca-cert.pem
  # fabric-ca-client enroll -d -u https://$ORG_ADMIN_USER:$ORG_ADMIN_PASS@$CA_HOST:7054
  # getOrgCACerts
  # # If admincerts are required in the MSP, copy the cert there now and to my local MSP also
  # mkdir -p $(dirname "${ORG_ADMIN_CERT}")
  # cp $ORG_ADMIN_HOME/msp/signcerts/* $ORG_ADMIN_CERT
  # mkdir $ORG_ADMIN_HOME/msp/admincerts
  # cp $ORG_ADMIN_HOME/msp/signcerts/* $ORG_ADMIN_HOME/msp/admincerts

  # # echo Get organization certificates ...
  # # fabric-ca-client enroll -d -u https://$ORG_ADMIN_USER:$ORG_ADMIN_PASS@$CA_HOST:7054
  # # getOrgCACerts
  # # copyAdminCert $ORDERER_GENERAL_LOCALMSPDIR

  # echo Create the genesis block
  # generateChannelArtifacts
}

function startOrderer {
  # Start the orderer
  env | grep ORDERER
  orderer
}


setupOrderer
startOrderer
