local filter_availabled_external = require("preferences").options.others.filter_availabled_external
local is_executable = require("utils.executable").is_executable
local lsp = require("configs.lsp")
local lsps = require("preferences").lsp.force

---Keep a forced server only when its binary is actually reachable.
---The `pcall` guards servers with no resolvable config or a function-style `cmd`;
---those cannot be probed, so they are let through and left to nvim to resolve.
---@param server_name string
---@return boolean
local function filter_executable(server_name)
  local success, result = pcall(function()
    return is_executable(vim.lsp.config[server_name].cmd[1])
  end)
  return not success or result
end

local function setup_custom_lsps()
  for _, server_name in pairs(lsps) do
    if filter_availabled_external == false or filter_executable(server_name) then
      vim.lsp.config(server_name, lsp.opts)
      vim.lsp.enable(server_name)
    end
  end
end

---@type LazySpec
return {
  "neovim/nvim-lspconfig",
  event = {
    "BufRead",
    "BufNewFile",
  },
  keys = {
    {
      "<leader>li",
      "<cmd>LspInfo<cr>",
      desc = "LSP | Info",
      silent = true,
    },
  },
  config = function()
    require("nvchad.configs.lspconfig").defaults() -- lua_ls settings + global nvchad capabilities
    lsp.setup()
    setup_custom_lsps()
  end,
}
