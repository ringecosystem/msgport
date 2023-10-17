#!/usr/bin/env bash

set -eo pipefail

deployer=0x0f14341A7f464320319025540E8Fe48Ad0fe5aec
create2=0x914d7Fec6aaC8cd542e72Bca78B30650d45643d7

out_dir=$PWD/artifacts
bytecode=$(jq -r '.bytecode.object' $out_dir/LineRegistry.sol/LineRegistry.json)

args=$(ethabi encode params -v address ${deployer:2})
initcode=$bytecode$args

out=$(cast create2 -i $initcode -d $create2 --starts-with "00" | grep -E '(Address:|Salt:)')
addr=$(echo $out | awk '{print $2}' )
salt=$(seth --to-uint256 $(echo $out | awk '{print $4}' ))
echo -e "LineRegistry: \n Addr: $addr \n Salt: $salt"
