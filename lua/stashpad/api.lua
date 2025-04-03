local File = require('stashpad.file')
local Git = require('stashpad.git')
local Win = require('stashpad.win')

---@class stashpad.Api
local M = {}

function M.delete()
    local ack = 'confirm and delete'
    local prompt = {
        'This will permanently delete all your notes',
        'Type the following phrase exactly to proceed',
        ack,
        '',
    }
    vim.ui.input({ prompt = table.concat(prompt, '\n') }, function(input)
        local levels = vim.log.levels
        if input ~= ack then
            vim.notify('skip', levels.INFO)
        else
            local ok, err = pcall(File.delete)
            if ok then
                vim.notify('success', levels.INFO)
            else
                vim.notify(string.format('fail: %s', err), levels.ERROR)
            end
        end
    end)
end

function M.branch()
    local branch = Git.branch()
    Win.toggle({
        info = File.get(vim.fs.joinpath('branch', branch)),
        title = string.format('Branch : %s', branch),
    })
end

function M.file()
    local name = vim.api.nvim_buf_get_name(0)
    if vim.fn.filereadable(name) == 0 then
        return
    end
    local cwd = assert(vim.uv.cwd())
    local path = vim.fs.relpath(cwd, name)
    if path == nil then
        return
    end
    local file = vim.fn.fnamemodify(path, ':r')
    Win.toggle({
        info = File.get(vim.fs.joinpath('file', file)),
        title = string.format('File : %s', vim.fs.basename(path)),
    })
end

function M.global()
    Win.toggle({
        info = File.get('global'),
        title = 'Global',
    })
end

function M.todo()
    Win.toggle({
        info = File.get('todo'),
        title = 'Todo',
    })
end

return M
