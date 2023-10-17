.PHONY: all fmt clean test deploy
.PHONY: tools ethabi foundry

-include .env

all    :; @forge build
fmt    :; @forge fmt
clean  :; @forge clean
test   :; @forge test

tools  :  foundry ethabi
ethabi :; cargo install ethabi-cli
foundry:; curl -L https://foundry.paradigm.xyz | bash

deploy :; @./bin/deploy.sh
