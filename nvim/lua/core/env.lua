local path_delimiter = require("utils.os").path_delimiter
local path_separator = require("utils.os").path_separator

local function prepend_if_exists(dir)
  if vim.uv.fs_stat(dir) then
    vim.env.PATH = dir .. path_delimiter .. vim.env.PATH
  end
end

prepend_if_exists(table.concat({ vim.fn.stdpath("data"), "mason", "bin" }, path_separator))
prepend_if_exists(table.concat({ vim.fn.stdpath("data"), "lazy-rocks", "hererocks", "bin" }, path_separator))
