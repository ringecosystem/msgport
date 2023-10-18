#!/usr/bin/env bash

set -eo pipefail

create2=0x914d7Fec6aaC8cd542e72Bca78B30650d45643d7

contract=${1:?}
args=${2:?}
out_dir=$PWD/out
bytecode=$(jq -r '.bytecode.object' $out_dir/$contract.sol/$contract.json)

initcode=$bytecode$args

out=$(cast create2 -i $initcode -d $create2 --starts-with "00000000000000" | grep -E '(Address:|Salt:)')
addr=$(echo $out | awk '{print $2}' )
salt=$(cast --to-uint256 $(echo $out | awk '{print $4}' ))
echo -e "$contract: \n Addr: $addr \n Salt: $salt"
