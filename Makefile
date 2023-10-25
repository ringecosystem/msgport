.PHONY: all fmt clean test deploy verify
.PHONY: tools foundry add config sync create3

-include .env

all    :; @forge build --force
fmt    :; @forge fmt
clean  :; @forge clean
test   :; @forge test

sync   :; @git submodule update --recursive

tools  :  foundry create3
create3:; @cargo install --git https://github.com/darwinia-network/create3-deploy -f
foundry:; curl -L https://foundry.paradigm.xyz | bash

deploy :; @./bin/deploy.sh
config :; @./bin/config.sh
verify :; @./bin/verify.sh
add    :; @./bin/add.sh
