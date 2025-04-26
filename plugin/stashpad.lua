local initialized = false
if initialized then
    return
end
initialized = true

require('stashpad').setup()
require('stashpad.command').init()
