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
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

vim.opt.laststatus = 2
vim.opt.inccommand = 'split'
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.termguicolors = true
vim.opt.undofile = true

-- TODO: remove
vim.opt.clipboard = 'unnamedplus'

vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic error messages' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic quickfix list' })
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

local NVIM_PACK_PATH = vim.fn.stdpath 'data' .. '/site/pack/core/opt/'

local plugins = {
    { src = 'git@github.com:nvim-lua/plenary.nvim.git' },
    { src = 'git@github.com:rose-pine/neovim.git' },
    { src = 'git@github.com:stevearc/oil.nvim' },
    { src = 'git@github.com:Allaman/emoji.nvim.git' },
    { src = 'git@github.com:folke/todo-comments.nvim.git' },
    { src = 'git@github.com:folke/snacks.nvim.git' }, -- for snacks.image

    -- Treesitter
    {
        src = 'git@github.com:nvim-treesitter/nvim-treesitter.git',
        version = 'master',
    },
    { src = 'git@github.com:windwp/nvim-ts-autotag.git' },

    -- Lsp
    { src = 'git@github.com:neovim/nvim-lspconfig.git' },
    { src = 'git@github.com:mason-org/mason.nvim.git' },
    { src = 'git@github.com:mason-org/mason-lspconfig.nvim.git' },
    { src = 'git@github.com:folke/lazydev.nvim.git' },
    { src = 'git@github.com:stevearc/conform.nvim.git' },

    { src = 'git@github.com:ibhagwan/fzf-lua.git' },

    -- Git
    { src = 'git@github.com:lewis6991/gitsigns.nvim.git' },
    { src = 'git@github.com:NeogitOrg/neogit.git' },

    -- Compile mode
    { src = 'git@github.com:m00qek/baleia.nvim.git' },
    { src = 'git@github.com:ej-shafran/compile-mode.nvim.git' },

    -- TODO: debug, snippets
}

-- https://github.com/nvim-treesitter/nvim-treesitter/wiki/Installation
vim.api.nvim_create_autocmd('PackChanged', {
    group = global_augroup,
    callback = function(ev)
        if ev.data.kind == 'delete' then
            return
        end

        vim.notify(vim.inspect(ev.data))

        if ev.data.spec.name == 'nvim-treesitter' then
            local do_update = require('nvim-treesitter.install').update { with_sync = true }

            do_update()
        elseif ev.data.spec.name == 'vim-kitty-navigator' then
            vim.notify(vim.fn.system('cp ' .. ev.data.path .. '/*.py ~/.config/kitty/'))
        end
    end,
})

vim.pack.add(plugins, { load = false })
pack_cleanup(plugins)

-- Treesitter ====================
---@diagnostic disable-next-line: missing-fields
require('nvim-treesitter.configs').setup {
    auto_install = true,
    indent = { enable = true },
    highlight = { enable = true },
    additional_vim_regex_highlighting = false,
}

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
-- END Treesitter ================

-- LSP ===========================
require('mason').setup {
    install_root_dir = vim.fn.stdpath 'data' .. 'mason-nvim-next',
}
require('mason-lspconfig').setup {
    ensure_installed = { 'lua_ls', 'ts_ls', 'clangd' },
}
require('lazydev').setup {}
local conform = require 'conform'
conform.setup {
    formatters_by_ft = {
        lua = { 'stylua' },
        javascript = { 'prettierd', 'eslint' },
        typescript = { 'prettierd', 'eslint' },
        typescriptreact = { 'prettierd', 'eslint' },
        javascriptreact = { 'prettierd', 'eslint' },
        vue = { 'prettierd', 'eslint' },
        c = { 'clang-format' },
        cpp = { 'clang-format' },
        go = { 'gofmt' },
    },
    formatters = {
        ['clang-format'] = {
            args = {
                '-style={BasedOnStyle: Mozilla, ColumnLimit: 120, IndentWidth: 4, AlwaysBreakAfterReturnType: None, AlwaysBreakAfterDefinitionReturnType: None, AllowShortFunctionsOnASingleLine: Empty}',
            },
        },
    },
}
vim.keymap.set('n', '<leader>f', function()
    conform.format { async = true }
end)

-- Autocomplete (with omnifunc) ====================

-- coq_nvim / nvim-cmp? Do I need it?
local function autocomplete()
    if vim.fn.pumvisible() == 0 then
        local old_shortmess = vim.o.shortmess
        vim.o.shortmess = old_shortmess .. 'c'

        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-x><C-o>', true, false, true), 'n', false)

        vim.schedule(function()
            vim.o.shortmess = old_shortmess
        end)
    end
end

vim.opt.updatetime = 300
vim.opt.completeopt = { 'menuone', 'noinsert', 'noselect', 'popup' }
vim.opt.omnifunc = 'syntaxcomplete#Complete' -- vim's builtin syntax autocomplete as fallback - when no LSP gets attached

