---@module 'luassert'

local git = require('stashpad.lib.git')

local Eq = assert.are.same

describe('git', function()
    it('parse', function()
        Eq('repo', git.parse_name('git@forge.com:user/repo.git'))
        Eq('repo', git.parse_name('https://forge.com/user/repo'))
        Eq('repo', git.parse_name('https://forge.com/user/repo.git'))
    end)
end)
