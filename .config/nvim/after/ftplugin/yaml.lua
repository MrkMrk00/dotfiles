local augroup = vim.api.nvim_create_augroup('config-ftplugin.yaml', { clear = true })

require('ibl').setup {
    enabled = true,
}

vim.api.nvim_create_autocmd('BufEnter', {
    group = augroup,
    pattern = { '*.yaml', '*.yml' },
    callback = function()
        require('ibl').setup {
            enabled = true,
        }
    end,
})

vim.api.nvim_create_autocmd('BufLeave', {
    group = augroup,
    pattern = { '*.yaml', '*.yml' },
    callback = function()
        require('ibl').setup {
            enabled = false,
        }
    end,
})
