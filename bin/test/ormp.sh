#!/usr/bin/env bash

set -eo pipefail

export ORMP_ADDRESS="0x0034607daf9c1dc6628f6e09E81bB232B6603A89";

forge test -vvv --match-contract ORMPLineTest --chain-id 44 --rpc-url https://darwiniacrab-rpc.dwellir.com
