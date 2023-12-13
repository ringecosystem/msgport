#!/usr/bin/env bash

set -eo pipefail

export LINE_DEPLOY_FILE="deploy_ormp_line.a"
export LINE_KEY=".ORMP_LINE"
# forge script script/config/RegistryLine.s.sol:RegistryLine --chain-id 46    --broadcast --slow
# forge script script/config/RegistryLine.s.sol:RegistryLine --chain-id 42161 --broadcast --slow --legacy
forge script script/config/RegistryLine.s.sol:RegistryLine --chain-id 1 --broadcast --slow --legacy
# forge script script/config/RegistryLine.s.sol:RegistryLine --chain-id 11155111 --broadcast

# forge script script/config/RegistryLine.s.sol:RegistryLine --chain-id 44       --broadcast
# forge script script/config/RegistryLine.s.sol:RegistryLine --chain-id 11155111 --broadcast
