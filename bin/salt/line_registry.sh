#!/usr/bin/env bash

set -eo pipefail

deployer=0x0f14341A7f464320319025540E8Fe48Ad0fe5aec
args=$(ethabi encode params -v address ${deployer:2})
. $PWD/bin/salt.sh "LineRegistry" "$args"
