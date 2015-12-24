FROM alpine

ENV BASH_ENV /nix/var/nix/profiles/default/etc/profile.d/nix.sh

ADD https://raw.githubusercontent.com/phunehehe/docker-images/master/scripts/install-nix.sh \
    https://raw.githubusercontent.com/phunehehe/docker-images/master/scripts/install-git.sh \
    https://raw.githubusercontent.com/phunehehe/docker-images/master/scripts/gc.sh \
    ./scripts/

RUN chmod +x ./scripts/install-nix.sh && ./scripts/install-nix.sh \
 && chmod +x ./scripts/install-git.sh && ./scripts/install-git.sh \
 && chmod +x ./scripts/gc.sh && ./scripts/gc.sh
