#!/usr/bin/env bash

set -eo pipefail

# forge script script/deploy/DeployLineRegistry.s.sol:DeployLineRegistry --chain-id 43     --broadcast --verify
# forge script script/deploy/DeployLineRegistry.s.sol:DeployLineRegistry --chain-id 421613 --broadcast --verify

forge script script/deploy/DeployORMPLine.s.sol:DeployORMPLine --chain-id 43     --broadcast --verify
forge script script/deploy/DeployORMPLine.s.sol:DeployORMPLine --chain-id 421613 --broadcast --verify
