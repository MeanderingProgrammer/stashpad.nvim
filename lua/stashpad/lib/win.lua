---@class (exact) stashpad.win.Config
---@field width number
---@field height number
---@field border string|string[]

---@class stashpad.win.State
---@field buf integer
---@field win integer
---@field file string

---@class stashpad.win.Opts
---@field info stashpad.file.Info
---@field title string

---@class stashpad.Win
---@field private config stashpad.win.Config
---@field private state? stashpad.win.State
local M = {}

---@type stashpad.win.Config
M.default = {
    width = 0.75,
    height = 0.75,
    border = vim.o.winborder,
}

---called from state on setup
---@param config stashpad.win.Config
function M.setup(config)
    M.config = config
    M.state = nil
end

---@return stashpad.schema.Field
function M.schema()
    local Schema = require('stashpad.debug.schema')
    return Schema.record({
        width = Schema.type('number'),
        height = Schema.type('number'),
        border = Schema.union({
            Schema.type('string'),
            Schema.list(Schema.type('string')),
        }),
    })
end

---@param opts stashpad.win.Opts
function M.toggle(opts)
    if M.state == nil then
        M.open(opts)
    elseif M.state.file == opts.info.file then
        M.close()
    else
        M.close()
        M.open(opts)
    end
end

---@private
---@param opts stashpad.win.Opts
function M.open(opts)
    assert(M.state == nil, 'stashpad already open')

    local info = opts.info

    local buf = vim.fn.bufadd(info.file)
    M.keymap(buf, 'q', M.close)
    M.keymap(buf, '<esc>', M.close)

    local cols = vim.o.columns
    local rows = vim.o.lines
    local width = math.floor((cols * M.config.width) + 0.5)
    local height = math.floor((rows * M.config.height) + 0.5)
    local win = vim.api.nvim_open_win(buf, true, {
        col = math.floor((cols - width) / 2),
        row = math.floor((rows - height) / 2),
        width = width,
        height = height,
        relative = 'editor',
        border = M.config.border,
        title = string.format(' Project : %s | %s ', info.project, opts.title),
        title_pos = 'center',
    })
    vim.api.nvim_set_option_value('winfixbuf', true, { win = win })

    vim.api.nvim_create_autocmd('BufLeave', {
        buffer = buf,
        callback = function()
            M.close()
        end,
    })

    M.state = { buf = buf, win = win, file = info.file }
end

---@private
---@param buf integer
---@param lhs string
---@param rhs function
function M.keymap(buf, lhs, rhs)
    local opts = { buffer = buf, noremap = true, silent = true }
    vim.keymap.set('n', lhs, rhs, opts)
end

---@private
function M.close()
    if M.state == nil then
        return
    end
    vim.api.nvim_buf_call(M.state.buf, function()
        vim.cmd.write({ mods = { silent = true } })
    end)
    vim.api.nvim_win_close(M.state.win, true)
    M.state = nil
end

return M
