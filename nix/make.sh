#!/usr/bin/env bash
set -efuxo pipefail


ln='ln --force --symbolic'
mkdir='mkdir --parents'

mounts=(dev dev/pts proc)


unmount_all() {
  rootfs=$1
  [[ -e $rootfs ]] || return 0

  # https://stackoverflow.com/a/11789688/168034
  IFS=$'\n'
  mapfile -t sorted < <(sort --reverse <<<"${mounts[*]}")
  unset IFS

  for m in "${sorted[@]}"
  do
    d="$rootfs/$m"
    [[ -e $d ]] || continue

    findmnt "$d" && sudo umount "$d"
    [[ -z $(find "$d" -mindepth 1) ]] || exit 1
  done
}


run_in_chroot() {
  rootfs=$1
  shift 1

  for m in "${mounts[@]}"
  do
    $mkdir "$rootfs/$m"
    sudo mount --bind "/$m" "$rootfs/$m"
  done

  sudo chroot "$rootfs" "$@"
  unmount_all "$rootfs"
}


build() {
  tag=$1
  url=$2

  this_dir=$(cd "$(dirname "$0")" && pwd)
  rootfs=$this_dir/$tag/rootfs
  nixexprs=$rootfs/root/.nix-defexpr
  store_dir=$rootfs/nix/store

  nix_build="nix-build --no-out-link $nixexprs --attr"


  # Clean up any previous run
  unmount_all "$rootfs"
  [[ -e $rootfs ]] && sudo rm --recursive "$rootfs"

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
  $mkdir "$rootfs/root/.nixpkgs"
  echo '{ allowUnfree = true; }' > "$rootfs/root/.nixpkgs/config.nix"

  if [[ ! -f $this_dir/$tag/Dockerfile ]]
  then cp "$this_dir/latest/Dockerfile" "$this_dir/$tag/Dockerfile"
  fi

  sudo chown --recursive "$USER" "$rootfs"
}


build latest https://nixos.org/channels/nixpkgs-unstable/nixexprs.tar.xz
build 20.03 https://nixos.org/channels/nixos-20.03/nixexprs.tar.xz
