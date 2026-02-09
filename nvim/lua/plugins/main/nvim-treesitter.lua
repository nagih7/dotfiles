-- File: lua/plugins/main/nvim-treesitter.lua
local is_nix = vim.fn.isdirectory("/nix/store") == 1

return {
  {
    "nvim-treesitter/nvim-treesitter",
    name = "nvim-treesitter",
    
    lazy = false,
    priority = 1000,
    
    build = is_nix and nil or ":TSUpdate",
    
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
    },
    
    config = function(_, opts)
      local writable_path = vim.fn.stdpath("data") .. "/treesitter-parsers"
      vim.fn.mkdir(writable_path, "p")
      
      vim.opt.runtimepath:prepend(writable_path)
      
      opts.parser_install_dir = writable_path

      if is_nix then
        opts.ensure_installed = {} 
        opts.auto_install = false
        opts.sync_install = false
      else
        opts.ensure_installed = { 
          "vim", "vimdoc", "lua", "markdown", "markdown_inline", "bash", "regex", "c", "query"
        }
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