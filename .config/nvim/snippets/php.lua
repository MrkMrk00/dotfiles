local ls = require 'luasnip'

local s = ls.snippet
local i = ls.insert_node
local fmt = require('luasnip.extras.fmt').fmt

local function method_snip(trigger, access_modifier)
    local config = {
        trig = trigger,
        name = access_modifier .. ' function',
    }

    local format = fmt(
        [[
<am> function <fn>(): <type>
{
    <>
}
    ]],
        {
            am = access_modifier,
            fn = i(1, 'ahoj'),
            type = i(2, 'void'),
            i(3, ''),
        },
        { delimiters = '<>' }
    )

    return s(config, format)
end

ls.add_snippets('php', {
    method_snip('pubf', 'public'),
    method_snip('prof', 'protected'),
    method_snip('prif', 'private'),
    method_snip('prisf', 'private static'),
    method_snip('prosf', 'protected static'),
    method_snip('pubsf', 'public static'),
})
