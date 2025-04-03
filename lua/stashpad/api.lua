local file = require('stashpad.file')
local git = require('stashpad.git')
local win = require('stashpad.win')

---@class stashpad.Api
local M = {}

function M.branch()
    local branch = git.branch()
    win.toggle({
        file = file.get({ 'branch' }, branch),
        title = string.format('Branch : %s', branch),
    })
end

function M.global()
    win.toggle({
        file = file.get({}, 'global'),
        title = 'Global',
    })
end

function M.todo()
    win.toggle({
        file = file.get({}, 'todo'),
        title = 'Todo',
    })
end

return M