vim.api.nvim_create_autocmd('InsertCharPre', {
    desc = 'Autocomplete (omnifunc) on insert',
    group = global_augroup,
    callback = autocomplete,
})
-- END Autocomplete ====================

-- Fallback for old eslint config file. TODO: Remove when not supported.
local function has_eslintrc(path)
    local found_files = vim.fs.find(
        { '.eslintrc', '.eslintrc.json', '.eslintrc.js', '.eslintrc.cjs', '.eslintrc.mjs' },
        {
            path = path,
            upward = true,
            limit = 2,
            type = 'file',
        }
    )

    return #found_files > 0
end

vim.api.nvim_create_autocmd('LspAttach', {
    group = global_augroup,
    callback = function(ev)
        vim.opt.omnifunc = 'v:lua.vim.lsp.omnifunc'

        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        if client ~= nil and client.name == 'eslint' and has_eslintrc(vim.fn.getcwd()) then
            vim.lsp.stop_client(ev.data.client_id, true)
            local new_config = vim.tbl_deep_extend('force', (require 'lspconfig.configs.eslint').default_config, {
                cmd_env = {
                    ESLINT_USE_FLAT_CONFIG = '0',
                },
                settings = {
                    useFlatConfig = false,
                    experimental = {
                        useFlatConfig = false,
                    },
                },
            })

            vim.lsp.start(new_config)
        end
    end,
})

local function setup_vuejs()
    local vue_language_server_path = vim.fn.expand '$MASON/packages'
        .. '/vue-language-server'
        .. '/node_modules/@vue/language-server'

    local vue_plugin = {
        name = '@vue/typescript-plugin',
        location = vue_language_server_path,
        languages = { 'vue' },
        configNamespace = 'typescript',
    }

    vim.lsp.config('ts_ls', {
        init_options = {
            plugins = {
                vue_plugin,
            },
        },
        filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue' },
    })
end
setup_vuejs()
-- END LSP =======================

-- FZF lua =======================
local fzf = require 'fzf-lua'
fzf.setup {
    { 'ivy', 'borderless-full' },
    files = {
        cwd_prompt = false,
    },
}
fzf.register_ui_select()
require('todo-comments').setup {
    signs = false,
}

vim.keymap.set('n', '<leader>sf', fzf.files)
vim.keymap.set('n', '<leader>sn', function()
    fzf.files { cwd = '~/.config/nvim-next/' }
end, { desc = 'Search neovim config' })
vim.keymap.set('n', '<leader>sg', fzf.live_grep_native)
vim.keymap.set('n', '<leader>/', fzf.lgrep_curbuf)
vim.keymap.set('n', '<leader>sr', fzf.resume)
vim.keymap.set('n', '<leader> ', fzf.buffers)
vim.keymap.set('n', '<leader>sc', '<CMD>TodoFzfLua<CR>')

vim.api.nvim_create_autocmd('LspAttach', {
    group = global_augroup,
    callback = function()
        -- Those are native NVIM keybinds, just remap them to use FzfLua instead native UI.
        vim.keymap.set({ 'n', 'v' }, 'gra', fzf.lsp_code_actions)
        vim.keymap.set('n', 'grr', fzf.lsp_references)
        vim.keymap.set('n', 'gri', fzf.lsp_implementations)
        vim.keymap.set('n', 'grt', fzf.lsp_typedefs)
        vim.keymap.set('n', 'gO', fzf.lsp_document_symbols)

        vim.keymap.set('n', 'grd', fzf.lsp_definitions)
        vim.keymap.set('n', 'grD', fzf.lsp_declarations)
        vim.keymap.set('n', '<leader>ca', fzf.lsp_code_actions)
        vim.keymap.set('n', '<leader>ws', fzf.lsp_workspace_symbols)

        -- remap vim.diagnostic.setloclist to use fzf instead
        vim.keymap.set('n', '<leader>q', fzf.lsp_document_diagnostics)
        vim.keymap.set('n', '<leader>wq', fzf.lsp_workspace_diagnostics)
    end,
})

-- END FZF =======================

-- GIT ===========================
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

        map('n', '<leader>gn', function()
            gitsigns.nav_hunk('next')
        end)
        map('n', '<leader>gp', function()
            gitsigns.nav_hunk('prev')
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
            gitsigns.setqflist(0, { open = false, use_location_list = true }, function()
                fzf.loclist()
            end)
        end, { desc = 'List all git hunks in current file in loclist' })
    end,
}

-- END GIT =======================
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

require('rose-pine').setup {
    styles = {
        italic = false,
        bold = false,
    },
}

vim.opt.background = 'light'
vim.cmd.colorscheme 'rose-pine'
vim.opt.guicursor = 'n-v-c:block-Cursor,i-ci:ver25-InCursor,r-cr:hor20-Cursor'
vim.cmd [[
    highlight Cursor guifg=black guibg=orange
    highlight InCursor guifg=white guibg=blue
]]

require('emoji').setup {
    plugin_path = NVIM_PACK_PATH,
}
