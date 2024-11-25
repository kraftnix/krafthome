{
  inputs,
  lib,
  ...
}: {
  imports = with inputs.provision.profiles; [
    # users.test-operator
    # users.test-deploy
  ];

  provision.defaults.enable = true;
  provision.core.env.enable = true;
  provision.core.shell.enable = true;
  provision.virt.qemu.guestAgent = true;
  provision.fs.boot.enable = true;

  fileSystems."/" = lib.mkDefault {device = "/dev/disk/by-label/nixos";};

  users.users.test.isNormalUser = true;
  # home-manager.users.test = import ../../home/users/example.nix;

  khome = {
    desktop = {
      enable = true;
      tuigreet.enable = true;
      sway.enable = true;
    };
    users.dev-user.enable = true;
    hardware.laptop.powersave = true;
    sound = {
      enable = true;
      bluetooth.enable = true;
      pipewire.enable = true;
      pipewire.wireplumber.enable = true;
    };
  };

  services.openssh.enable = true;
  programs.neovim.enable = true;
  # nixpkgs.overlays = [
  #   (_: _: {
  #     #inherit (inputs.stable.legacyPackages.x86_64-linux) dogdns helvum;
  #   })
  #   self.overlays.vimPlugins
  #   self.overlays.neovimBundle
  #   self.inputs.provision.overlays.default
  # ];

  system.stateVersion = "23.11";
}
