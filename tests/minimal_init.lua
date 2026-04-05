---@param name string
---@return string
local function get_path(name)
    local paths = vim.fs.find(name, { path = vim.fn.stdpath('data') })
    assert(#paths == 1, 'plugin must have one path')
    return paths[1]
end

-- source this plugin
vim.opt.rtp:prepend('.')
vim.cmd.runtime('plugin/stashpad.lua')

-- used for unit testing
vim.opt.rtp:prepend(get_path('plenary.nvim'))
vim.cmd.runtime('plugin/plenary.vim')
