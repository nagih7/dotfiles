-- WARN: You need to fill all of them. Even empty list/table

---@type Preferences
local M = {
  lsp = {
    -- Servers to force-enable. filter_availabled_external=true means binary must be in PATH.
    -- after/lsp/<server>.lua provides per-server settings automatically.
    force = {
      "sonarlint",    -- custom cmd in after/lsp/sonarlint.lua
      "nil_ls",       -- Nix: nil
      "gopls",        -- Nix: gopls
      "vtsls",        -- Nix: vtsls (TypeScript)
      "basedpyright", -- Nix: basedpyright (Python static analysis)
      "ruff",         -- Nix: ruff (Python linter/formatter as LSP)
      "rust_analyzer",-- Nix: rust-analyzer
      "cssls",        -- Nix: vscode-langservers-extracted
      "html",
      "jsonls",
      "eslint",
      "terraformls",  -- Nix: terraform-ls
      "helm_ls",      -- Nix: helm-ls (via qvalentin/helm-ls.nvim or binary)
      "clangd",       -- Nix: clang-tools (C/C++)
    },
    exclude = {
      "dartls",
      "jdtls",
      "sqls",
    },
  },

  options = {
    indent = {
      default = 2,
      space = {
        [4] = {
          "c",
          "cpp",
          "cs",
          "groovy",
          "java",
          "jenkins",
          "kotlin",
          "python",
        },
        [2] = {
          "just",
        },
      },
      tab = {},
    },

    wrap = {
      default = true,
      revert = {
        "grug-far",
        "lazy",
        "log",
        "markdown",
        "mason",
      },
    },

    inlay_hint = {
      server_default = true,
      servers = true,
      client = false,
    },

    semantic_tokens = {
      server_default = true,
      servers = {
        gopls = true,
        vtsls = false,
      },
      client = true,
    },

    others = {
      auto_format_enabled = true,
      ai_suggestion_enabled = false,
      filter_availabled_external = true,
    },
  },
}

return M
