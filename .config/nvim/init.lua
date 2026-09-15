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

vim.g.clipboard = 'osc52'

vim.keymap.set('n', '<Esc>', '<CMD>nohlsearch<CR>')
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

vim.filetype.add {
    pattern = {
        ['.*/.*%helmfile.*%.ya?ml'] = 'helm',
        ['.*/templates/.*%.ya?ml'] = 'helm',
        ['.*/.*%helmfile.*%.ya?ml.gotmpl'] = 'helm',
        ['.*/templates/.*%.ya?ml.gotmpl'] = 'helm',
    },
}

local plugins = {
    { src = 'git@github.com:rose-pine/neovim.git', name = 'rose-pine' },
    { src = 'git@github.com:nvim-lua/plenary.nvim.git' },
    { src = 'git@github.com:tpope/vim-sleuth.git' },
    { src = 'git@github.com:lukas-reineke/indent-blankline.nvim.git' },
    { src = 'git@github.com:nvim-mini/mini.surround.git' },
    { src = 'git@github.com:nvim-mini/mini.jump2d.git' },

    -- Treesitter
    { src = 'git@github.com:nvim-treesitter/nvim-treesitter.git', version = 'main' },
    { src = 'git@github.com:windwp/nvim-ts-autotag.git' },
    { src = 'git@github.com:nvim-treesitter/nvim-treesitter-textobjects.git', version = 'main' },

    -- LSP
    { src = 'git@github.com:neovim/nvim-lspconfig.git' },

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

-- git ========================================
vim.keymap.set('n', '<leader>gg', function()
    require('neogit').open()
end)

local gitsigns = require 'gitsigns'
gitsigns.setup {
    on_attach = function(bufnr)
        local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
        end

        map('n', '<leader>gs', gitsigns.stage_hunk)
        map('n', '<leader>gr', gitsigns.reset_hunk)

        map({ 'n', 'x', 'o' }, ']h', function()
            gitsigns.nav_hunk 'next'
        end)
        map({ 'n', 'x', 'o' }, '[h', function()
            gitsigns.nav_hunk 'prev'
        end)

        map('v', '<leader>gs', function()
            gitsigns.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end)
        map('v', '<leader>gr', function()
            gitsigns.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end)

        map('n', '<leader>gb', function()
            gitsigns.blame_line { full = true }
        end)
        map('n', '<leader>gB', gitsigns.blame)
        map('n', '<leader>gq', function()
            ---@diagnostic disable-next-line: param-type-mismatch
            gitsigns.setqflist(0, { open = false, use_location_list = true }, function()
                require('fzf-lua').loclist()
            end)
        end, { desc = 'List all git hunks in current file in loclist' })
    end,
}
-- End git ====================================

-- Completion ====================
vim.opt.completeopt = {
    'fuzzy',
    'menuone',
    'noinsert',
    'noselect',
    'popup',
}
vim.opt.omnifunc = 'syntaxcomplete#Complete'
vim.o.winborder = 'rounded'
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

vim.api.nvim_create_autocmd('LspAttach', {
    group = global_augroup,
    callback = function()
        vim.opt.omnifunc = 'v:lua.vim.lsp.omnifunc'
    end,
})

vim.lsp.enable { 'ts_ls', 'gopls', 'golangci_lint_ls', 'jedi_language_server' }

local js_formatters = { 'oxfmt', 'prettierd', 'prettier', 'eslint' }

local conform = require 'conform'
conform.setup {
    formatters_by_ft = {
        lua = { 'stylua' },
        javascript = js_formatters,
        typescript = js_formatters,
        typescriptreact = js_formatters,
        javascriptreact = js_formatters,
        c = { 'clang-format' },
        cpp = { 'clang-format' },
        go = { 'gofmt' },
        php = { 'php-cs-fixer' },
        python = { 'ruff' },
    },
    formatters = {
        prettierd = { require_cwd = true },
        prettier = { require_cwd = true },
    },
}

vim.keymap.set('n', '<leader>f', function()
    conform.format {
        async = true,
        lsp_format = 'fallback',
        -- quiet = true,
    }
end)

local lint = require 'lint'
vim.api.nvim_create_autocmd('BufWritePost', {
    group = global_augroup,
    callback = function()
        lint.try_lint(nil, {
            ignore_errors = true,
        })
    end,
})

vim.keymap.del('n', 'grn')
vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename)

-- END Completion ================

-- Treesitter =====================
local ts = require 'nvim-treesitter'
ts.setup {
    install_dir = vim.fn.stdpath 'data' .. '/treesitter',
}
ts.install { 'stable' }

vim.api.nvim_create_autocmd('FileType', {
    group = global_augroup,
    pattern = ts.get_installed(),
    callback = function()
        vim.treesitter.start()
    end,
})

require('nvim-treesitter-textobjects').setup {
    select = {
        lookahead = true,
        include_surrounding_whitespace = false,
    },
    move = {
        set_jumps = true,
    },
}

