source: cargoHash:
{
  stdenv,
  lib,
  rustPlatform,
  pkg-config,
  dbus,
}:
rustPlatform.buildRustPackage rec {
  pname = "nushell_plugin_dbus";
  inherit cargoHash;
  inherit (source) version src;
  nativeBuildInputs = [ pkg-config ] ++ lib.optionals stdenv.cc.isClang [ rustPlatform.bindgenHook ];
  buildInputs = [ dbus.dev ];
  meta = with lib; {
    description = "A nushell plugin for user interaction";
    mainProgram = "nu_plugin_dbus";
    homepage = "https://github.com/Trivernis/nu-plugin-dialog";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    platforms = with platforms; all;
  };
}
