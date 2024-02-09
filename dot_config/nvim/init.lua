vim.o.number = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.modeline = true
vim.o.undofile = true
vim.o.hidden = true
vim.o.hlsearch = false
vim.o.encoding = 'UTF-8'

vim.opt.wildmode = {'longest', 'list', 'full'}
vim.opt.wildmenu = true

-- General keymaps
vim.g.C_Ctrl_j = 'off'

vim.keymap.set('n', '<C-j>', '<C-w>j')
vim.keymap.set('n', '<C-k>', '<C-w>k')
vim.keymap.set('n', '<C-l>', '<C-w>l')
vim.keymap.set('n', '<C-h>', '<C-w>h')

vim.keymap.set('c', '<C-a>', '<Home>')
vim.keymap.set('c', '<C-b>', '<Left>')
vim.keymap.set('c', '<C-f>', '<Right>')
vim.keymap.set('c', '<C-d>', '<Delete>')
vim.keymap.set('c', '<M-b>', '<S-Left>')
vim.keymap.set('c', '<M-f>', '<S-Right>')
vim.keymap.set('c', '<M-d>', '<S-Right><Delete>')
vim.keymap.set('c', '<C-g>', '<C-c>')

vim.keymap.set("n", "]g", vim.diagnostic.goto_next)
vim.keymap.set("n", "[g", vim.diagnostic.goto_prev)
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist)
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float)

function MapF1()
	if vim.bo.buftype == 'help' then
		vim.cmd('quit')
	else
		vim.cmd('help')
	end
end
vim.keymap.set('i', '<F1>', '<Esc>') -- I keep hitting this by mistake
vim.keymap.set('n', '<F1>', ':lua MapF1()<CR>')

-- insert current date and time
vim.keymap.set('n', '<F3>', 'a<C-R>=strftime("%Y-%m-%d %a %H:%M ")<CR><Esc>')
vim.keymap.set('i', '<F3>', '<C-R>=strftime("%Y-%m-%d %a %H:%M ")<CR>')

-- remove all trailing whitespace
vim.keymap.set('n', '<F12>', [[:let _s=@/<Bar>:%s/\s\+$//e<Bar>:let @/=_s<Bar><CR>]])

-- highlight trailing whitespace
vim.cmd([[
highlight Trail ctermbg=black guibg=darkred
call matchadd('Trail', '\s\+$', 100)
]])

local ft_maps = {
	{{'*dts', '*dtsi'}, 'set filetype=dts'},
	{{'*docker'}, 'set filetype=dockerfile'},
	{{'run.log'}, 'set filetype=walog'},
	{{'*.weechat'}, 'set filetype=irc'},
	{{'*.xaml'}, 'set filetype=xml'},
	{{'*.html'}, 'set filetype=htmljinja'},
	{{'*.md'}, 'set filetype=markdown'},
	{{'*.objdump'}, 'set filetype=objdump'},
	{{'*.sqlite*'}, 'set filetype=sqlite'},
	{{'*PULLREQ_EDITMSG'}, 'set spell textwidth=80'},
	{{'*COMMIT_EDITMSG'}, 'set spell textwidth=80'},
	{{'*.doku'}, 'set filetype=dokuwiki'},
	{{'*.tmpl'}, 'set filetype=jinja'},
	{{'*.rst'}, 'set filetype=rrst textwidth=80'},
}

for _, ftm in ipairs(ft_maps) do
	vim.api.nvim_create_autocmd(
		{'BufRead', 'BufNewFile'},
		{pattern = ftm[1], command = ftm[2]}
	)
end


-- Autocommmands

---
--  Plugin Config
---
-- airline (must be set before laoding plugins)
vim.g['airline#extensions#tabline#enabled'] = 1
vim.g['airline#extensions#whitespace#enabled'] = 1
vim.g['airline_powerline_fonts']= 1

require('plugins')

-- lauguage servers
require('lspconfig').pyright.setup{}
require('lspconfig').gopls.setup{}
require('lspconfig').rust_analyzer.setup{}
require('lspconfig').ccls.setup{}
require('lspconfig').bashls.setup{
	filetypes = { "sh", "bash"},
}
require('lspconfig').lua_ls.setup{
  on_init = function(client)
    local path = client.workspace_folders[1].name
    if not vim.loop.fs_stat(path..'/.luarc.json') and not vim.loop.fs_stat(path..'/.luarc.jsonc') then
      client.config.settings = vim.tbl_deep_extend('force', client.config.settings, {
        Lua = {
          runtime = {
            -- Tell the language server which version of Lua you're using
            -- (most likely LuaJIT in the case of Neovim)
            version = 'LuaJIT'
          },
          -- Make the server aware of Neovim runtime files
          workspace = {
            checkThirdParty = false,
            library = {
              vim.env.VIMRUNTIME
              -- "${3rd}/luv/library"
              -- "${3rd}/busted/library",
            }
            -- or pull in all of 'runtimepath'. NOTE: this is a lot slower
            -- library = vim.api.nvim_get_runtime_file("", true)
          }
        }
      })

      client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
    end
    return true
  end
}

-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    -- Enable completion triggered by <c-x><c-o>
    vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

    -- Buffer local mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    local opts = { buffer = ev.buf }
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
    vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
    vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
    vim.keymap.set('n', '<space>wl', function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, opts)
    vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
    vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    vim.keymap.set('n', '<space>f', function()
      vim.lsp.buf.format { async = true }
    end, opts)
  end,
})

-- colorscheme
vim.opt.background = 'dark'
vim.cmd('colorscheme gruvbox')
vim.g.gruvbox_improved_strings = 1
vim.g.gruvbox_improved_warnings = 1


-- ranger
vim.g.ranger_replace_netrw = 1
vim.keymap.set('n', '<leader>f', ':silent RangerEdit<CR>')


-- bufexplorer
vim.keymap.set('n', '<leader>ee', ':BufExplorer<CR>')
vim.keymap.set('n', '<leader>es', ':BufExplorerHorizontalSplit<CR>')
vim.keymap.set('n', '<leader>ev', ':BufExplorerVerticalSplit<CR>')

-- aerial
require('aerial').setup({
  show_guides = true,
  close_automatic_events = {'unfocus', 'switch_buffer', 'unsupported'},
  on_attach = function(bufnr)
    -- Jump forwards/backwards with '{' and '}'
    vim.keymap.set('n', '{', '<cmd>AerialPrev<CR>', {buffer = bufnr})
    vim.keymap.set('n', '}', '<cmd>AerialNext<CR>', {buffer = bufnr})
  end
})

vim.keymap.set('n', '<F8>', ':AerialToggle<CR>')

-- minimap
MiniMap = require("mini.map")

MiniMap.setup({
 symbols = {
   encode = MiniMap.gen_encode_symbols.dot('4x2'),
   scroll_view = '┋',
   scroll_line = '▶',
 },
})

vim.keymap.set('n', '<Leader>mc', MiniMap.close)
vim.keymap.set('n', '<Leader>mf', MiniMap.toggle_focus)
vim.keymap.set('n', '<Leader>mo', MiniMap.open)
vim.keymap.set('n', '<Leader>mr', MiniMap.refresh)
vim.keymap.set('n', '<Leader>ms', MiniMap.toggle_side)
vim.keymap.set('n', '<Leader>mt', MiniMap.toggle)

-- sideways.vim
vim.keymap.set('n', '<M-h>', ':SidewaysLeft<CR>')
vim.keymap.set('n', '<M-l>', ':SidewaysRight<CR>')

