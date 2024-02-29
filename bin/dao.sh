#!/usr/bin/env bash

set -eo pipefail

c3=$PWD/script/input/c3.json

deployer=$(jq -r ".DEPLOYER" $c3)
dao=$(jq -r ".MSGPORTDAO" $c3)
registry=$(jq -r ".PORTREGISTRY_ADDR" $c3)
ormp_port=$(jq -r ".ORMPPORT_ADDR" $c3)

set -x

# seth send -F $deployer $registry "transferOwnership(address)" $dao --chain darwinia
# seth send -F $deployer $registry "transferOwnership(address)" $dao --chain arbitrum
# seth send -F $deployer $registry "transferOwnership(address)" $dao --chain ethereum

# seth send -F $deployer $ormp_port "transferOwnership(address)" $dao --chain darwinia
# seth send -F $deployer $ormp_port "transferOwnership(address)" $dao --chain arbitrum
# seth send -F $deployer $ormp_port "transferOwnership(address)" $dao --chain ethereum
# seth send -F $deployer $ormp_port "transferOwnership(address)" $dao --chain arbitrum
seth send -F $deployer $ormp_port "transferOwnership(address)" $dao --chain polygon
