local ls = require 'luasnip'
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local d = ls.dynamic_node
local sn = ls.snippet_node

-- Detect if the cursor is inside a class definition using Tree-sitter
local function in_class()
    local ts_utils = require 'nvim-treesitter.ts_utils'

    local node = ts_utils.get_node_at_cursor()
    if not node then
        return false
    end

    local row, _ = unpack(vim.api.nvim_win_get_cursor(0))
    row = row - 1

    while node do
        if node:type() == 'class_definition' then
            local start_row, _, end_row, _ = node:range()

            if row > start_row and row <= end_row + 1 then
                return true
            end
        end
        node = node:parent()
    end
    return false
end

-- Dynamic snippet builder for method or function
local function def_node()
    if in_class() then
        return sn(nil, {
            t 'def ',
            i(1, 'method_name'),
            t '(self',
            i(2),
            t { '):', '    ' },
            i(0),
        })
    else
        return sn(nil, {
            t 'def ',
            i(1, 'function_name'),
            t '(',
            i(2),
            t { '):', '    ' },
            i(0),
        })
    end
end

-- Register snippets
ls.add_snippets('python', {
    -- def __init__(...
    s('init', {
        t 'def __init__(self',
        i(0),
        t { '):', '    ' },
        i(1, 'pass'),
    }),

    -- context-aware def snippet
    s('def', d(1, def_node, {})),
})
