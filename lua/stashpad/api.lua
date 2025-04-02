local file = require('stashpad.file')
local git = require('stashpad.git')
local win = require('stashpad.win')

---@class stashpad.Api
local M = {}

function M.branch()
    local branch = git.branch()
    win.toggle({
        file = file.get(branch),
        title = string.format(' Branch : %s ', branch),
    })
end

return M
