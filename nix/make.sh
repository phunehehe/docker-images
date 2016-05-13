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
channel=nixos-16.03
nixpkgs=$rootfs/$channel
store_dir=$rootfs/nix/store
state_dir=$rootfs/nix/var/nix

# Get the latest release
mkdir --parents "$rootfs"
cp --recursive "$(readlink --canonicalize ~/.nix-defexpr/channels/$channel)" "$nixpkgs"

build="nix-build --no-out-link $nixpkgs --attr"
ln='ln --force --symbolic'


# Populate the store

cacert=$($build cacert)

wanted_packages=(
  $cacert
  $($build nix)

  # The closure for Nix includes these so we are repeating ourselves a
  # bit to make it easier to install them further down.
  $($build bash)
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


# Pack up (Git doesn't like empty dirs like /tmp so we can't just leave rootfs
# as is)
tar --create --verbose --xz \
    --directory "$rootfs" \
    --file "$this_dir/rootfs.tar.xz" \
    .

echo "
FROM scratch
ADD rootfs.tar.xz /
ENV NIX_PATH=nixpkgs=/$channel \
    PATH=/nix/var/nix/profiles/default/bin \
    SSL_CERT_FILE=/nix/var/nix/profiles/default/etc/ssl/certs/ca-bundle.crt \
    USER=root
RUN $env PATH=$bootstrap_path \
         nix-env --install ${wanted_packages[*]}
" > "$this_dir/Dockerfile"
