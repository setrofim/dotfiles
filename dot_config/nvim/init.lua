-- The following re-definition is to suppress undefined-global warnings just for "vim" throughout the file
---@diagnostic disable-next-line: undefined-global
local vim = vim

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

vim.keymap.set('n', '<leader>e', ':tabe %<CR>')

vim.keymap.set('n', '<leader><C-r>', ':luafile ~/.config/nvim/init.lua<CR>')

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
vim.keymap.set("n", "]e", function()
    vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR })
end)
vim.keymap.set("n", "[e", function()
    vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR })
end)
vim.keymap.set("n", "]w", function()
    vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.WARNING })
end)
vim.keymap.set("n", "[w", function()
    vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.WARNING })
end)
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
vim.keymap.set('n', '<leader>dt', [[:let _s=@/<Bar>:%s/\s\+$//e<Bar>:let @/=_s<Bar><CR>]])

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

-- autocompletion / cmp (needs to happend before lsp setup -- see capabilities below
local cmp = require('cmp')

cmp.setup({
    snippet = {
        -- REQUIRED - you must specify a snippet engine
        expand = function(args)
            vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
            -- require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
            -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
            -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
        end,
    },
    window = {
        -- completion = cmp.config.window.bordered(),
        -- documentation = cmp.config.window.bordered(),
    },
    mapping = cmp.mapping.preset.insert({
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.abort(),
        ['<CR>'] = cmp.mapping.confirm({ select = false }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    }),
    sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'vsnip' }, -- For vsnip users.
        -- { name = 'luasnip' }, -- For luasnip users.
        -- { name = 'ultisnips' }, -- For ultisnips users.
        -- { name = 'snippy' }, -- For snippy users.
    }, {
        { name = 'buffer' },
    })
})

-- Set configuration for specific filetype.
cmp.setup.filetype('gitcommit', {
    sources = cmp.config.sources({
        { name = 'git' }, -- You can specify the `git` source if [you were installed it](https://github.com/petertriho/cmp-git).
    }, {
        { name = 'buffer' },
    })
})

-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline({ '/', '?' }, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
        { name = 'buffer' }
    }
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
        { name = 'path' }
    }, {
        { name = 'cmdline' }
    })
})

-- Set up lspconfig.
local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- lauguage servers
require('lspconfig').pyright.setup{ capabilities = capabilities }
require('lspconfig').gopls.setup{ capabilities = capabilities }
require('lspconfig').rust_analyzer.setup{ capabilities = capabilities }
require('lspconfig').ccls.setup{ capabilities = capabilities }
require('lspconfig').bashls.setup{
    capabilities = capabilities,
    filetypes = { "sh", "bash"},
}
require('lspconfig').lua_ls.setup{
    capabilities = capabilities,
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
        vim.o.signcolumn = 'yes'
        vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

        -- Buffer local mappings.
        -- See `:help vim.lsp.*` for documentation on any of the below functions
        local opts = { buffer = ev.buf }
        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
        vim.keymap.set('n', '<C-K>', vim.lsp.buf.signature_help, opts)
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

-- colorscheme / gruvbox
vim.opt.background = 'dark'
vim.g.gruvbox_improved_strings = 1
vim.g.gruvbox_improved_warnings = 1

local gruvbox = require("gruvbox")
gruvbox.setup({
    overrides = {
        SignColumn = { bg = gruvbox.palette.dark0 },
        GruvboxRedSign = { fg = gruvbox.palette.red, bg = gruvbox.palette.dark0 },
        GruvboxYellowSign = { fg = gruvbox.palette.yellow, bg = gruvbox.palette.dark0 },
        GruvboxBlueSign = { fg = gruvbox.palette.blue, bg = gruvbox.palette.dark0 },
        GruvboxAquaSign = { fg = gruvbox.palette.aqua, bg = gruvbox.palette.dark0 },
    }
})
vim.cmd('colorscheme gruvbox')

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

-- vim-filtering
vim.cmd([[
function! FilterUserInput()
    let obj =  FilteringNew()
    call obj.parseQuery(input('>'), '|')
    call obj.run()
endfunction
]])
vim.keymap.set('n', ',F', ':call FilterUserInput()<CR>')
vim.keymap.set('n', ',v', ":call FilteringNew().addToParameter('alt', expand(\"<cword>\")).run()<CR>")
--vim.keymap.set('n', ',F', ":call FilteringNew().addToParameter('alt', @/).run()<CR>")
--vim.keymap.set('n', ',g', ':call FilteringGetForSource().return()<CR>')

-- telescope
local telescope = require('telescope.builtin')
vim.keymap.set('n', ',ff', telescope.find_files, {})
vim.keymap.set('n', '<C-p>', telescope.find_files, {}) -- muscle memory from years of using ctrlp plugin
vim.keymap.set('n', ',fg', telescope.live_grep, {})
vim.keymap.set('n', ',fb', telescope.buffers, {})
vim.keymap.set('n', ',fh', telescope.help_tags, {})
vim.keymap.set('n', ',fB', telescope.git_bcommits, {})
vim.keymap.set('n', ',fC', telescope.git_commits, {})
vim.keymap.set('n', ',fM', telescope.marks, {})
vim.keymap.set('n', ',fm', telescope.keymaps, {})

vim.keymap.set('n', ',fi', telescope.lsp_incoming_calls, {})
vim.keymap.set('n', ',fo', telescope.lsp_outgoing_calls, {})
vim.keymap.set('n', ',fd', telescope.lsp_definitions, {})
vim.keymap.set('n', ',fs', telescope.lsp_dynamic_workspace_symbols, {})
vim.keymap.set('n', ',fr', telescope.lsp_references, {})
vim.keymap.set('n', ',fI', telescope.lsp_implementations, {})
vim.keymap.set('n', ',fD', telescope.diagnostics, {})

-- treesitter
require('nvim-treesitter.configs').setup({
    -- A directory to install the parsers into.
    -- If this is excluded or nil parsers are installed
    -- to either the package dir, or the "site" dir.
    -- If a custom path is used (not nil) it must be added to the runtimepath.
    parser_install_dir = "~/.cache/treesitter",

    -- A list of parser names, or "all"
    -- ensure_installed = { "c", "java", "kotlin", "lua", "go", "python", "rust" },

    -- Install parsers synchronously (only applied to `ensure_installed`)
    sync_install = false,

    -- Automatically install missing parsers when entering buffer
    auto_install = true,

    highlight = {
        -- `false` will disable the whole extension
        enable = true,

        -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
        -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
        -- Using this option may slow down your editor, and you may see some duplicate highlights.
        -- Instead of true it can also be a list of languages
        additional_vim_regex_highlighting = false,
    },
})
vim.opt.runtimepath:append("~/.cache/treesitter")

require('nvim-surround').setup()

-- Debug Adapter Protocol (DAP) configuration
-- should happen after colorscheme loading to ensure correct colors in the UI
require('dapconfig')

-- centerpad
vim.api.nvim_set_keymap('n', '<leader>z', '<cmd>Centerpad 100<cr>', { silent = true, noremap = true })
