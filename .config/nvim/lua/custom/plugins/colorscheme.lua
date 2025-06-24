local colorscheme = 'rose-pine'

local function load_colorscheme()
  if colorscheme == 'binary' then
    vim.cmd.colorscheme 'binary'
  elseif colorscheme == 'rose-pine' then
    vim.cmd.colorscheme 'rose-pine-dawn'
  end

  vim.o.background = 'light'
  vim.opt.guicursor = 'n-v-c:block-Cursor,i-ci:ver25-InCursor,r-cr:hor20-Cursor'
  vim.cmd [[
    highlight Cursor guifg=black guibg=orange
    highlight InCursor guifg=white guibg=blue
  ]]
end

return {
  {
    'jackplus-xyz/binary.nvim',
    event = 'VeryLazy',
    init = load_colorscheme,
  },

  {
    'rose-pine/neovim',
    name = 'rose-pine',
    event = 'VeryLazy',
    opts = {
      highlight_groups = {
        TelescopeBorder = { fg = 'overlay', bg = 'overlay' },
        TelescopeNormal = { fg = 'subtle', bg = 'overlay' },
        TelescopeSelection = { fg = 'text', bg = 'highlight_med' },
        TelescopeSelectionCaret = { fg = 'love', bg = 'highlight_med' },
        TelescopeMultiSelection = { fg = 'text', bg = 'highlight_high' },

        TelescopeTitle = { fg = 'base', bg = 'love' },
        TelescopePromptTitle = { fg = 'base', bg = 'pine' },
        TelescopePreviewTitle = { fg = 'base', bg = 'iris' },

        TelescopePromptNormal = { fg = 'text', bg = 'surface' },
        TelescopePromptBorder = { fg = 'surface', bg = 'surface' },
      },
      styles = {
        italic = false,
        bold = false,
      },
    },
    init = load_colorscheme,
  },
}
