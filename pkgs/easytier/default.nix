{ lib
, pkgs
, stdenv
, fetchFromGitHub
, protobuf
, nixosTests
, nix-update-script
, installShellFiles
, withQuic ? false
, # with QUIC protocol support
}:

let
  rustPlatform =
    let
      rustToolchain = pkgs.rust-bin.stable."1.95.0".default.override {
        extensions = [ "rust-src" ];
      };
    in
    pkgs.makeRustPlatform {
      cargo = rustToolchain;
      rustc = rustToolchain;
    };
in
rustPlatform.buildRustPackage
  (finalAttrs: {
    pname = "easytier";
    version = "2.6.3";

    src = fetchFromGitHub {
      owner = "EasyTier";
      repo = "EasyTier";
      tag = "v${finalAttrs.version}";
      hash = "sha256-hkzpztxg3hU57oCm2zL3U8BUyZrUkhOa3oGwcQngzE8=";
    };

    cargoHash = "sha256-FNrWO0PwpyHmitovkwao1b77owbEAw0devfc5auEWKY=";

    nativeBuildInputs = [
      protobuf
      rustPlatform.bindgenHook
      installShellFiles
      pkgs.mold
    ];

    buildNoDefaultFeatures = stdenv.hostPlatform.isMips;
    buildFeatures = lib.optional stdenv.hostPlatform.isMips "mips" ++ lib.optional withQuic "quic";

    postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
      installShellCompletion --cmd easytier-cli \
        --bash <($out/bin/easytier-cli gen-autocomplete bash) \
        --fish <($out/bin/easytier-cli gen-autocomplete fish) \
        --zsh <($out/bin/easytier-cli gen-autocomplete zsh)
      installShellCompletion --cmd easytier-core \
        --bash <($out/bin/easytier-core --gen-autocomplete bash) \
        --fish <($out/bin/easytier-core --gen-autocomplete fish) \
        --zsh <($out/bin/easytier-core --gen-autocomplete zsh)
    '';

    doCheck = false; # tests failed due to heavy rely on network

    passthru = {
      tests = { inherit (nixosTests) easytier; };
      updateScript = nix-update-script { };
    };

    meta = {
      homepage = "https://github.com/EasyTier/EasyTier";
      changelog = "https://github.com/EasyTier/EasyTier/releases/tag/v${finalAttrs.version}";
      description = "Simple, decentralized mesh VPN with WireGuard support";
      longDescription = ''
        EasyTier is a simple, safe and decentralized VPN networking solution implemented
        with the Rust language and Tokio framework.
      '';
      mainProgram = "easytier-core";
      license = lib.licenses.asl20;
      platforms = with lib.platforms; unix ++ windows;
      maintainers = with lib.maintainers; [ ltrump ];
    };
  })
