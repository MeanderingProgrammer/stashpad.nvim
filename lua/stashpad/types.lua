---@meta

---@class (exact) stashpad.Config
---@field root string
---@field fallback string
---@field buffer stashpad.Buffer
---@field window stashpad.Window

---@class (exact) stashpad.Buffer
---@field filetype fun(): string

---@class (exact) stashpad.Window
---@field width number
---@field height number
---@field border string|string[]
