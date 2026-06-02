local is_nix = vim.fn.isdirectory("/nix/store") == 1
local writable_path = vim.fn.stdpath("data") .. "/treesitter-parsers"

return {
  {
    "nvim-treesitter/nvim-treesitter",
    name = "nvim-treesitter",

    lazy = false,
    priority = 1000,

    build = is_nix and nil or ":TSUpdate",

    -- init runs before config, so checkhealth sees the correct install dir
    init = function()
      vim.fn.mkdir(writable_path, "p")
      vim.opt.runtimepath:prepend(writable_path)
    end,

    opts = {
      highlight = { enable = true },
      indent = { enable = true },

      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "gsn",
          node_incremental = "gsi",
          node_decremental = "gsd",
          scope_incremental = "gss",
        },
      },

      textobjects = {
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            ["af"] = "@function.outer",
            ["if"] = "@function.inner",
            ["ac"] = "@class.outer",
            ["ic"] = "@class.inner",
          },
        },
      },

      -- Base parsers always needed (bundled with nvim on NixOS, installed on others)
      ensure_installed = {
        "vim", "vimdoc", "lua", "markdown", "markdown_inline", "bash", "regex", "c", "query",
      },
    },

    opts_extend = { "ensure_installed" },

    config = function(_, opts)
      opts.parser_install_dir = writable_path

      if is_nix then
        -- Don't auto-install; parsers are either Nix-bundled or installed via :TSInstall
        opts.auto_install = false
        opts.sync_install = false
      else
        opts.auto_install = true
      end

      local status_ok, configs = pcall(require, "nvim-treesitter.configs")
      if status_ok then
        configs.setup(opts)

        vim.treesitter.language.register("groovy", "jenkins")
        vim.treesitter.language.register("bash", "dotenv")
        vim.treesitter.language.register("bash", "zsh")
      end
    end,
  }
}