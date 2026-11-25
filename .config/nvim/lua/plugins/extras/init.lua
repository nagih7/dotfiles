local ide_mode = require("utils.os").ide_mode
local is_executable = require("utils.executable").is_executable

---@type LazySpec
return {
  -- Blink
  {
    name = "Blink",
    import = "plugins.extras.blink",
    enabled = true,
  },
  
  -- Coding (Conform, Linting)
  {
    name = "Coding",
    import = "plugins.extras.coding",
    enabled = true,
  },
  
  -- LSP (Trouble, etc.)
  {
    name = "LSP",
    import = "plugins.extras.lsp",
    enabled = true,
  },

  -- Mason (server/tool installer)
  -- NOTE: plugins/extras/mason/ has no init.lua, and lazy's `import` only picks up
  -- `*.lua` and `*/init.lua` under the imported module. Without this entry the whole
  -- group was never imported, so mason was not installed and every per-language
  -- mason-tool-installer spec (all marked `optional = true`) was a silent no-op.
  {
    name = "Mason",
    import = "plugins.extras.mason",
    enabled = true,
  },

  -- Git
  {
    name = "Git",
    import = "plugins.extras.git",
    enabled = true,
  },
  
  -- Motion
  {
    name = "Motion",
    import = "plugins.extras.motion",
    enabled = true,
  },
  
  -- Others
  {
    name = "Others",
    import = "plugins.extras.others",
    enabled = true,
  },
  
  -- Telescope
  {
    name = "Telescope",
    import = "plugins.extras.telescope",
    enabled = true,
  },
  
  -- UI
  {
    name = "UI",
    import = "plugins.extras.ui",
    enabled = true,
  },
}
