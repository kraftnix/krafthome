source: cargoHash:
{
  stdenv,
  lib,
  rustPlatform,
}:
rustPlatform.buildRustPackage rec {
  pname = "nushell_plugin_port_list";
  useFetchCargoVendor = true;
  inherit cargoHash;
  inherit (source) version src;
  checkPhase = ''
    cargo test --workspace
  '';
  meta = with lib; {
    description = "A nushell plugin to display all active network connections.";
    mainProgram = "nu_plugin_port_list";
    homepage = "https://github.com/FMotalleb/nu_plugin_port_list";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    platforms = with platforms; all;
  };
}
