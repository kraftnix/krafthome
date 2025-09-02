source: cargoHash:
{
  stdenv,
  lib,
  rustPlatform,
  nushell,
}:
rustPlatform.buildRustPackage rec {
  pname = "nushell_plugin_file";
  inherit cargoHash;
  inherit (source) version src;
  # patches = [
  #   ./file.Cargo.toml.patch
  # ];
  # cargoLock.lockFile = ./file.Cargo.lock;
  # postPatch = ''
  #   ln -fs ${./file.Cargo.lock} Cargo.lock
  # '';
  meta = with lib; {
    description = "A nushell plugin that will inspect a file and return information based on it's magic number.";
    mainProgram = "nu_plugin_file";
    homepage = "https://github.com/fdncred/nu_plugin_file";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    platforms = with platforms; all;
  };
}
