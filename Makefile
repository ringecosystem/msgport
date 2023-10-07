.PHONY: all clean test
.PHONY: tools foundry

-include .env

all    :; forge build
clean  :; forge clean
test   :; forge test

tools  :  foundry
foundry:; curl -L https://foundry.paradigm.xyz | bash
