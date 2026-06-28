# Autocommands Documentation

This document provides detailed information about all autocommands configured in `lua/config/autocmds.lua`.

## Table of Contents

- [Overview](#overview)
- [File Type Specific Settings](#file-type-specific-settings)
- [File Management](#file-management)
- [LSP Integration](#lsp-integration)
- [Terminal Settings](#terminal-settings)
- [Plugin Integration](#plugin-integration)
- [Creating Custom Autocommands](#creating-custom-autocommands)
- [Performance Considerations](#performance-considerations)

## Overview

All autocommands in this configuration follow these principles:

1. **Organized by Purpose**: Grouped into logical categories
2. **Augroups**: Every autocommand belongs to an augroup with `clear = true`
3. **Type Safety**: Uses Lua API (`vim.api.nvim_create_autocmd`) over vim commands
4. **Descriptive**: Each autocommand includes a `desc` field explaining its purpose
5. **Targeted**: Only triggers on specific events/patterns to minimize overhead

## File Type Specific Settings

### Text Files Auto-wrap

**Purpose**: Improve readability for text-based files by enabling line wrapping

**Configuration**:
```lua
local text_files_group = vim.api.nvim_create_augroup("TextFilesSettings", { clear = true })

vim.api.nvim_create_autocmd({ "FileType", "BufEnter" }, {
    group = text_files_group,
    pattern = { "*.md", "*.txt", "*.text", "*.rst", "*.org", "*.adoc" },
    desc = "Enable line wrapping for text files",
    callback = function()
        local ft = vim.bo.filetype
        local text_types = {
            ["markdown"] = true,
            ["text"] = true,
            ["rst"] = true,
            ["org"] = true,
            ["asciidoc"] = true,
        }
        if text_types[ft] then
            vim.opt_local.wrap = true
            vim.opt_local.linebreak = true
        end
    end,
})
```

**Details**:
- **Events**: `FileType`, `BufEnter`
- **Patterns**: Various text file extensions
- **Settings Applied**:
  - `wrap = true`: Enable line wrapping
  - `linebreak = true`: Break at word boundaries (not in the middle of words)
- **Buffer-local**: Settings only apply to the current buffer

**Why Both Events?**
- `FileType`: Triggered when file type is detected
- `BufEnter`: Ensures settings persist when switching between buffers

### Help and Man Pages in Current Window

**Purpose**: Maximize screen space when viewing documentation

**Configuration**:
```lua
local help_window_group = vim.api.nvim_create_augroup("HelpInCurrentWindow", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
    group = help_window_group,
    pattern = { "help", "man" },
    desc = "Open help and man pages in current window only",
    callback = function()
        vim.cmd("wincmd o")
    end,
})
```

**Details**:
- **Event**: `FileType`
- **Patterns**: `help`, `man`
- **Action**: `wincmd o` (close all other windows)
- **Use Case**: When you open `:help` or `:Man`, other splits are automatically closed

### Quickfix in Current Window

**Purpose**: Give quickfix/location lists full screen space

**Configuration**:
```lua
local quickfix_window_group = vim.api.nvim_create_augroup("QuickfixInCurrentWindow", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
    group = quickfix_window_group,
    pattern = "qf",
    desc = "Open quickfix in current window only",
    callback = function()
        vim.cmd("wincmd o")
    end,
})
```

**Details**:
- **Event**: `FileType`
- **Pattern**: `qf` (quickfix)
- **Action**: Maximize the quickfix window
- **Triggered By**: `:copen`, `:lopen`, grep results, etc.

## File Management

### Auto-reload Files

**Purpose**: Always show the latest version of files modified outside Neovim

**Configuration**:
```lua
local auto_reload_group = vim.api.nvim_create_augroup("AutoReload", { clear = true })

vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
    group = auto_reload_group,
    desc = "Auto-reload files when changed outside Neovim",
    callback = function()
        if vim.api.nvim_get_mode().mode ~= 'c' then
            vim.cmd('checktime')
        end
    end,
})
```

**Details**:
- **Events**:
  - `FocusGained`: When Neovim window gains focus
  - `BufEnter`: When entering a buffer
  - `CursorHold`: When cursor is idle (after `updatetime` ms)
- **Safety Check**: Skips reload in command-line mode (`mode ~= 'c'`)
- **Command**: `checktime` - checks if buffers have been modified externally

**Use Cases**:
- Git operations that modify files
- External build tools that regenerate files
- Collaborating on the same codebase
- File watchers/auto-generators

**Note**: Works in conjunction with `vim.opt.autoread = true` (set in `general.lua`)

### Auto-save on Text Change

**Purpose**: Never lose work - save automatically as you type

**Configuration**:
```lua
local autosave_group = vim.api.nvim_create_augroup("AutoSave", { clear = true })

vim.api.nvim_create_autocmd({ "TextChangedI", "TextChanged" }, {
    group = autosave_group,
    pattern = "*",
    desc = "Automatically save modifiable buffers on text change",
    callback = function()
        if vim.bo.modifiable and vim.bo.modified and vim.bo.buftype == "" then
            vim.cmd("silent! update")
        end
    end,
})
```

**Details**:
- **Events**:
  - `TextChangedI`: Text changed in insert mode
  - `TextChanged`: Text changed in normal mode
- **Safety Checks**:
  1. `vim.bo.modifiable`: Buffer can be modified
  2. `vim.bo.modified`: Buffer has unsaved changes
  3. `vim.bo.buftype == ""`: Normal file buffer (excludes special buffers)
- **Command**: `silent! update` - save only if buffer has changed, suppress messages

**What's NOT Saved**:
- Quickfix lists
- Help pages
- Terminal buffers
- Plugin windows (NvimTree, Telescope, etc.)
- Read-only files
- Unnamed buffers

**Performance Impact**: Minimal - only runs when you actually change text, and uses `update` instead of `write` (no-op if unchanged)

## LSP Integration

### LSP Attach Configuration

**Purpose**: Configure LSP features and keybindings when a language server attaches

**Configuration**:
```lua
local lsp_attach_group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true })

vim.api.nvim_create_autocmd("LspAttach", {
    group = lsp_attach_group,
    desc = "Configure LSP keybindings and settings when LSP attaches",
    callback = function(lsp_env)
        local opts = { buffer = lsp_env.buf }

        -- Configure inlay hint highlight
        vim.api.nvim_set_hl(0, 'LspInlayHint', {
            fg = '#565f89',
            bg = '#292e42',
            italic = true,
            bold = false,
            blend = 30,
        })

        -- Hover documentation
        vim.keymap.set('n', 'K', function()
            vim.lsp.buf.hover({ border = 'rounded' })
        end, vim.tbl_extend('force', opts, { desc = 'LSP Hover Documentation' }))

        -- Show diagnostics
        vim.keymap.set('n', 'ge', function()
            vim.diagnostic.open_float({ border = 'rounded' })
        end, vim.tbl_extend('force', opts, { desc = 'Show Diagnostics' }))
    end,
})
```

**Details**:

#### Event: `LspAttach`
- Triggered when an LSP client attaches to a buffer
- Runs once per buffer-client pair
- Provides `lsp_env` with buffer number and client info

#### Inlay Hints Highlighting
Custom colors for LSP inlay hints (type annotations, parameter names, etc.):
- **Foreground**: `#565f89` (muted blue-gray)
- **Background**: `#292e42` (dark blue-gray)
- **Style**: Italic
- **Blend**: 30% (subtle transparency)

#### Buffer-local Keybindings

| Key | Function | Description |
|-----|----------|-------------|
| `K` | `vim.lsp.buf.hover()` | Show hover documentation |
| `ge` | `vim.diagnostic.open_float()` | Show diagnostics at cursor |

**Why Buffer-local?**
- Keybindings only active in LSP-enabled buffers
- Prevents conflicts in non-LSP buffers
- Each buffer can have different LSP servers with consistent keybindings

**Rounded Borders**: All LSP floating windows use rounded borders for better aesthetics

## Terminal Settings

### Terminal Keybindings

**Purpose**: Make terminal mode more user-friendly

**Configuration**:
```lua
local terminal_group = vim.api.nvim_create_augroup("TerminalSettings", { clear = true })

vim.api.nvim_create_autocmd("TermOpen", {
    group = terminal_group,
    pattern = "term://*",
    desc = "Configure terminal keybindings",
    callback = function()
        local opts = { buffer = 0 }
        vim.o.timeoutlen = 300

        -- Exit terminal mode
        vim.keymap.set('t', 'jj', [[<C-\><C-n>]], opts)

        -- Window command prefix
        vim.keymap.set('t', '<C-w>', [[<C-\><C-n><C-w>]], opts)
    end,
})
```

**Details**:

#### Event: `TermOpen`
- Triggered when a terminal buffer is created
- Pattern `term://*` matches all terminal buffers

#### Keybindings

| Key | Mode | Mapping | Description |
|-----|------|---------|-------------|
| `jj` | Terminal | `<C-\><C-n>` | Exit terminal mode to normal mode |
| `<C-w>` | Terminal | `<C-\><C-n><C-w>` | Window navigation prefix |

#### Timeout Configuration
- Sets `timeoutlen = 300` for faster key sequence detection
- Applies globally (not buffer-local) for consistency

**Use Cases**:
1. **Quick Exit**: Type `jj` to leave terminal mode (same as insert mode escape)
2. **Window Navigation**: `<C-w>h/j/k/l` to navigate between windows without leaving terminal
3. **Copy Mode**: Exit terminal mode to yank/copy terminal output

## Plugin Integration

### Oil.nvim File Operations

**Purpose**: Integrate Oil file operations with LSP and project-wide refactoring

**Configuration**:
```lua
local oil_actions_group = vim.api.nvim_create_augroup("OilActions", { clear = true })

vim.api.nvim_create_autocmd("User", {
    group = oil_actions_group,
    pattern = "OilActionsPost",
    desc = "Notify Snacks plugin when Oil renames a file",
    callback = function(event)
        if event.data.actions[1].type == "move" then
            Snacks.rename.on_rename_file(event.data.actions[1].src_url, event.data.actions[1].dest_url)
        end
    end,
})
```

**Details**:

#### Event: `User` with pattern `OilActionsPost`
- Custom event emitted by Oil.nvim after file operations
- Contains action metadata in `event.data`

#### Action Detection
- Checks if the action type is `"move"`
- Extracts `src_url` (original path) and `dest_url` (new path)

#### Integration with Snacks
- Calls `Snacks.rename.on_rename_file()` to update references
- Updates imports, requires, and other file references
- Notifies LSP servers about the rename

**Workflow**:
1. User renames/moves a file using Oil (`:Oil`)
2. Oil executes the file system operation
3. Oil emits `OilActionsPost` event
4. Autocommand detects the move action
5. Snacks updates all references to the file
6. LSP servers are notified to update their index

**Benefits**:
- Seamless refactoring when reorganizing project structure
- Automatic import/require updates
- LSP diagnostics stay accurate
- No broken references after file moves

## Creating Custom Autocommands

### Basic Template

```lua
-- 1. Create an augroup
local my_group = vim.api.nvim_create_augroup("MyCustomGroup", { clear = true })

-- 2. Create the autocommand
vim.api.nvim_create_autocmd("EventName", {
    group = my_group,
    pattern = "pattern",  -- Optional
    desc = "Clear description of what this does",
    callback = function(event)
        -- Your logic here
        -- event.buf contains the buffer number
        -- event.file contains the filename
        -- event.match contains the matched pattern
    end,
})
```

### Common Events

| Event | When Triggered | Use Case |
|-------|----------------|----------|
| `BufRead` | After reading a file into a buffer | File-specific settings |
| `BufWrite` | Before writing a file | Formatting, linting |
| `BufEnter` | Entering a buffer | Context-specific settings |
| `FileType` | When file type is detected | Language-specific config |
| `LspAttach` | LSP client attaches | LSP keybindings |
| `VimEnter` | After Vim/Neovim starts | Initialization tasks |
| `InsertEnter` | Entering insert mode | UI changes |
| `CursorHold` | Cursor idle for `updatetime` | Delayed actions |
| `TextChanged` | Text changed in normal mode | Auto-save |
| `WinEnter` | Entering a window | Window-specific settings |

### Examples

#### Format on Save
```lua
local format_group = vim.api.nvim_create_augroup("FormatOnSave", { clear = true })

vim.api.nvim_create_autocmd("BufWritePre", {
    group = format_group,
    pattern = { "*.lua", "*.py", "*.js" },
    desc = "Format code before saving",
    callback = function()
        vim.lsp.buf.format({ async = false })
    end,
})
```

#### Highlight on Yank
```lua
local highlight_group = vim.api.nvim_create_augroup("YankHighlight", { clear = true })

vim.api.nvim_create_autocmd("TextYankPost", {
    group = highlight_group,
    desc = "Briefly highlight yanked text",
    callback = function()
        vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200 })
    end,
})
```

#### Restore Cursor Position
```lua
local cursor_group = vim.api.nvim_create_augroup("RestoreCursor", { clear = true })

vim.api.nvim_create_autocmd("BufReadPost", {
    group = cursor_group,
    desc = "Restore cursor to last position when opening file",
    callback = function()
        local mark = vim.api.nvim_buf_get_mark(0, '"')
        local lcount = vim.api.nvim_buf_line_count(0)
        if mark[1] > 0 and mark[1] <= lcount then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
    end,
})
```

## Performance Considerations

### Best Practices

1. **Use Augroups**
   - Prevents duplicate autocommands on `:source`
   - Enables bulk deletion with `clear = true`

2. **Specific Patterns**
   - Use specific file patterns instead of `*` when possible
   - Example: `*.lua` vs `*`

3. **Targeted Events**
   - Only listen to events you actually need
   - Avoid overusing frequent events like `CursorMoved`

4. **Efficient Callbacks**
   - Keep callback logic lightweight
   - Use buffer-local settings (`vim.opt_local`) instead of global
   - Cache expensive computations

5. **Conditional Execution**
   - Add guards to skip unnecessary work
   - Example: Check if buffer is modifiable before attempting save

### Performance Impact

| Autocommand | Impact | Frequency | Notes |
|-------------|--------|-----------|-------|
| TextFiles wrap | Low | Per file open | Quick buffer-local option |
| Help/Quickfix window | Low | Occasional | Runs only for special buffers |
| Auto-reload | Low | Per focus/idle | Uses native `checktime` |
| Auto-save | Medium | Per text change | Optimized with checks |
| LSP Attach | Low | Once per buffer | Runs only on LSP attach |
| Terminal bindings | Low | Per terminal open | Buffer-local keymaps |
| Oil integration | Low | Per file operation | Event-driven, not polling |

### Monitoring Performance

Check autocommand execution time:
```vim
:profile start profile.log
:profile autocmd *
" Perform actions
:profile dump
:profile stop
```

Review `profile.log` to identify slow autocommands.

## Troubleshooting

### Autocommand Not Firing

1. **Check if event exists**: `:help autocmd-events`
2. **Verify pattern**: Use `:autocmd GroupName` to list active autocommands
3. **Add debug logging**:
   ```lua
   callback = function()
       print("Autocommand fired!")
       -- your logic
   end
   ```

### Duplicate Autocommands

**Problem**: Autocommand runs multiple times

**Solution**: Ensure augroup uses `clear = true`:
```lua
vim.api.nvim_create_augroup("MyGroup", { clear = true })  -- ✓ Correct
vim.api.nvim_create_augroup("MyGroup", {})  -- ✗ Wrong
```

### Conflicting Autocommands

**Problem**: Multiple autocommands interfere with each other

**Solutions**:
1. Use unique augroup names
2. Check execution order with `:autocmd`
3. Use `++once` for one-time execution (if needed)
4. Add conditional logic to skip when inappropriate

### Buffer-local vs Global

**Remember**:
- `opts = { buffer = 0 }` in keymaps = buffer-local
- `vim.opt_local` = buffer-local options
- `vim.opt` = global options

Always prefer buffer-local when possible to avoid side effects.

## References

- [Neovim Autocmd Documentation](https://neovim.io/doc/user/autocmd.html)
- [Neovim Lua Guide - Autocommands](https://neovim.io/doc/user/lua-guide.html#lua-guide-autocommands)
- [Vim Events List](https://neovim.io/doc/user/autocmd.html#autocmd-events)
