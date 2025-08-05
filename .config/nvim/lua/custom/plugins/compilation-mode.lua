return {
  'ej-shafran/compile-mode.nvim',
  branch = 'latest',
  lazy = true,
  cmd = {
    'Compile',
    'Recompile',
  },
  dependencies = {
    'nvim-lua/plenary.nvim',
    -- if you want to enable coloring of ANSI escape codes in
    -- compilation output, add:
    { 'm00qek/baleia.nvim', tag = 'v1.3.0' },
  },
  config = function()
    ---@type CompileModeOpts
    vim.g.compile_mode = {
      -- to add ANSI escape code support, add:
      baleia_setup = true,

      -- to make `:Compile` replace special characters (e.g. `%`) in
      -- the command (and behave more like `:!`), add:
      bang_expansion = true,

      error_regexp_table = {
        typescript = {
          regex = '^\\(.\\+\\)(\\([1-9][0-9]*\\),\\([1-9][0-9]*\\)): error TS[1-9][0-9]*:',
          filename = 1,
          row = 2,
          col = 3,
          type = 2,
        },
        pascal = {
          regex = '^\\(.\\+\\)(\\([1-9][0-9]*\\),\\([1-9][0-9]*\\)) Error:',
          filename = 1,
          row = 2,
          col = 3,
          type = 2,
        },
        pascal_fatal = {
          regex = '^\\(.\\+\\)(\\([1-9][0-9]*\\),\\([1-9][0-9]*\\)) Fatal:',
          filename = 1,
          row = 2,
          col = 3,
          type = 2,
        },
      },
    }
  end,
}
