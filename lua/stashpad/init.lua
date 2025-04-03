---@class stashpad.Init: stashpad.Api
local M = {}

---@class (exact) stashpad.Config
---@field file stashpad.config.File
---@field git stashpad.config.Git
---@field project stashpad.config.Project
---@field win stashpad.config.Win

---@private
M.initialized = false

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
        -- Fallback for branch if it cannot be determined
        branch = function()
            return 'default'
        end,
    },
    project = {
        order = { 'remote', 'root', 'lsp' },
        markers = { '.git' },
        fallback = function()
            return 'default'
        end,
    },
    win = {
        width = 0.75,
        height = 0.75,
        border = vim.o.winborder,
    },
}

---@param opts? stashpad.user.Config
function M.setup(opts)
    -- Skip initialization if already done and input is empty
    if M.initialized and vim.tbl_count(opts or {}) == 0 then
        return
    end
    M.initialized = true

    local config = vim.tbl_deep_extend('force', M.default, opts or {})
    require('stashpad.file').setup(config.file)
    require('stashpad.git').setup(config.git)
    require('stashpad.project').setup(config.project)
    require('stashpad.win').setup(config.win)
end

return setmetatable(M, {
    __index = function(_, key)
        -- Allows API methods to be accessed from top level
        return require('stashpad.api')[key]
    end,
})
