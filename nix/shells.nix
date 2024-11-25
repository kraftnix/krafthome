{inputs, ...}: {
  imports = [inputs.devshell.flakeModule inputs.git-hooks-nix.flakeModule];
  perSystem = {
    config,
    pkgs,
    ...
  }: {
    devshells.default = {
      imports = [inputs.provision.devshellModules.provision];
      provision.enable = true;
      provision.nvfetcher.enable = true;
      provision.nvfetcher.sources.nixos.baseDir = "./nixos/packages";
      provision.nvfetcher.sources.home.baseDir = "./home/packages";
      devshell.startup.pre-commit = {
        text = config.pre-commit.installationScript;
      };
      packages = with pkgs;
        [
          just
          openssh
        ]
        ++ config.pre-commit.settings.enabledPackages;
    };
    pre-commit = {
      settings.hooks = {
        alejandra.enable = true;
        nil.enable = true;
      };
    };
  };
}
