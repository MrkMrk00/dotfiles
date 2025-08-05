return {
  {
    'stevearc/oil.nvim',
    tag = 'stable',
    lazy = false,
    config = function()
      require('oil').setup {
        view_options = {
          show_hidden = true,
        },
      }

      vim.api.nvim_create_user_command('Ex', 'Oil', {})
    end,
  },
}
