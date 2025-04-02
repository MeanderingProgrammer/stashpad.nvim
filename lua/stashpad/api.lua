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

    local buf = vim.fn.bufadd(file)

    local rows = vim.o.lines
    local cols = vim.o.columns

    local height = math.floor(rows * 0.8)
    local width = math.floor(cols * 0.8)

    local win = vim.api.nvim_open_win(buf, true, {
        border = 'rounded',
        relative = 'editor',
        height = height,
        width = width,
        row = math.floor((rows - height) / 2),
        col = math.floor((cols - width) / 2),
    })

    vim.print({
        buf = buf,
        win = win,
        repo = repo,
        branch = branch,
        directory = directory,
        file = file,
    })
end

return M
