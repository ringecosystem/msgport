#!/usr/bin/env bash

set -eo pipefail

# forge script script/deploy/DeployLineRegistry.s.sol:DeployLineRegistry --chain-id 46    --broadcast --verify --slow
# forge script script/deploy/DeployLineRegistry.s.sol:DeployLineRegistry --chain-id 42161 --broadcast --verify --slow --legacy
# forge script script/deploy/DeployLineRegistry.s.sol:DeployLineRegistry --chain-id 1 --broadcast --verify --slow --legacy

# forge script script/deploy/DeployORMPLine.s.sol:DeployORMPLine         --chain-id 46    --broadcast --verify --slow
# forge script script/deploy/DeployORMPLine.s.sol:DeployORMPLine         --chain-id 42161 --broadcast --verify --slow --legacy
# forge script script/deploy/DeployORMPLine.s.sol:DeployORMPLine         --chain-id 1 --broadcast --verify --slow --legacy

# forge script script/deploy/DeployORMPLineExt.s.sol:DeployORMPLineExt     --chain-id 1 --broadcast --verify --slow --legacy
# forge script script/deploy/DeployORMPLineExt.s.sol:DeployORMPLineExt     --chain-id 46          --broadcast --verify
# forge script script/deploy/DeployORMPLineExt.s.sol:DeployORMPLineExt     --chain-id 42161     --legacy --broadcast --verify --skip-simulation

 forge script script/deploy/DeployLineRegistry.s.sol:DeployLineRegistry      --chain-id 421614 --broadcast --verify --slow --legacy
forge script script/deploy/DeployMultiLine.s.sol:DeployMultiLine             --chain-id 421614 --broadcast --verify --slow --legacy
forge script script/deploy/DeployXAccount.s.sol:DeployXAccount               --chain-id 421614 --broadcast --verify --slow --legacy
forge script script/deploy/DeployXAccountFactory.s.sol:DeployXAccountFactory --chain-id 421614 --broadcast --verify --slow --legacy

 forge script script/deploy/DeployLineRegistry.s.sol:DeployLineRegistry      --chain-id 44 --broadcast --verify --slow --legacy
forge script script/deploy/DeployMultiLine.s.sol:DeployMultiLine             --chain-id 44 --broadcast --verify --slow --legacy
forge script script/deploy/DeployXAccount.s.sol:DeployXAccount               --chain-id 44 --broadcast --verify --slow --legacy
forge script script/deploy/DeployXAccountFactory.s.sol:DeployXAccountFactory --chain-id 44 --broadcast --verify --slow --legacy
