args: {
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.khome.browsers;
  inherit
    (lib)
    mkEnableOption
    mkIf
    ;
in {
  # imports = [
  #   ./chromium.nix
  #   ./tor.nix
  #   ./firefox
  # ];

  options.khome.browsers = {
    links.enable = mkEnableOption "enable links cli browser";
  };

  config = {
    home.packages = with pkgs; mkIf cfg.links.enable [links];
  };
}
