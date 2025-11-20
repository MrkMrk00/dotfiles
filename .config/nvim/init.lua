local global_augroup = vim.api.nvim_create_augroup('config-global-augroup', { clear = true })

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.swapfile = false
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

vim.opt.spell = true
vim.opt.spelllang = { 'en_us' }

-- TODO: remove
vim.opt.clipboard = 'unnamedplus'

vim.keymap.set('n', '<Esc>', '<CMD>nohlsearch<CR>')
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic error messages' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setqflist, { desc = 'Open diagnostic quickfix list' })
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

vim.keymap.set('n', '<leader>sl', function()
    local search_term = vim.fn.expand '<cword>'

    vim.api.nvim_feedkeys(vim.keycode('/' .. search_term .. '<CR>'), 'n', false)
end)

vim.api.nvim_create_autocmd('TextYankPost', {
    desc = 'Highlight when yanking (copying) text',
    group = global_augroup,
    callback = function()
        vim.highlight.on_yank()
    end,
})

vim.filetype.add {
    pattern = {
        ['.*/.*%helmfile.*%.ya?ml'] = 'helm',
        ['.*/templates/.*%.ya?ml'] = 'helm',
    },
}

local plugins = {
    { src = 'git@github.com:rose-pine/neovim.git', name = 'rose-pine' },
    { src = 'git@github.com:nvim-lua/plenary.nvim.git' },
    { src = 'git@github.com:tpope/vim-sleuth.git' },
    { src = 'git@github.com:yetone/avante.nvim.git' },
    { src = 'git@github.com:MunifTanjim/nui.nvim.git' },
    { src = 'git@github.com:lukas-reineke/indent-blankline.nvim.git' },

    -- Treesitter
    {
        src = 'git@github.com:nvim-treesitter/nvim-treesitter.git',
        version = 'master',
    },
    { src = 'git@github.com:windwp/nvim-ts-autotag.git' },
    { src = 'git@github.com:nvim-treesitter/nvim-treesitter-textobjects.git' },
    { src = 'git@github.com:nvim-treesitter/nvim-treesitter-context.git' },

    -- LSP
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
lib.pack_on_plugin_change('avante.nvim', function(ev)
    local makepath = ev.data.path

    vim.notify(vim.fn.system { 'make', '-C', makepath })
end)

lib.pack_register_plugins(plugins)
lib.pack_cleanup(plugins)

require('treesitter').setup()
require('lsp').setup()
require('git').setup()
require('fzf').setup()

-- Completion ====================
vim.opt.completefuzzycollect = 'keyword'
vim.opt.completeopt = {
    'fuzzy',
    'menuone',
    'noinsert',
    'noselect',
    'popup',
}
vim.opt.omnifunc = 'syntaxcomplete#Complete'

vim.opt.autocomplete = true
vim.opt.complete = {
    'o', -- omnifunc
    '.', -- current buffer
    'w', -- buffers in other windows
}
vim.opt.autocompletetimeout = 200
vim.opt.autocompletedelay = 500

vim.keymap.set('i', '<CR>', function()
    if vim.fn.pumvisible() == 1 then
        -- popup menu visible: close it, then insert newline
        return vim.api.nvim_replace_termcodes('<C-e><CR>', true, false, true)
    else
        -- no popup menu: just newline
        return vim.api.nvim_replace_termcodes('<CR>', true, false, true)
    end
end, { expr = true })

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

-- AI ========================================
require('render-markdown').setup {
    file_types = { 'markdown', 'Avante' },
}

local is_avante_initialized = false
local AVANTE_INITIALIZED_EVENT = 'AvanteInitialized'

vim.system({ 'bw', '--nointeraction', 'get', 'password', 'Claude Code' }, { text = true }, function(result)
    vim.schedule(function()
        if result.code ~= 0 then
            vim.notify('[Avante] failed to load claude API key: ' .. result.stderr, vim.log.levels.ERROR)

            return
        end

        vim.env.AVANTE_ANTHROPIC_API_KEY = result.stdout

        require('avante').setup {
            behaviour = {
                auto_suggestions = false,
                auto_approve_tool_permissions = false,
            },
            auto_suggestions_provider = 'claude',
            provider = 'claude',
            providers = {
                claude = {
                    endpoint = 'https://api.anthropic.com',
                    model = 'claude-sonnet-4-5-20250929',
                    timeout = 30000,
                    extra_request_body = {
                        temperature = 0.75,
                        max_tokens = 20480,
                    },
                },
            },
        }

        is_avante_initialized = true
        vim.api.nvim_exec_autocmds('User', {
            pattern = AVANTE_INITIALIZED_EVENT,
        })
    end)
end)

vim.api.nvim_create_user_command('ZenMode', function()
    if is_avante_initialized then
        require('avante.api').zen_mode()
        return
    end

    vim.notify('waiting for avante to get initialized...', vim.log.levels.INFO)
    vim.api.nvim_create_autocmd('User', {
        pattern = AVANTE_INITIALIZED_EVENT,
        once = true,
        callback = function()
            require('avante.api').zen_mode()
        end,
    })
end, {})
