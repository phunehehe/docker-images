#!/usr/bin/env bash
set -efuxo pipefail

rm -fr /var/cache/apk/*

nix-collect-garbage --delete-old
nix-store --optimise
