#!/bin/bash
#
# Copyright IBM Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#

set -e

source $(dirname "$0")/env.sh


function setupPeer {

  echo Enroll to get peer TLS cert and key pair
  ENROLLMENT_URL=https://$PEER0_USER:$PEER0_PASS@$CA_HOST:7054

  # Generate server TLS cert and key pair for the peer
  genClientTLSCert $ENROLLMENT_URL $PEER_HOST $CORE_PEER_TLS_CERT_FILE $CORE_PEER_TLS_KEY_FILE

  echo Generate client TLS cert and key pair for the peer
  genClientTLSCert $ENROLLMENT_URL $PEER_NAME $CORE_PEER_TLS_CLIENTCERT_FILE $CORE_PEER_TLS_CLIENTKEY_FILE

  echo Generate client TLS cert and key pair for the peer CLI
  genClientTLSCert $ENROLLMENT_URL $PEER_NAME /data/tls/$PEER_NAME-cli-client.crt /data/tls/$PEER_NAME-cli-client.key

  echo Enroll the peer to get an enrollment certificate and set up the core local MSP directory
  fabric-ca-client enroll -d -u $ENROLLMENT_URL -M $CORE_PEER_MSPCONFIGPATH
  finishMSPSetup $CORE_PEER_MSPCONFIGPATH

  # Check if we need the org amdin certificate
  echo Get organization certificates and copy admin certificate to peer MSP
  # Create organization MSP folder
  getOrgCACerts
  # We need to copy the admin certificate to orderer's MSP
  copyAdminCert ${CORE_PEER_MSPCONFIGPATH}

  touch $PEER_HOME/setup.done
}

function startPeer {
  # Note: part of the config is backed into the image under /etc/hyperledger/fabric:
  # The config path environment variable is set to:
  #   FABRIC_CFG_PATH="/etc/hyperledger/fabric"
  #
  # This is the path that is used by peer, orderer (and also other tools like configtxgen) to
  # find the configuration.
  # Here we have:
  #
  #   root@a68933754a0b:/# ls /etc/hyperledger/fabric/
  #   configtx.yaml  core.yaml  msp  orderer.yaml
  #
  # The core.yaml that is used by peer, it was not changed and we use the default one.
  # Note: without this config, the peer wouldn't start and raise the error:
  #  [main] main -> ERRO 001 Fatal error when initializing core config : error when reading core config file: Unsupported Config Type ""
  #
  # Start the peer
  log "Starting peer '$CORE_PEER_ID' with MSP at '$CORE_PEER_MSPCONFIGPATH'"
  env | grep CORE
  peer node start
}


if [ ! -e $PEER_HOME/setup.done ]; then
  # Only do the setup once.
  # To trigger the setup, do `rm -rf data/peerX/`.
  setupPeer
fi
startPeer
