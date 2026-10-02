---@diagnostic disable-next-line: undefined-global
local vim = vim

if vim.b.did_indent then
  return
end
vim.b.did_indent = 1

vim.bo.indentexpr = "v:lua.require'cbordiag'.indent()"
vim.bo.formatexpr = "v:lua.require'cbordiag'.format()"
vim.bo.indentkeys = "0{,0},0[,0],!^F,o,O"
vim.bo.shiftwidth = 2
vim.bo.expandtab = true
