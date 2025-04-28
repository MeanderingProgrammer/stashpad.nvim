# stashpad.nvim

Plugin for storing scratch notes based on git info

# Default Configuration

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
            return 'default'
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
