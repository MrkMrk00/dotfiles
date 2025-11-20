local M = {}

local augroup = vim.api.nvim_create_augroup('config-fzf-augroup', { clear = true })

function M.setup()
    local fzf = require 'fzf-lua'
    fzf.setup {
        { 'ivy', 'borderless-full' },
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
        group = augroup,
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
end

return M
