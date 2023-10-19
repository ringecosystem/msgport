#!/usr/bin/env bash

set -eo pipefail

export LINE_DEPLOY_FILE="deploy_ormp_line.a"
export LINE_KEY=".ORMP_LINE"
forge script script/config/RegistryLine.s.sol:RegistryLine --chain-id 44     --broadcast
forge script script/config/RegistryLine.s.sol:RegistryLine --chain-id 421614 --broadcast --skip-simulation
