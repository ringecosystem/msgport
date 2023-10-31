#!/usr/bin/env bash

set -eo pipefail

deployer=0x0f14341A7f464320319025540E8Fe48Ad0fe5aec
ormp=0x009D223Aad560e72282db9c0438Ef1ef2bf7703D
registry=0x001263Ee00A5296C2226BDa668cDd465925dF372
ormp_line=0x001ddFd752a071964fe15C2386ec1811963D00C2
name="ORMP"

verify() {
  local addr; addr=$1
  local chain_id; chain_id=$2
  local args; args=$3
  local path; path=$4
  local name; name=${path#*:}
  (set -x; forge verify-contract \
    --chain-id $chain_id \
    --num-of-optimizations 999999 \
    --watch \
    --constructor-args $args \
    --etherscan-api-key $ETHERSCAN_API_KEY \
    --compiler-version v0.8.17+commit.8df45f5f \
    --show-standard-json-input \
    $addr \
    $path > script/output/$chain_id/$name.v.json)
}

verify $registry  421614 $(cast abi-encode "constructor(address)" $deployer) src/LineRegistry.sol:LineRegistry
verify $registry  44     $(cast abi-encode "constructor(address)" $deployer) src/LineRegistry.sol:LineRegistry

verify $ormp_line 421614 $(cast abi-encode "constructor(address,address,string)" $deployer $ormp $name) src/lines/ORMPLine.sol:ORMPLine
verify $ormp_line 44     $(cast abi-encode "constructor(address,address,string)" $deployer $ormp $name) src/lines/ORMPLine.sol:ORMPLine
