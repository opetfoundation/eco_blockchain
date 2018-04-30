#!/bin/bash

set -e

SCRIPT_PATH=`dirname $0`
FABRIC_CA_SERVER_HOME=/etc/hyperledger/fabric-ca

# Initialize the root CA
fabric-ca-server init -b $CA_ADMIN_USER_PASS

# Copy the root CA's signing certificate to the data directory to be used by others
# cp $FABRIC_CA_SERVER_HOME/ca-cert.pem $TARGET_CERTFILE

if ls /etc/hosts.orginal; then
  # If we have modified the original file already, restore it before
  # we modify it again.
  cp /etc/hosts.orginal /etc/hosts
fi
cp /etc/hosts /etc/hosts.orginal
cat $SCRIPT_PATH/hosts >> /etc/hosts

# Start the root CA
fabric-ca-server start
