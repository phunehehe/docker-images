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

channel=$(git rev-parse --abbrev-ref HEAD)
channels_dir=$rootfs/root/channels
nixexprs=$channels_dir/$channel

# Get the latest release
mkdir --parents "$channels_dir"
cp --recursive "$(readlink --canonicalize "$HOME/.nix-defexpr/channels/$channel")" "$nixexprs"

build="nix-build --no-out-link $nixexprs --attr"
ln='ln --force --symbolic'


# Populate the store

cacert=$($build cacert)

wanted_packages=(
  $cacert
  $($build nix)

  # The closure for Nix includes these so we are repeating ourselves a
  # bit to make it easier to install them further down.
  $($build bash)
  $($build coreutils)
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

nix-env --install "${wanted_packages[*]}" --profile "$state_dir/profiles/default"


# (Bash) scripts want /usr/bin/env
mkdir --parents "$rootfs/usr/bin"
$ln /nix/var/nix/profiles/default/bin/env "$rootfs/usr/bin/"

# nix-build wants /tmp
mkdir --parents "$rootfs/tmp"

# RUN wants /bin/sh
mkdir --parents "$rootfs/bin"
$ln /nix/var/nix/profiles/default/bin/sh "$rootfs/bin/"

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
ENV NIX_PATH=nixpkgs=${nixexprs/$rootfs/} \
    PATH=/nix/var/nix/profiles/default/bin \
    SSL_CERT_FILE=/nix/var/nix/profiles/default/etc/ssl/certs/ca-bundle.crt \
    USER=root
" > "$this_dir/Dockerfile"
