---@meta

---@class (exact) stashpad.user.Config
---@field file? stashpad.config.user.File
---@field git? stashpad.config.user.Git
---@field project? stashpad.config.user.Project
---@field win? stashpad.config.user.Win

---@class (exact) stashpad.config.user.File
---@field root? string
---@field extension? fun(): string

---@class (exact) stashpad.config.user.Git
---@field branch? fun(): string

---@class (exact) stashpad.config.user.Project
---@field order? stashpad.project.Option[]
---@field markers? string[]
---@field fallback? fun(): string

---@class (exact) stashpad.config.user.Win
---@field width? number
---@field height? number
---@field border? string|string[]
