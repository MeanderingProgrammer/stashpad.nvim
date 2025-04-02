if vim.g.loaded_stashpad then
    return
end
vim.g.loaded_stashpad = true

require('stashpad').setup()
require('stashpad.command').setup()
