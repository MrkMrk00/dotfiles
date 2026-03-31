local M = {}

local augroup = vim.api.nvim_create_augroup('config-lsp-augroup', { clear = true })

function M.setup()
    require('mason').setup {
        install_root_dir = vim.fn.stdpath 'data' .. 'mason-nvim-next',
    }

    local mason_lspconfig = require 'mason-lspconfig'
    mason_lspconfig.setup {
        ensure_installed = { 'lua_ls' },
    }

    local conform = require 'conform'
    conform.setup {
        formatters_by_ft = {
            lua = { 'stylua' },
            javascript = { 'prettierd', 'eslint' },
            typescript = { 'prettierd', 'eslint' },
            typescriptreact = { 'prettierd', 'eslint' },
            javascriptreact = { 'prettierd', 'eslint' },
            vue = { 'prettierd', 'eslint' },
            svelte = { 'prettierd', 'eslint' },
            c = { 'clang-format' },
            cpp = { 'clang-format' },
            go = { 'gofmt' },
            php = { 'php-cs-fixer' },
            python = { 'ruff' },
        },
        formatters = {
            ['clang-format'] = {
                args = {
                    '-style={BasedOnStyle: Mozilla, ColumnLimit: 120, IndentWidth: 4, AlwaysBreakAfterReturnType: None, AlwaysBreakAfterDefinitionReturnType: None, AllowShortFunctionsOnASingleLine: Empty, BreakBeforeBraces: Linux, UseTab: Never, AllowShortIfStatementsOnASingleLine: true}',
                },
            },
            prettierd = { require_cwd = true },
            prettier = { require_cwd = true },
        },
    }

    local lint = require 'lint'
    vim.keymap.set('n', '<leader>f', function()
        conform.format {
            async = true,
            lsp_format = 'fallback',
            -- quiet = true,
        }
    end)

    vim.api.nvim_create_autocmd('LspAttach', {
        group = augroup,
        callback = function()
            vim.opt.omnifunc = 'v:lua.vim.lsp.omnifunc'
        end,
    })

    vim.api.nvim_create_autocmd('BufWritePost', {
        group = augroup,
        callback = function()
            lint.try_lint(nil, {
                ignore_errors = true,
            })
        end,
    })

    vim.keymap.del('n', 'grn')
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename)
end

return M
