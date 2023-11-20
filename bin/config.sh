#!/usr/bin/env bash

set -eo pipefail

export LINE_CONFIG_FILE="ormp_line.c"
export LINE_DEPLOY_FILE="deploy_ormp_line.a"
export LINE_KEY=".ORMP_LINE"

cid="QmPqyGBHxRCxZJEKf8WTeDZB2JDMrtfrPqxGcxN2scj64E"
cid=$(ipfs cid format -v 1 -b base32 $cid)
uri="ipfs:://$cid"
# forge script script/config/LineConfig.s.sol:LineConfig --sig "run(uint256[],string)" "[42161]" $uri --chain-id 46    --broadcast --slow
# forge script script/config/LineConfig.s.sol:LineConfig --sig "run(uint256[],string)" "[46]"    $uri --chain-id 42161 --broadcast --slow --legacy

forge script script/config/LineConfig.s.sol:LineConfig --sig "run(uint256[],string)" "[44]"       $uri --chain-id 11155111 --broadcast
forge script script/config/LineConfig.s.sol:LineConfig --sig "run(uint256[],string)" "[11155111]" $uri --chain-id 44       --broadcast
