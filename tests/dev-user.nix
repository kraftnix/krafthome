{
  name = "dev-user";

  machine = {
    self,
    profiles,
    config,
    pkgs,
    ...
  }: {
    home-manager.users.test-user = {hmProfiles, ...}: {
      imports = [hmProfiles.themes.tokyo-night];
      khome.roles.basic.enable = true;
      khome.roles.dev.enable = true;
      khome.roles.dev.graphical = true;
      khome.desktop.wm.sway.enable = true;
      khome.desktop.wm.sway.full = true;
      services.gnome-keyring.enable = true;
      services.gnome-keyring.components = ["secrets"];
    };
    users.users.test-user = {
      isNormalUser = true;
      extraGroups = ["tty" "wheel"];
    };
  };

  testScript = let
    hostname = "basic";
  in ''
    ${hostname}.wait_for_unit("default.target")
    ${hostname}.shutdown()
  '';
}
