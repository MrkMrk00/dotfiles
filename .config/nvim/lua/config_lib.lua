local M = {}

local initialized = false
local augroup = vim.api.nvim_create_augroup('config-lib-augroup', { clear = true })
local pack_change_listeners = {}

local function register_listeners()
    vim.api.nvim_create_autocmd('PackChanged', {
        group = augroup,
        callback = function(ev)
            if ev.data.kind == 'delete' then
                return
            end

            local plugin_name = ev.data.spec.name
            if pack_change_listeners[plugin_name] == nil then
                return
            end

            for _, listener in ipairs(pack_change_listeners[plugin_name]) do
                pcall(listener, ev)
            end
        end,
    })
end

function M.pack_on_plugin_change(plugin_name, listener)
    if pack_change_listeners[plugin_name] == nil then
        pack_change_listeners[plugin_name] = {}
    end

    table.insert(pack_change_listeners[plugin_name], listener)
end

function M.pack_cleanup(specs)
    local should_delete = {}
    local should_update = {}

    for _, pack_plugin in ipairs(vim.pack.get()) do
        local found = nil
        for _, plugin in ipairs(specs) do
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

function M.pack_register_plugins(specs)
    if not initialized then
        register_listeners()

        initialized = true
    end

    vim.pack.add(specs, { load = false })
end

function M.pack_get_path()
    return vim.fn.stdpath 'data' .. '/site/pack/core/opt/'
end

return M
