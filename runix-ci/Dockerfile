FROM folsomlabs/base-nix
RUN {

    nix-env --install git
    nix-collect-garbage --delete-old

    # Build the Runix test to populate the Nix store
    # Do not GC after this
    git clone https://gitlab.com/phunehehe/runix.git
    ./runix/test.sh
    rm --force --recursive runix

    nix-store --optimise
}
