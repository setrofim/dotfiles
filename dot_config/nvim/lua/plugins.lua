-- see:
--    https://github.com/folke/lazy.nvim
--
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  'wbthomason/packer.nvim', -- plugin manager (can manage itself)

  'mfussenegger/nvim-dap', -- java debug
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
  {
    'nvim-telescope/telescope.nvim', tag = '0.1.5',
    dependencies = {
        'nvim-lua/plenary.nvim',
        'ryanoasis/vim-devicons',
    },
  },
  'AndrewRadev/sideways.vim', -- move function args, etc. around
  {
     'vim-airline/vim-airline',
     dependencies = {
      'nvim-tree/nvim-web-devicons',
      'ryanoasis/vim-devicons',
      'nvim-treesitter/nvim-treesitter',
      'sharkdp/fd',
     },
  }, -- powerline-like status bar
  'vim-airline/vim-airline-themes', -- themes for the above
  'nvim-tree/nvim-web-devicons', -- additional icons
  'ryanoasis/vim-devicons', -- additional icons

  {'nvim-treesitter/nvim-treesitter', build = ':TSUpdate'}, -- tree-sitter AST integration (requried for aerial below)
  'stevearc/aerial.nvim', -- code outliner (tagbar replacement)

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
