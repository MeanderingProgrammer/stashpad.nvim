---@class stashpad.schema.Error
---@field path string
---@field expected string
---@field actual string

---@class stashpad.schema.Field
---@field expected fun(self: stashpad.schema.Field): string
---@field check fun(self: stashpad.schema.Field, path: string, data: any): stashpad.schema.Error[]

---@class stashpad.schema.Record: stashpad.schema.Field
---@field private fields table<string, stashpad.schema.Field>
local Record = {}
Record.__index = Record

---@param fields table<string, stashpad.schema.Field>
---@return stashpad.schema.Field
function Record.new(fields)
    local self = setmetatable({}, Record)
    self.fields = fields
    return self
end

---@return string
function Record:expected()
    local fields = {} ---@type string[]
    for key, field in pairs(self.fields) do
        fields[#fields + 1] = ('%s: %s'):format(key, field:expected())
    end
    local body = table.concat(fields, ', ')
    return ('{ %s }'):format(body)
end

---@param path string
---@param data any
---@return stashpad.schema.Error[]
function Record:check(path, data)
    local errors = {} ---@type stashpad.schema.Error[]

    if type(data) ~= 'table' then
        errors[#errors + 1] = {
            path = path,
            expected = self:expected(),
            actual = type(data),
        }
        return errors
    end

    for key, field in pairs(self.fields) do
        local errs = field:check(key, data[key])
        for _, err in ipairs(errs) do
            err.path = ('%s.%s'):format(path, err.path)
            errors[#errors + 1] = err
        end
    end

    for key, value in pairs(data) do
        if self.fields[key] == nil then
            errors[#errors + 1] = {
                path = ('%s.%s'):format(path, key),
                expected = 'NOTHING',
                actual = vim.inspect(value),
            }
        end
    end

    return errors
end

---@class stashpad.schema.List: stashpad.schema.Field
---@field private field stashpad.schema.Field
local List = {}
List.__index = List

---@param field stashpad.schema.Field
---@return stashpad.schema.Field
function List.new(field)
    local self = setmetatable({}, List)
    self.field = field
    return self
end

---@return string
function List:expected()
    return ('%s[]'):format(self.field:expected())
end

---@param path string
---@param data any
---@return stashpad.schema.Error[]
function List:check(path, data)
    local errors = {} ---@type stashpad.schema.Error[]

    if not vim.islist(data) then
        errors[#errors + 1] = {
            path = path,
            expected = self:expected(),
            actual = type(data),
        }
        return errors
    end

    for i, value in ipairs(data) do
        local errs = self.field:check(tostring(i), value)
        for _, err in ipairs(errs) do
            err.path = ('%s.%s'):format(path, err.path)
            errors[#errors + 1] = err
        end
    end

    return errors
end

---@class stashpad.schema.Union: stashpad.schema.Field
---@field private fields stashpad.schema.Field[]
local Union = {}
Union.__index = Union

---@param fields stashpad.schema.Field[]
---@return stashpad.schema.Field
function Union.new(fields)
    local self = setmetatable({}, Union)
    self.fields = fields
    return self
end

---@return string
function Union:expected()
    local fields = {} ---@type string[]
    for _, field in ipairs(self.fields) do
        fields[#fields + 1] = field:expected()
    end
    local body = table.concat(fields, '|')
    return ('(%s)'):format(body)
end

---@param path string
---@param data any
---@return stashpad.schema.Error[]
function Union:check(path, data)
    local valid = false
    for _, field in ipairs(self.fields) do
        local errors = field:check(path, data)
        valid = valid or (#errors == 0)
    end
    local errors = {} ---@type stashpad.schema.Error[]
    if not valid then
        errors[#errors + 1] = {
            path = path,
            expected = self:expected(),
            actual = vim.inspect(data),
        }
    end
    return errors
end

---@class stashpad.schema.Type: stashpad.schema.Field
---@field private type type
local Type = {}
Type.__index = Type

---@param type type
---@return stashpad.schema.Field
function Type.new(type)
    local self = setmetatable({}, Type)
    self.type = type
    return self
end

---@return string
function Type:expected()
    return self.type
end

---@param path string
---@param data any
---@return stashpad.schema.Error[]
function Type:check(path, data)
    local errors = {} ---@type stashpad.schema.Error[]
    if type(data) ~= self.type then
        errors[#errors + 1] = {
            path = path,
            expected = self:expected(),
            actual = type(data),
        }
    end
    return errors
end

---@class stashpad.schema.Literal: stashpad.schema.Field
---@field private value any
local Literal = {}
Literal.__index = Literal

---@param value any
---@return stashpad.schema.Field
function Literal.new(value)
    local self = setmetatable({}, Literal)
    self.value = value
    return self
end

---@return string
function Literal:expected()
    return vim.inspect(self.value)
end

---@param path string
---@param data any
---@return stashpad.schema.Error[]
function Literal:check(path, data)
    local errors = {} ---@type stashpad.schema.Error[]
    if data ~= self.value then
        errors[#errors + 1] = {
            path = path,
            expected = self:expected(),
            actual = vim.inspect(data),
        }
    end
    return errors
end

---@class stashpad.Schema
return {
    record = Record.new,
    list = List.new,
    union = Union.new,
    type = Type.new,
    literal = Literal.new,
}
