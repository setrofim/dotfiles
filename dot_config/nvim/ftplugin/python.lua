---@diagnostic disable-next-line: undefined-global
local vim = vim

vim.keymap.set('n', '<F7>', 'Oimport ipdb; ipdb.set_trace()  # XXX<Esc>')
-- TODO: ideally this should be <s-F7> or <c-F7>, but neither mapping appears
-- to work (possible term issue?)
vim.keymap.set('n', '<F6>', 'oimport ipdb; ipdb.set_trace()  # XXX<Esc>')
vim.keymap.set('i', '<F7>', 'import ipdb; ipdb.set_trace()  # XXX<Esc>')
