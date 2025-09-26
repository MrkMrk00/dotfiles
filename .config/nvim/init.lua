local global_augroup = vim.api.nvim_create_augroup('config-global-augroup', { clear = true })

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = 'a' -- enable mouse in all modes
vim.opt.showmode = true
vim.opt.signcolumn = 'yes'
vim.opt.cursorline = true

vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.expandtab = true
vim.opt.scrolloff = 10

vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true

vim.opt.laststatus = 2
vim.opt.inccommand = 'split'
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.termguicolors = true
vim.opt.undofile = true

-- TODO: remove
vim.opt.clipboard = 'unnamedplus'

vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic error messages' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setqflist, { desc = 'Open diagnostic quickfix list' })
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

vim.api.nvim_create_autocmd('TextYankPost', {
    desc = 'Highlight when yanking (copying) text',
    group = global_augroup,
    callback = function()
        vim.highlight.on_yank()
    end,
})

local plugins = {
    { src = 'git@github.com:rose-pine/neovim.git', name = 'rose-pine' },

    -- Deps
    { src = 'git@github.com:nvim-lua/plenary.nvim.git' },

    -- Custom rendering in buffers
    { src = 'git@github.com:folke/snacks.nvim.git' }, -- snacks.image
    { src = 'git@github.com:MeanderingProgrammer/render-markdown.nvim.git' },

    -- Treesitter
    {
        src = 'git@github.com:nvim-treesitter/nvim-treesitter.git',
        version = 'master',
    },
    { src = 'git@github.com:windwp/nvim-ts-autotag.git' },
    { src = 'git@github.com:nvim-treesitter/nvim-treesitter-textobjects.git' },

    -- Lsp
    { src = 'git@github.com:neovim/nvim-lspconfig.git' },
    { src = 'git@github.com:mason-org/mason.nvim.git' },
    { src = 'git@github.com:mason-org/mason-lspconfig.nvim.git' },
    { src = 'git@github.com:folke/lazydev.nvim.git' },

    -- Formatter
    { src = 'git@github.com:stevearc/conform.nvim.git' },
    { src = 'git@github.com:mfussenegger/nvim-lint.git' },

    -- Fuzzy finder, UI select
    { src = 'git@github.com:ibhagwan/fzf-lua.git' },

    -- File manager
    { src = 'git@github.com:stevearc/oil.nvim' },

    -- Git
    { src = 'git@github.com:lewis6991/gitsigns.nvim.git' },
    { src = 'git@github.com:NeogitOrg/neogit.git' },

    -- Snippets
    { src = 'git@github.com:L3MON4D3/LuaSnip.git' },
}

local lib = require 'config_lib'
lib.pack_on_plugin_change('nvim-treesitter', function()
    local do_update = require('nvim-treesitter.install').update { with_sync = true }

    do_update()
end)
lib.pack_on_plugin_change('LuaSnip', function(ev)
    local makepath = ev.data.path

    vim.notify(vim.fn.system { 'make', '-C', makepath, 'install_jsregexp' })
end)

lib.pack_register_plugins(plugins)
lib.pack_cleanup(plugins)

require('treesitter').setup()
require('lsp').setup()
require('git').setup()
require('fzf').setup()

-- Completion ====================
vim.opt.updatetime = 300
vim.opt.completeopt = { 'menuone', 'noinsert', 'noselect', 'popup', 'fuzzy' }
vim.opt.omnifunc = 'syntaxcomplete#Complete' -- vim's builtin syntax autocomplete as fallback - when no LSP gets attached

vim.opt.autocomplete = true
vim.opt.complete = { 'o', '.', 'w', 'f' }
vim.opt.completefuzzycollect = 'keyword'
-- END Completion ================

-- Snippets ======================
require('luasnip.loaders.from_lua').lazy_load { paths = { './snippets' } }

vim.keymap.set('i', '<C-E>', function()
    require('luasnip').expand()
end, { silent = true, desc = 'Expand snippet' })
vim.keymap.set({ 'i', 's' }, '<C-J>', function()
    require('luasnip').jump(1)
end, { silent = true, desc = 'Go to next placeholder in snippet' })
vim.keymap.set({ 'i', 's' }, '<C-K>', function()
    require('luasnip').jump(-1)
end, { silent = true, desc = 'Go to previous placeholder in snippet' })

-- END Snippets ==================

local oil = require 'oil'
oil.setup {
    view_options = {
        show_hidden = true,
    },
}

vim.api.nvim_create_user_command('Ex', 'Oil', {})

require('snacks').setup {
    image = { enable = true },
}

require('render-markdown').setup {}

-- Colors ========================================
require('rose-pine').setup {
    styles = {
        italic = false,
    },
    highlight_groups = {
        StatusLine = { fg = 'love', bg = 'love', blend = 10 },
        StatusLineNC = { fg = 'subtle', bg = 'surface' },
    },
}

vim.opt.background = 'light'
vim.cmd.colorscheme 'rose-pine'
vim.opt.guicursor = 'n-v-c:block-Cursor,i-ci:ver25-InCursor,r-cr:hor20-Cursor'
vim.cmd [[
    highlight Cursor guifg=black guibg=orange
    highlight InCursor guifg=white guibg=blue
]]
