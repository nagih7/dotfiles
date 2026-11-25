---@type LazySpec
return {
  "WhoIsSethDaniel/mason-tool-installer.nvim",
  opts = {
    ---@type Mason.Package[]
    ensure_installed = {
      "nil", -- Used for LSP (nil_ls), already listed in preferences.lsp.force
      "nixfmt", -- RFC 166 formatter, the nixpkgs standard
    },
  },
  opts_extend = {
    "ensure_installed",
  },
  optional = true,
}
