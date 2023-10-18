#!/usr/bin/env bash

set -eo pipefail

deployer=0x0f14341A7f464320319025540E8Fe48Ad0fe5aec
ormp=0x0034607daf9c1dc6628f6e09E81bB232B6603A89
name="ORMP"
args=$(ethabi encode params \
  -v address ${deployer:2} \
  -v address ${ormp:2} \
  -v string "$name" \
)
. $PWD/bin/salt.sh "ORMPLine" "$args"
