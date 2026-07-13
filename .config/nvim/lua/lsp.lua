local M = {
    mason_path = vim.fn.stdpath 'data' .. '/meson',
}

local augroup = vim.api.nvim_create_augroup('config-lsp-augroup', { clear = true })

function M.setup()
    require('mason').setup { install_root_dir = M.meson_path }
    local mason_lspconfig = require 'mason-lspconfig'
    mason_lspconfig.setup {
        ensure_installed = { 'lua_ls' },
    }

    local conform = require 'conform'

    local js_formatters = { 'oxfmt', 'prettierd', 'prettier', 'eslint' }

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
