---@enum stashpad.schema.Kind
local Kind = {
    data = 'data',
    type = 'type',
}

---@class stashpad.schema.Context
---@field path string[]
---@field data any
local Context = {}
Context.__index = Context

---@param path string[]
---@param data any
---@return stashpad.schema.Context
function Context.new(path, data)
    local self = setmetatable({}, Context)
    self.path = path
    self.data = data
    return self
end

---@param key any
---@return stashpad.schema.Context
function Context:get(key)
    local path = vim.list_extend({}, self.path)
    path = vim.list_extend(path, { tostring(key) })
    assert(type(self.data) == 'table')
    return Context.new(path, self.data[key])
end

---@param kind stashpad.schema.Kind
---@return string
function Context:actual(kind)
    if kind == Kind.data then
        return vim.inspect(self.data)
    elseif kind == Kind.type then
        return type(self.data)
    else
        error('invalid kind: ' .. kind)
    end
end

---@class stashpad.schema.Error
---@field path string[]
---@field expected string
---@field actual string

---@class stashpad.schema.Errors
---@field private errors stashpad.schema.Error[]
local Errors = {}
Errors.__index = Errors

---@return stashpad.schema.Errors
function Errors.new()
    local self = setmetatable({}, Errors)
    self.errors = {}
    return self
end

---@return boolean
function Errors:empty()
    return #self.errors == 0
end

---@param ctx stashpad.schema.Context
---@param expected string
---@param kind stashpad.schema.Kind
function Errors:add(ctx, expected, kind)
    self.errors[#self.errors + 1] = {
        path = ctx.path,
        expected = expected,
        actual = ctx:actual(kind),
    }
end

---@param other stashpad.schema.Errors
function Errors:extend(other)
    for _, err in ipairs(other.errors) do
        self.errors[#self.errors + 1] = err
    end
end

---@return string[]
function Errors:get()
    local messages = {} ---@type string[]
    for _, err in ipairs(self.errors) do
        local path = table.concat(err.path, '.')
        local body = ('expected: %s, got: %s'):format(err.expected, err.actual)
        local message = ('%s - %s'):format(path, body)
        messages[#messages + 1] = message
    end
    table.sort(messages)
    return messages
end

---@class stashpad.schema.Field
---@field type fun(self: stashpad.schema.Field): string
---@field check fun(self: stashpad.schema.Field, ctx: stashpad.schema.Context): stashpad.schema.Errors

---@class stashpad.schema.Record: stashpad.schema.Field
---@field private fields table<string, stashpad.schema.Field>
local Record = {}
Record.__index = Record

---@param fields table<string, stashpad.schema.Field>
---@return stashpad.schema.Record
function Record.new(fields)
    local self = setmetatable({}, Record)
    self.fields = fields
    return self
end

---@return string
function Record:type()
    return 'table'
end

---@param ctx stashpad.schema.Context
---@return stashpad.schema.Errors
function Record:check(ctx)
    local data = ctx.data
    local errors = Errors.new()
    if type(data) ~= 'table' then
        errors:add(ctx, self:type(), Kind.type)
    else
        ---@cast data table<any, any>
        for key, field in pairs(self.fields) do
            errors:extend(field:check(ctx:get(key)))
        end
        for key in pairs(data) do
            if self.fields[key] == nil then
                errors:add(ctx:get(key), 'nil', Kind.type)
            end
        end
    end
    return errors
end

---@class stashpad.schema.List: stashpad.schema.Field
---@field private field stashpad.schema.Field
local List = {}
List.__index = List

---@param field stashpad.schema.Field
---@return stashpad.schema.List
function List.new(field)
    local self = setmetatable({}, List)
    self.field = field
    return self
end

---@return string
function List:type()
    return ('(%s)[]'):format(self.field:type())
end

---@param ctx stashpad.schema.Context
---@return stashpad.schema.Errors
function List:check(ctx)
    local errors = Errors.new()
    if not vim.islist(ctx.data) then
        errors:add(ctx, self:type(), Kind.type)
    else
        for key in ipairs(ctx.data) do
            errors:extend(self.field:check(ctx:get(key)))
        end
    end
    return errors
end

---@class stashpad.schema.Union: stashpad.schema.Field
---@field private fields stashpad.schema.Field[]
local Union = {}
Union.__index = Union

---@param fields stashpad.schema.Field[]
---@return stashpad.schema.Union
function Union.new(fields)
    local self = setmetatable({}, Union)
    self.fields = fields
    return self
end

---@return string
function Union:type()
    local values = {} ---@type string[]
    for _, field in ipairs(self.fields) do
        values[#values + 1] = field:type()
    end
    return table.concat(values, '|')
end

---@param ctx stashpad.schema.Context
---@return stashpad.schema.Errors
function Union:check(ctx)
    local valid = false
    for _, field in ipairs(self.fields) do
        valid = valid or field:check(ctx):empty()
    end
    local errors = Errors.new()
    if not valid then
        errors:add(ctx, self:type(), Kind.data)
    end
    return errors
end

---@class stashpad.schema.Enum: stashpad.schema.Field
---@field private values string[]
local Enum = {}
Enum.__index = Enum

---@param values table<string, string>
---@return stashpad.schema.Enum
function Enum.new(values)
    local self = setmetatable({}, Enum)
    self.values = vim.tbl_values(values)
    return self
end

---@return string
function Enum:type()
    local values = {} ---@type string[]
    for _, value in ipairs(self.values) do
        values[#values + 1] = vim.inspect(value)
    end
    table.sort(values)
    return table.concat(values, '|')
end

---@param ctx stashpad.schema.Context
---@return stashpad.schema.Errors
function Enum:check(ctx)
    local errors = Errors.new()
    if not vim.tbl_contains(self.values, ctx.data) then
        errors:add(ctx, self:type(), Kind.data)
    end
    return errors
end

---@class stashpad.schema.Type: stashpad.schema.Field
---@field private value type
local Type = {}
Type.__index = Type

---@param value type
---@return stashpad.schema.Type
function Type.new(value)
    local self = setmetatable({}, Type)
    self.value = value
    return self
end

---@return string
function Type:type()
    return self.value
end

---@param ctx stashpad.schema.Context
---@return stashpad.schema.Errors
function Type:check(ctx)
    local errors = Errors.new()
    if type(ctx.data) ~= self.value then
        errors:add(ctx, self:type(), Kind.type)
    end
    return errors
end

---@param schema stashpad.schema.Field
---@param data any
---@return string[]
local function validate(schema, data)
    return schema:check(Context.new({}, data)):get()
end

---@class stashpad.Schema
return {
    record = Record.new,
    list = List.new,
    union = Union.new,
    enum = Enum.new,
    type = Type.new,
    validate = validate,
}
