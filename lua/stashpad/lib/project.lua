local Git = require('stashpad.lib.git')

---@class (exact) stashpad.project.Config
---@field order stashpad.project.Option[]
---@field markers string[]
---@field fallback fun(): string

---@alias stashpad.project.Option stashpad.project.Provider|fun(): string?

---@enum stashpad.project.Provider
local Provider = {
    lsp = 'lsp',
    remote = 'remote',
    root = 'root',
}

---@class stashpad.Project
---@field private config stashpad.project.Config
local M = {}

---@type stashpad.project.Config
M.default = {
    order = { 'remote', 'root', 'lsp' },
    markers = { '.git' },
    fallback = function()
        return 'default'
    end,
}

---called from state on setup
---@param config stashpad.project.Config
function M.setup(config)
    M.config = config
end

---@return stashpad.schema.Field
function M.schema()
    local Schema = require('stashpad.debug.schema')
    return Schema.record({
        order = Schema.list(Schema.union({
            Schema.enum(Provider),
            Schema.type('function'),
        })),
        markers = Schema.list(Schema.type('string')),
        fallback = Schema.type('function'),
    })
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
    elseif option == Provider.lsp then
        return M.lsp()
    elseif option == Provider.remote then
        return Git.remote()
    elseif option == Provider.root then
        return M.root()
    else
        return nil
    end
end

---@private
---@return string?
function M.lsp()
    local folders = vim.lsp.buf.list_workspace_folders()
    return vim.fs.basename(folders[1])
end

---@private
---@return string?
function M.root()
    local dir = vim.fs.root(assert(vim.uv.cwd()), M.config.markers)
    return vim.fs.basename(dir)
end

return M
