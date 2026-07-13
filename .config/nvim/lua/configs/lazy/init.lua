local lazypath = string.format("%s/lazy/lazy.nvim", vim.fn.stdpath("data"))

if not vim.uv.fs_stat(lazypath) then
  local repo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system({ "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath })
end

vim.opt.rtp:prepend(lazypath)

-- Seed lockfile from config dir (may be Nix store) on fresh install so plugin versions are pinned.
local data_lockfile = vim.fn.stdpath("data") .. "/lazy-lock.json"
if not vim.uv.fs_stat(data_lockfile) then
  local src = vim.fn.stdpath("config") .. "/lazy-lock.json"
  local fd = io.open(src, "r")
  if fd then
    local content = fd:read("*a")
    fd:close()
    local out = io.open(data_lockfile, "w")
    if out then
      out:write(content)
      out:close()
    end
  end
end

-- load plugins
require("lazy").setup({
  {
    "NvChad/NvChad",
    optional = true,
  },
  {
    import = "plugins.init",
  },
}, require("configs.lazy.config"))
