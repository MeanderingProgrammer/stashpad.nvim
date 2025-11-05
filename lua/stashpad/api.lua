local file = require('stashpad.lib.file')
local git = require('stashpad.lib.git')
local win = require('stashpad.lib.win')

---@class stashpad.Api
local M = {}

function M.branch()
    local branch = git.branch()
    win.toggle({
        info = file.get(vim.fs.joinpath('branch', branch)),
        title = ('Branch : %s'):format(branch),
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
    local root = vim.fn.fnamemodify(path, ':r')
    win.toggle({
        info = file.get(vim.fs.joinpath('file', root)),
        title = ('File : %s'):format(vim.fs.basename(path)),
    })
end

---@param project? string
function M.global(project)
    win.toggle({
        info = file.get('global', project),
        title = 'Global',
    })
end

---@param project? string
function M.todo(project)
    win.toggle({
        info = file.get('todo', project),
        title = 'Todo',
    })
end

---@return string
function M.project()
    return file.project()
end

function M.validate()
    local messages = require('stashpad.state').validate()
    if #messages == 0 then
        vim.notify('valid configuration', vim.log.levels.INFO)
    else
        for _, message in ipairs(messages) do
            vim.notify(message, vim.log.levels.ERROR)
        end
    end
end

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
            local ok, err = pcall(file.delete)
            if ok then
                vim.notify('success', levels.INFO)
            else
                vim.notify(('fail: %s'):format(err), levels.ERROR)
            end
        end
    end)
end

return M
