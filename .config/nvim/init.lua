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

-- gofmt is stupid and uses tabs
vim.api.nvim_create_autocmd('BufEnter', {
    group = global_augroup,
    pattern = '*.go',
    callback = function()
        vim.opt.listchars = { tab = '  ', trail = '·', nbsp = '␣' }
    end,
})

vim.api.nvim_create_autocmd('BufLeave', {
    group = global_augroup,
    pattern = '*.go',
    callback = function()
        vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
    end,
})

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

-- Automatically update/delete plugins when the input specs into vim.pack.add change.
local function pack_cleanup(specs)
    local should_delete = {}
    local should_update = {}

    for _, pack_plugin in ipairs(vim.pack.get()) do
        local found = nil
        for _, plugin in ipairs(specs) do
            if plugin.src == pack_plugin.spec.src then
                found = plugin
                break
            end
        end

        if found == nil then
            table.insert(should_delete, pack_plugin.spec.name)
        elseif found.version ~= nil and found.version ~= pack_plugin.spec.version then
            table.insert(should_update, pack_plugin.spec.name)
        end
    end

    if #should_delete > 0 then
        vim.pack.del(should_delete)
    end

    if #should_update > 0 then
        vim.pack.update(should_update, { force = true })
    end
end

-- local NVIM_PACK_PATH = vim.fn.stdpath 'data' .. '/site/pack/core/opt/'
local plugins = {
    -- Deps
    { src = 'git@github.com:nvim-lua/plenary.nvim.git' },

    -- Colorscheme
    { src = 'git@github.com:rose-pine/neovim.git', name = 'rose-pine' },

    -- Custom rendering in buffers
    { src = 'git@github.com:m00qek/baleia.nvim.git' }, -- terminal color escape codes
    { src = 'git@github.com:folke/snacks.nvim.git' }, -- snacks.image
    { src = 'git@github.com:MeanderingProgrammer/render-markdown.nvim.git' },
    { src = 'git@github.com:folke/todo-comments.nvim.git' },

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

    -- Format, lint
    { src = 'git@github.com:stevearc/conform.nvim.git' },
    { src = 'git@github.com:mfussenegger/nvim-lint.git' },

    -- Fuzzy finder, UI select
    { src = 'git@github.com:ibhagwan/fzf-lua.git' },

    -- File manager
    { src = 'git@github.com:stevearc/oil.nvim' },

    -- Git
    { src = 'git@github.com:lewis6991/gitsigns.nvim.git' },
    { src = 'git@github.com:NeogitOrg/neogit.git' },

    -- Emacs' compilation mode :) and REPL stuff
    { src = 'git@github.com:ej-shafran/compile-mode.nvim.git' },
    { src = 'git@github.com:Vigemus/iron.nvim.git' },

    -- Snippets
    { src = 'git@github.com:L3MON4D3/LuaSnip.git' },
    { src = 'git@github.com:windwp/nvim-autopairs.git' },

    -- TODO: debug
}

vim.api.nvim_create_autocmd('PackChanged', {
    group = global_augroup,
    callback = function(ev)
        if ev.data.kind == 'delete' then
            return
        end

        if ev.data.spec.name == 'nvim-treesitter' then
            local do_update = require('nvim-treesitter.install').update { with_sync = true }

            do_update()
        elseif ev.data.spec.name == 'LuaSnip' then
            local makepath = ev.data.path

            vim.notify(vim.fn.system { 'make', '-C', makepath, 'install_jsregexp' })
        end
    end,
})

vim.pack.add(plugins, { load = false })
pack_cleanup(plugins)

require('treesitter').setup()
require('lsp').setup()
require('git').setup()
require('autocomplete').setup()
require('fzf').setup()
require('repl').setup()

-- Snippets ======================
local ls = require 'luasnip'

vim.keymap.set('i', '<C-E>', ls.expand, { silent = true })
vim.keymap.set({ 'i', 's' }, '<C-J>', function()
    ls.jump(1)
end, { silent = true })
vim.keymap.set({ 'i', 's' }, '<C-K>', function()
    ls.jump(-1)
end, { silent = true })

local function register_php_snips()
    local s = ls.snippet
    local i = ls.insert_node
    local fmt = require('luasnip.extras.fmt').fmt

    local function method_snip(trigger, access_modifier)
        local config = {
            trig = trigger,
            name = access_modifier .. ' function',
        }

        local format = fmt(
            [[
<am> function <fn>(): <type>
{
    <>
}
    ]],
            {
                am = access_modifier,
                fn = i(1, 'ahoj'),
                type = i(2, 'void'),
                i(3, ''),
            },
            { delimiters = '<>' }
        )

        return s(config, format)
    end

    ls.add_snippets('php', {
        method_snip('pubf', 'public'),
        method_snip('prof', 'protected'),
        method_snip('prif', 'private'),
        method_snip('prisf', 'private static'),
        method_snip('prosf', 'protected static'),
        method_snip('pubsf', 'public static'),
    })
end

register_php_snips()

-- END Snippets ==================

local ts_repeat_move = require 'nvim-treesitter.textobjects.repeatable_move'

--  make builtin f, F, t, T repeatable with ; and ,
vim.keymap.set({ 'n', 'x', 'o' }, 'f', ts_repeat_move.builtin_f_expr, { expr = true })
vim.keymap.set({ 'n', 'x', 'o' }, 'F', ts_repeat_move.builtin_F_expr, { expr = true })
vim.keymap.set({ 'n', 'x', 'o' }, 't', ts_repeat_move.builtin_t_expr, { expr = true })
vim.keymap.set({ 'n', 'x', 'o' }, 'T', ts_repeat_move.builtin_T_expr, { expr = true })

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

local todo = require 'todo-comments'
todo.setup {
    signs = false,
}

local next_todo, prev_todo = ts_repeat_move.make_repeatable_move_pair(todo.jump_next, todo.jump_prev)
vim.keymap.set('n', '<leader>sc', '<CMD>TodoFzfLua<CR>')
vim.keymap.set('n', ']t', next_todo, { desc = 'Jump to next TODO' })
vim.keymap.set('n', '[t', prev_todo, { desc = 'Jump to previous TODO' })

-- Compile mode settings
vim.g.compile_mode = {
    -- to add ANSI escape code support, add:
    baleia_setup = true,

    -- to make `:Compile` replace special characters (e.g. `%`) in
    -- the command (and behave more like `:!`), add:
    bang_expansion = true,

    error_regexp_table = {
        typescript = {
            regex = '^\\(.\\+\\)(\\([1-9][0-9]*\\),\\([1-9][0-9]*\\)): error TS[1-9][0-9]*:',
            filename = 1,
            row = 2,
            col = 3,
            type = 2,
        },
        pascal = {
            regex = '^\\(.\\+\\)(\\([1-9][0-9]*\\),\\([1-9][0-9]*\\)) Error:',
            filename = 1,
            row = 2,
            col = 3,
            type = 2,
        },
        pascal_fatal = {
            regex = '^\\(.\\+\\)(\\([1-9][0-9]*\\),\\([1-9][0-9]*\\)) Fatal:',
            filename = 1,
            row = 2,
            col = 3,
            type = 2,
        },
    },
}

require('nvim-autopairs').setup {}
require('render-markdown').setup {}

require('rose-pine').setup {
    styles = {
        italic = false,
        bold = false,
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
