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
    return require('stashpad.debug.schema').validate(M.config, {
        record = {
            file = require('stashpad.lib.file').schema(),
            git = require('stashpad.lib.git').schema(),
            project = require('stashpad.lib.project').schema(),
            win = require('stashpad.lib.win').schema(),
        },
    })
end

return M
