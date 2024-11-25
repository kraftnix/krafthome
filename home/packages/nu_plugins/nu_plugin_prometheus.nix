source: cargoHash: {
  stdenv,
  lib,
  rustPlatform,
  openssl,
  pkg-config,
}:
rustPlatform.buildRustPackage rec {
  pname = "nushell_plugin_prometheus";
  inherit cargoHash;
  inherit (source) version src;
  nativeBuildInputs = [pkg-config] ++ lib.optionals stdenv.cc.isClang [rustPlatform.bindgenHook];
  buildInputs = [openssl];
  meta = with lib; {
    description = "A nushell plugin for querying prometheus";
    mainProgram = "nu_plugin_prometheus";
    homepage = "https://github.com/drbrain/nu_plugin_prometheus";
    license = licenses.mit;
    maintainers = with maintainers; [];
    platforms = with platforms; all;
  };
}
