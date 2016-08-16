FROM phunehehe/nix:16.03
ENV ANDROID_HOME=/root/android-sdk-linux \
    JAVA_HOME=/nix/var/nix/profiles/default \
    LD_LIBRARY_PATH=/nix/var/nix/profiles/default/lib
ADD ./install.sh /root/install.sh
RUN /root/install.sh
