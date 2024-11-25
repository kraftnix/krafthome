local ls = require("luasnip")
-- some shorthands...
local s = ls.snippet
local n = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node

local makeMkOption = function (optionName, indent)
  local option = optionName or "option";
  local description = "`" .. option .. "` option.";
  indent = indent or ""
  return fmta (
    [[
    mkOption {
      <>default = <>;
      <>description = "<>";
      <>type = <>;
    <>};<>
    ]],
    {
      t(indent),
      i(1, "true"),
      t(indent),
      i(2, description),
      t(indent),
      i(3, "types.bool"),
      t(indent),
      i(0),
    }
  )
end

local dynamic_mirror = function (pos, valuePos, func)
  local genObj = func or (function (basicString)
    return i(1, basicString)
  end)
  return d(
    pos,
    function (args)
      return sn(nil, genObj(args[1][1]))
    end,
    { valuePos }
  )
end

local snippets = {
  -- mysnips.mkOption.snippet,
  s({
    trig = "snip-mkOption",
    namr = "mkOption object",
    dscr = "Create a default mkOption structure"
  }, makeMkOption()),


  -- default new module file
  s({
    trig = "snip-options",
    namr = "mkOption object",
    dscr = "Create a default mkOption structure"
  }, fmta (
    [[
      options = {
        <> = <>
      };
    ]],
    {
      i(1, "myopt"),
      -- sn(2, mysnips.mkOption.opts)
      dynamic_mirror(2, 1, function (args)
        return makeMkOption(args, "\t")
      end)
    }
  )),

  -- default new module file
  s({
    trig = "snip-newmodule",
    namr = "newfile object",
    dscr = "Create a default mkOption structure"
  }, fmta (
    [[
      { config, lib, ... }:
      let
        cfg = config.<>;
        l = lib;
        inherit (lib)
          mkOption
          types
          ;
      in
      {
        options.<> = {
          enable = mkEnableOption "Enable <>";
          <> = mkOption {
            default = <>;
            description = "<>";
            type = <>;
          };
          <>
        };

        config = mkIf cfg.enable {

        };
      }
    ]],
    {
      i(1, "my-module"),
      rep(1),
      dynamic_mirror(2, 1, function (opt)
        return i(1, "`" .. opt .. "`")
      end),
      i(3, "my-option"),
      i(4, "true"),
      dynamic_mirror(5, 3, function (opt)
        return i(1, "`" .. opt .. "` option.")
      end),
      i(6, "types.bool"),
      i(0)
    }
  )),

  -- default new module file
  s({
      trig = "snip-newfile",
      namr = "newfile object",
      dscr = "Create a default mkOption structure"
    },
    fmta(
      [[
        { config, lib, ... }: {
          l = lib;
          inherit (lib)
            ;
          in
        {
          <>
        }
      ]],
    { i(0) }
  )),

  -- { config, ... } {}
  s({
    trig = "snip-config-closure",
    namr = "Config closure",
    dscr = "Create a config closure"
  }, fmta(
    [[
      { config, ... }: {
        <>
      }<>
    ]],
    { i(1), i(0) }
  )),

  -- submoduleWith
  s({
    trig = "snip-submoduleWith",
    namr = "Config closure",
    dscr = "Create a config closure"
  }, fmta(
    [[
      submoduleWith {
        modules = [
          <>
        ];
      }<>
    ]],
    { i(1), i(0) }
  )),

  -- -> { inherit ; }
  s({
    trig = "snip-inherit",
    namr = "inherit closure",
  }, fmta(
    [[
      {
        inherit <>;
      }<>
    ]],
    { i(1), i(0) }
  )),

  -- pipe
  s({
    trig = "snip-pipe",
    namr = "inherit closure",
  }, fmta(
    [[
      lib.pipe <> [
        <>
        <>
      ];
    ]],
    {
      i(1, "{}"),
      i(2, "(filterAttrs (_: c: c.enable))"),
      i(3, "(mapAttrs (_: c: c.myval))"),
    }
  )),

  -- pipe
  s({
    trig = "snip-pipe-filter-map",
    namr = "inherit closure",
  }, fmta(
    [[
      lib.pipe <> [
        (filterAttrs (<>: <>: <>))
        (mapAttrs (<>: <>: <>))
      ];
    ]],
    {
      i(1, "{}"),
      i(2, "n"),
      i(3, "v"),
      dynamic_mirror(4, 3, function (attrs)
        return {
          t(attrs .. "."),
          i(1, "enable")
        }
      end),
      dynamic_mirror(5, 2),
      dynamic_mirror(6, 3),
      dynamic_mirror(7, 6, function (attrs)
        return {
          t(attrs .. "."),
          i(1, "value")
        }
      end),
    }
  )),

  -- pipe
  s({
    trig = "snip-pipe-filter-map-enable",
    namr = "inherit closure",
  }, fmta(
    [[
      lib.pipe <> [
        (filterAttrs (_: c: c.<>))
        (mapAttrs (_: c: c.<>))
      ];
    ]],
    {
      i(1, "{}"),
      i(2, "enable"),
      i(3, "myval"),
    }
  )),

  -- mapAttrs
  s({
    trig = "snip-mapAttrs",
    namr = "mapAttrs",
  }, fmta(
    [[
      mapAttrs (<>: <>: <>) <>
    ]],
    {
      i(1, "_"),
      i(2, "c"),
      dynamic_mirror(3, 2, function (attrs)
        return {
          t(attrs .. "."),
          i(1, "val")
        }
      end),
      i(4, "{};"),
    }
  )),

  -- concatStringsSep
  s({
    trig = "snip-concatStringsSep",
    namr = "concatStringsSep",
  }, fmta(
    [[
      concatStringsSep "<>" (<>)
    ]],
    {
      i(1, "\\n"),
      i(2, ""),
    }
  )),

  -- map
  s({
    trig = "snip-map",
    namr = "map",
  }, fmta(
    [[
      map (<>: <>) <>
    ]],
    {
      i(1, "x"),
      dynamic_mirror(2, 1, function (attrs)
        return {
          t(attrs .. "."),
          i(1, "val")
        }
      end),
      i(3, "[];"),
    }
  )),

  -- -- fold
  -- s({
  --   trig = "snip-pipe-filter-map-enable",
  --   namr = "inherit closure",
  -- }, fmta(
  --   [[
  --     lib.foldlAttrs
  --       (acc: name: value:
  --         lib.recursiveUpdate acc (optionalAttrs (lib.hasAttr network.name value.networks) {
  --           ${name} = value.networks.${network.name};
  --         })
  --       )
  --       { }
  --       hosts
  --     ;
  --
  --
  --     lib.pipe <> [
  --       (filterAttrs (_: c: c.<>))
  --       (mapAttrs (_: c: c.<>))
  --     ];
  --   ]],
  --   {
  --     i(1, "{}"),
  --     i(2, "enable"),
  --     i(3, "myval"),
  --   }
  -- )),

}

return snippets
