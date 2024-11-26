{ self, ... }@args:
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
  cfg = config.khome.desktop.apps;
in
{
  options.khome.desktop.apps = {
    dev.vscode = opts.enable "add vscode package";

    creativity = {
      enable = opts.enable "add all creativity apps";
      darktable = opts.enableTrue "add darktable (image editing)";
      ansel = opts.enableTrue "add ansel (image editing), better darktable";
      rnote = opts.enableTrue "add rnote (tablet drawing)";
    };

    media = {
      enable = opts.enable "add all media apps";
      calibre = opts.enable "add calibre (book library)";
      freetube = opts.enableTrue "add freetube (youtube player)";
    };

    messengers = {
      element = opts.enable "add element-desktop (matrix electron client)";
      mirage = opts.enable "add mirage (matrix client)";
      nheko = opts.enable "add nheko (matrix gtk client)";
      signal = opts.enable "add signal";
      telegram = opts.enable "add telegram";
    };

    productivity = {
      electron-mail = opts.enable "add electron-mail (protonmail electron client)";
      kalendar = opts.enable "add kalendar (KDE email client)";
      evolution = opts.enable "add evolution (GTK email client)";
    };
  };

  config = mkMerge [
    ## Dev
    (mkIf cfg.dev.vscode {
      programs.vscode = {
        enable = true;
        package = pkgs.vscodium;
        extensions = with pkgs.vscode-extensions; [
          bbenoist.Nix
        ];
      };
    })

    ## Creativity
    (mkIf cfg.creativity.enable {
      home.packages =
        [ ]
        ++ (optional cfg.creativity.darktable pkgs.darktable)
        ++ (optional cfg.creativity.ansel pkgs.ansel)
        ++ (optional cfg.creativity.rnote pkgs.rnote);
    })

    ## Media
    (mkIf cfg.media.enable {
      home.packages =
        [ ] ++ (optional cfg.media.calibre pkgs.calibre) ++ (optional cfg.media.freetube pkgs.freetube);
    })

    ## Messengers
    {
      home.packages =
        [ ]
        ++ (optional cfg.messengers.element pkgs.element-desktop)
        ++ (optional cfg.messengers.mirage pkgs.mirage-im)
        ++ (optional cfg.messengers.nheko pkgs.nheko)
        ++ (optional cfg.messengers.signal pkgs.signal-desktop)
        ++ (optional cfg.messengers.telegram pkgs.tdesktop);
    }

    ## Productivity
    {
      home.packages =
        [ ]
        ++ (optional cfg.productivity.electron-mail pkgs.electron-mail)
        ++ (optional cfg.productivity.kalendar pkgs.kalendar)
        ++ (optionals cfg.productivity.evolution [
          pkgs.evolution
          pkgs.dconf
          pkgs.pinentry-gnome
        ]);
    }
  ];
}
