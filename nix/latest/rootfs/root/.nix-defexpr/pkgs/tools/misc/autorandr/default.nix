{ stdenv
, python3Packages
, fetchFromGitHub
, systemd
, xrandr }:

let
  python = python3Packages.python;
  version = "1.10.1";
in
  stdenv.mkDerivation {
    pname = "autorandr";
    inherit version;

    buildInputs = [ python ];

    # no wrapper, as autorandr --batch does os.environ.clear()
    buildPhase = ''
      substituteInPlace autorandr.py \
        --replace 'os.popen("xrandr' 'os.popen("${xrandr}/bin/xrandr' \
        --replace '["xrandr"]' '["${xrandr}/bin/xrandr"]'
    '';

    installPhase = ''
      runHook preInstall
      make install TARGETS='autorandr' PREFIX=$out

      make install TARGETS='bash_completion' DESTDIR=$out/share/bash-completion/completions

      make install TARGETS='autostart_config' PREFIX=$out DESTDIR=$out

      ${if systemd != null then ''
        make install TARGETS='systemd udev' PREFIX=$out DESTDIR=$out \
          SYSTEMD_UNIT_DIR=/lib/systemd/system \
          UDEV_RULES_DIR=/etc/udev/rules.d
        substituteInPlace $out/etc/udev/rules.d/40-monitor-hotplug.rules \
          --replace /bin/systemctl "/run/current-system/systemd/bin/systemctl"
      '' else ''
        make install TARGETS='pmutils' DESTDIR=$out \
          PM_SLEEPHOOKS_DIR=/lib/pm-utils/sleep.d
        make install TARGETS='udev' PREFIX=$out DESTDIR=$out \
          UDEV_RULES_DIR=/etc/udev/rules.d
      ''}

      runHook postInstall
    '';

    src = fetchFromGitHub {
      owner = "phillipberndt";
      repo = "autorandr";
      rev = version;
      sha256 = "0msw9b1hdy3gbq9w5d04mfizhyirz1c648x84mlcbzl8salm7vpg";
    };

    meta = with stdenv.lib; {
      homepage = "https://github.com/phillipberndt/autorandr/";
      description = "Automatically select a display configuration based on connected devices";
      license = licenses.gpl3Plus;
      maintainers = with maintainers; [ coroa globin ];
      platforms = platforms.unix;
    };
  }