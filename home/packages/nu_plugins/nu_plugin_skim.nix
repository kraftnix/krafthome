source: cargoHash: {
  stdenv,
  lib,
  rustPlatform,
}:
rustPlatform.buildRustPackage rec {
  pname = "nushell_plugin_skim";
  inherit cargoHash;
  inherit (source) version src;
  # cargoLock.lockFile = ./skim.Cargo.lock;
  # postPatch = ''
  #   ln -s ${./skim.Cargo.lock} Cargo.lock
  # '';
  meta = with lib; {
    description = "A nushell plugin for skim";
    mainProgram = "nu_plugin_skim";
    homepage = "https://github.com/idanarye/nu_plugin_skim";
    license = licenses.mit;
    maintainers = with maintainers; [];
    platforms = with platforms; all;
  };
}
