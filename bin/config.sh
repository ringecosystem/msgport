#!/usr/bin/env bash

set -eo pipefail

export PORT_CONFIG_FILE="ormp_port.c"
export PORT_DEPLOY_FILE="deploy_ormp_port.a"
export PORT_KEY=".ORMP_PORT"

cid="QmWpJRDW55oEPxcvKPbCg8p31odC2CnDJLqeT9MFn3peYi"
cid=$(ipfs cid format -v 1 -b base32 $cid)
uri="ipfs://$cid"
# forge script script/config/PortConfig.s.sol:PortConfig --sig "run(uint256[],string)" "[42161]" $uri --chain-id 46    --broadcast --slow
# forge script script/config/PortConfig.s.sol:PortConfig --sig "run(uint256[],string)" "[46]"    $uri --chain-id 42161 --broadcast --slow --legacy
# forge script script/config/PortConfig.s.sol:PortConfig --sig "run(uint256[],string)" "[46]"    $uri --chain-id 1 --broadcast --slow --legacy

# forge script script/config/PortConfig.s.sol:PortConfig --sig "run(uint256[],string)" "[421614,11155111]" $uri --chain-id 44       --broadcast
# forge script script/config/PortConfig.s.sol:PortConfig --sig "run(uint256[],string)" "[11155111,44]"     $uri --chain-id 421614   --broadcast --skip-simulation --legacy
# forge script script/config/PortConfig.s.sol:PortConfig --sig "run(uint256[],string)" "[44,421614]"       $uri --chain-id 11155111 --broadcast

forge script script/config/PortConfig.s.sol:PortConfig --sig "run(uint256[],string)" "[421614,11155111]" $uri --chain-id 43 --broadcast
forge script script/config/PortConfig.s.sol:PortConfig --sig "run(uint256[],string)" "[43]"              $uri --chain-id 11155111 --broadcast
forge script script/config/PortConfig.s.sol:PortConfig --sig "run(uint256[],string)" "[43]"              $uri --chain-id 421614 --broadcast --skip-simulation --legacy
