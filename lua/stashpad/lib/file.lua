local Project = require('stashpad.lib.project')

---@class (exact) stashpad.file.Config
---@field root string
---@field extension fun(): string

---@class stashpad.file.Info
---@field project string
---@field file string

---@class stashpad.File
---@field private config stashpad.file.Config
local M = {}

---Should only be called from init.lua setup
---@param config stashpad.file.Config
function M.setup(config)
    M.config = config
end

function M.delete()
    vim.fs.rm(M.config.root, { recursive = true, force = true })
end

---@return string
function M.project()
    return vim.fs.joinpath(M.config.root, Project.get())
end

---@param name string
---@return stashpad.file.Info
function M.get(name)
    local project = Project.get()
    local path = vim.fs.joinpath(M.config.root, project, name)
    local file = string.format('%s.%s', path, M.config.extension())

    local dir = vim.fs.dirname(file)
    if vim.uv.fs_stat(dir) == nil then
        vim.fn.mkdir(dir, 'p')
    end
    if vim.uv.fs_stat(file) == nil then
        assert(io.open(file, 'w')):close()
    end

    ---@type stashpad.file.Info
    return { project = project, file = file }
end

return M
