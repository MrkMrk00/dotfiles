vim.opt.listchars = { tab = '  ', trail = '·', nbsp = '␣' }

vim.api.nvim_create_autocmd('BufEnter', {
    pattern = '*.go',
    callback = function()
        vim.opt.listchars = { tab = '  ', trail = '·', nbsp = '␣' }
    end,
})

vim.api.nvim_create_autocmd('BufLeave', {
    pattern = '*.go',
    callback = function()
        vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
    end,
})
