#!/usr/bin/env bash

# aapt wants libz.so.1 from zlib
# gradle wants libstdc++.so.6 from stdenv.cc.cc
# jdk for obvious reasons
nix-env --file '<nixpkgs>' --install --attr jdk stdenv.cc.cc zlib

# aapt wants /lib64/ld-linux-x86-64.so.2 from glibc
# glibc has colissions with stdenv.cc.cc
nix-env --file '<nixpkgs>' --set-flag priority 1 gcc
nix-env --file '<nixpkgs>' --install --attr glibc
ln --symbolic /nix/var/nix/profiles/default/lib /lib64

for p in curl.bin gnutar gzip
do
    PATH=$(nix-build '<nixpkgs>' --attr $p)/bin:$PATH
done
mkdir --parents "$ANDROID_HOME"
curl --silent https://dl.google.com/android/android-sdk_r24.4.1-linux.tgz \
| tar --directory "$ANDROID_HOME" --extract --gzip --strip-components=1

echo y | "$ANDROID_HOME/tools/android" update sdk --no-ui --all \
    --filter android-24,build-tools-24.0.1,platform-tools,extra-android-m2repository

nix-store --gc
nix-store --optimize
