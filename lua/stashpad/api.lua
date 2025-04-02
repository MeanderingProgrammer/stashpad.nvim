local git = require('stashpad.git')
local state = require('stashpad.state')

---@class stashpad.Api
local M = {}

function M.open()
    local repo = git.repo() or 'default'
    local branch = git.branch() or 'default'
    local directory = vim.fs.joinpath(state.config.root, repo)
    local file = vim.fs.joinpath(directory, branch)

    vim.fn.mkdir(directory, 'p')
    if vim.uv.fs_stat(file) == nil then
        assert(io.open(file, 'w')):close()
    end

    vim.print({
        repo = repo,
        branch = branch,
        directory = directory,
        file = file,
    })
    -- vim.fn.bufadd()
end

return M
