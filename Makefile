.PHONY: all fmt clean test
.PHONY: tools ethabi foundry

-include .env

all    :; @forge build
fmt    :; @forge fmt
clean  :; @forge clean
test   :; @forge test

tools  :  foundry ethabi
ethabi :; cargo install ethabi-cli
foundry:; curl -L https://foundry.paradigm.xyz | bash


salt   :; @./bin/salt.sh
deploy :; @./bin/deploy.sh
