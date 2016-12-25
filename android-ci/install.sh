#!/usr/bin/env bash
set -efuxo pipefail

nixEnv="nix-env $NIX_OPTIONS"
nixBuild="nix-build --no-out-link $NIX_OPTIONS"


$nixEnv --file /root --install

# Binaries in the SDK hardcode the linker path
ln --symbolic /nix/var/nix/profiles/default/lib /lib64


for p in curl gnutar gzip
do
    PATH=$($nixBuild '<nixpkgs>' --attr $p)/bin:$PATH
done
mkdir --parents "$ANDROID_HOME"
curl --silent "$SDK_URL" \
| tar --directory "$ANDROID_HOME" --extract --gzip --strip-components=1

echo y | "$ANDROID_HOME/tools/android" update sdk --no-ui --all \
    --filter android-24,build-tools-24.0.1,platform-tools,extra-android-m2repository


nix-store --gc
nix-store --optimize
