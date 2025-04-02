local state = require('stashpad.state')

---@class stashpad.Api
local M = {}

function M.open()
    vim.print('TODO')
    vim.print(state.config)
end

return M
