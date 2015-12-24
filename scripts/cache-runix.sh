#!/usr/bin/env bash
set -efuxo pipefail

# Note: no more GC after this
git clone https://gitlab.com/phunehehe/runix.git
./runix/test.sh
rm -rf runix

nix-store --optimise
