local git = require('stashpad.git')

---@class (exact) stashpad.config.File
---@field root string
---@field extension fun(): string

---@class stashpad.File
---@field private config stashpad.config.File
local M = {}

---Should only be called from init.lua setup
---@param config stashpad.config.File
function M.setup(config)
    M.config = config
end

---@param name string
---@return string
function M.get(name)
    local repo = git.repo()
    local dir = vim.fs.joinpath(M.config.root, repo)
    vim.fn.mkdir(dir, 'p')

    local extension = M.config.extension()
    local file = string.format('%s.%s', vim.fs.joinpath(dir, name), extension)
    if vim.uv.fs_stat(file) == nil then
        assert(io.open(file, 'w')):close()
    end

    return file
end

return M
