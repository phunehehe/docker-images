{ stdenv, fetchurl, fetchpatch, lvm2, libuuid, gettext, readline
, utillinux, check, enableStatic ? false }:

stdenv.mkDerivation rec {
  name = "parted-3.1";

  src = fetchurl {
    url = "mirror://gnu/parted/${name}.tar.xz";
    sha256 = "05fa4m1bky9d13hqv91jlnngzlyn7y4rnnyq6d86w0dg3vww372y";
  };

  patches = [
    # Fix build with glibc >= 2.28
    # https://github.com/NixOS/nixpkgs/issues/86403
    (fetchpatch {
      url = "https://gitweb.gentoo.org/repo/gentoo.git/plain/sys-block/parted/files/parted-3.2-sysmacros.patch?id=8e2414f551c14166f259f9a25a594aec7a5b9ea0";
      sha256 = "0fdgifjbri7n28hv74zksac05gw72p2czzvyar0jp62b9dnql3mp";
    })
  ];

  buildInputs = [ libuuid ]
    ++ stdenv.lib.optional (readline != null) readline
    ++ stdenv.lib.optional (gettext != null) gettext
    ++ stdenv.lib.optional (lvm2 != null) lvm2;

  configureFlags =
       (if (readline != null)
        then [ "--with-readline" ]
        else [ "--without-readline" ])
    ++ stdenv.lib.optional (lvm2 == null) "--disable-device-mapper"
    ++ stdenv.lib.optional enableStatic "--enable-static";

  doCheck = true;
  checkInputs = [ check utillinux ];

  meta = {
    description = "Create, destroy, resize, check, and copy partitions";

    longDescription = ''
      GNU Parted is an industrial-strength package for creating, destroying,
      resizing, checking and copying partitions, and the file systems on
      them.  This is useful for creating space for new operating systems,
      reorganising disk usage, copying data on hard disks and disk imaging.

      It contains a library, libparted, and a command-line frontend, parted,
      which also serves as a sample implementation and script backend.
    '';

    homepage = "https://www.gnu.org/software/parted/";
    license = stdenv.lib.licenses.gpl3Plus;

    maintainers = [
      # Add your name here!
    ];

    # GNU Parted requires libuuid, which is part of util-linux-ng.
    platforms = stdenv.lib.platforms.linux;
  };
}