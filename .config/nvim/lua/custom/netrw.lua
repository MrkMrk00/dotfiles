vim.g.netrw_liststyle = 1
vim.g.netrw_sort_sequence = '[/]'

local function current_dirname()
  local filepath = vim.api.nvim_buf_get_name(0)

  return vim.fn.fnamemodify(filepath, ':p:h')
end

function string:startswith(start)
  return self:sub(1, #start) == start
end

local function run_with_opts(callback, opts)
  local old_values = {}

  for key, new_value in pairs(opts) do
    if key:startswith '_' then
      goto next
    end

    old_values[key] = vim.g[key]
    vim.g['netrw_' .. key] = new_value
::next::
  end

  callback()

  for key, old_value in pairs(old_values) do
    vim.g['netrw_' .. key] = old_value
  end
end

local N = {
  Lexplore = function(opts)
    run_with_opts(function()
      vim.cmd('Lexplore ' .. (opts._path or ''))
    end, opts or {})
  end,

  Explore = function(opts)
    run_with_opts(function()
      vim.cmd('Explore ' .. (opts._path or ''))
    end, opts or {})
  end,
}

vim.keymap.set('n', '<leader>ee', function()
  N.Lexplore {
    liststyle = 3,
    banner = 0,
    winsize = 25,
  }
end, { desc = 'open [e]xplore side panel' })

vim.keymap.set('n', '<leader>eE', function()
  N.Explore()
end, { desc = '[e]xplore' })

vim.keymap.set('n', '<leader>ec', function()
  N.Lexplore {
    liststyle = 3,
    banner = 0,
    winsize = 25,
    _path = current_dirname(),
  }
end, { desc = "[e]xplore [c]urrent buffer's dirname" })

vim.keymap.set('n', '<leader>eC', function()
  N.Explore {
    _path = current_dirname(),
  }
end, { desc = "open [e]xplore [C]urrent in buffer's dirname" })
