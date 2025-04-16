---@class stashpad.Init: stashpad.Api
local M = {}

---@class (exact) stashpad.Config
---@field file stashpad.file.Config
---@field git stashpad.git.Config
---@field project stashpad.project.Config
---@field win stashpad.win.Config

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

---@param opts? stashpad.UserConfig
function M.setup(opts)
    -- Skip initialization if already done and input is empty
    if M.initialized and vim.tbl_count(opts or {}) == 0 then
        return
    end
    M.initialized = true

    local config = vim.tbl_deep_extend('force', M.default, opts or {})
    require('stashpad.lib.file').setup(config.file)
    require('stashpad.lib.git').setup(config.git)
    require('stashpad.lib.project').setup(config.project)
    require('stashpad.lib.win').setup(config.win)
end

return setmetatable(M, {
    __index = function(_, key)
        -- Allows API methods to be accessed from top level
        return require('stashpad.api')[key]
    end,
})
