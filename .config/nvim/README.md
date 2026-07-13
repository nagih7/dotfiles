# Neovim Config

Personal Neovim configuration built on top of [NvChad](https://github.com/NvChad/NvChad), managed with [lazy.nvim](https://github.com/folke/lazy.nvim).

**Theme:** Catppuccin (toggle: One Light) · **Completion:** blink-cmp · **LSP:** native vim.lsp

---

## Structure

```
nvim/
├── init.lua                  # Entry point
├── chadrc.lua                # NvChad UI config (theme, statusline, dashboard)
├── justfile                  # Task runner shortcuts
│
├── lua/
│   ├── core/                 # Neovim core settings
│   │   ├── options.lua       # vim.opt / vim.o settings
│   │   ├── keymaps.lua       # Global keymaps
│   │   ├── autocmds.lua      # Autocommands
│   │   ├── commands.lua      # Custom user commands
│   │   ├── globals.lua       # Global helpers
│   │   └── env.lua           # Environment detection
│   │
│   ├── configs/              # Feature configurations
│   │   ├── lazy/             # lazy.nvim bootstrap & config
│   │   ├── lsp/              # LSP setup & autocmds
│   │   ├── diagnostic/       # Diagnostic display config
│   │   ├── runner/           # Code runner per language (go, python, ts, c/cpp, etc.)
│   │   └── ui/
│   │       ├── nvdash/       # Dashboard (header, buttons)
│   │       ├── statusline/   # Custom statusline modules
│   │       └── tabufline/    # Buffer/tab line
│   │
│   ├── plugins/
│   │   ├── init.lua          # Root plugin spec
│   │   └── extras/           # Modular plugin groups (toggle per group)
│   │       ├── blink/        # Completion sources
│   │       ├── coding/       # Formatter (conform) + linter (nvim-lint)
│   │       ├── dap/          # Debug Adapter Protocol (nvim-dap, dap-ui)
│   │       ├── git/          # gitsigns, diffview, mini-diff
│   │       ├── languages/    # Per-language tooling (see below)
│   │       ├── lsp/          # Trouble, etc.
│   │       ├── motion/       # Flash, surround, treesj, dial, multi-cursor, etc.
│   │       ├── others/       # oil, auto-session, ufo, cloak, tmux-nav, etc.
│   │       ├── telescope/    # Telescope extensions
│   │       └── ui/           # which-key, noice, todo-comments, rainbow, etc.
│   │
│   └── overseer/
│       └── template/default/ # Overseer task templates (go, cpp, nodejs)
│
├── after/lsp/                # Per-LSP server configs (gopls, vtsls, basedpyright, etc.)
├── ftplugin/                 # Filetype-specific overrides (go, json, dotenv, etc.)
└── ftdetect/filetypes.lua    # Custom filetype detection
```

---

## Language Support

| Language        | LSP                     | Formatter       | Linter             | Debug           |
| --------------- | ----------------------- | --------------- | ------------------ | --------------- |
| Go              | gopls                   | gofmt/goimports | golangci-lint      | nvim-dap        |
| Python          | basedpyright / pyright  | ruff            | ruff               | nvim-dap-python |
| TypeScript/JS   | vtsls / denols / eslint | prettier        | eslint             | —               |
| C/C++           | clangd                  | clang-format    | —                  | —               |
| Lua             | lua_ls                  | stylua          | —                  | —               |
| Terraform / HCL | —                       | terraform_fmt   | trivy              | —               |
| Ansible         | —                       | —               | ansible-lint       | —               |
| Helm            | helm_ls                 | —               | —                  | —               |
| Docker          | —                       | —               | hadolint           | —               |
| YAML            | —                       | prettier        | —                  | —               |
| JSON            | jsonls                  | prettier        | —                  | —               |
| Groovy          | groovyls                | —               | —                  | —               |
| Jenkins         | —                       | —               | jenkinsfile-linter | —               |
| GraphQL         | —                       | —               | —                  | —               |
| Kubernetes      | —                       | —               | —                  | —               |

---

## Key Plugins

- **UI:** NvChad base46, Noice, which-key, todo-comments, rainbow-delimiters
- **Navigation:** Flash, oil.nvim, Telescope + fzf-native, Snacks picker
- **Editor:** nvim-surround, treesj, nvim-ufo (folding), autopairs, guess-indent
- **Git:** gitsigns, diffview, mini-diff
- **Tasks:** overseer.nvim (Go, C++, Node.js templates)
- **Session:** auto-session

---

## Requirements

- Neovim >= 0.10
- `git`, `ripgrep` (`rg`), `fd`
- A [Nerd Font](https://www.nerdfonts.com/) for icons
- Language-specific tools installed via Mason or system package manager
