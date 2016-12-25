FROM phunehehe/nix:16.09

# Either JAVA_HOME or which is needed for gradlew to find java
ENV ANDROID_HOME=/root/android-sdk-linux \
    JAVA_HOME=/nix/var/nix/profiles/default \
    LD_LIBRARY_PATH=/nix/var/nix/profiles/default/lib

COPY default.nix install.sh /root/

# Use this to speed up test builds with a local Nix cache
# docker build --build-arg NIX_OPTIONS='--option binary-caches http://10.0.2.2:5000/' .
ARG NIX_OPTIONS=

# Use this to speed up test builds with a local HTTP cache
# docker build --build-arg SDK_URL=http://10.0.2.2:8080/android-sdk_r24.4.1-linux.tgz .
ARG SDK_URL=https://dl.google.com/android/android-sdk_r24.4.1-linux.tgz

RUN /root/install.sh
