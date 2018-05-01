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

  export FABRIC_CA_CLIENT_HOME=$ORDERER_HOME
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

  echo Get organization certificates and copy admin certificate to orderer MSP
  export CA_CERTFILE=/data/opet-ca-cert.pem
  getOrgCACerts
  # The org admin home is created in getOrgCACerts
  ORG_ADMIN_HOME=/data/fabric.opetbot.com/admin
  # We need to copy the admin certificate to orderer's MSP
  ORG_ADMIN_CERT=${ORDERER_GENERAL_LOCALMSPDIR}/admincerts/cert.pem
  mkdir -p $(dirname "${ORG_ADMIN_CERT}")
  cp $ORG_ADMIN_HOME/msp/signcerts/* $ORG_ADMIN_CERT

  touch $ORDERER_HOME/setup.done
}

function startOrderer {
  # Note: part of the config is backed into the image under /etc/hyperledger/fabric:
  # The config path environment variable is set to:
  #   FABRIC_CFG_PATH="/etc/hyperledger/fabric"
  #
  # This is the path that is used by orderer (and also other tools like configtxgen) to
  # find the configuration.
  # Here we have:
  #
  #   root@a68933754a0b:/# ls /etc/hyperledger/fabric/
  #   configtx.yaml  core.yaml  msp  orderer.yaml
  #
  # So the orderer.yaml that is used by orderer was not changed and we use the default one.
  # Note: without this config, the orderer wouldn't start and raise the error:
  #  [orderer/common/server] Main -> ERRO 001 failed to parse config:  Error reading configuration: Unsupported Config Type ""
  #
  # Start the orderer
  env | grep ORDERER
  orderer
}


if [ ! -e $ORDERER_HOME/setup.done ]; then
  # Only do the setup once.
  # To trigger the setup, do `rm -rf data/orderer/`.
  setupOrderer
fi
startOrderer
