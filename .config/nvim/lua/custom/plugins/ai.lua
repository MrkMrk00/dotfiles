return {
  {
    'yetone/avante.nvim',
    lazy = true,
    version = false,
    keys = {
      '<leader>aa',
    },
    opts = {
      provider = 'copilot',
      behaviour = {
        auto_suggestions = false,
      },
    },
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      'stevearc/dressing.nvim',
      'nvim-lua/plenary.nvim',
      'MunifTanjim/nui.nvim',
      {
        'zbirenbaum/copilot.lua',
        lazy = true,
        cmd = 'Copilot',
        opts = {
          suggestion = {
            auto_trigger = false,
            -- keymap = {
            --   accept = '<C-y>',
            --   next = '<C-n>',
            --   prev = '<C-p>',
            -- },
          },
        },
      },
      {
        'MeanderingProgrammer/render-markdown.nvim',
        opts = {
          file_types = { 'markdown', 'Avante' },
        },
        ft = { 'markdown', 'Avante' },
      },
    },
  },
}
