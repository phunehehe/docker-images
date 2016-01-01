FROM alpine
ENV BASH_ENV /nix/var/nix/profiles/default/etc/profile.d/nix.sh
COPY ./install.sh .
RUN ./install.sh
