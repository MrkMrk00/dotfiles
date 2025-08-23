local M = {}

function M.setup()
    local iron = require 'iron.core'
    local view = require 'iron.view'
    iron.setup {
        config = {
            scratch_repl = true,
            repl_definition = {
                haskell = {
                    command = function(meta)
                        local filename = vim.api.nvim_buf_get_name(meta.current_bufnr)

                        return { 'ghci', filename }
                    end,
                },
            },
            repl_open_cmd = view.split.vertical.botright '40%',
        },

        keymaps = {
            toggle_repl = '<leader>rr',
            send_file = '<leader>rf',
            visual_send = '<leader>rs',
            send_code_block = '<space>rb',
            send_code_block_and_move = '<space>rn',
        },
    }
end

return M
