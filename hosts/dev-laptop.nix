{ ... }:
{
  security.elewrap = { };
  provision.roles.desktop = {
    enable = true;
    nixTrustedUsers = [ "test" ];
  };
  provision.virt.qemu.guestAgent = true;
  provision.fs = {
    bcachefs.enable = true; # enable extra tools etc.
    disko.devices.root = {
      device = "/dev/vda";
      profile = "bcachefs-luks-uefi";
    };
  };

  khome.roles.dev = {
    enable = true;
    graphical = true;
    users = [ "myuser" ];
    security.enable = true;
  };

  home-manager.users.myuser =
    { hmProfiles, ... }:
    {
      imports = [ hmProfiles.neovim ];
      khome.misc.keepass.firejail.enable = true;
      programs.walker = {
        enable = true;
        runAsService = true;
        settings = {
          theme = "custom";
          terminal = "wezterm";
        };
      };
      khome.desktop.services.poweralertd.enable = true;
      khome.desktop.anyrun = {
        enable = true;
        modKeybind = "b";
      };
      khome.desktop.wm.legacyTheme.enable = true;
      khome.desktop.swww = {
        enable = true;
        systemdIntegration = true;
        wallpaperDirs = [ "${../home/modules/themes}" ];
      };
      khome.desktop.wm.sway = {
        enable = true;
        enableTap = true;
        full = true;
      };
      khome.shell.atuin.enableSystemdDaemon = true;
      programs.eww-hyprland.enable = true;
      programs.wl-kbptr.enable = true;
    };

  khome = {
    desktop = {
      enable = true;
      tuigreet.enable = true;
      sway.enable = true;
      wifi.enable = true;
    };
    users.dev-user.enable = true;
    users.dev-user.name = "myuser";
    hardware.laptop = {
      battery-tools = true;
      powersave = true;
      headless = true;
    };
    shell.ssh-symlink.enable = true;
    shell.yubikey = {
      enable = true;
      graphical = true;
      enableGpgAgent = true;
      setupUser = "myuser";
      polkit = {
        enable = true;
        allowedUser = "myuser";
        allowedReaders = [ "Yubico YubiKey OTP+FIDO+CCID 00 00" ];
      };
    };
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
