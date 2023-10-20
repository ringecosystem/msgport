.PHONY: all fmt clean test deploy verify
.PHONY: tools ethabi foundry sync add config

-include .env

all    :; @forge build --force
fmt    :; @forge fmt
clean  :; @forge clean
test   :; @forge test

sync   :; @git submodule update --recursive

tools  :  foundry ethabi
ethabi :; cargo install ethabi-cli
foundry:; curl -L https://foundry.paradigm.xyz | bash

deploy :; @./bin/deploy.sh
config :; @./bin/config.sh
verify :; @./bin/verify.sh
add    :; @./bin/add.sh
