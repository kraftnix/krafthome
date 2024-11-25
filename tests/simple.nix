{
  name = "min";

  machine = {
    config,
    pkgs,
    ...
  }: {
    networking.domain = "testing";
  };

  testScript = let
    hostname = "basic";
  in ''
    ${hostname}.wait_for_unit("default.target")
    ${hostname}.shutdown()
  '';
}
