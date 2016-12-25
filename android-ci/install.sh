#!/usr/bin/env bash
set -efuxo pipefail

nixEnv="nix-env $NIX_OPTIONS"
nixBuild="nix-build --no-out-link $NIX_OPTIONS"


$nixEnv --file /root --install

# Binaries in the SDK hardcode the linker path
ln --symbolic /nix/var/nix/profiles/default/lib /lib64


for p in curl.bin unzip
do
    PATH=$($nixBuild '<nixpkgs>' --attr $p)/bin:$PATH
done
mkdir --parents "$ANDROID_HOME"

zip=sdk.zip
curl --silent "$SDK_URL" --output $zip
unzip $zip -d $ANDROID_HOME
rm $zip


echo y \
| "$ANDROID_HOME/tools/android" update sdk --no-ui --all \
    --filter android-24,build-tools-24.0.1,platform-tools,extra-android-m2repository


nix-store --gc
nix-store --optimize
