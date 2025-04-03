---@class (exact) stashpad.config.Win
---@field width number
---@field height number
---@field border string|string[]

---@class stashpad.win.State
---@field buf integer
---@field win integer
---@field file string

---@class stashpad.win.Opts
---@field file string
---@field title string

---@class stashpad.Win
---@field private config stashpad.config.Win
---@field private state? stashpad.win.State
local M = {}

---Should only be called from init.lua setup
---@param config stashpad.config.Win
function M.setup(config)
    M.config = config
    M.state = nil
end

---@param opts stashpad.win.Opts
function M.toggle(opts)
    if M.state == nil then
        M.open(opts)
    elseif M.state.file == opts.file then
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

    local buf = vim.fn.bufadd(opts.file)
    vim.keymap.set('n', 'q', M.close, { buffer = buf, noremap = true, silent = true })
    vim.keymap.set('n', '<esc>', M.close, { buffer = buf, noremap = true, silent = true })

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
        title = string.format(' %s ', opts.title),
        title_pos = 'center',
    })
    vim.api.nvim_set_option_value('winfixbuf', true, { win = win })

    vim.api.nvim_create_autocmd('BufLeave', {
        buffer = buf,
        callback = function()
            M.close()
        end,
    })

    M.state = { buf = buf, win = win, file = opts.file }
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
