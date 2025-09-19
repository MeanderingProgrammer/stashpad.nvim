# stashpad.nvim

Plugin for storing scratch notes based on git info

# Install

## lazy.nvim

```lua
{
    'MeanderingProgrammer/stashpad.nvim',
    ---@module 'stashpad'
    ---@type stashpad.UserConfig
    opts = {},
}
```

## packer.nvim

```lua
use({
    'MeanderingProgrammer/stashpad.nvim',
    config = function()
        require('stashpad').setup({})
    end,
})
```

# Commands

| Command              | Lua Function                                   | Description                                   |
| -------------------- | ---------------------------------------------- | --------------------------------------------- |
| `:Stashpad branch`   | `require('stashpad').branch()`                 | current project git branch notes              |
| `:Stashpad file`     | `require('stashpad').file()`                   | current project file notes                    |
| `:Stashpad global`   | `require('stashpad').global(project?: string)` | project (or current) global notes             |
| `:Stashpad todo`     | `require('stashpad').todo(project?: string)`   | project (or current) todo notes               |
| `:Stashpad project`  | `require('stashpad').project()`                | returns value of current project              |
| `:Stashpad validate` | `require('stashpad').validate()`               | validates configuration and prints any errors |
| `:Stashpad delete`   | `require('stashpad').delete()`                 | delete all notes across all projects          |

# Setup

## Default Configuration

```lua
require('stashpad').setup({
    file = {
        -- Typically resolves to ~/.local/share/nvim/stashpad
        root = vim.fs.joinpath(vim.fn.stdpath('data'), 'stashpad'),
        -- Extension to use for files
        extension = function()
            return 'md'
        end,
    },
    git = {
        -- Fallback for branch if it cannot be determined
        branch = function()
            return 'default'
        end,
    },
    project = {
        order = { 'remote', 'root', 'lsp' },
        markers = { '.git' },
        fallback = function()
            return vim.fs.basename(assert(vim.uv.cwd()))
        end,
    },
    win = {
        width = 0.75,
        height = 0.75,
        border = vim.o.winborder,
    },
})
```

# Similar Projects

- [folke/snacks.nvim](https://github.com/folke/snacks.nvim)
- [LintaoAmons/scratch.nvim](https://github.com/LintaoAmons/scratch.nvim)
- [yujinyuz/gitpad.nvim](https://github.com/yujinyuz/gitpad.nvim)
