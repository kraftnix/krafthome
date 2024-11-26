source: cargoHash:
{
  stdenv,
  lib,
  rustPlatform,
}:
rustPlatform.buildRustPackage rec {
  pname = "nushell_plugin_dialog";
  inherit cargoHash;
  inherit (source) version src;
  checkPhase = ''
    cargo test --workspace
  '';
  meta = with lib; {
    description = "A nushell plugin for user interaction";
    mainProgram = "nu_plugin_dialog";
    homepage = "https://github.com/Trivernis/nu-plugin-dialog";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    platforms = with platforms; all;
  };
}
