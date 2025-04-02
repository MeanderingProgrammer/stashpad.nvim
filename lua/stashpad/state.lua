---@class stashpad.State
---@field config stashpad.Config
local M = {}

---@param default stashpad.Config
---@param user stashpad.user.Config
function M.setup(default, user)
    M.config = vim.tbl_deep_extend('force', default, user)
end

return M
