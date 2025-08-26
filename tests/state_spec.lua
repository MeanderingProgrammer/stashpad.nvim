---@module 'luassert'

local Eq = assert.are.same

---@param config stashpad.UserConfig
---@return string[]
local function validate(config)
    require('stashpad').setup(config)
    return require('stashpad.state').validate()
end

describe('state', function()
    it('default', function()
        Eq({}, validate({}))
    end)

    it('extra', function()
        local config = {
            additional = true,
            file = { additional = true },
        }
        local expected = {
            'additional - expected: nil, got: boolean',
            'file.additional - expected: nil, got: boolean',
        }
        Eq(expected, validate(config))
    end)

    it('type', function()
        local config = {
            file = 'invalid',
            git = {
                branch = 'invalid',
            },
            project = {
                markers = 'invalid',
                order = 'invalid',
            },
            win = {
                border = false,
            },
        }
        local expected = {
            'file - expected: table, got: string',
            'git.branch - expected: function, got: string',
            'project.markers - expected: string[], got: string',
            'project.order - expected: "lsp"|"remote"|"root"|function[], got: string',
            'win.border - expected: string|string[], got: false',
        }
        Eq(expected, validate(config))
    end)

    it('value', function()
        local config = {
            project = {
                order = { 'invalid' },
            },
        }
        local expected = {
            'project.order.1 - expected: "lsp"|"remote"|"root"|function, got: "invalid"',
        }
        Eq(expected, validate(config))
    end)
end)
