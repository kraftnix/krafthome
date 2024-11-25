{
  name = "media-user";

  machine = {
    self,
    profiles,
    config,
    pkgs,
    ...
  }: {
    imports = [profiles.users.media];
  };

  testScript = let
    hostname = "basic";
  in ''
    ${hostname}.wait_for_unit("default.target")
    ${hostname}.shutdown()
  '';
}
