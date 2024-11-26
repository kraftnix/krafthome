{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  globalCfg = config.themes.base16;
  templates = importJSON ./templates.json;
  schemes = importJSON ./schemes.json;

  # mustache engine
  mustache =
    template-attrs: name: src:
    pkgs.stdenv.mkDerivation {
      name = "${name}-${template-attrs.scheme-slug}";
      inherit src;
      data = pkgs.writeText "${name}-data" (builtins.toJSON template-attrs);
      phases = [ "buildPhase" ];
      buildPhase = "${pkgs.mustache-go}/bin/mustache $data $src > $out";
      allowSubstitutes = false; # will never be in cache
    };

  # imports a YAML file into attrs via YAML -> JSON -> attributes
  # DO NOT USE FOR SECRETS
  importYAML' =
    path: name:
    importJSON (
      pkgs.stdenv.mkDerivation {
        inherit path name;
        phases = [ "buildPhase" ];
        buildPhase = "${pkgs.yj}/bin/yj -yj < $path > $out";
        allowSubstitutes = false; # will never be in cache
      }
    );

  # nasty python script for dealing with yaml + different output types
  python = pkgs.python3.withPackages (ps: with ps; [ pyyaml ]);
  loadyaml =
    {
      src,
      name ? "yaml",
    }:
    importJSON (
      pkgs.stdenv.mkDerivation {
        inherit name src;
        phases = [ "buildPhase" ];
        buildPhase = ''
          slug_all='ffffff'
          slug=''${slug_all%.*}
          ${python}/bin/python ${./base16writer.py} $slug < $src > $out
        '';
        allowSubstitutes = false; # will never be in cache
      }
    );

  yamlFormat = pkgs.formats.yaml { };

  genReadableColors' =
    theme:
    with theme;
    theme
    // rec {
      # base16 style
      background = base00;
      foreground = base05;
      backgroundAlt = base01;
      foregroundAlt = base04;
      # Term Colors
      red = base08;
      orange = base09;
      yellow = base0A;
      green = base0B;
      cyan = base0C;
      magenta = base0D;
      blue = base0E;
      white = base0F;
      black = background;
    };
  # Dirty theme generation (with overrides)
  genTheme' =
    {
      scheme ? globalCfg.scheme,
      variant ? globalCfg.variant,
      localTheme ? globalCfg.localTheme,
      overrides ? globalCfg.extraParams,
    }:
    let
      remName = "base16-${scheme}-${variant}";
      gitPath = "${pkgs.fetchgit (schemes."${scheme}")}/${variant}.yaml";
      #remoteSrc = (genReadableColors' importYAML' gitPath remName) // overrides;
      localSrc = (genReadableColors' localTheme) // overrides;
      /*
        src = if localTheme != {}
        then (yamlFormat.generate localTheme.scheme-slug localSrc)
        else (yamlFormat.generate remName remoteSrc);
      */
      src = yamlFormat.generate localTheme.scheme-slug localSrc;
    in
    genReadableColors' (loadyaml {
      inherit src;
    });

  defaultTheme = genTheme' { overrides = globalCfg.extraParams; };
  createTemplate' =
    {
      repo,
      theme ? defaultTheme,
      templateName ? "default.mustache",
    }:
    mustache theme repo "${pkgs.fetchgit (templates."${repo}")}/templates/${templateName}";
  themeModule =
    { config, ... }:
    {
      options = with types; {
        scheme = mkOption {
          type = str;
          default = "solarized";
          description = "theme scheme";
        };
        variant = mkOption {
          type = str;
          default = "solarized-dark";
          description = "variant";
        };
        extraParams = mkOption {
          type = attrs;
          default = { };
          description = "extra pamas";
        };
        colors = mkOption {
          type = attrsOf str;
          description = "Base16 color set";
          default = { };
        };
        colorsH = mkOption {
          type = attrsOf str;
          description = "Base16 color set prepended with #";
          default = { };
        };
        localTheme = mkOption {
          type = attrsOf str;
          default = globalCfg.localTheme;
          description = "End local base16 theme";
          example = {
            scheme = "Atelier Cave";
            author = "Bram de Haan (http://atelierbramdehaan.nl)";
            base00 = "19171c"; # Default Background
            base01 = "26232a"; # Lighter Background (Used for status bars, line number and folding marks)
            base02 = "585260"; # Selection Background
            base03 = "655f6d"; # Comments, Invisibles, Line Highlighting
            base04 = "7e7887"; # Dark Foreground (Used for status bars)
            base05 = "8b8792"; # Default Foreground, Caret, Delimiters, Operators
            base06 = "e2dfe7"; # Light Foreground (Not often used)
            base07 = "efecf4"; # Light Background (Not often used)
            base08 = "be4678"; # red - Variables, XML Tags, Markup Link Text, Markup Lists, Diff Deleted
            base09 = "aa573c"; # orange - Integers, Boolean, Constants, XML Attributes, Markup Link Url
            base0A = "a06e3b"; # yellow - Classes, Markup Bold, Search Text Background
            base0B = "2a9292"; # green - Strings, Inherited Class, Markup Code, Diff Inserted
            base0C = "398bc6"; # cyan - Support, Regular Expressions, Escape Characters, Markup Quotes
            base0D = "576ddb"; # magenta - Functions, Methods, Attribute IDs, Headings
            base0E = "955ae7"; # blue - Keywords, Storage, Selector, Markup Italic, Diff Changed
            base0F = "bf40bf"; # white - Deprecated, Opening/Closing Embedded Language Tags, e.g. <?php ?>
          };
        };
      };
    };
  # Keep only hex strings
  hexStrOnly =
    attrSet:
    filterAttrs (n: v: (builtins.typeOf v == "string") && (builtins.stringLength v == 6)) attrSet;
  # Superset of theme colors with helpers + overrides
  genColors' =
    theme: overrides:
    with theme;
    (hexStrOnly theme)
    // {
      # Useful Helpers
      primary = magenta;
      secondary = cyan;
    }
    // overrides;
