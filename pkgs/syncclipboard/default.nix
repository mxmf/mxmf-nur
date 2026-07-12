{ lib, stdenv, fetchurl, autoPatchelfHook, makeWrapper, dpkg, xorg, gcc, zlib, fontconfig, lttng-ust_2_12, icu, openssl }:

stdenv.mkDerivation rec {
  pname = "sync-clipboard";
  version = "3.1.8";

  src = fetchurl {
    url = "https://github.com/Jeric-X/SyncClipboard/releases/download/v${version}/SyncClipboard_linux_x64.deb";
    hash = "sha256-/E/JXWai7jSA4yGttA9M7Gh0rAs7t2icBTbYKWfNyL8=";
  };



  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
    dpkg
  ];

  buildInputs = [
    gcc
    zlib
    fontconfig
    lttng-ust_2_12
    xorg.libXt
    xorg.libXtst
    xorg.libXinerama
  ];

  unpackCmd = "dpkg -x $curSrc source";

  installPhase = ''
    mkdir -p $out/bin
    mv opt usr $out/
    ln -s $out/opt/xyz.jericx.desktop.syncclipboard/SyncClipboard.Desktop.Default $out/bin/SyncClipboard
    sed -i "s|/opt/xyz.jericx.desktop.syncclipboard/SyncClipboard.Desktop.Default|$out/bin/SyncClipboard|" $out/usr/share/applications/xyz.jericx.desktop.syncclipboard.desktop 
    wrapProgram $out/bin/SyncClipboard \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ icu openssl xorg.libX11 xorg.libICE xorg.libSM ]}
  '';

  meta = with lib; {
    description = "Cross-Platform Clipboard Syncing Solution";
  };
}
