# GIT_SSL_CAINFO is needed for 16.03 (patched in unstable)
FROM scratch
ADD rootfs /
ENV GIT_SSL_CAINFO=/nix/var/nix/profiles/default/etc/ssl/certs/ca-bundle.crt \
    NIX_PATH=nixpkgs=/root/.nix-defexpr \
    PATH=/nix/var/nix/profiles/default/bin \
    SSL_CERT_FILE=/nix/var/nix/profiles/default/etc/ssl/certs/ca-bundle.crt \
    USER=root
