---@class stashpad.Init: stashpad.Api
local M = {}

---@class (exact) stashpad.user.Config
---@field root? string
---@field fallback? string
---@field buffer? stashpad.user.Buffer
---@field window? stashpad.user.Window

---@class (exact) stashpad.user.Buffer
---@field filetype? fun(): string

---@class (exact) stashpad.user.Window
---@field width? number
---@field height? number
---@field border? string|string[]

---@private
---@type stashpad.Config
M.default = {
    -- Typically resolves to ~/.local/share/nvim/stashpad
    root = vim.fs.joinpath(vim.fn.stdpath('data'), 'stashpad'),
    -- Fallback for repo and branch if they cannot be determined
    fallback = 'default',
    buffer = {
        filetype = function()
            return 'markdown'
        end,
    },
    window = {
        width = 0.75,
        height = 0.75,
        border = vim.o.winborder,
    },
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
