#!/usr/bin/env bash
set -efuxo pipefail


run_in_chroot() {

  rootfs=$1
  shift 1

  mounts=(dev proc)

  for m in "${mounts[@]}"
  do
    $mkdir "$rootfs/$m"
    sudo mount --bind "/$m" "$rootfs/$m"
  done

  sudo chroot "$rootfs" "$@"

  for m in "${mounts[@]}"
  do
    sudo umount "$rootfs/$m"
    rmdir "$rootfs/$m"
  done

  sudo chown --recursive "$USER" "$rootfs"
}


build() {

  tag=$1
  url=$2

  ln='ln --force --symbolic'
  mkdir='mkdir --parents'

  this_dir=$(cd "$(dirname "$0")" && pwd)
  rootfs=$this_dir/$tag/rootfs
  nixexprs=$rootfs/root/.nix-defexpr
  store_dir=$rootfs/nix/store

  nix_build="nix-build --no-out-link $nixexprs --attr"


  # Cleanup any previous run
  if [[ -e $rootfs ]]
  then
    chmod u+w --recursive "$rootfs"
    rm --force --recursive "$rootfs"
  fi

  # Add nixpkgs
  $mkdir "$nixexprs"
  curl --location --silent "$url" \
  | tar --extract --xz --directory "$nixexprs" --strip-components 1

  # https://github.com/NixOS/nix/issues/697
  $mkdir "$rootfs/etc/nix"
  echo 'build-users-group =' > "$rootfs/etc/nix/nix.conf"

  # nix-build wants /tmp
  $mkdir "$rootfs/tmp"
  touch "$rootfs/tmp/.gitignore"


  # Populate the store

  # Nix has multiple outputs, and `out` is not always the default one
  nix=$($nix_build nix.out)

  wanted_packages=(
    $($nix_build bash)
    $($nix_build cacert)
    $($nix_build coreutils)
    $nix
  )

  all_packages=($(
    nix-store --query --requisites "${wanted_packages[@]}" \
    | sort --unique
  ))

  $mkdir "$store_dir"
  for p in "${all_packages[@]}"
  do
    cp --recursive "$p" "$store_dir"/
  done

  nix-store --export "${all_packages[@]}" \
  | run_in_chroot "$rootfs" "$nix/bin/nix-store" --import

  run_in_chroot "$rootfs" "$nix/bin/nix-env" --install "${wanted_packages[@]}"
  run_in_chroot "$rootfs" "$nix/bin/nix-store" --gc
  run_in_chroot "$rootfs" "$nix/bin/nix-store" --optimize


  # (Bash) scripts want /usr/bin/env
  $mkdir "$rootfs/usr/bin"
  $ln /nix/var/nix/profiles/default/bin/env "$rootfs/usr/bin/"

  # Docker wants /bin/sh
  $mkdir "$rootfs/bin"
  $ln /nix/var/nix/profiles/default/bin/sh "$rootfs/bin/"

  # Random applications want these
  echo hosts: files dns > "$rootfs/etc/nsswitch.conf"
  echo root:x:0:0:root:/root:/bin/sh > "$rootfs/etc/passwd"
}


build 16.03 https://nixos.org/channels/nixos-16.03/nixexprs.tar.xz
build latest https://nixos.org/channels/nixos-unstable/nixexprs.tar.xz
