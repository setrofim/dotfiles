-- see:
--    https://github.com/folke/lazy.nvim
--
---@diagnostic disable-next-line: undefined-global
local vim = vim

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
    'wbthomason/packer.nvim', -- plugin manager (can manage itself)

    -- debug
    {
      "mfussenegger/nvim-dap",
      dependencies = {
            'nvim-neotest/nvim-nio', -- async I/O (required for nvim-dap-ui)
            'rcarriga/nvim-dap-ui',
        },
    },

    'ldelossa/nvim-dap-projects', -- per-project debug configuration
    'mfussenegger/nvim-dap-python', -- Python debug
    'leoluz/nvim-dap-go', -- Go debug

    -- misc
    'mfussenegger/nvim-jdtls', -- java language server
    'nvim-lua/plenary.nvim', -- additional lua functions
    'neovim/nvim-lspconfig', -- language server configuration
    'rafaqz/ranger.vim',  -- use ranger as file browser
    'ellisonleao/gruvbox.nvim', -- colorscheme
    'jlanzarotta/bufexplorer', -- better buffer navigation
    'echasnovski/mini.map', -- mini map (buffer text overview)
    'tpope/vim-fugitive', -- git integration
    'scrooloose/nerdcommenter', -- code commenting
    'nielsadb/vim-filtering', -- filter lines in buffer
    'stevearc/aerial.nvim', -- code outliner (tagbar replacement)
    'AndrewRadev/sideways.vim', -- move function args, etc. around
    'jsborjesson/vim-uppercase-sql', -- auto-cap SQL (*sigh* it's bad that I write enough SQL for this to be useful)
    'kylechui/nvim-surround', -- add, remove, and change sourrounding brackets/parents/tags/etc.

    -- fuzzy search
    {
        'nvim-telescope/telescope.nvim',
        tag = '0.1.5',
        dependencies = {
            'nvim-lua/plenary.nvim',
            'ryanoasis/vim-devicons',
        },
    },

    -- powerline-like status bar
    {
        'vim-airline/vim-airline',
        dependencies = {
            'vim-airline/vim-airline-themes',
            'nvim-tree/nvim-web-devicons',
            'ryanoasis/vim-devicons',
            'nvim-treesitter/nvim-treesitter',
            'sharkdp/fd',
        },
    },
    'nvim-tree/nvim-web-devicons', -- additional icons
    'ryanoasis/vim-devicons', -- additional icons

    -- tree-sitter AST integration (requried for aerial below)
    {
        'nvim-treesitter/nvim-treesitter',
        build = ':TSUpdate',
    },

    -- autocompletion
    'neovim/nvim-lspconfig',
    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-buffer',
    'hrsh7th/cmp-path',
    'hrsh7th/cmp-cmdline',
    'hrsh7th/nvim-cmp',
    'hrsh7th/cmp-vsnip',
    'hrsh7th/vim-vsnip',

    -- syntax highlighting
    'trapd00r/irc.vim', -- IRC logs
    'Glench/Vim-Jinja2-Syntax', -- jinja2 templates
    'vim-scripts/django.vim', -- Django templates
    'tsandall/vim-rego', -- rego (OPA policy language)
    'aklt/plantuml-syntax', -- PlantUML
    'nathanalderson/yang.vim', -- YANG
    'nblock/vim-dokuwiki', -- DokuWiki
})

-- vim: set et sts=4 sw=4:
