#!/usr/bin/env bash

set -eo pipefail

c3=$PWD/script/input/c3.json

deployer=$(jq -r ".DEPLOYER" $c3)
ormp=$(jq -r ".ORMP_ADDR" $c3)
registry=$(jq -r ".PORTREGISTRY_ADDR" $c3)
ormp_port=$(jq -r ".ORMPPORT_ADDR" $c3)
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

# verify $registry  42161 $(cast abi-encode "constructor(address)" $deployer) src/PortRegistry.sol:PortRegistry
# verify $registry  46    $(cast abi-encode "constructor(address)" $deployer) src/PortRegistry.sol:PortRegistry
# verify $registry  1    $(cast abi-encode "constructor(address)" $deployer) src/PortRegistry.sol:PortRegistry

verify $ormp_port 421614   $(cast abi-encode "constructor(address,address,string)" $deployer $ormp $name) src/ports/ORMPPort.sol:ORMPPort
verify $ormp_port 44       $(cast abi-encode "constructor(address,address,string)" $deployer $ormp $name) src/ports/ORMPPort.sol:ORMPPort
verify $ormp_port 11155111 $(cast abi-encode "constructor(address,address,string)" $deployer $ormp $name) src/ports/ORMPPort.sol:ORMPPort
