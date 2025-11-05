---@module 'luassert'

---@param config stashpad.UserConfig
---@param expected string[]
local function validate(config, expected)
    require('stashpad').setup(config)
    local actual = require('stashpad.state').validate()
    assert.same(expected, actual)
end

describe('state', function()
    it('default', function()
        validate({}, {})
    end)

    it('extra', function()
        local config = {
            additional = true,
            file = { additional = true },
        }
        validate(config, {
            'additional - expected: nil, got: boolean',
            'file.additional - expected: nil, got: boolean',
        })
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
        validate(config, {
            'file - expected: table, got: string',
            'git.branch - expected: function, got: string',
            'project.markers - expected: string[], got: string',
            'project.order - expected: "lsp"|"remote"|"root"|function[], got: string',
            'win.border - expected: string|string[], got: false',
        })
    end)

    it('value', function()
        local config = {
            project = {
                order = { 'invalid' },
            },
        }
        validate(config, {
            'project.order.1 - expected: "lsp"|"remote"|"root"|function, got: "invalid"',
        })
    end)
end)
