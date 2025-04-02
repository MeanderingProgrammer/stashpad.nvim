---@class stashpad.Git
local M = {}

---@return string?
function M.repo()
    local origin = M.run({ 'git', 'remote', 'get-url', 'origin' })
    return origin ~= nil and M.parse_name(origin) or nil
end

---@param origin string
---@return string
function M.parse_name(origin)
    -- git@forge.com:user/repo.git     -> repo
    -- https://forge.com/user/repo     -> repo
    -- https://forge.com/user/repo.git -> repo
    local details = vim.split(origin, '/', { plain = true })
    local name = details[#details]:gsub('%.git$', '')
    return name
end

---@return string?
function M.branch()
    return M.run({ 'git', 'branch', '--show-current' })
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
