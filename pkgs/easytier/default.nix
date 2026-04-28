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
    version = "2.6.2";

    src = fetchFromGitHub {
      owner = "EasyTier";
      repo = "EasyTier";
      tag = "v${finalAttrs.version}";
      hash = "sha256-1eqjLw1NZbfl1ItDCtegnVsMdLXkIBXKpt/69FSACY4=";
    };

    cargoHash = "sha256-sK4eZCW1+Jm9ZgGqBAdQc1Bpsyp7PIoFMwY710/+tCk=";

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
