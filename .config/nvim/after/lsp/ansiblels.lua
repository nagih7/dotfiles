---@diagnostic disable: missing-fields

---@type vim.lsp.Config
return {
  ---lspconfig ships only "yaml.ansible", but pearofducks/ansible-vim's ftdetect
  ---sets plain "ansible" on playbooks, so the server never attached. Keep both:
  ---"ansible" for ansible-vim, "yaml.ansible" for anything setting the compound ft.
  filetypes = {
    "ansible",
    "yaml.ansible",
  },
}