vim.keymap.set({ 'x', 'o' }, 'af', function()
    require('nvim-treesitter-textobjects.select').select_textobject('@function.outer', 'textobjects')
end)
vim.keymap.set({ 'x', 'o' }, 'if', function()
    require('nvim-treesitter-textobjects.select').select_textobject('@function.inner', 'textobjects')
end)
vim.keymap.set({ 'x', 'o' }, 'ac', function()
    require('nvim-treesitter-textobjects.select').select_textobject('@class.outer', 'textobjects')
end)
vim.keymap.set({ 'x', 'o' }, 'ic', function()
    require('nvim-treesitter-textobjects.select').select_textobject('@class.inner', 'textobjects')
end)
vim.keymap.set({ 'x', 'o' }, 'as', function()
    require('nvim-treesitter-textobjects.select').select_textobject('@local.scope', 'locals')
end)
vim.keymap.set({ 'n', 'x', 'o' }, ']m', function()
    require('nvim-treesitter-textobjects.move').goto_next_start('@function.outer', 'textobjects')
end)
vim.keymap.set({ 'n', 'x', 'o' }, '[m', function()
    require('nvim-treesitter-textobjects.move').goto_previous_start('@function.outer', 'textobjects')
end)

local ts_repeat_move = require 'nvim-treesitter-textobjects.repeatable_move'
vim.keymap.set({ 'n', 'x', 'o' }, ';', ts_repeat_move.repeat_last_move)
vim.keymap.set({ 'n', 'x', 'o' }, ',', ts_repeat_move.repeat_last_move_opposite)

-- make builtin f, F, t, T also repeatable with ; and ,
vim.keymap.set({ 'n', 'x', 'o' }, 'f', ts_repeat_move.builtin_f_expr, { expr = true })
vim.keymap.set({ 'n', 'x', 'o' }, 'F', ts_repeat_move.builtin_F_expr, { expr = true })
vim.keymap.set({ 'n', 'x', 'o' }, 't', ts_repeat_move.builtin_t_expr, { expr = true })
vim.keymap.set({ 'n', 'x', 'o' }, 'T', ts_repeat_move.builtin_T_expr, { expr = true })

vim.opt.foldmethod = 'expr'
vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'
vim.opt.foldlevel = 99

require('nvim-ts-autotag').setup {
    opts = {
        enable_close = true, -- Auto close tags
        enable_rename = true, -- Auto rename pairs of tags
        enable_close_on_slash = false, -- Auto close on trailing </
    },
}
-- End Treesitter ================

local fzf = require 'fzf-lua'
fzf.setup {
    { 'telescope', 'borderless-full' },
    files = {
        cwd_prompt = false,
        follow = true,
    },
    defaults = {
        prompt = '',
    },
    grep = {
        hidden = true,
        follow = true,
    },
}
fzf.register_ui_select()

vim.keymap.set('n', '<leader>sf', fzf.files)
vim.keymap.set('n', '<leader>sn', function()
    fzf.files { cwd = '~/.config/nvim/' }
end, { desc = 'Search neovim config' })
vim.keymap.set('n', '<leader>cd', fzf.zoxide)
vim.keymap.set('n', '<leader>sg', fzf.live_grep_native)
vim.keymap.set('n', '<leader>/', fzf.lgrep_curbuf)
vim.keymap.set('n', '<leader>sr', fzf.resume)
vim.keymap.set('n', '<leader> ', fzf.buffers)
vim.keymap.set('n', '<leader>sm', fzf.manpages)

vim.keymap.set({ 'n', 'v' }, '<leader>ss', function()
    local mode = vim.api.nvim_get_mode()

    if mode.blocking or mode.mode == 'n' then
        fzf.grep {
            search = vim.fn.expand '<cword>',
            lgrep = true,
        }

        return
    end

    fzf.grep_visual()
end)

-- Those are native NVIM keybinds :/
vim.keymap.del({ 'n', 'v' }, 'gra')
vim.keymap.del('n', 'grr')
vim.keymap.del('n', 'gri')
vim.keymap.del('n', 'grt')
vim.keymap.del('n', 'gO')

vim.api.nvim_create_autocmd('LspAttach', {
    group = global_augroup,
    callback = function()
        vim.keymap.set('n', 'gr', fzf.lsp_references)
        vim.keymap.set('n', 'gi', fzf.lsp_implementations)
        vim.keymap.set('n', 'gt', fzf.lsp_typedefs)
        vim.keymap.set('n', 'gd', fzf.lsp_definitions)
        vim.keymap.set('n', 'gD', fzf.lsp_declarations)
        vim.keymap.set({ 'n', 'v' }, '<leader>ca', fzf.lsp_code_actions)
        vim.keymap.set('n', '<leader>ws', fzf.lsp_live_workspace_symbols)

        -- remap vim.diagnostic.setloclist to use fzf instead
        vim.keymap.set('n', '<leader>wq', fzf.lsp_workspace_diagnostics)
    end,
})

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

local ibl_patterns = { '*.yaml', '*.yml', '*.yaml.gotmpl' }

vim.api.nvim_create_autocmd('BufEnter', {
    group = global_augroup,
    pattern = ibl_patterns,
    callback = function()
        require('ibl').setup {
            enabled = true,
        }
    end,
})

vim.api.nvim_create_autocmd('BufLeave', {
    group = global_augroup,
    pattern = ibl_patterns,
    callback = function()
        require('ibl').setup {
            enabled = false,
        }
    end,
})

require('mini.surround').setup()
require('mini.jump2d').setup {
    mappings = {
        start_jumping = 'gj',
    },
    view = { dim = true },
    silent = true,
}
