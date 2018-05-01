#!/bin/bash

set -e

SCRIPT_PATH=`dirname $0`

echo $FABRIC_CA_SERVER_HOME
echo $FABRIC_CA_SERVER_CSR_HOSTS
echo $FABRIC_CA_SERVER_CA_NAME

# Initialize the root CA
fabric-ca-server init -b $CA_ADMIN_USER:$CA_ADMIN_PASS

# Copy the root CA's signing certificate to the data directory to be used by others
cp $FABRIC_CA_SERVER_HOME/ca-cert.pem $TARGET_CERTFILE

# setupHosts

# Start the root CA
fabric-ca-server start
