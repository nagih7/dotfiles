---@type LazySpec
return {
  name = "UI",
  {
    "NvChad/ui",
    lazy = false,
    config = function()
      require("nvchad")
    end,
    dependencies = "nvim-lua/plenary.nvim",
  },
  {
    "nvchad/base46",
    lazy = false,
    build = function()
      require("base46").load_all_highlights()
    end,
    keys = {
      {
        "<leader>ur",
        function()
          require("base46").load_all_highlights()
        end,
        desc = "Utils | Refresh UI (NvChad)",
        silent = true,
      },
      {
        "<leader>ot",
        function()
          require("base46").toggle_theme()
          vim.notify(vim.g.icon_toggled and "Light" or "Dark", vim.log.levels.INFO, { title = "Theme", id = "base46_theme" })
        end,
        desc = "Options | Toggle Theme",
        silent = true,
      },
      {
        "<leader>oT",
        function()
          require("base46").toggle_transparency()
          vim.notify(require("nvconfig").base46.transparency and "Enabled" or "Disabled", vim.log.levels.INFO, { title = "Transparency", id = "base46_transparency" })
        end,
        desc = "Options | Toggle Theme",
        silent = true,
      },
    },
    -- vim.g.base46_cache is set in core.globals, before lazy loads, so build hooks see it too.
    config = function()
      local base46_cache = vim.g.base46_cache

      -- Nothing compiled yet (fresh install, or a build hook that failed): compile now,
      -- otherwise readdir() aborts startup with E484 and the UI loads unthemed.
      if vim.fn.isdirectory(base46_cache) == 0 or vim.tbl_isempty(vim.fn.readdir(base46_cache)) then
        require("base46").load_all_highlights()
        return
      end

      for _, v in ipairs(vim.fn.readdir(base46_cache)) do
        dofile(string.format("%s/%s", base46_cache, v))
      end
    end,
  },
}
