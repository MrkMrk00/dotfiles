local M = {}

function M.setup()
    ---@diagnostic disable-next-line: missing-fields
    require('nvim-treesitter.configs').setup {
        auto_install = true,
        indent = { enable = true },
        highlight = { enable = true },
        additional_vim_regex_highlighting = false,
        textobjects = {
            select = {
                enable = true,
                keymaps = {
                    ['if'] = '@function.inner',
                    ['af'] = '@function.outer',
                    ['ib'] = '@block.inner',
                    ['ab'] = '@block.outer',
                    ['as'] = '@statement.outer',
                },
                include_surrounding_whitespace = false,
            },
            move = {
                enable = true,
                set_jumps = true,
                goto_next_start = {
                    [']f'] = '@function.outer',
                },
                goto_previous_start = {
                    ['[f'] = '@function.outer',
                },
            },
        },
    }

    local ts_repeat_move = require 'nvim-treesitter.textobjects.repeatable_move'
    vim.keymap.set({ 'n', 'x', 'o' }, ';', ts_repeat_move.repeat_last_move)
    vim.keymap.set({ 'n', 'x', 'o' }, ',', ts_repeat_move.repeat_last_move_opposite)

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
end

return M
