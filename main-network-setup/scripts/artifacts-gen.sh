#!/bin/bash
#
# Copyright IBM Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#

set -e

source $(dirname "$0")/env.sh

echo Create the genesis block and channel artifacts
cp /scripts/configtx.yaml /data/fabric.opetbot.com/
export FABRIC_CFG_PATH=/data/fabric.opetbot.com
generateChannelArtifacts
