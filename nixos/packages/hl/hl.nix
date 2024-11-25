{
  lib,
  rustPlatform,
  fetchFromGitHub,
  stdenv,
  darwin,
}:
rustPlatform.buildRustPackage rec {
  pname = "hl";
  version = "0.29.8";

  src = fetchFromGitHub {
    owner = "pamburus";
    repo = "hl";
    rev = "v${version}";
    hash = "sha256-YL9DWVArUf+ZdldTyTY4Y2rDMofwZJ8o6PsVECkr2q0=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "htp-0.4.2" = "sha256-oYLN0aCLIeTST+Ib6OgWqEgu9qyI0n5BDtIUIIThLiQ=";
      "wildflower-0.3.0" = "sha256-vv+ppiCrtEkCWab53eutfjHKrHZj+BEAprV5by8plzE=";
    };
  };

  buildInputs = lib.optionals stdenv.isDarwin [
    darwin.apple_sdk.frameworks.CoreFoundation
    darwin.apple_sdk.frameworks.CoreServices
  ];

  meta = {
    description = "A fast and powerful log viewer and processor that translates JSON or logfmt logs into a pretty human-readable format";
    homepage = "https://github.com/pamburus/hl";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [];
    mainProgram = "hl";
  };
}
