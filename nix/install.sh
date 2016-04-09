#!/usr/bin/env sh
# ^ Not using bash here because we don't have it yet

apk add --update-cache bash curl
rm -fr /var/cache/apk/*

# https://github.com/NixOS/nix/issues/697
mkdir /etc/nix
echo 'build-users-group =' > /etc/nix/nix.conf

# Install script wants $USER
USER=$(whoami)
export USER

# So the script won't try to use sudo
mkdir /nix

curl https://nixos.org/nix/install | sh

# BASH_ENV is defined in Dockerfile
# shellcheck source=/dev/null
. "$BASH_ENV"

nix-channel --add https://nixos.org/channels/nixos-16.03/
nix-channel --update
nix-env --upgrade
nix-collect-garbage --delete-old
nix-store --optimise
