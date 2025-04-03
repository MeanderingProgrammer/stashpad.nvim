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

---@param prefix string[]
---@param name string
---@return string
function M.get(prefix, name)
    local path = vim.list_extend({ M.config.root, git.repo() }, prefix)
    local dir = vim.fs.joinpath(unpack(path))
    if vim.uv.fs_stat(dir) == nil then
        vim.fn.mkdir(dir, 'p')
    end

    local extension = M.config.extension()
    local file = string.format('%s.%s', vim.fs.joinpath(dir, name), extension)
    if vim.uv.fs_stat(file) == nil then
        assert(io.open(file, 'w')):close()
    end

    return file
end

return M
