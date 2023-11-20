#!/usr/bin/env bash

set -eo pipefail

# forge script script/deploy/DeployLineRegistry.s.sol:DeployLineRegistry --chain-id 46    --broadcast --verify --slow
# forge script script/deploy/DeployLineRegistry.s.sol:DeployLineRegistry --chain-id 42161 --broadcast --verify --slow --legacy

# forge script script/deploy/DeployLineRegistry.s.sol:DeployLineRegistry --chain-id 11155111 --broadcast --verify
forge script script/deploy/DeployORMPLine.s.sol:DeployORMPLine         --chain-id 11155111 --broadcast --verify
