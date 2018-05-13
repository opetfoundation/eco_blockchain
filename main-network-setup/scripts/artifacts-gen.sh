#!/bin/bash
#
# Generate the genesis block and channel configuration transaction.
# See the ../Makefile for usage example.

set -e

source $(dirname "$0")/env.sh

echo Create the genesis block and channel artifacts
cp /scripts/configtx.yaml /data/fabric.opetbot.com/
export FABRIC_CFG_PATH=/data/fabric.opetbot.com
generateChannelArtifacts
