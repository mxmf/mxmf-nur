{ lib
, pkgs
, appimageTools
, fetchurl
}:

let
  version = "0.9.3";
  pname = "texsilde";

  src = fetchurl {
    url = "https://download.texslide.com/release/texslide-x64.AppImage";
    hash = "sha256-98sBK0g3M9FTqS2uSCuYulwHBV+eNNceW1P5ylioEQQ=";
  };

in
appimageTools.wrapType2 {
  inherit pname version src;

  extraPkgs = pkgs: [ pkgs.librsvg ];


  profile = ''
    export GDK_PIXBUF_MODULE_FILE=$(echo ${pkgs.librsvg}/lib/gdk-pixbuf-2.0/*/loaders.cache)
  '';



  meta = {
    description = "TexSlide empowers scholars, engineers, and educators to present complex formulas and charts with ease.";
    homepage = "https://texslide.com/";
    license = lib.licenses.unfree;
    maintainers = [ ];
    platforms = [ "x86_64-linux" ];
  };
}
