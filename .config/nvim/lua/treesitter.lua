local M = {}

function M.setup()
    local augroup = vim.api.nvim_create_augroup('config.treesitter', { clear = true })
    local ts = require 'nvim-treesitter'
    ts.setup {
        install_dir = vim.fn.stdpath('data') .. '/treesitter'
    }
    ts.install({ 'stable' })

    vim.api.nvim_create_autocmd('FileType', {
        group = augroup,
        pattern = ts.get_installed(),
        callback = function()
            vim.treesitter.start()
        end
    })

    require('nvim-treesitter-textobjects').setup {
        select = {
            lookahead = true,
            include_surrounding_whitespace = false,
        },
        move = {
            set_jumps = true,
        },
    }

    vim.keymap.set({ "x", "o" }, "af", function()
        require "nvim-treesitter-textobjects.select".select_textobject("@function.outer", "textobjects")
    end)
    vim.keymap.set({ "x", "o" }, "if", function()
        require "nvim-treesitter-textobjects.select".select_textobject("@function.inner", "textobjects")
    end)
    vim.keymap.set({ "x", "o" }, "ac", function()
        require "nvim-treesitter-textobjects.select".select_textobject("@class.outer", "textobjects")
    end)
    vim.keymap.set({ "x", "o" }, "ic", function()
        require "nvim-treesitter-textobjects.select".select_textobject("@class.inner", "textobjects")
    end)
    vim.keymap.set({ "x", "o" }, "as", function()
        require "nvim-treesitter-textobjects.select".select_textobject("@local.scope", "locals")
    end)
    vim.keymap.set({ "n", "x", "o" }, "]m", function()
        require("nvim-treesitter-textobjects.move").goto_next_start("@function.outer", "textobjects")
    end)
    vim.keymap.set({ "n", "x", "o" }, "[m", function()
        require("nvim-treesitter-textobjects.move").goto_previous_start("@function.outer", "textobjects")
    end)

    local ts_repeat_move = require 'nvim-treesitter-textobjects.repeatable_move'
    vim.keymap.set({ 'n', 'x', 'o' }, ';', ts_repeat_move.repeat_last_move)
    vim.keymap.set({ 'n', 'x', 'o' }, ',', ts_repeat_move.repeat_last_move_opposite)

    -- make builtin f, F, t, T also repeatable with ; and ,
    vim.keymap.set({ 'n', 'x', 'o' }, 'f', ts_repeat_move.builtin_f_expr, { expr = true })
    vim.keymap.set({ 'n', 'x', 'o' }, 'F', ts_repeat_move.builtin_F_expr, { expr = true })
    vim.keymap.set({ 'n', 'x', 'o' }, 't', ts_repeat_move.builtin_t_expr, { expr = true })
    vim.keymap.set({ 'n', 'x', 'o' }, 'T', ts_repeat_move.builtin_T_expr, { expr = true })

    vim.opt.foldmethod = 'expr'
    vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'
    vim.opt.foldlevel = 99

    require('nvim-ts-autotag').setup {
        opts = {
            enable_close = true,           -- Auto close tags
            enable_rename = true,          -- Auto rename pairs of tags
            enable_close_on_slash = false, -- Auto close on trailing </
        },
    }
end

return M
