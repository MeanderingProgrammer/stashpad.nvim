---@module 'luassert'

local git = require('stashpad.lib.git')

describe('git', function()
    it('parse', function()
        assert.same('repo', git.parse_name('git@forge.com:user/repo.git'))
        assert.same('repo', git.parse_name('https://forge.com/user/repo'))
        assert.same('repo', git.parse_name('https://forge.com/user/repo.git'))
    end)
end)
