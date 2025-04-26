---@class (exact) stashpad.git.Config
---@field branch fun(): string

---@class stashpad.Git
---@field private config stashpad.git.Config
local M = {}

---@type stashpad.git.Config
M.default = {
    -- Fallback for branch if it cannot be determined
    branch = function()
        return 'default'
    end,
}

---called from state on setup
---@param config stashpad.git.Config
function M.setup(config)
    M.config = config
end

---@return stashpad.schema.Field
function M.schema()
    local Schema = require('stashpad.debug.schema')
    return Schema.record({
        branch = Schema.type('function'),
    })
end

---@return string?
function M.remote()
    local origin = M.run({ 'git', 'remote', 'get-url', 'origin' })
    return origin ~= nil and M.parse_name(origin) or nil
end

---@param origin string
---@return string
function M.parse_name(origin)
    local details = vim.split(origin, '/', { plain = true })
    local name = details[#details]:gsub('%.git$', '')
    return name
end

---@return string
function M.branch()
    local branch = M.run({ 'git', 'branch', '--show-current' })
    return branch or M.config.branch()
end

---@private
---@param command string[]
---@return string?
function M.run(command)
    local result = vim.system(command, { text = true }):wait()
    -- Fails when not in a git repository
    if result.code ~= 0 or result.stdout == nil then
        return nil
    else
        return vim.fn.trim(result.stdout)
    end
end

return M
