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
      inputs',
      self',
      ...
    }:
    let
      # should replace tree-sitter stuff with https://github.com/NixOS/nixpkgs/pull/344849
      genGrammar =
        language:
        let
          sources = pkgs.callPackage (import "${./_sources}/generated.nix") { };
          source = sources."tree-sitter-${language}";
        in
        {
          inherit language;
          inherit (source) version src;
          meta = {
            homepage = "https://github.com/${source.src.owner}/${source.src.repo}";
            # license = lib.gpl2;
          };
        };
      extraGrammars = {
        tree-sitter-nu = genGrammar "nu";
        tree-sitter-bash = genGrammar "bash";
        # tree-sitter-markdown = genGrammar "markdown";
        tree-sitter-python = genGrammar "python";
        tree-sitter-javascript = genGrammar "javascript";
        tree-sitter-yuck = genGrammar "yuck";
      };
      inherit (pkgs.tree-sitter) buildGrammar;
      genGrammar' = language: buildGrammar (genGrammar language);
      nvimGrammars = rec {
        nu = genGrammar' "nu";
        bash = genGrammar' "bash";
        javascript = genGrammar' "javascript";
        markdown = genGrammar' "markdown";
        markdown-inline = markdown // {
          language = "markdown_inline";
          location = "tree-sitter-markdown-inline";
        };
        python = genGrammar' "python";
        yuck = genGrammar' "yuck";
      };
      allTreesitter =
        removeAttrs
          (
            pkgs.tree-sitter.builtGrammars
            // {
              tree-sitter-nu = nvimGrammars.nu;
              # tree-sitter-javascript = nvimGrammars.javascript;
            }
          )
          [
            "tree-sitter-nix"
          ];
    in
    {
      packagesGroups.tree-sitter-grammars =
        pkgs.tree-sitter.passthru.builtGrammars
        // (lib.mapAttrs (_: pkgs.tree-sitter.passthru.buildGrammar) extraGrammars);
      packages = {
        stylix-default-wallpaper =
          pkgs.runCommand "wallpaper.jpg" { WALLPAPER = ../home/modules/themes/wallpaper.jpg; }
            ''
              cp $WALLPAPER $out
            '';
        wezterm-upstream = inputs'.wezterm.packages.default;
        hl = pkgs.callPackage (import ./hl/hl.nix) { };
        # inherit (extraGrammars) tree-sitter-nu tree-sitter-bash tree-sitter-markdown tree-sitter-python tree-sitter-yuck;
        tree-sitter-with-nu = pkgs.tree-sitter.override {
          extraGrammars = {
            inherit (extraGrammars) tree-sitter-nu;
          };
        };
        allNvimTreesitter = pkgs.vimPlugins.nvim-treesitter.overrideAttrs {
          tree-sitter-grammars = allTreesitter;
          passthru.dependencies = map pkgs.neovimUtils.grammarToPlugin (lib.attrValues allTreesitter);
        };
        nvim-treesitter-full =
          (pkgs.vimPlugins.nvim-treesitter.overrideAttrs (
            oldAttrs:
            oldAttrs
            // {
              # tree-sitter = pkgs.tree-sitter-with-nu;
              tree-sitter = self'.packages.tree-sitter-full;
              extraGrammars = nvimGrammars;
            }
          )).withPlugins
            (plugins: (lib.attrValues plugins) ++ (lib.attrValues nvimGrammars));
        tree-sitter-full = pkgs.tree-sitter.override {
          inherit extraGrammars;
        };
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

        # neovim-bundle = (
        #   (inputs'.nixpkgs.legacyPackages.extend
        #     (final: prev: {
        #       vimPlugins = prev.vimPlugins // self'.vimPlugins;
        #     })
        #   ).extend(
        #     inputs.nix2vim.overlay
        #   )
        # ).neovimBuilder (import ../../home/vim/neovim-pkg.nix { });

        #)).neovimBuilder (import ../vim/neovim-pkg.nix { });
      } // ((import ./desktop) pkgs);

      overlayAttrs = {
        inherit allTreesitter;
        inherit (extraGrammars)
          tree-sitter-nu
          tree-sitter-bash
          # tree-sitter-markdown
          tree-sitter-python
          tree-sitter-javascript
          tree-sitter-yuck
          ;
        inherit (config.packages)
          # tree-sitter-full
          # tree-sitter-grammars
          # tree-sitter-parsers
          # nvim-treesitter-full
          # allTreesitter
          allNvimTreesitter
          wezterm-upstream
          get-default-ssh
          skr
          get-recent-ssh
          skk
          # neovim-bundle
          libbluray-full
          mpv-bluray
          firefox-priv-defaults-wayland
          stylix-default-wallpaper
          ;
      };
    };
}
