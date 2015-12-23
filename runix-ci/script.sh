#!/usr/bin/env bash
set -efuxo pipefail

# https://github.com/NixOS/nix/issues/697
mkdir /etc/nix
echo 'build-users-group =' > /etc/nix/nix.conf

# Install script wants $USER
USER=$(whoami)
export USER

# So the script won't try to use sudo
mkdir /nix

curl https://nixos.org/nix/install | sh
. /nix/var/nix/profiles/default/etc/profile.d/nix.sh

nix-channel --update
nix-env --upgrade
nix-env --install git
nix-collect-garbage --delete-old

# Build Runix to cache dependencies (no more GC after this)
git clone https://gitlab.com/phunehehe/runix.git
./runix/test.sh
rm -rf runix

nix-store --optimise
