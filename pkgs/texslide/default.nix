{ lib
, pkgs
, appimageTools
, fetchurl
}:

let
  version = "0.9.4";
  pname = "texslide";

  src = fetchurl {
    url = "https://download.texslide.com/release/texslide-x64.AppImage";
    hash = "sha256-VcEuPVGwAW8SysYjkV/p5CxcFZg4crP+I+I8BdDNOac=";
  };


  appimageContents = appimageTools.extractType1 { inherit pname src version; };

in
appimageTools.wrapType2 {
  inherit pname version src;

  extraPkgs = pkgs: [ pkgs.librsvg ];


  profile = ''
    export GDK_PIXBUF_MODULE_FILE=$(echo ${pkgs.librsvg}/lib/gdk-pixbuf-2.0/*/loaders.cache)
  '';


  extraInstallCommands = ''
    install -Dm444 ${appimageContents}/${pname}.desktop -t $out/share/applications/
    install -Dm444 ${appimageContents}/${pname}.png -t $out/share/pixmaps/
  '';

  meta = {
    description = "TexSlide empowers scholars, engineers, and educators to present complex formulas and charts with ease.";
    homepage = "https://texslide.com/";
    license = lib.licenses.unfree;
    maintainers = [ ];
    platforms = [ "x86_64-linux" ];
  };
}
