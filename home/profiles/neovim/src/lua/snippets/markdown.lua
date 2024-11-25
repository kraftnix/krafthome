local ls = require("luasnip")
-- some shorthands...
local s = ls.snippet
local n = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node

local date = function() return {os.date('%Y-%m-%d')} end
ls.add_snippets(nil, {
  all = {
  }
})
return {
  s({
      trig = "meta",
      namr = "Metadata",
      dscr = "Yaml metadata format for markdown"
    }, {
      t({"---",
      "title: "}), i(1, "note_title"), t({"",
      "author: "}), i(2, "author"), t({"",
      "date: "}), f(date, {}), t({"",
      "categories: ["}), i(3, ""), t({"]",
      "lastmod: "}), f(date, {}), t({"",
      "tags: ["}), i(4), t({"]",
      "comments: true",
      "---", ""}),
      i(0)
  }),
  s({trig = "table(%d+)x(%d+)", regTrig = true}, {
    d(1, function(args, snip)
        local nodes = {}
        local i_counter = 0
        local hlines = ""
        for _ = 1, snip.captures[2] do
            i_counter = i_counter + 1
            table.insert(nodes, t("| "))
            table.insert(nodes, i(i_counter, "Column".. i_counter))
            table.insert(nodes, t(" "))
            hlines = hlines .. "|---"
        end
        table.insert(nodes, t{"|", ""})
        hlines = hlines .. "|"
        table.insert(nodes, t{hlines, ""})
        for _ = 1, snip.captures[1] do
            for _ = 1, snip.captures[2] do
                i_counter = i_counter + 1
                table.insert(nodes, t("| "))
                table.insert(nodes, i(i_counter))
                print(i_counter)
                table.insert(nodes, t(" "))
            end
            table.insert(nodes, t{"|", ""})
        end
        return sn(nil, nodes)
    end)
  }),
}
