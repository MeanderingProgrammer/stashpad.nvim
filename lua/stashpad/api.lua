local git = require('stashpad.git')
local state = require('stashpad.state')

---@class stashpad.Api
local M = {}

function M.open()
    local config = state.config
    local buffer = config.buffer
    local window = config.window

    local repo = git.repo() or config.fallback
    local branch = git.branch() or config.fallback
    local directory = vim.fs.joinpath(config.root, repo)
    local file = vim.fs.joinpath(directory, branch)

    vim.fn.mkdir(directory, 'p')
    if vim.uv.fs_stat(file) == nil then
        assert(io.open(file, 'w')):close()
    end

    local buf = vim.fn.bufadd(file)
    vim.api.nvim_set_option_value('filetype', buffer.filetype(), { buf = buf })

    local cols = vim.o.columns
    local rows = vim.o.lines
    local width = math.floor((cols * window.width) + 0.5)
    local height = math.floor((rows * window.height) + 0.5)
    local win = vim.api.nvim_open_win(buf, true, {
        col = math.floor((cols - width) / 2),
        row = math.floor((rows - height) / 2),
        width = width,
        height = height,
        relative = 'editor',
        border = window.border,
        title = string.format(' %s : %s ', repo, branch),
        title_pos = 'center',
    })
    vim.api.nvim_set_option_value('winfixbuf', true, { win = win })
end

return M
