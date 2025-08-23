local M = {}

local augroup = vim.api.nvim_create_augroup('config-fzf-augroup', { clear = true })

function M.setup()
    local fzf = require 'fzf-lua'
    fzf.setup {
        { 'ivy', 'borderless-full' },
        files = {
            cwd_prompt = false,
        },
    }
    fzf.register_ui_select()

    vim.keymap.set('n', '<leader>sf', fzf.files)
    vim.keymap.set('n', '<leader>sn', function()
        fzf.files { cwd = '~/.config/nvim/' }
    end, { desc = 'Search neovim config' })
    vim.keymap.set('n', '<leader>sg', fzf.live_grep_native)
    vim.keymap.set('n', '<leader>/', fzf.lgrep_curbuf)
    vim.keymap.set('n', '<leader>sr', fzf.resume)
    vim.keymap.set('n', '<leader> ', fzf.buffers)

    -- Those are native NVIM keybinds - they prefix with my custom -> slow
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
            vim.keymap.set('n', '<leader>q', fzf.lsp_document_diagnostics)
            vim.keymap.set('n', '<leader>wq', fzf.lsp_workspace_diagnostics)
        end,
    })
end

return M
