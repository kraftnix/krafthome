{
  self,
  inputs,
  lib,
  ...
}:
{
  imports = [
    inputs.flake-parts.flakeModules.easyOverlay
  ];

  perSystem =
    {
      config,
      pkgs,
      ...
    }:
    {
      packages = {
        stylix-default-wallpaper =
          pkgs.runCommand "wallpaper.jpg" { WALLPAPER = ../home/modules/themes/wallpaper.jpg; }
            ''
              cp $WALLPAPER $out
            '';
        hl = pkgs.callPackage (import ./hl/hl.nix) { };
        nirius = pkgs.callPackage (import ./nirius.nix) { };
        get-default-ssh = pkgs.writeScriptBin "get-default-ssh" "echo /run/user/$UID/gnupg/S.gpg-agent.ssh";
        skr = pkgs.writeScriptBin "skr" "export SSH_AUTH_SOCK=/run/user/$UID/gnupg/S.gpg-agent.ssh";
        get-recent-ssh = pkgs.writeScriptBin "get-recent-ssh" ''
          nu -c "ls (ls /tmp | where name =~ ssh- | sort-by modified -r | get name | get 0) | get 0.name"
        '';
        skk = pkgs.writeScriptBin "skk" ''
          export SSH_AUTH_SOCK=$(get-recent-ssh)
        '';

        nix-find = pkgs.writeScriptBin "nix-find" ''
          #!/usr/bin/env nu

          ${builtins.readFile ./nix-find.nu}
        '';
      }
      // ((import ./desktop) pkgs);

      overlayAttrs = {
        inherit (config.packages)
          nirius
          get-default-ssh
          skr
          get-recent-ssh
          skk
          libbluray-full-mine
          mpv-bluray
          firefox-priv-defaults-wayland
          stylix-default-wallpaper
          ;
      };
    };
}
