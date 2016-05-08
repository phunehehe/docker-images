#!/usr/bin/env bash
set -efuxo pipefail


find_in_rootfs() {
  rootfs=$1
  name=$2
  result=$(find "$rootfs" -name "$name")
  echo "${result/$rootfs/}"
}


this_dir=$(cd "$(dirname "$0")" && pwd)
rootfs=$this_dir/rootfs
store_dir=$rootfs/nix/store
state_dir=$rootfs/nix/var/nix

# Get the latest release, something like
# nixexprs=https://nixos.org/releases/nixos/16.03/nixos-16.03.714.69420c5/nixexprs.tar.xz
# FIXME: this does not seem to be cached
nixexprs=$(
  curl --head --silent https://nixos.org/channels/nixos-16.03/nixexprs.tar.xz \
  | awk '/Location/ {print $2}' \
  | tr --delete '[:space:]')

build="nix-build --no-out-link $nixexprs --attr"
ln='ln --force --symbolic'


# Populate the store

cacert=$($build cacert)

# The closure for Nix includes Bash so we are repeating ourselves a bit
# here. Makes it easier to install Bash further down.
wanted_packages=(
  $cacert
  $($build bash)
  $($build nix)

  # Needed to unpack nixexprs, see FIXME above
  $($build gnutar)
  $($build xz)
)
all_packages=(
  $(nix-store --query --requisites "${wanted_packages[@]}" \
  | sort --unique))

bootstrap_path=
mkdir --parents "$store_dir"
for p in "${all_packages[@]}"
do
  bin=$p/bin
  [[ -e $bin ]] && bootstrap_path=$bin:$bootstrap_path
  cp --recursive "$p" "$store_dir"/
done

nix-store --export "${all_packages[@]}" \
| env NIX_STATE_DIR="$state_dir" nix-store --import


# (Bash) scripts want /usr/bin/env
env=$(find_in_rootfs "$rootfs" env)
mkdir --parents "$rootfs/usr/bin"
$ln "$env" "$rootfs/usr/bin/"

# nix-build wants /tmp
mkdir --parents "$rootfs/tmp"

# RUN wants /bin/sh
sh=$(find_in_rootfs "$rootfs" sh)
mkdir --parents "$rootfs/bin"
$ln "$sh" "$rootfs/bin/"

# https://github.com/NixOS/nix/issues/697
mkdir --parents "$rootfs/etc/nix"
echo 'build-users-group =' > "$rootfs/etc/nix/nix.conf"


echo "
FROM scratch
ADD rootfs /
ENV NIX_PATH=nixpkgs=$nixexprs \
    PATH=/nix/var/nix/profiles/default/bin \
    SSL_CERT_FILE=/nix/var/nix/profiles/default/etc/ssl/certs/ca-bundle.crt \
    USER=root
RUN $env PATH=$bootstrap_path \
         SSL_CERT_FILE=$cacert/etc/ssl/certs/ca-bundle.crt \
         nix-env --install ${wanted_packages[*]}
" > "$this_dir/Dockerfile"
