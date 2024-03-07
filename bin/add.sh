#!/usr/bin/env bash

set -eo pipefail

export PORT_KEY="ORMPPORT_ADDR"
forge script script/config/RegistryPort.s.sol:RegistryPort --sig "run(uint256[],string)" "[43,421614,11155111]" --chain-id 43       "ORMP" --broadcast -g 200
forge script script/config/RegistryPort.s.sol:RegistryPort --sig "run(uint256[],string)" "[43,421614,11155111]" --chain-id 421614   "ORMP" --broadcast --slow --legacy --skip-simulation
forge script script/config/RegistryPort.s.sol:RegistryPort --sig "run(uint256[],string)" "[43,421614,11155111]" --chain-id 11155111 "ORMP" --broadcast

export PORT_KEY="MULTIPORT_ADDR"
forge script script/config/RegistryPort.s.sol:RegistryPort --sig "run(uint256[],string)" "[43,421614,11155111]" --chain-id 43       "Multi" --broadcast -g 200
forge script script/config/RegistryPort.s.sol:RegistryPort --sig "run(uint256[],string)" "[43,421614,11155111]" --chain-id 421614   "Multi" --broadcast --slow --legacy --skip-simulation
forge script script/config/RegistryPort.s.sol:RegistryPort --sig "run(uint256[],string)" "[43,421614,11155111]" --chain-id 11155111 "Multi" --broadcast

export PORT_KEY="XACCOUNTFACTORY_ADDR"
forge script script/config/RegistryPort.s.sol:RegistryPort --sig "run(uint256[],string)" "[43,421614,11155111]" --chain-id 43       "xAccountFactory" --broadcast -g 200
forge script script/config/RegistryPort.s.sol:RegistryPort --sig "run(uint256[],string)" "[43,421614,11155111]" --chain-id 421614   "xAccountFactory" --broadcast --slow --legacy --skip-simulation
forge script script/config/RegistryPort.s.sol:RegistryPort --sig "run(uint256[],string)" "[43,421614,11155111]" --chain-id 11155111 "xAccountFactory" --broadcast
