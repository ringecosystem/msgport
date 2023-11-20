#!/usr/bin/env bash

set -eo pipefail

export LINE_DEPLOY_FILE="deploy_ormp_line.a"
export LINE_KEY=".ORMP_LINE"
# forge script script/config/RegistryLine.s.sol:RegistryLine --chain-id 42161 --broadcast --slow --legacy
forge script script/config/RegistryLine.s.sol:RegistryLine --chain-id 11155111 --broadcast
