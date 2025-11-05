---@class (exact) stashpad.file.Config
---@field root string
---@field extension fun(): string

---@class stashpad.file.Info
---@field project string
---@field file string

---@class stashpad.File
---@field private config stashpad.file.Config
local M = {}

---@type stashpad.file.Config
M.default = {
    -- Typically resolves to ~/.local/share/nvim/stashpad
    root = vim.fs.joinpath(vim.fn.stdpath('data'), 'stashpad'),
    -- Extension to use for files
    extension = function()
        return 'md'
    end,
}

---called from state on setup
---@param config stashpad.file.Config
function M.setup(config)
    M.config = config
end

---@return stashpad.Schema
function M.schema()
    ---@type stashpad.Schema
    return {
        record = {
            root = { type = 'string' },
            extension = { type = 'function' },
        },
    }
end

function M.delete()
    vim.fs.rm(M.config.root, { recursive = true, force = true })
end

---@return string
function M.project()
    return vim.fs.joinpath(M.config.root, M.resolve())
end

---@param name string
---@param project? string
---@return stashpad.file.Info
function M.get(name, project)
    project = project or M.resolve()
    local path = vim.fs.joinpath(M.config.root, project, name)
    local file = ('%s.%s'):format(path, M.config.extension())

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

---@private
---@return string
function M.resolve()
    return require('stashpad.lib.project').get()
end

return M
