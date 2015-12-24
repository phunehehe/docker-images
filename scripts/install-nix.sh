#!/usr/bin/env sh
# ^ Not using bash here because we don't have it yet

apk add --update-cache bash curl

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
