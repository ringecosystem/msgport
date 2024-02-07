#!/usr/bin/env bash

set -eo pipefail

# forge script script/deploy/DeployPortRegistry.s.sol:DeployPortRegistry --chain-id 46    --broadcast --verify --slow
# forge script script/deploy/DeployPortRegistry.s.sol:DeployPortRegistry --chain-id 42161 --broadcast --verify --slow --legacy
# forge script script/deploy/DeployPortRegistry.s.sol:DeployPortRegistry --chain-id 1 --broadcast --verify --slow --legacy

# forge script script/deploy/DeployORMPPort.s.sol:DeployORMPPort         --chain-id 46    --broadcast --verify --slow
# forge script script/deploy/DeployORMPPort.s.sol:DeployORMPPort         --chain-id 42161 --broadcast --verify --slow --legacy
# forge script script/deploy/DeployORMPPort.s.sol:DeployORMPPort         --chain-id 1 --broadcast --verify --slow --legacy

# forge script script/deploy/DeployORMPPortExt.s.sol:DeployORMPPortExt     --chain-id 1 --broadcast --verify --slow --legacy
# forge script script/deploy/DeployORMPPortExt.s.sol:DeployORMPPortExt     --chain-id 46          --broadcast --verify
# forge script script/deploy/DeployORMPPortExt.s.sol:DeployORMPPortExt     --chain-id 42161     --legacy --broadcast --verify --skip-simulation

# forge script script/deploy/DeployORMPPort.s.sol:DeployORMPPort         --chain-id 43       --broadcast --verify --slow --legacy --skip-simulation
# forge script script/deploy/DeployORMPPort.s.sol:DeployORMPPort         --chain-id 421614   --broadcast --verify --slow --legacy --skip-simulation
# forge script script/deploy/DeployORMPPort.s.sol:DeployORMPPort         --chain-id 11155111 --broadcast --verify --slow --legacy

forge script script/deploy/DeployORMPPort.s.sol:DeployORMPPort --chain-id 1     --broadcast --verify --slow
forge script script/deploy/DeployORMPPort.s.sol:DeployORMPPort --chain-id 44    --broadcast --verify --slow
forge script script/deploy/DeployORMPPort.s.sol:DeployORMPPort --chain-id 46    --broadcast --verify --slow
forge script script/deploy/DeployORMPPort.s.sol:DeployORMPPort --chain-id 42161 --broadcast --verify --slow --legacy --skip-simulation
