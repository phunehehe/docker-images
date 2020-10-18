{
  mkDerivation, lib,
  extra-cmake-modules,
  libpthreadstubs, libXdmcp,
  qtbase, qttools, qtx11extras
}:

mkDerivation {
  name = "kwindowsystem";
  meta = {
    maintainers = [ lib.maintainers.ttuegel ];
    broken = builtins.compareVersions qtbase.version "5.7.0" < 0;
  };
  nativeBuildInputs = [ extra-cmake-modules ];
  buildInputs = [ libpthreadstubs libXdmcp qttools qtx11extras ];
  propagatedBuildInputs = [ qtbase ];
  patches = [
    ./platform-plugins-path.patch
  ];
  preConfigure = ''
    NIX_CFLAGS_COMPILE+=" -DNIXPKGS_QT_PLUGIN_PATH=\"''${!outputBin}/$qtPluginPrefix\""
  '';
  outputs = [ "out" "dev" ];
}