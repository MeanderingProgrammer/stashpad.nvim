---@param name string
---@return string
local function get_path(name)
    local data_path = vim.fn.stdpath('data')
    local plugin_path = vim.fs.find(name, { path = data_path })
    assert(#plugin_path == 1)
    return plugin_path[1]
end

-- Source this plugin
vim.opt.rtp:prepend('.')
vim.cmd.runtime('plugin/stashpad.lua')

-- Plenary for testing
vim.opt.rtp:prepend(get_path('plenary.nvim'))
vim.cmd.runtime('plugin/plenary.vim')
