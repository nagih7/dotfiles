local g = vim.g
local preferences_options = require("preferences").options

-- Rainbow-delimiters: nvim 0.12 changed get_parser to return nil instead of throwing.
-- Set condition early (before plugins load) so the autocmd guard fires before lib.attach.
g.rainbow_delimiters = {
  condition = function(bufnr)
    if vim.bo[bufnr].buftype ~= "" then return false end
    local lang = vim.treesitter.language.get_lang(vim.bo[bufnr].ft)
    if not lang then return false end
    local ok, parser = pcall(vim.treesitter.get_parser, bufnr, lang, { error = false })
    return ok and parser ~= nil
  end,
}

g.markdown_recommended_style = 0
g.health = {
  style = nil, ---@type "float" | nil
}

g.loaded_node_provider = 0
g.loaded_python3_provider = 0
g.loaded_perl_provider = 0
g.loaded_ruby_provider = 0

g.auto_format_enabled = preferences_options.others.auto_format_enabled
