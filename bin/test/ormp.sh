#!/usr/bin/env bash

set -eo pipefail

export ORMP_ADDRESS="0x00000000001523057a05d6293C1e5171eE33eE0A";

forge test -vvv --match-contract ORMPLineTest --chain-id 44
