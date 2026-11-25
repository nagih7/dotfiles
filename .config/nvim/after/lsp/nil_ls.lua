---@diagnostic disable: missing-fields

---@type vim.lsp.Config
return {
  settings = {
    ["nil"] = {
      ---nil has no formatter of its own; point it at the same one conform uses
      ---so `vim.lsp.buf.format()` and the conform path agree.
      formatting = {
        command = { "nixfmt" },
      },
      nix = {
        flake = {
          ---Re-evaluate the flake on save so inputs resolve without a restart.
          autoEvalInputs = true,
        },
      },
    },
  },
}
