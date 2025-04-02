---@meta

---@class (exact) stashpad.user.Config
---@field file? stashpad.config.user.File
---@field git? stashpad.config.user.Git
---@field win? stashpad.config.user.Win

---@class (exact) stashpad.config.user.File
---@field root? string
---@field extension? fun(): string

---@class (exact) stashpad.config.user.Git
---@field fallback? string

---@class (exact) stashpad.config.user.Win
---@field width? number
---@field height? number
---@field border? string|string[]
