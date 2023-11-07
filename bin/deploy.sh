#!/usr/bin/env bash

set -eo pipefail

forge script script/deploy/DeployLineRegistry.s.sol:DeployLineRegistry --chain-id 44     --broadcast --verify
forge script script/deploy/DeployLineRegistry.s.sol:DeployLineRegistry --chain-id 421614 --broadcast --verify --skip-simulation

forge script script/deploy/DeployORMPLine.s.sol:DeployORMPLine         --chain-id 44     --broadcast --verify
forge script script/deploy/DeployORMPLine.s.sol:DeployORMPLine         --chain-id 421614 --broadcast --verify --skip-simulation
