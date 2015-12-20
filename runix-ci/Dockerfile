FROM folsomlabs/base-nix

RUN nix-env --install git
RUN nix-collect-garbage --delete-old

RUN git clone https://gitlab.com/phunehehe/runix.git
RUN ./runix/test.sh

RUN nix-store --optimise
