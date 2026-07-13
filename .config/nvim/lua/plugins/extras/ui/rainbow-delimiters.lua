---@type LazySpec
return {
  "HiPhish/rainbow-delimiters.nvim",
  event = "VeryLazy",
  config = function()
    -- Primary guard is vim.g.rainbow_delimiters.condition set in core/globals.lua (pre-plugin).
    -- This is a defense-in-depth patch for the same nvim 0.12 nil-parser bug.
    -- Do NOT call setup() here — it would overwrite vim.g.rainbow_delimiters and lose the condition.
    local lib = require("rainbow-delimiters.lib")
    local orig_attach = lib.attach
    lib.attach = function(bufnr)
      local lang = vim.treesitter.language.get_lang(vim.bo[bufnr].ft)
      if not lang then return end
      local ok, parser = pcall(vim.treesitter.get_parser, bufnr, lang, { error = false })
      if not ok or not parser then return end
      orig_attach(bufnr)
    end
  end,
}
