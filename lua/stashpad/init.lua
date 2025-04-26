---@class stashpad.Init: stashpad.Api
local M = {}

---@class (exact) stashpad.Config
---@field file stashpad.file.Config
---@field git stashpad.git.Config
---@field project stashpad.project.Config
---@field win stashpad.win.Config

---@private
---@type boolean
M.initialized = false

---@type stashpad.Config
M.default = {
    file = require('stashpad.lib.file').default,
    git = require('stashpad.lib.git').default,
    project = require('stashpad.lib.project').default,
    win = require('stashpad.lib.win').default,
}

---@param opts? stashpad.UserConfig
function M.setup(opts)
    -- Skip initialization if already done and input is empty
    if M.initialized and vim.tbl_count(opts or {}) == 0 then
        return
    end
    M.initialized = true
    local config = vim.tbl_deep_extend('force', M.default, opts or {})
    require('stashpad.state').setup(config)
end

return setmetatable(M, {
    __index = function(_, key)
        -- Allows API methods to be accessed from top level
        return require('stashpad.api')[key]
    end,
})
