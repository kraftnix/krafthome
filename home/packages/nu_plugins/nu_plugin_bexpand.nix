source: cargoHash:
{
  stdenv,
  lib,
  rustPlatform,
}:
rustPlatform.buildRustPackage rec {
  pname = "nushell_plugin_bexpand";
  useFetchCargoVendor = true;
  inherit cargoHash;
  inherit (source) version src;
  meta = with lib; {
    description = "Bash-style brace expansion in nushell.";
    mainProgram = "nu_plugin_bexpand";
    homepage = "https://codeberg.org/Taywee/nu-plugin-bexpand";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    platforms = with platforms; all;
  };
}
