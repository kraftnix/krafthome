{ self, ... }:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkIf
    mkMerge
    optional
    optionals
    ;
  opts = self.inputs.extra-lib.lib.options;
  cfg = config.khome.shell.atuin;
in
{
  options.khome.shell.atuin = {
    enable = opts.enable "enable atuin";
    address = opts.stringNull "if set, set as sync_address";
    enableSync = opts.enable "enables syncing";
  };

  config = mkIf cfg.enable {
    programs.atuin = {
      enable = true;
      settings = {
        # full options: https://github.com/ellie/atuin/blob/main/atuin-client/config.toml
        dialect = "uk";
        auto_sync = cfg.enableSync;
        sync_frequency = "5m";
        #sync_address = "";
        sync_address = mkIf (cfg.address != null) cfg.address;
        search_mode = "fuzzy";
        update_check = false;
        show_preview = true;
        sync.records = true; # sync v2
      };
    };
  };
}
