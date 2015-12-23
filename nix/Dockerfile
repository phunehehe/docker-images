FROM alpine

# Nix install script wants $USER
ENV USER root

# It also wants these
RUN apk add --update bash curl \
 && rm -fr /var/cache/apk/*

# For the build-users-group hack see https://github.com/NixOS/nix/issues/697
# /nix is created beforehand so that the script won't try to use sudo
RUN mkdir /etc/nix \
 && echo 'build-users-group =' > /etc/nix/nix.conf \
 && mkdir /nix \
 && curl https://nixos.org/nix/install | sh \
 && . /nix/var/nix/profiles/default/etc/profile.d/nix.sh \
 && nix-channel --update \
 && nix-env --upgrade \
 && nix-collect-garbage --delete-old \
 && nix-store --optimise

# Busybox's sh has
# PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
# It's convenient to hijack /usr/local/sbin because it doesn't exist
RUN ln -fsT /nix/var/nix/profiles/default/bin /usr/local/sbin
