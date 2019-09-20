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
    "$($nix_build bash)"
    "$($nix_build cacert)"
    "$($nix_build coreutils)"
    "$nix"
  )

  mapfile -t all_packages < <(
    nix-store --query --requisites "${wanted_packages[@]}" \
    | sort --unique
  )

  $mkdir "$store_dir"
  for p in "${all_packages[@]}"
  do
    cp --recursive "$p" "$store_dir"/
  done

  nix-store --export "${all_packages[@]}" \
  | run_in_chroot "$rootfs" "$nix/bin/nix-store" --import

  # Disable sandbox to avoid https://github.com/NixOS/nix/issues/2633
  # Suggested solutions don't seem to work
  run_in_chroot "$rootfs" "$nix/bin/nix-env" --option sandbox false --install "${wanted_packages[@]}"

  run_in_chroot "$rootfs" "$nix/bin/nix-store" --gc
  run_in_chroot "$rootfs" "$nix/bin/nix-store" --optimize


  # (Bash) scripts want /usr/bin/env
  $mkdir "$rootfs/usr/bin"
  $ln /nix/var/nix/profiles/default/bin/env "$rootfs/usr/bin/"

  # Docker wants /bin/sh
  $mkdir "$rootfs/bin"
  $ln /nix/var/nix/profiles/default/bin/sh "$rootfs/bin/"

  # Random applications want these
  touch "$rootfs/etc/nsswitch.conf"
  touch "$rootfs/etc/services"

  # Because who wants builds to fail on unfree stuff anyway
  mkdir "$rootfs/root/.nixpkgs"
  echo '{ allowUnfree = true; }' > "$rootfs/root/.nixpkgs/config.nix"

  [[ -f $this_dir/$tag/Dockerfile ]] \
    || cp "$this_dir/latest/Dockerfile" "$this_dir/$tag/Dockerfile"
}


build latest https://nixos.org/channels/nixpkgs-unstable/nixexprs.tar.xz
build 19.03 https://nixos.org/channels/nixos-19.03/nixexprs.tar.xz
