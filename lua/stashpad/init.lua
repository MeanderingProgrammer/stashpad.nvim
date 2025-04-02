---@class stashpad.Init: stashpad.Api
local M = {}

---@class (exact) stashpad.user.Config
---@field root? string

---@private
---@type stashpad.Config
M.default = {
    -- Typically resolves to ~/.local/share/nvim/stashpad
    root = vim.fs.joinpath(vim.fn.stdpath('data'), 'stashpad'),
}

---@param opts? stashpad.user.Config
function M.setup(opts)
    require('stashpad.state').setup(M.default, opts or {})
end

return setmetatable(M, {
    __index = function(_, key)
        -- Allows API methods to be accessed from top level
        return require('stashpad.api')[key]
    end,
})
