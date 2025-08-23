local M = {}

local augroup = vim.api.nvim_create_augroup('config-cmp-augroup', { clear = true })
function M.autocomplete()
    if vim.fn.pumvisible() == 0 then
        local old_shortmess = vim.o.shortmess
        vim.o.shortmess = old_shortmess .. 'c'

        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-x><C-o>', true, false, true), 'n', false)

        vim.schedule(function()
            vim.o.shortmess = old_shortmess
        end)
    end
end

function M.setup()
    vim.opt.updatetime = 300
    vim.opt.completeopt = { 'menuone', 'noinsert', 'noselect', 'popup' }
    vim.opt.omnifunc = 'syntaxcomplete#Complete' -- vim's builtin syntax autocomplete as fallback - when no LSP gets attached

    vim.api.nvim_create_autocmd('InsertCharPre', {
        desc = 'Autocomplete (omnifunc) on insert',
        group = augroup,
        callback = M.autocomplete,
    })

    vim.keymap.set('i', '<C-Space>', M.autocomplete)
end

return M
