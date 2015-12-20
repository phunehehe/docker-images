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
 \
 && nix-env --install git \
 && nix-collect-garbage --delete-old \
 \
 && git clone https://gitlab.com/phunehehe/runix.git \
 && ./runix/test.sh \
 && rm -fr runix \
 \
 && nix-store --optimise

RUN ln -s /nix/var/nix/profiles/default/etc/profile.d/nix.sh /root/.bashrc
