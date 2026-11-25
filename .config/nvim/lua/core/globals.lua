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

-- base46 reads vim.g.base46_cache at module load (`local cache_path = vim.g.base46_cache`),
-- and on a fresh install lazy.nvim runs build hooks before plugin `init` hooks. Setting it
-- here, before configs.lazy, keeps the first-run compile from failing on a nil cache path.
g.base46_cache = string.format("%s/base46/", vim.fn.stdpath("data"))

-- Route "+/"* through OSC 52 on headless hosts: no xclip/wl-copy can work without a
-- DISPLAY, and nvim only auto-enables this when the terminal advertises osc52 in
-- g.termfeatures, which tmux/ssh often hides. Harmless where a real provider exists.
if vim.fn.has("unix") == 1 and vim.env.DISPLAY == nil and vim.env.WAYLAND_DISPLAY == nil then
  g.clipboard = "osc52"
end

g.markdown_recommended_style = 0
g.health = {
  style = nil, ---@type "float" | nil
}

g.loaded_node_provider = 0
g.loaded_python3_provider = 0
g.loaded_perl_provider = 0
g.loaded_ruby_provider = 0

g.auto_format_enabled = preferences_options.others.auto_format_enabled
