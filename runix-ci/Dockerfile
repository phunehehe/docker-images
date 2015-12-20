FROM folsomlabs/base-nix
RUN set -efuxo pipefail \
 \
 && nix-env --install git \
 && nix-collect-garbage --delete-old \
 \
 && git clone https://gitlab.com/phunehehe/runix.git \
 && ./runix/test.sh \
 && rm --force --recursive runix \
 \
 && nix-store --optimise
}
