local api = require('stashpad.api')

local name = 'Stashpad'
local plugin = 'stashpad.nvim'

---@class stashpad.Command
local M = {}

---called from plugin directory
function M.init()
    vim.api.nvim_create_user_command(name, M.command, {
        nargs = '*',
        desc = plugin .. ' commands',
        complete = function(prefix, cmdline)
            if cmdline:find(name .. '%s+%S+%s+.*') then
                return {}
            elseif cmdline:find(name .. '%s+') then
                return M.matches(prefix, vim.tbl_keys(api))
            else
                return {}
            end
        end,
    })
end

---@private
---@param opts { fargs: string[] }
function M.command(opts)
    local args, err = opts.fargs, nil
    if #args == 0 or #args == 1 then
        local command = #args == 0 and api.branch or api[args[1]]
        if command ~= nil then
            command()
        else
            err = ('unexpected command: %s'):format(args[1])
        end
    else
        err = ('unexpected # arguments: %d'):format(#args)
    end
    if err ~= nil then
        vim.notify(('%s: %s'):format(plugin, err), vim.log.levels.ERROR)
    end
end

---@private
---@param prefix string
---@param values string[]
---@return string[]
function M.matches(prefix, values)
    local result = {} ---@type string[]
    for _, value in ipairs(values) do
        if vim.startswith(value, prefix) then
            result[#result + 1] = value
        end
    end
    return result
end

return M
