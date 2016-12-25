{ pkgs ? import <nixpkgs> {}, ... }: pkgs.buildEnv {

  name = "android-env";

  # glibc has colissions with stdenv.cc.cc
  ignoreCollisions = true;

  paths = with pkgs; [
    glibc.out        # aapt   needs ld-linux-x86-64.so.2
    jdk.out
    stdenv.cc.cc.lib # gradle needs libstdc++.so.6
    zlib.out         # aapt   needs libz.so.1
  ];
}
