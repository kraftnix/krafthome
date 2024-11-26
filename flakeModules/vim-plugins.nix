{
  lib,
  flake-parts-lib,
  ...
}:
flake-parts-lib.mkTransposedPerSystemModule {
  name = "vimPlugins";
  option = lib.mkOption {
    type = lib.types.anything;
    default = { };
    description = ''
      An attribute set of system-specific library functions.
    '';
  };
  file = ./vim-plugins.nix;
}
