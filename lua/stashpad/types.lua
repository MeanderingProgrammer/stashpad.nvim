---@meta

---@class (exact) stashpad.UserConfig
---@field file? stashpad.file.UserConfig
---@field git? stashpad.git.UserConfig
---@field project? stashpad.project.UserConfig
---@field win? stashpad.win.UserConfig

---@class (exact) stashpad.file.UserConfig
---@field root? string
---@field extension? fun(): string

---@class (exact) stashpad.git.UserConfig
---@field branch? fun(): string

---@class (exact) stashpad.project.UserConfig
---@field order? stashpad.project.Option[]
---@field markers? string[]
---@field fallback? fun(): string

---@class (exact) stashpad.win.UserConfig
---@field width? number
---@field height? number
---@field border? string|string[]
