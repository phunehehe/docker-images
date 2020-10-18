let
  fromEnv = var: def:
    let val = builtins.getEnv var; in
    if val != "" then val else def;
in rec {
  shell = "/nix/store/2jysm3dfsgby5sw5jgj43qjrb5v79ms9-bash-4.4-p23/bin/bash";
  coreutils = "/nix/store/w9wc0d31p4z93cbgxijws03j5s2c4gyf-coreutils-8.31/bin";
  bzip2 = "/nix/store/fk8lj79i2jsd8psj3sk9qn9zfhmhf74s-bzip2-1.0.6.0.1-bin/bin/bzip2";
  gzip = "/nix/store/ljjm1r3hn8wmlh5gp38vms13hipjmygy-gzip-1.10/bin/gzip";
  xz = "/nix/store/9x8vjfxjz2wv7xb90vwv5i697z6gr7d2-xz-5.2.5-bin/bin/xz";
  tar = "/nix/store/1yyn6aar4kw3vjn2fs5xv5jxywdly8wn-gnutar-1.32/bin/tar";
  tarFlags = "--warning=no-timestamp";
  tr = "/nix/store/w9wc0d31p4z93cbgxijws03j5s2c4gyf-coreutils-8.31/bin/tr";
  nixBinDir = fromEnv "NIX_BIN_DIR" "/nix/store/jjmar1q8k7l25mdmnhpxs9nwaa38rpnk-nix-2.3.7/bin";
  nixPrefix = "/nix/store/jjmar1q8k7l25mdmnhpxs9nwaa38rpnk-nix-2.3.7";
  nixLibexecDir = fromEnv "NIX_LIBEXEC_DIR" "/nix/store/jjmar1q8k7l25mdmnhpxs9nwaa38rpnk-nix-2.3.7/libexec";
  nixLocalstateDir = "/nix/var";
  nixSysconfDir = "/etc";
  nixStoreDir = fromEnv "NIX_STORE_DIR" "/nix/store";

  # If Nix is installed in the Nix store, then automatically add it as
  # a dependency to the core packages. This ensures that they work
  # properly in a chroot.
  chrootDeps =
    if dirOf nixPrefix == builtins.storeDir then
      [ (builtins.storePath nixPrefix) ]
    else
      [ ];
}
