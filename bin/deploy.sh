#!/usr/bin/env bash

set -eo pipefail

forge script script/Deploy.s.sol:Deploy --chain-id 43     --broadcast --verify
forge script script/Deploy.s.sol:Deploy --chain-id 421613 --broadcast --verify
