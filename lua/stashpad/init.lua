---@class stashpad.Init: stashpad.Api
local M = {}

---@class (exact) stashpad.Config
---@field file stashpad.config.File
---@field git stashpad.config.Git
---@field win stashpad.config.Win

---@private
---@type stashpad.Config
M.default = {
    file = {
        -- Typically resolves to ~/.local/share/nvim/stashpad
        root = vim.fs.joinpath(vim.fn.stdpath('data'), 'stashpad'),
        -- Extension to use for files
        extension = function()
            return 'md'
        end,
    },
    git = {
        -- Fallback for any information that cannot be determined
        fallback = 'default',
    },
    win = {
        width = 0.75,
        height = 0.75,
        border = vim.o.winborder,
    },
}

---@param opts? stashpad.user.Config
function M.setup(opts)
    local config = vim.tbl_deep_extend('force', M.default, opts or {})
    require('stashpad.file').setup(config.file)
    require('stashpad.git').setup(config.git)
    require('stashpad.win').setup(config.win)
end

return setmetatable(M, {
    __index = function(_, key)
        -- Allows API methods to be accessed from top level
        return require('stashpad.api')[key]
    end,
})
