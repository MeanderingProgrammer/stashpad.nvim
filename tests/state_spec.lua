---@module 'luassert'

local Eq = assert.are.same

---@param opts stashpad.UserConfig
---@return string[]
local function validate(opts)
    require('stashpad').setup(opts)
    return require('stashpad.state').validate()
end

describe('state', function()
    it('valid', function()
        Eq({}, validate({}))
    end)

    it('extra', function()
        Eq(
            {
                'additional - expected: nil, got: boolean',
                'file.additional - expected: nil, got: boolean',
            },
            validate({
                additional = true,
                file = { additional = true },
            })
        )
    end)

    it('type', function()
        Eq(
            {
                'file - expected: table, got: string',
                'git.branch - expected: function, got: string',
                'project.markers - expected: string[], got: string',
                'project.order - expected: ("remote"|"root"|"lsp"|function)[], got: string',
                'win.border - expected: (string|string[]), got: false',
            },
            ---@diagnostic disable: assign-type-mismatch
            validate({
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
            })
        )

        Eq(
            {
                'project.order.1 - expected: ("remote"|"root"|"lsp"|function), got: "invalid"',
            },
            ---@diagnostic disable: assign-type-mismatch
            validate({
                project = {
                    order = { 'invalid' },
                },
            })
        )
    end)
end)
