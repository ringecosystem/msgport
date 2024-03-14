#!/usr/bin/env bash

set -eo pipefail

c3=$PWD/script/input/c3.json

deployer=$(jq -r ".DEPLOYER" $c3)
ormp=$(jq -r ".ORMP_ADDR" $c3)
registry=$(jq -r ".PORTREGISTRY_ADDR" $c3)
ormp_port=$(jq -r ".ORMPPORT_ADDR" $c3)
multi_port=$(jq -r ".MULTIPORT_ADDR" $c3)
xaccount_factory=$(jq -r ".XACCOUNTFACTORY_ADDR" $c3)
module=$(jq -r ".SAFEMSGPORTMODULE_ADDR" $c3)
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
# verify $multi_port 421614   $(cast abi-encode "constructor(address,uint256,string)" $deployer 1 "Multi") src/ports/MultiPort.sol:MultiPort
# verify $multi_port 43       $(cast abi-encode "constructor(address,uint256,string)" $deployer 1 "Multi") src/ports/MultiPort.sol:MultiPort
verify $multi_port 11155111 $(cast abi-encode "constructor(address,uint256,string)" $deployer 1 "Multi") src/ports/MultiPort.sol:MultiPort
verify $xaccount_factory 11155111   $( \
  cast abi-encode "constructor(address,address,address,address,address,address,string)" \
  $deployer \
  $module \
  0xc22834581ebc8527d974f8a1c97e1bea4ef910bc \
  0x69f4d1788e39c87893c980c06edf4b7f686e2938 \
  0x017062a1de2fe6b99be3d9d37841fed19f573804 \
  0x00004582a7deb2c39fda29b0934de73cdfac6150 \
  "xAccountFactory" \
) src/xAccount/XAccountFactory.sol:XAccountFactory
verify $module 11155111  "0xbd666d74" src/xAccount/SafeMsgportModule.sol:SafeMsgportModule

# verify $ormp_port 421614   $(cast abi-encode "constructor(address,address,string)" $deployer $ormp $name) src/ports/ORMPPort.sol:ORMPPort
# verify $ormp_port 43       $(cast abi-encode "constructor(address,address,string)" $deployer $ormp $name) src/ports/ORMPPort.sol:ORMPPort
# verify $ormp_port 11155111 $(cast abi-encode "constructor(address,address,string)" $deployer $ormp $name) src/ports/ORMPPort.sol:ORMPPort


# verify $ormp_port 42161 $(cast abi-encode "constructor(address,address,string)" $deployer $ormp $name) src/ports/ORMPPort.sol:ORMPPort
# verify $ormp_port 44    $(cast abi-encode "constructor(address,address,string)" $deployer $ormp $name) src/ports/ORMPPort.sol:ORMPPort
# verify $ormp_port 46    $(cast abi-encode "constructor(address,address,string)" $deployer $ormp $name) src/ports/ORMPPort.sol:ORMPPort
# verify $ormp_port 137   $(cast abi-encode "constructor(address,address,string)" $deployer $ormp $name) src/ports/ORMPPort.sol:ORMPPort
# verify $ormp_port 1     $(cast abi-encode "constructor(address,address,string)" $deployer $ormp $name) src/ports/ORMPPort.sol:ORMPPort
# verify $ormp_port 81457   $(cast abi-encode "constructor(address,address,string)" $deployer $ormp $name) src/ports/ORMPPort.sol:ORMPPort

