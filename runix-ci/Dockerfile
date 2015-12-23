FROM phunehehe/nix

RUN nix-env --install git nss-cacert \
 && nix-collect-garbage --delete-old \
 && nix-store --optimise

RUN mkdir -p /etc/ssl/certs \
 && ln -s /nix/var/nix/profiles/default/etc/ssl/certs/ca-bundle.crt /etc/ssl/certs

RUN git clone https://gitlab.com/phunehehe/runix.git \
 && ./runix/test.sh \
 && rm -rf runix
