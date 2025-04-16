local Git = require('stashpad.lib.git')

---@class (exact) stashpad.project.Config
---@field order stashpad.project.Option[]
---@field markers string[]
---@field fallback fun(): string

---@alias stashpad.project.Option 'remote'|'root'|'lsp'|fun(): string?

---@class stashpad.Project
---@field private config stashpad.project.Config
local M = {}

---Should only be called from init.lua setup
---@param config stashpad.project.Config
function M.setup(config)
    M.config = config
end

---@return string
function M.get()
    for _, option in ipairs(M.config.order) do
        local value = M.resolve(option)
        if value ~= nil then
            return value
        end
    end
    return M.config.fallback()
end

---@private
---@param option stashpad.project.Option
---@return string?
function M.resolve(option)
    if type(option) == 'function' then
        return option()
    elseif option == 'remote' then
        return Git.remote()
    elseif option == 'root' then
        return M.root()
    elseif option == 'lsp' then
        return M.lsp()
    else
        return nil
    end
end

---@private
---@return string?
function M.root()
    local dir = vim.fs.root(assert(vim.uv.cwd()), M.config.markers)
    return vim.fs.basename(dir)
end

---@private
---@return string?
function M.lsp()
    local folders = vim.lsp.buf.list_workspace_folders()
    return vim.fs.basename(folders[1])
end

return M
