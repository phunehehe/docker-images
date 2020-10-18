{ pkgs, haskellLib }:

with haskellLib;

self: super: {

  # This compiler version needs llvm 7.x.
  llvmPackages = pkgs.llvmPackages_7;

  # Disable GHC 8.8.x core libraries.
  array = null;
  base = null;
  binary = null;
  bytestring = null;
  Cabal = null;
  containers = null;
  deepseq = null;
  directory = null;
  filepath = null;
  ghc-boot = null;
  ghc-boot-th = null;
  ghc-compact = null;
  ghc-heap = null;
  ghc-prim = null;
  ghci = null;
  haskeline = null;
  hpc = null;
  integer-gmp = null;
  libiserv = null;
  mtl = null;
  parsec = null;
  pretty = null;
  process = null;
  rts = null;
  stm = null;
  template-haskell = null;
  terminfo = null;
  text = null;
  time = null;
  transformers = null;
  unix = null;
  xhtml = null;

  # Hasura 1.3.1
  # Because of ghc-heap-view, profiling needs to be disabled.
  graphql-engine = overrideCabal (super.graphql-engine) (drv: {
     # GHC 8.8.x needs a revert of https://github.com/hasura/graphql-engine/commit/a77bb0570f4210fb826985e17a84ddcc4c95d3ea
     patches = [ ./patches/hasura-884-compat.patch ];
  });

  # GHC 8.8.x can build haddock version 2.23.*
  haddock = self.haddock_2_23_1;
  haddock-api = self.haddock-api_2_23_1;

  # These builds need Cabal 3.2.x.
  cabal2spec = super.cabal2spec.override { Cabal = self.Cabal_3_2_0_0; };
  cabal-install = super.cabal-install.overrideScope (self: super: { Cabal = self.Cabal_3_2_0_0; });

  # Ignore overly restrictive upper version bounds.
  aeson-diff = doJailbreak super.aeson-diff;
  async = doJailbreak super.async;
  ChasingBottoms = doJailbreak super.ChasingBottoms;
  chell = doJailbreak super.chell;
  Diff = dontCheck super.Diff;
  doctest = doJailbreak super.doctest;
  hashable = doJailbreak super.hashable;
  hashable-time = doJailbreak super.hashable-time;
  hledger-lib = doJailbreak super.hledger-lib;  # base >=4.8 && <4.13, easytest >=0.2.1 && <0.3
  integer-logarithms = doJailbreak super.integer-logarithms;
  lucid = doJailbreak super.lucid;
  parallel = doJailbreak super.parallel;
  quickcheck-instances = doJailbreak super.quickcheck-instances;
  setlocale = doJailbreak super.setlocale;
  split = doJailbreak super.split;
  system-fileio = doJailbreak super.system-fileio;
  tasty-expected-failure = doJailbreak super.tasty-expected-failure;
  tasty-hedgehog = doJailbreak super.tasty-hedgehog;
  test-framework = doJailbreak super.test-framework;
  th-expand-syns = doJailbreak super.th-expand-syns;
  # TODO: remove when upstream accepts https://github.com/snapframework/io-streams-haproxy/pull/17
  io-streams-haproxy = doJailbreak super.io-streams-haproxy; # base >=4.5 && <4.13
  snap-server = doJailbreak super.snap-server;
  exact-pi = doJailbreak super.exact-pi;
  time-compat = doJailbreak super.time-compat;
  http-media = doJailbreak super.http-media;
  servant-server = doJailbreak super.servant-server;
  foundation = dontCheck super.foundation;
  vault = dontHaddock super.vault;

  # https://github.com/snapframework/snap-core/issues/288
  snap-core = overrideCabal super.snap-core (drv: { prePatch = "substituteInPlace src/Snap/Internal/Core.hs --replace 'fail   = Fail.fail' ''"; });

  # Upstream ships a broken Setup.hs file.
  csv = overrideCabal super.csv (drv: { prePatch = "rm Setup.hs"; });

  # https://github.com/kowainik/relude/issues/241
  relude = dontCheck super.relude;

  # The tests for semver-range need to be updated for the MonadFail change in
  # ghc-8.8:
  # https://github.com/adnelson/semver-range/issues/15
  semver-range = dontCheck super.semver-range;

  # The current version 2.14.2 does not compile with ghc-8.8.x or newer because
  # of issues with Cabal 3.x.
  darcs = dontDistribute super.darcs;

  # Only 0.7 is compatible with ghc 8.7 https://hackage.haskell.org/package/apply-refact/changelog
  apply-refact = super.apply-refact_0_7_0_0;

  # The package needs the latest Cabal version.
  cabal-install-parsers = super.cabal-install-parsers.overrideScope (self: super: { Cabal = self.Cabal_3_2_0_0; });

  # cabal-fmt requires Cabal3
  cabal-fmt = super.cabal-fmt.override { Cabal = self.Cabal_3_2_0_0; };

  # liquidhaskell does not support ghc version 8.8.x.
  liquid = markBroken super.liquid;
  liquid-base = markBroken super.liquid-base;
  liquid-bytestring = markBroken super.liquid-bytestring;
  liquid-containers = markBroken super.liquid-containers;
  liquid-ghc-prim = markBroken super.liquid-ghc-prim;
  liquid-parallel = markBroken super.liquid-parallel;
  liquid-platform = markBroken super.liquid-platform;
  liquid-prelude = markBroken super.liquid-prelude;
  liquid-vector = markBroken super.liquid-vector;
  liquidhaskell = markBroken super.liquidhaskell;

}