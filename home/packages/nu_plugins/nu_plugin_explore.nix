source: cargoHash: {
  stdenv,
  lib,
  rustPlatform,
}:
rustPlatform.buildRustPackage rec {
  pname = "nushell_plugin_explore";
  inherit cargoHash;
  inherit (source) version src;
  checkPhase = ''
    cargo test --workspace
  '';
  meta = with lib; {
    description = "A fast structured data explorer for Nushell.";
    mainProgram = "nu_plugin_explore";
    homepage = "https://github.com/amtoine/nu_plugin_explore";
    license = licenses.mit;
    maintainers = with maintainers; [];
    platforms = with platforms; all;
  };
}
