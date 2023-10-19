#!/usr/bin/env bash

set -eo pipefail

export LINE_CONFIG_FILE="ormp_line.c"
export LINE_DEPLOY_FILE="deploy_ormp_line.a"
export LINE_KEY=".ORMP_LINE"
forge script script/config/LineConfig.s.sol:LineConfig --sig "run(uint256[])" "[421614]" --chain-id 44     --broadcast
forge script script/config/LineConfig.s.sol:LineConfig --sig "run(uint256[])" "[44]"     --chain-id 421614 --broadcast --skip-simulation
