{ stdenv, fetchFromGitHub, gettext, makeWrapper, tcl, which, writeScript
, ncurses, perl , cyrus_sasl, gss, gpgme, kerberos, libidn, libxml2, notmuch, openssl
, lmdb, libxslt, docbook_xsl, docbook_xml_dtd_42, w3m, mailcap, runtimeShell, sqlite, zlib
, glibcLocales
, fetchpatch
}:

stdenv.mkDerivation rec {
  version = "20200925";
  pname = "neomutt";

  src = fetchFromGitHub {
    owner  = "neomutt";
    repo   = "neomutt";
    rev    = version;
    sha256 = "1q931n9sijq1iin3swzk57rz7qmy485hvr1fahy5i2wd1xx9yhb2";
  };

  buildInputs = [
    cyrus_sasl gss gpgme kerberos libidn ncurses
    notmuch openssl perl lmdb
    mailcap sqlite
  ];

  patches = [
    # To be removed on next release. Fixes two bugs in the sidebar behavior.
    (fetchpatch {
      url = "https://github.com/neomutt/neomutt/commit/96753674e70edb695c1dc7af73e3317956c1b259.patch";
      sha256 = "0yjmgdfhn8ra7bc3d40c3c29imgpgbhzphjxp6575llh9kw5h53s";
    })
    (fetchpatch {
      url = "https://github.com/neomutt/neomutt/commit/6078653c9233644ca76c24bdb64e49bd443dd714.patch";
      sha256 = "1s1p86bqpc9xq9z5qfh0mxxh6syps8shq0dm7bbkg1bz7qya5phy";
    })
  ];

  nativeBuildInputs = [
    docbook_xsl docbook_xml_dtd_42 gettext libxml2 libxslt.bin makeWrapper tcl which zlib w3m
  ];

  enableParallelBuilding = true;

  postPatch = ''
    substituteInPlace contrib/smime_keys \
      --replace /usr/bin/openssl ${openssl}/bin/openssl

    for f in doc/*.{xml,xsl}*  ; do
      substituteInPlace $f \
        --replace http://docbook.sourceforge.net/release/xsl/current     ${docbook_xsl}/share/xml/docbook-xsl \
        --replace http://www.oasis-open.org/docbook/xml/4.2/docbookx.dtd ${docbook_xml_dtd_42}/xml/dtd/docbook/docbookx.dtd
    done


    # allow neomutt to map attachments to their proper mime.types if specified wrongly
    # and use a far more comprehensive list than the one shipped with neomutt
    substituteInPlace send/sendlib.c \
      --replace /etc/mime.types ${mailcap}/etc/mime.types
  '';

  preBuild = ''
    export HOME=$(mktemp -d)
  '';

  configureFlags = [
    "--enable-autocrypt"
    "--gpgme"
    "--gss"
    "--lmdb"
    "--notmuch"
    "--ssl"
    "--sasl"
    "--with-homespool=mailbox"
    "--with-mailpath="
    # To make it not reference .dev outputs. See:
    # https://github.com/neomutt/neomutt/pull/2367
    "--disable-include-path-in-cflags"
    # Look in $PATH at runtime, instead of hardcoding /usr/bin/sendmail
    "ac_cv_path_SENDMAIL=sendmail"
    "--zlib"
  ];

  # Fix missing libidn in mutt;
  # this fix is ugly since it links all binaries in mutt against libidn
  # like pgpring, pgpewrap, ...
  NIX_LDFLAGS = "-lidn";

  postInstall = ''
    wrapProgram "$out/bin/neomutt" --prefix PATH : "$out/libexec/neomutt"
  '';

  doCheck = true;

  preCheck = ''
    cp -r ${fetchFromGitHub {
      owner = "neomutt";
      repo = "neomutt-test-files";
      rev = "8629adab700a75c54e8e28bf05ad092503a98f75";
      sha256 = "1ci04nqkab9mh60zzm66sd6mhsr6lya8wp92njpbvafc86vvwdlr";
    }} $(pwd)/test-files
    chmod -R +w test-files
    (cd test-files && ./setup.sh)

    export NEOMUTT_TEST_DIR=$(pwd)/test-files
  '';

  checkTarget = "test";
  postCheck = "unset NEOMUTT_TEST_DIR";

  meta = with stdenv.lib; {
    description = "A small but very powerful text-based mail client";
    homepage    = "http://www.neomutt.org";
    license     = licenses.gpl2Plus;
    maintainers = with maintainers; [ cstrahan erikryb jfrankenau vrthra ma27 ];
    platforms   = platforms.unix;
  };
}