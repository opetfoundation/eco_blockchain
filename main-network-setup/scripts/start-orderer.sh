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

  echo Enroll orderer user to CA
  genClientTLSCert $ENROLLMENT_URL $ORDERER_HOST $ORDERER_GENERAL_TLS_CERTIFICATE $ORDERER_GENERAL_TLS_PRIVATEKEY

  # Enroll again to get the orderer's enrollment certificate (default profile)
  fabric-ca-client enroll -d -u $ENROLLMENT_URL -M $ORDERER_GENERAL_LOCALMSPDIR

  # Finish setting up the local MSP for the orderer
  finishMSPSetup $ORDERER_GENERAL_LOCALMSPDIR

  echo Get organization certificates and copy admin certificate to orderer MSP
  # Create organization MSP folder
  getOrgCACerts
  # We need to copy the admin certificate to orderer's MSP
  copyAdminCert ${ORDERER_GENERAL_LOCALMSPDIR}

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
