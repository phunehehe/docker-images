FROM phunehehe/nix:16.03
RUN nix-env --file '<nixpkgs>' --install android-sdk openjdk which \
 && nix-env --file '<nixpkgs>' --install --attr stdenv.cc.cc \
 && nix-store --gc \
 && nix-store --optimize
ENV ANDROID_HOME=/nix/var/nix/profiles/default/libexec/android-sdk-linux \
    LD_LIBRARY_PATH=/nix/var/nix/profiles/default/lib
