{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib)
    foldl'
    hasAttr
    listToAttrs
    literalExpression
    mapAttrs'
    mapAttrsToList
    mkOption
    nameValuePair
    ;

  inherit (lib.types)
    attrsOf
    bool
    listOf
    package
    path
    str
    ;

  # NOTE: it may be possible to replace the haumea + symlink generation code with a recursive symlink builtin
  hlib = inputs.haumea.lib;

  luafiles = hlib.load {
    src = config.sourceDir;
    inputs = {
      inherit lib;
    };
    loader = [
      (hlib.matchers.extension "lua" hlib.loaders.path)
    ];
  };

  nameValuePairs = mapAttrsToList (name: value: { inherit name value; });

  flattenAttrsFileStructure =
    attrs:
    let
      recurse =
        root:
        foldl' (
          acc: item:
          #trace ("item ${builtins.toJSON item}\nacc: ${builtins.toJSON acc}")
          (
            if (builtins.typeOf item.value) == "set" then
              acc ++ (recurse "${root}/${item.name}" (nameValuePairs item.value))
            else
              acc
              ++ [
                {
                  name = "${root}/${item.name}.lua";
                  value = item.value;
                }
              ]
          )
        ) [ ];
    in
    recurse "" (nameValuePairs attrs);

  neovimLinks = listToAttrs (flattenAttrsFileStructure luafiles);
  neovimFileLinks = mapAttrs' (
    path: source: nameValuePair "${config.targetDir}/${path}" { inherit source; }
  ) neovimLinks;

  pluginFileLinks = listToAttrs (
    map (
      pkg:
      let
        pluginName =
          if (hasAttr pkg.pname config.pluginNameRemaps) then
            config.pluginNameRemaps.${pkg.pname}
          else
            pkg.pname;
      in
      nameValuePair "${config.targetDir}/nix-plugins/${pluginName}" {
        source = pkg;
        # recursive = true;
      }
    ) config.plugins
  );

  treesitterParsers = mapAttrs' (
    name: pkg:
    nameValuePair "${config.targetDir}/parser/${name}" {
      source = "${pkg}/parser/${name}.so";
    }
  ) pkgs.vimPlugins.nvim-treesitter.grammarPlugins;
in
{
  options = {
    enable = mkOption {
      description = "Enable neovim-lazy configuration.";
      type = bool;
      default = false;
    };
    plugins = mkOption {
      description = "Neovim Plugins to install via Nix.";
      type = listOf package;
      default = [ ];
      apply = plugins: [ pkgs.vimPlugins.lazy-nvim ] ++ plugins;
    };
    pluginNameRemaps = mkOption {
      description = ''
        Some Neovim Plugins in NixOS have a bad/incorrect `pname` attribute, which does not match
        the expected plugin name when unpacked, these must be manually remapped

        This is a workaround and is normally not needed. Ideally patches to `pname` should be submitted
        to upstream.

        Used by `NixPlugin` lua helper function
      '';
      type = attrsOf str;
      example = {
        "Comment.nvim" = "comment.nvim";
      };
      default = {
        "telescope-undo" = "telescope-undo.nvim";
        "telescope-env" = "telescope-env.nvim";
        "lspkind-nvim" = "lspkind.nvim";
        "gitlinker-nvim" = "gitlinker.nvim";
        # "terminal-nvim" = "terminal.nvim";
        # "easypick-nvim" = "easypick.nvim";
        "browser-bookmarks-nvim" = "browser-bookmarks.nvim";
        "telescope-live-grep-args-nvim" = "telescope-live-grep-args.nvim";
        "telescope-lazy-nvim" = "telescope-lazy.nvim";
        "telescope-luasnip" = "telescope-luasnip.nvim";
      };
    };
    sourceDir = mkOption {
      description = "Directory (in source code) containing what will be `.config/nvim/` contents.";
      type = path;
      example = literalExpression "./neovim";
    };
    targetDir = mkOption {
      description = "Directory that neovim lua files and plugins are linked to.";
      default = ".config/nvim";
      type = str;
    };
    extraPackages = mkOption {
      description = "Extra packages for neovim binary (such as LSPs).";
      type = listOf package;
      default = [ ];
    };

    __pluginFileLinks = mkOption {
      description = "(read-only) Symlinks of nix installed plugins.";
      default = pluginFileLinks;
      readOnly = true;
    };
    __luaFiles = mkOption {
      description = "(read-only) Symlinks of nix installed plugins.";
      default = luafiles;
      readOnly = true;
    };
    __neovimFileLinks = mkOption {
      description = "(read-only) Symlinks of nix installed plugins.";
      default = neovimFileLinks;
      readOnly = true;
    };
  };
}
