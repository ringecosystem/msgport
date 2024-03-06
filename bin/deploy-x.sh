#!/usr/bin/env bash

set -eo pipefail

forge script script/deploy/DeployORMPPort.s.sol:DeployORMPPort --chain-id 81457   --broadcast --verify --legacy --with-gas-price 1060000
