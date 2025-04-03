---@module 'luassert'

local git = require('stashpad.git')

local eq = assert.are.same

describe('git', function()
    it('parse', function()
        eq('repo', git.parse_name('git@forge.com:user/repo.git'))
        eq('repo', git.parse_name('https://forge.com/user/repo'))
        eq('repo', git.parse_name('https://forge.com/user/repo.git'))
    end)
end)
