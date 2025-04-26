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
        Eq(0, #validate({}))
    end)

    it('extra', function()
        Eq(
            {
                'stashpad.additional - expected: nil, got: boolean',
                'stashpad.file.additional - expected: nil, got: boolean',
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
                'stashpad.file - expected: table, got: string',
                'stashpad.git.branch - expected: function, got: string',
                'stashpad.project.markers - expected: string[], got: string',
                'stashpad.project.order - expected: ("remote"|"root"|"lsp"|function)[], got: string',
                'stashpad.win.border - expected: (string|string[]), got: false',
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
                'stashpad.project.order.1 - expected: ("remote"|"root"|"lsp"|function), got: "invalid"',
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
