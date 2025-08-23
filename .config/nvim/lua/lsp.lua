local M = {}

local augroup = vim.api.nvim_create_augroup('config-lsp-augroup', { clear = true })

function M._setup_vuejs()
    local vue_language_server_path = vim.fn.expand '$MASON/packages'
        .. '/vue-language-server'
        .. '/node_modules/@vue/language-server'

    local vue_plugin = {
        name = '@vue/typescript-plugin',
        location = vue_language_server_path,
        languages = { 'vue' },
        configNamespace = 'typescript',
    }

    vim.lsp.config('vtsls', {
        settings = {
            vtsls = {
                -- This should be enabled, but the plugins then have to be defined per project :/.
                -- autoUseWorkspaceTsdk = true,
                tsserver = {
                    globalPlugins = {
                        vue_plugin,
                    },
                },
            },
        },
        filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue' },
    })
end

function M.setup()
    require('mason').setup {
        install_root_dir = vim.fn.stdpath 'data' .. 'mason-nvim-next',
    }

    require('mason-lspconfig').setup {
        ensure_installed = { 'lua_ls', 'vtsls', 'clangd', 'phpactor' },
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
            svelte = { 'prettierd', 'eslint' },
            c = { 'clang-format' },
            cpp = { 'clang-format' },
            go = { 'gofmt' },
            php = { 'php-cs-fixer' },
        },
        formatters = {
            ['clang-format'] = {
                args = {
                    '-style={BasedOnStyle: Mozilla, ColumnLimit: 120, IndentWidth: 4, AlwaysBreakAfterReturnType: None, AlwaysBreakAfterDefinitionReturnType: None, AllowShortFunctionsOnASingleLine: Empty, BreakBeforeBraces: Linux, UseTab: Never, AllowShortIfStatementsOnASingleLine: true}',
                },
            },
        },
    }

    local lint = require 'lint'
    lint.linters_by_ft = {
        javascript = { 'eslint' },
        typescript = { 'eslint' },
        typescriptreact = { 'eslint' },
        javascriptreact = { 'eslint' },
        vue = { 'eslint' },
        php = { 'phpstan' },
    }

    vim.keymap.set('n', '<leader>f', function()
        conform.format {
            async = true,
            lsp_format = 'fallback',
            callback = function()
                lint.try_lint()
            end,
        }
    end)

    vim.api.nvim_create_autocmd({ 'BufWritePost' }, {
        group = augroup,
        callback = function()
            lint.try_lint()
        end,
    })

    vim.api.nvim_create_autocmd('LspAttach', {
        group = augroup,
        callback = function()
            vim.opt.omnifunc = 'v:lua.vim.lsp.omnifunc'
        end,
    })

    M._setup_vuejs()
end

return M
