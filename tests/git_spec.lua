---@module 'luassert'

local git = require('stashpad.git')

describe('git', function()
    it('parse', function()
        assert.are.same('repo', git.parse_name('git@forge.com:user/repo.git'))
        assert.are.same('repo', git.parse_name('https://forge.com/user/repo'))
        assert.are.same('repo', git.parse_name('https://forge.com/user/repo.git'))
    end)
end)
