-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

return {
  'nvim-neo-tree/neo-tree.nvim',
  event = 'VeryLazy',
  version = '*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
    'MunifTanjim/nui.nvim',
  },
  cmd = 'Neotree',
  keys = {
    { '\\', ':Neotree reveal<CR>', { desc = 'NeoTree reveal' } },
  },
  opts = {
    filesystem = {
      filtered_items = {
        visible = true,
      },

      window = {
        mappings = {
          ['\\'] = 'close_window',
          ['d'] = 'add_directory',
          ['D'] = 'delete',
          ['R'] = 'rename',
          ['%'] = 'add',
        },
      },
    },
  },
}
