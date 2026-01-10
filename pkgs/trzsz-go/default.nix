{ lib, buildGoModule, fetchFromGitHub, nix-update-script }:

buildGoModule rec {
  pname = "trzsz-go";
  version = "1.1.8";

  src = fetchFromGitHub {
    owner = "trzsz";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-g1fbgKTFS9aPAmnTeFYoymrDEoZ6BtzUhA2Z9SNYbsU=";
  };

  vendorHash = "sha256-AsrRHHBlzW5s/PtJSQ+hAgqUIYwDwoemQaerRV/QKX0=";

  doCheck = false;

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "trzsz-go makes all terminals that support local shell to support trzsz ( trz / tsz ), which similar to ( rz / sz ), and compatible with tmux.";
    homepage = "https://trzsz.github.io/go";
    license = licenses.mit;
    maintainers = [ ];
  };
}

