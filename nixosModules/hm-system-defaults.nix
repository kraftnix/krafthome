{ config, lib, ... }:
{
  home-manager.sharedModules = [
    {
      xdg.configFile."nix/registry.json".text =
        lib.mkDefault
          config.environment.etc."nix/registry.json".text;
    }
  ];
}
