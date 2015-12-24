#!/usr/bin/env bash
set -efuxo pipefail

nix-env --install git
nix-collect-garbage --delete-old
nix-store --optimise
