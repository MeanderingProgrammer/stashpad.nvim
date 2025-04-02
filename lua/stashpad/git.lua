---@class (exact) stashpad.config.Git
---@field fallback string

---@class stashpad.Git
---@field private config stashpad.config.Git
local M = {}

---Should only be called from init.lua setup
---@param config stashpad.config.Git
function M.setup(config)
    M.config = config
end

---@return string
function M.repo()
    local origin = M.run({ 'git', 'remote', 'get-url', 'origin' })
    return origin ~= nil and M.parse_name(origin) or M.config.fallback
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
    return M.run({ 'git', 'branch', '--show-current' }) or M.config.fallback
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
