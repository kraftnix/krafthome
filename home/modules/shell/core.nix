args:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkDefault
    mkEnableOption
    mkOption
    optionals
    types
    ;
  cfg = config.khome.shell;
in
{
  options.khome.shell = {
    keyboardLayout = mkOption {
      type = types.str;
      default = "gb";
      description = "keyboard layout";
    };
    editor = mkOption {
      type = types.str;
      default = "vim";
      description = "default editor";
    };
    direnv.enable = mkEnableOption "enable direnv";
    core-tools = {
      enable = mkEnableOption "enable direnv";
      packages = mkOption {
        default = with pkgs; [
          # shell
          dogdns # dig alternative
          du-dust # du alternative
          gping # ping alternative (tui)
          prettyping # ping alternative
          cryptsetup # LUKS
          bandwhich # shows network utilization by process
          vimv-rs # batch rename files with vim
          difftastic # awesome diff tool
          zenith # best top alternative
          tre-command # tree alternative
          tlrc # rust tldr

          # tui
          ranger # tui file browser
          yazi # tui file browser

          # maintenance
          # xdg-ninja
          calc # tui calculator
          fastfetch # neofetch replacement

          sysz # tui systemctl
          jc # unix -> json converter
          jq # json viewer | grep
          jless # interactive json explorer

          # libvirt # virtual machines
          # ov # terminal-based text viewer
          # so # stack exchange searcher

          # TODO: later add to desktop core
          # monitor # system resources / process monitor UI
        ];
        description = "core tools added to all users";
        type = types.listOf types.package;
      };
    };
    misc.enable = mkEnableOption "misc cli tools";
    man.enable = mkEnableOption "enable manpage generation";
    proxychains.enable = mkEnableOption "enable proxychains";
    xplr.enable = mkEnableOption "enable xplr";
    nix-tools.enable = mkEnableOption "add all nix helper tools";
  };

  config = {
    home.sessionVariables.EDITOR = cfg.editor;
    home.keyboard.layout = cfg.keyboardLayout;
    home.packages =
      with pkgs;
      [ ]
      ++ (optionals cfg.xplr.enable [ xplr ])
      ++ (optionals cfg.proxychains.enable [ proxychains ])
      ++ (optionals cfg.misc.enable [
        rustscan # rust-based fast nmap alternative
        tea # cli gitea
        glow # cli markdown viewer
        # charm     # cli terminal backend
        sshfs # mount userspace fs over SSH
        vimv-rs # vim move/rename files
        gum # UI shell scripts like telescope
      ])
      ++ (optionals cfg.core-tools.enable cfg.core-tools.packages)
      ++ (optionals cfg.nix-tools.enable [
        nix-doc # An interactive Nix documentation tool
        nix-diff # Explain why two Nix derivations differ
        nix-du # A tool to determine which gc-roots take space in your nix store
        nix-init # Command line tool to generate Nix packages from URLs
        nix-index # A files database for nixpkgs # incompatible with nix-index-database
        nix-info # basic info on your current nix install
        nix-fast-build # build things fast
        nix-ld # Run unpatched dynamic binaries on NixOS
        nix-melt # A ranger-like flake.lock viewer
        nix-search-cli # cli tool that search nixos.org, can search for packages
        nix-template # Make creating nix expressions easy
        nix-top # Tracks what nix is building
        nurl # generate fetchers from url
        nix-tree # Interactively browse a Nix store paths dependencies
        nvd # Nix/NixOS package version diff tool
        nix-output-monitor # nom, pretty build printing
      ]);
    programs.direnv.enable = cfg.direnv.enable;
    programs.man.enable = mkDefault cfg.man.enable;
    programs.man.generateCaches = mkDefault cfg.man.enable;
    manual.manpages.enable = mkDefault cfg.man.enable;
    manual.json.enable = mkDefault cfg.man.enable;
  };
}
