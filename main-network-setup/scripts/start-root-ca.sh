#!/bin/bash

set -e

SCRIPT_PATH=`dirname $0`

echo $FABRIC_CA_SERVER_HOME
echo $FABRIC_CA_SERVER_CSR_HOSTS
echo $FABRIC_CA_SERVER_CA_NAME

mkdir -p $FABRIC_CA_SERVER_HOME

FABRIC_CA_TEMPLATE=$SCRIPT_PATH/fabric-ca-server-config.yaml
FABRIC_CA_CONFIG=$FABRIC_CA_SERVER_HOME/fabric-ca-server-config.yaml

# Generate the config file
( echo "cat <<EOF >${FABRIC_CA_CONFIG}";
  cat ${FABRIC_CA_TEMPLATE};
  echo "EOF";
) >$FABRIC_CA_SERVER_HOME/gen.config.sh
. $FABRIC_CA_SERVER_HOME/gen.config.sh
cat ${FABRIC_CA_CONFIG}

# Initialize the root CA
fabric-ca-server init -b $CA_ADMIN_USER:$CA_ADMIN_PASS

# Copy the root CA's signing certificate to the data directory to be used by others
cp $FABRIC_CA_SERVER_HOME/ca-cert.pem $TARGET_CERTFILE

# setupHosts

# Start the root CA
fabric-ca-server start
