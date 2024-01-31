#!/usr/bin/env bash

set -eo pipefail

export PORT_DEPLOY_FILE="deploy_ormp_port.a"
export PORT_KEY=".ORMP_PORT"
# forge script script/config/RegistryPort.s.sol:RegistryPort --chain-id 46    --broadcast --slow
# forge script script/config/RegistryPort.s.sol:RegistryPort --chain-id 42161 --broadcast --slow --legacy
forge script script/config/RegistryPort.s.sol:RegistryPort --chain-id 1 --broadcast --slow --legacy
# forge script script/config/RegistryPort.s.sol:RegistryPort --chain-id 11155111 --broadcast

# forge script script/config/RegistryPort.s.sol:RegistryPort --chain-id 44       --broadcast
# forge script script/config/RegistryPort.s.sol:RegistryPort --chain-id 11155111 --broadcast
