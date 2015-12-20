FROM nixos/nix
RUN nix-env --install bash git \
 && git clone https://gitlab.com/phunehehe/runix.git \
 && ./runix/test.sh \
 && rm -fr runix
