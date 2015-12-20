FROM phunehehe/nix

RUN nix-env --install git \
 && nix-collect-garbage --delete-old \
 && nix-store --optimise

RUN git clone https://gitlab.com/phunehehe/runix.git \
 && ./runix/test.sh \
 && rm -rf runix
