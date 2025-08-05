return {
  {
    'mfussenegger/nvim-dap',
    lazy = true,
    keys = {
      {
        '<leader>db',
        function()
          require('dap').toggle_breakpoint()
        end,
        mode = 'n',
        desc = '[d]ebugger breakpoint',
      },
      {
        '<leader>dB',
        function()
          vim.ui.input({ prompt = 'Breakpoint condition: ' }, function(condition)
            if condition then
              require('dap').toggle_breakpoint(condition)
            end
          end)
        end,
        mode = 'n',
        desc = '[d]ebugger conditional breakpoint',
      },
    },
    dependencies = {
      'mason-org/mason.nvim',
      'jay-babu/mason-nvim-dap.nvim',
      { 'rcarriga/nvim-dap-ui', opts = {} },
      'nvim-neotest/nvim-nio',
    },
    config = function()
      local dap = require 'dap'
      local dapui = require 'dapui'

      vim.keymap.set('n', '<F7>', function()
        dap.step_back()
      end, {
        desc = 'Debugger: step back',
      })
      vim.keymap.set('n', '<F8>', function()
        dap.continue()
      end, {
        desc = 'Debugger: continue',
      })
      vim.keymap.set('n', '<F9>', function()
        dap.step_over()
      end, {
        desc = 'Debugger: step over',
      })
      vim.keymap.set('n', '<F10>', function()
        dap.step_into()
      end, {
        desc = 'Debugger: step into',
      })
      vim.keymap.set('n', '<S-F10>', function()
        dap.step_out()
      end, {
        desc = 'Debugger: step out',
      })

      vim.keymap.set('n', 'F9', function()
        dap.continue()
      end)

      dap.listeners.before.attach.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.launch.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated.dapui_config = function()
        dapui.close()
      end
      dap.listeners.before.event_exited.dapui_config = function()
        dapui.close()
      end

      require('mason-nvim-dap').setup {
        ensure_installed = { 'codelldb' },
        automatic_installation = false,
        handlers = {},
      }
    end,
  },
}
