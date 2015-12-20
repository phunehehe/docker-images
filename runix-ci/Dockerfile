FROM folsomlabs/base-nix

# Git is most likely needed to build Runix apps
RUN nix-env --install git

RUN nix-collect-garbage --delete-old

# Build the Runix test to populate the Nix store
# Do not GC after this
RUN git clone https://gitlab.com/phunehehe/runix.git
RUN ./runix/test.sh
RUN rm --force --recursive runix

RUN nix-store --optimise
