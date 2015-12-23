FROM alpine

# bash for the script below
# curl for https://github.com/NixOS/nixos-homepage/blob/9858d97a0a9283a778bd04f8de1d1a42b1241b16/nix/install.in#L31
RUN apk add --update bash curl \
 && rm -fr /var/cache/apk/*

COPY ./script.sh /script.sh
RUN /script.sh

ENV BASH_ENV /nix/var/nix/profiles/default/etc/profile.d/nix.sh
