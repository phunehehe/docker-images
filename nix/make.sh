#!/usr/bin/env bash
set -efuxo pipefail


# Add nixpkgs

this_dir=$(cd "$(dirname "$0")" && pwd)
rootfs=$this_dir/rootfs
channel=$(git rev-parse --abbrev-ref HEAD)

channels_dir=$rootfs/root/channels
mkdir='mkdir --parents'
$mkdir "$channels_dir"

nixexprs=$channels_dir/$channel
cp -H --recursive "$HOME/.nix-defexpr/channels/$channel" "$nixexprs"

build="nix-build --no-out-link $nixexprs --attr"


# Prepare chroot

# https://github.com/NixOS/nix/issues/697
$mkdir "$rootfs/etc/nix"
echo 'build-users-group =' > "$rootfs/etc/nix/nix.conf"

# nix-build wants /tmp
$mkdir "$rootfs/tmp"

my_chroot() {
  mounts=(dev proc)

  for m in "${mounts[@]}"
  do
    $mkdir "$rootfs/$m"
    sudo mount --bind "/$m" "$rootfs/$m"
  done

  sudo chroot "$rootfs" "$@"

  for m in "${mounts[@]}"
  do sudo umount "$rootfs/$m"
  done
}


# Populate the store

cacert=$($build cacert)

# Nix has multiple outputs, and `out` is not always the default one
nix=$($build nix.out)

wanted_packages=(
  $cacert
  $nix

  # The closure for Nix includes these so we are repeating ourselves a
  # bit to make it easier to install them further down.
  $($build bash)
  $($build coreutils)
)

all_packages=(
  $(nix-store --query --requisites "${wanted_packages[@]}" \
  | sort --unique))

store_dir=$rootfs/nix/store
$mkdir "$store_dir"
for p in "${all_packages[@]}"
do
  cp --recursive "$p" "$store_dir"/
done

nix-store --export "${all_packages[@]}" \
| my_chroot "$nix/bin/nix-store" --import

my_chroot "$nix/bin/nix-env" --install "${wanted_packages[@]}"


# (Bash) scripts want /usr/bin/env
$mkdir "$rootfs/usr/bin"
ln='ln --force --symbolic'
$ln /nix/var/nix/profiles/default/bin/env "$rootfs/usr/bin/"

# Docker wants /bin/sh
$mkdir "$rootfs/bin"
$ln /nix/var/nix/profiles/default/bin/sh "$rootfs/bin/"

# Random applications want these
echo hosts: files dns > "$rootfs/etc/nsswitch.conf"
echo root:x:0:0:root:/root:/bin/sh > "$rootfs/etc/passwd"

# chroot left files unreadable
sudo chown --recursive "$USER" "$rootfs"

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
