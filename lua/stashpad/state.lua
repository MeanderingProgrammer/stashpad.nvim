---@class stashpad.State
---@field private config stashpad.Config
local M = {}

---called from init on setup
---@param config stashpad.Config
function M.setup(config)
    M.config = config
    require('stashpad.lib.file').setup(config.file)
    require('stashpad.lib.git').setup(config.git)
    require('stashpad.lib.project').setup(config.project)
    require('stashpad.lib.win').setup(config.win)
end

---@return string[]
function M.validate()
    local Schema = require('stashpad.debug.schema')
    local schema = Schema.record({
        file = require('stashpad.lib.file').schema(),
        git = require('stashpad.lib.git').schema(),
        project = require('stashpad.lib.project').schema(),
        win = require('stashpad.lib.win').schema(),
    })

    local messages = {} ---@type string[]
    local errors = schema:check('stashpad', M.config)
    for _, err in ipairs(errors) do
        local msg = ('expected: %s, got: %s'):format(err.expected, err.actual)
        messages[#messages + 1] = ('%s - %s'):format(err.path, msg)
    end
    table.sort(messages)
    return messages
end

return M