in
{
  # options.themes.base16 = mkOption {
  #   type = types.submoduleWith {
  #     modules = [
  #       themeModule
  #       {
  #         options.programs = mkOption {
  #           type = types.attrsOf (types.submodule themeModule);
  #           default = { };
  #           description = mdDoc "program specific overrides";
  #         };
  #       }
  #     ];
  #   };
  #
  # };
  # options.themes.base16 = with types; (themeOpts { }).options // {
  #   programs = mkOption {
  #     type = attrsOf (submodule themeOpts);
  #     default = { };
  #     description = mdDoc "program specific overrides";
  #   };
  # };

  # config.lib.base16 = rec {
  #   # Common options
  #   theme = defaultTheme;
  #   colors = genColors' theme globalCfg.colors;
  #   colorsH = mapAttrs (name: value: "#${value}") colors;
  #   template = repo: createTemplate' { inherit repo; };
  #
  #   programs = mapAttrs
  #     (name: localCfg:
  #       let
  #         cfg = recursiveUpdate globalCfg localCfg;
  #       in
  #       rec {
  #         theme = with cfg; genTheme' {
  #           inherit scheme variant localTheme;
  #           overrides = extraParams;
  #         };
  #         template = repo: createTemplate' {
  #           inherit repo;
  #           theme = theme;
  #         };
  #         customTemplate = repo: { repo ? repo, theme ? theme, templateName ? "default.mustache" }:
  #           createTemplate' {
  #             inherit repo theme templateName;
  #           };
  #         colors = genColors' theme cfg.colors;
  #         colorsH = mapAttrs (name: value: "#${value}") colors;
  #         extraParams = globalCfg.extraParams // cfg.extraParams;
  #       })
  #     globalCfg.programs;
  #
  #   getColors = program: if hasAttr program programs then programs.${program}.colors else colors;
  #   getColorsH = program: if hasAttr program programs then programs.${program}.colorsH else colorsH;
  #   getTheme = program: if hasAttr program programs then programs.${program}.theme else theme;
  #   getTemplate = program: if hasAttr program programs then programs.${program}.template program else template program;
  #   getCustomTemplate = program: if hasAttr program programs then programs.${program}.customTemplate program else createTemplate';
  #
  #
  #
  #   # Helper functions
  #   customTemplate = createTemplate';
  #   genTheme = genTheme';
  #   importYAML = importYAML';
  # };
}
