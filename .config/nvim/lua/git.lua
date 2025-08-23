local M = {}

function M.setup()
    vim.keymap.set('n', '<leader>gg', function()
        require('neogit').open()
    end)

    local gitsigns = require 'gitsigns'
    local ts_repeat_move = require 'nvim-treesitter.textobjects.repeatable_move'

    gitsigns.setup {
        on_attach = function(bufnr)
            local function map(mode, l, r, opts)
                opts = opts or {}
                opts.buffer = bufnr
                vim.keymap.set(mode, l, r, opts)
            end

            map('n', '<leader>gs', gitsigns.stage_hunk)
            map('n', '<leader>gr', gitsigns.reset_hunk)

            -- make the next/prev hunk commands repeatable with ";" and ","
            local next_hunk_repeat, prev_hunk_repeat = ts_repeat_move.make_repeatable_move_pair(function()
                ---@diagnostic disable-next-line: param-type-mismatch
                gitsigns.nav_hunk 'next'
            end, function()
                ---@diagnostic disable-next-line: param-type-mismatch
                gitsigns.nav_hunk 'prev'
            end)

            map({ 'n', 'x', 'o' }, ']h', next_hunk_repeat)
            map({ 'n', 'x', 'o' }, '[h', prev_hunk_repeat)

            map('v', '<leader>gs', function()
                gitsigns.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
            end)
            map('v', '<leader>gr', function()
                gitsigns.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
            end)

            map('n', '<leader>gb', function()
                gitsigns.blame_line { full = true }
            end)
            map('n', '<leader>gB', gitsigns.blame)
            map('n', '<leader>gq', function()
                ---@diagnostic disable-next-line: param-type-mismatch
                gitsigns.setqflist(0, { open = false, use_location_list = true }, function()
                    require('fzf-lua').loclist()
                end)
            end, { desc = 'List all git hunks in current file in loclist' })
        end,
    }
end

return M
