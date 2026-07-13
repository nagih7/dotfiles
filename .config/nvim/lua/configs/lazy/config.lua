---@type LazyConfig
return {
  -- Lockfile outside config dir so it's writable when config is a Nix store path (read-only).
  lockfile = vim.fn.stdpath("data") .. "/lazy-lock.json",

  defaults = {
    lazy = true,
  },
  install = {
    colorscheme = {
      "nvchad",
    },
  },

  rock = {
    hererocks = false, -- NixOS: use system luarocks instead of downloading hererocks
  },

  ui = {
    backdrop = 100,
    border = vim.o.winborder,
    icons = {
      ft = "",
      lazy = "󰂠 ",
      loaded = "",
      not_loaded = "",
    },
  },

  change_detection = {
    enabled = true,
    notify = false,
  },

  checker = {
    enabled = true,
    notify = false,
    frequency = 604800, -- 7 days
  },

  performance = {
    rtp = {
      disabled_plugins = {
        "2html_plugin",
        "tohtml",
        "getscript",
        "getscriptPlugin",
        "gzip",
        "logipat",
        "netrw",
        "netrwPlugin",
        "netrwSettings",
        "netrwFileHandlers",
        "matchit",
        "tar",
        "tarPlugin",
        "rrhelper",
        "spellfile_plugin",
        "vimball",
        "vimballPlugin",
        "zip",
        "zipPlugin",
        "tutor",
        "rplugin",
        "syntax",
        "synmenu",
        "optwin",
        "compiler",
        "bugreport",
        "ftplugin",
      },
    },
  },
}
