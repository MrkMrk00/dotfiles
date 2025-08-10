---@class PlugSpec
---@field src string
---@field name ?string
---@field version ?string
---@field on_update ?fun(plug: vim.pack.PlugData)

local M = {}

---@type PlugSpec[]
local plugins = {}
local augroup = vim.api.nvim_create_augroup('lazy_plug', { clear = true })

--- @param ev vim.api.keyset.create_autocmd.callback_args
local function call_update_hooks(ev)
    for _, plugin in ipairs(plugins) do
        if plugin.src == ev.data.spec.src and plugin.on_update ~= nil then
            plugin.on_update(ev.data.spec)
        end
    end
end

local function plug_cleanup()
    local should_delete = {}
    local should_update = {}

    for _, pack_plugin in ipairs(vim.pack.get()) do
        local found = nil
        for _, plugin in ipairs(plugins) do
            if plugin.src == pack_plugin.spec.src then
                found = plugin
                break
            end
        end

        if found == nil then
            table.insert(should_delete, pack_plugin.spec.name)
        elseif found.version ~= nil and found.version ~= pack_plugin.spec.version then
            table.insert(should_update, pack_plugin.spec.name)
        end
    end

    if #should_delete > 0 then
        vim.pack.del(should_delete)
    end

    if #should_update > 0 then
        vim.pack.update(should_update, { force = true })
    end
end

---@param plug_specs PlugSpec[]
function M.setup(plug_specs)
    plugins = plug_specs

    vim.api.nvim_create_autocmd('PackChanged', {
        group = augroup,
        callback = call_update_hooks,
    })

    vim.pack.add(plugins, { load = false })

    plug_cleanup()
end

return M
