FROM phunehehe/nix:16.09

# Either JAVA_HOME or which is needed for gradlew to find java
ENV ANDROID_HOME=/root/Android/Sdk/tools \
    JAVA_HOME=/nix/var/nix/profiles/default \
    LD_LIBRARY_PATH=/nix/var/nix/profiles/default/lib

# This needs ANDROID_HOME above to take effect first
ENV PATH=$ANDROID_HOME/tools:$PATH

COPY default.nix install.sh /root/

# Use this to speed up test builds with a local cache
# docker build --build-arg NIX_OPTIONS='--option binary-caches http://10.0.2.2:5000/' --build-arg SDK_URL=http://10.0.2.2:8080/tools_r25.2.3-linux.zip .
ARG NIX_OPTIONS=
ARG SDK_URL=https://dl.google.com/android/repository/tools_r25.2.3-linux.zip

RUN /root/install.sh
