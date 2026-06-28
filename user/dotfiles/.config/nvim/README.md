# Neovim Configuration

A modern, feature-rich Neovim configuration with comprehensive LSP support, fuzzy finding, and extensive plugin ecosystem.

## Features

### Core Functionality

- **Plugin Manager**: [lazy.nvim](https://github.com/folke/lazy.nvim) - Fast and modern plugin manager
- **LSP Support**: Full Language Server Protocol support with Mason, LSP Config, and Lspsaga
- **Code Completion**: [blink.cmp](https://github.com/saghen/blink.cmp) - Fast completion engine with LuaSnip integration
- **Syntax Highlighting**: [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) - Advanced syntax highlighting and code parsing
- **Fuzzy Finder**: [Snacks.picker](https://github.com/folke/snacks.nvim) - Fast file/text searching
- **File Manager**: [Oil.nvim](https://github.com/stevearc/oil.nvim) - Edit your filesystem like a buffer

### Development Tools

- **LSP Features**:
  - Auto-completion with multiple sources (LSP, path, snippets, buffer, dictionary)
  - Go to definition/references
  - Hover documentation with rounded borders
  - Code actions via Lspsaga
  - Symbol navigation and workspace symbols
  - Format on save with [conform.nvim](https://github.com/stevearc/conform.nvim)
  - Real-time diagnostics with custom icons

- **Git Integration**:
  - [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim) - Git decorations and hunk management
  - Lazygit terminal integration

- **Code Navigation**:
  - [Leap.nvim](https://github.com/ggandor/leap.nvim) - Lightning-fast motion plugin
  - [Aerial](https://github.com/stevearc/aerial.nvim) - Code outline window
  - Word reference navigation with Snacks.words

### UI Enhancements

- **Status Line**: [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim) - Blazing fast status line
- **Notifications**: [nvim-notify](https://github.com/rcarriga/nvim-notify) - Fancy notification manager
- **Breadcrumbs**: [barbecue](https://github.com/utilyre/barbecue.nvim) - VS Code-like winbar
- **Key Hints**: [which-key](https://github.com/folke/which-key.nvim) - Display keybinding hints
- **Indent Guides**: [indent-blankline](https://github.com/lukas-reineke/indent-blankline.nvim)
- **Color Preview**: [nvim-highlight-colors](https://github.com/brenoprata10/nvim-highlight-colors.nvim)
- **Theme**: [tokyonight](https://github.com/folke/tokyonight.nvim)

### Specialized Tools

- **Markdown Support**:
  - [obsidian.nvim](https://github.com/epwalsh/obsidian.nvim) - Obsidian integration
  - [img-clip.nvim](https://github.com/HakonHarnes/img-clip.nvim) - Image clipboard support
  - [image.nvim](https://github.com/3rd/image.nvim) - Image preview in terminal

- **Terminal Integration**:
  - [toggleterm](https://github.com/akinsho/toggleterm.nvim) - Multiple terminal management
  - Floating terminals for lazygit, yazi, fish, and Claude Code

- **Utilities**:
  - [yanky.nvim](https://github.com/gbprod/yanky.nvim) - Clipboard history manager
  - [trouble.nvim](https://github.com/folke/trouble.nvim) - Pretty diagnostics list
  - [todo-comments](https://github.com/folke/todo-comments.nvim) - Highlight TODO comments
  - [im-select](https://github.com/keaising/im-select.nvim) - Auto-switch input method
  - [mini.nvim](https://github.com/echasnovski/mini.nvim) - Collection of minimal plugins
  - [distant.nvim](https://github.com/chipsenkbeil/distant.nvim) - Remote file editing

### Supported Languages

Pre-configured LSP and formatting for:
- **System**: Lua, Bash, Fish, Shell
- **Web**: JavaScript, TypeScript, Vue, React, HTML, CSS, JSON
- **System Programming**: Rust, C, C++
- **Scripting**: Python
- **Data**: YAML, TOML, XML
- **Documentation**: Markdown

## Project Structure

```
~/.config/nvim/
├── init.lua                 # Entry point
├── install.sh              # Automated installation script
├── uninstall.sh            # Automated uninstallation script
├── lua/
│   ├── config/              # Core configuration (auto-loaded)
│   │   ├── init.lua        # Configuration loader
│   │   ├── lazy.lua        # Lazy.nvim bootstrap
│   │   ├── general.lua     # Editor settings
│   │   ├── keybinding.lua  # Key mappings
│   │   ├── lsp.lua         # LSP configuration
│   │   ├── autocmds.lua    # Autocommands configuration
│   │   └── ...             # Other configs
│   ├── plugins/             # Plugin specifications (auto-loaded by lazy.nvim)
│   │   ├── Lsp.lua         # LSP plugins
│   │   ├── blink.lua       # Completion engine
│   │   ├── snacks.lua      # Snacks features
│   │   ├── nvim-treesitter.lua
│   │   └── ...             # Other plugin configs
│   └── utils/               # Utility functions
├── snippets/                # Custom snippets
│   └── markdown.json
└── docs/                    # Additional documentation
    └── AUTOCOMMANDS.md     # Detailed autocommands guide
```

## Installation

### Quick Install (Recommended)

Use the automated installation script:

```bash
# Clone the repository
git clone <your-repo-url> /tmp/nvim-config
cd /tmp/nvim-config

# Run the installer
./install.sh
```

The script will:
- ✅ Check system requirements (Neovim >= 0.10.0, Git)
- ✅ Backup existing configuration automatically
- ✅ Install the configuration
- ✅ Check and optionally install dependencies (ripgrep, fd, Node.js, etc.)
- ✅ Optionally install a Nerd Font
- ✅ Bootstrap lazy.nvim and install all plugins

**Installation Options:**
```bash
./install.sh              # Interactive installation (recommended)
./install.sh --auto       # Automatic installation (skip all prompts)
./install.sh --skip-backup # Skip backing up existing config
./install.sh --help       # Show help message
```

### Manual Installation

If you prefer to install manually:

#### Prerequisites

- Neovim >= 0.10.0
- Git
- A [Nerd Font](https://www.nerdfonts.com/) (for icons)
- [ripgrep](https://github.com/BurntSushi/ripgrep) (for fuzzy finding)
- [fd](https://github.com/sharkdp/fd) (optional, for faster file finding)
- Node.js (for some LSP servers)

#### Steps

1. Backup your existing configuration:
```bash
mv ~/.config/nvim ~/.config/nvim.backup
```

2. Clone this repository:
```bash
git clone <your-repo-url> ~/.config/nvim
```

3. Launch Neovim:
```bash
nvim
```

Lazy.nvim will automatically install all plugins on first launch.

4. Install LSP servers:
```vim
:Mason
```

### Verify Installation

Check that everything is working:
```vim
:checkhealth
```

This will show any missing dependencies or configuration issues.

## Uninstallation

### Quick Uninstall

Use the automated uninstallation script:

```bash
cd ~/.config/nvim

# Remove configuration only (keeps plugin data and cache)
./uninstall.sh

# Complete removal (removes everything)
./uninstall.sh --full
```

The script will:
- Show what will be removed with file sizes
- Offer to create a backup before removal
- Clean up configuration and optionally data/cache/state

### Manual Uninstallation

Remove configuration files:
```bash
rm -rf ~/.config/nvim
```

Remove all Neovim data (optional):
```bash
rm -rf ~/.local/share/nvim  # Plugin data, Mason installations
rm -rf ~/.local/state/nvim  # State files
rm -rf ~/.cache/nvim        # Cache files
```

## Configuration Guide

### Adding New Plugins

1. Create a new file in `lua/plugins/`:
```lua
-- lua/plugins/my-plugin.lua
return {
    'author/plugin-name',
    dependencies = { 'dependency1', 'dependency2' },
    opts = {
        -- Plugin options here
    },
}
```

2. Lazy.nvim automatically loads all files in the `plugins/` directory

### Adding New Configuration

1. Create a new file in `lua/config/`:
```lua
-- lua/config/my-config.lua
vim.opt.option_name = value
-- Your configuration here
```

2. The configuration loader (`lua/config/init.lua`) automatically requires all config files

### Modifying Keybindings

Edit `lua/config/keybinding.lua`:
```lua
vim.keymap.set('n', '<leader>x', ':YourCommand<CR>', { desc = 'Description' })
```

### Configuring LSP Servers

Edit `lua/config/lsp.lua`:

1. For Mason-managed servers (auto-install):
```lua
require("mason-lspconfig").setup({
    handlers = {
        function(server_name)
            require("lspconfig")[server_name].setup({
                capabilities = capabilities,
            })
        end,
    },
})
```

2. For custom server configuration:
```lua
vim.lsp.config('server_name', {
    cmd = { 'command' },
    filetypes = { 'filetype' },
    root_markers = { 'marker.file' },
    settings = {
        -- Server-specific settings
    },
})
```

### Adding Formatters

Edit `lua/config/lsp.lua` in the conform.setup section:
```lua
formatters_by_ft = {
    your_filetype = { "formatter_name" },
}
```

## Key Bindings

Leader key: `<Space>`

### Basic Navigation
| Key | Mode | Action |
|-----|------|--------|
| `<leader>e` | n | Open Oil file manager |
| `H` / `L` | n | Previous/Next buffer |
| `<leader>c` | n | Close current buffer |
| `<leader>w` | n | Save all buffers |
| `<leader>q` | n | Quit |
| `jj` | i | Exit insert mode |
| `C-h/j/k/l` | n | Navigate windows |
| `C` | n | Copy relative file path |

### LSP
| Key | Mode | Action |
|-----|------|--------|
| `K` | n | Hover documentation |
| `gd` | n | Go to definition |
| `gr` | n | Show references |
| `gn` | n | Rename symbol |
| `ga` | n | Code actions |
| `ge` | n | Show diagnostics |

### Fuzzy Finding (Snacks)
| Key | Mode | Action |
|-----|------|--------|
| `<leader>,` | n | Switch buffers |
| `<leader>/` | n | Grep in project |
| `<leader>:` | n | Command history |
| `<leader>ff` | n | Find files |
| `<leader>fg` | n | Find git files |
| `<leader>fc` | n | Find config files |
| `<leader>fr` | n | Recent files |
| `<leader>sd` | n | Diagnostics |
| `<leader>ss` | n | LSP symbols |

### Terminal
| Key | Mode | Action |
|-----|------|--------|
| `<leader>tt` | n | Toggle float terminal |
| `<leader>tl` | n | Toggle lazygit |
| `<leader>ty` | n | Toggle yazi |
| `<leader>tc` | n | Toggle Claude Code |
| `jj` | t | Exit terminal mode |

### Navigation
| Key | Mode | Action |
|-----|------|--------|
| `f` | n,x,o | Leap motion |
| `]]` / `[[` | n,t | Next/Prev word reference |

### Clipboard
| Key | Mode | Action |
|-----|------|--------|
| `gp` / `gP` | n,x | Paste from yanky |
| `<C-p>` / `<C-n>` | n | Cycle yanky history |

## Editor Settings

- Line numbers: Relative + absolute
- Clipboard: System clipboard integrated
- Search: Smart case-insensitive
- Indentation: 4 spaces, smart indent
- Encoding: UTF-8
- Fold method: Indent (level 99)
- Update time: 200ms (faster responses)
- Auto-reload: Files changed outside Neovim

## Autocommands (lua/config/autocmds.lua)

> **📖 For detailed technical documentation, see [docs/AUTOCOMMANDS.md](docs/AUTOCOMMANDS.md)**

The configuration includes intelligent autocommands organized by category for better maintainability. All autocommands use `vim.api.nvim_create_autocmd` for consistency and type safety.

### File Type Specific Settings

#### Text Files Auto-wrap
**Augroup**: `TextFilesSettings`

Automatically enables line wrapping and line breaks for text-based file types:
- Markdown (`.md`)
- Plain text (`.txt`, `.text`)
- reStructuredText (`.rst`)
- Org mode (`.org`)
- AsciiDoc (`.adoc`)

**Triggers**: `FileType`, `BufEnter`

This improves readability when working with documentation and prose.

#### Help and Man Pages
**Augroup**: `HelpInCurrentWindow`

When opening help or man pages, automatically closes other windows to display the documentation in full view.

**Pattern**: `help`, `man`
**Trigger**: `FileType`

#### Quickfix Window
**Augroup**: `QuickfixInCurrentWindow`

Automatically maximizes the quickfix window when opened.

**Pattern**: `qf`
**Trigger**: `FileType`

### File Management

#### Auto-reload Files
**Augroup**: `AutoReload`

Automatically reloads files when they're modified outside Neovim. This ensures you always see the latest version without manual intervention.

**Triggers**: `FocusGained`, `BufEnter`, `CursorHold`

**How it works**: When you focus the window, enter a buffer, or the cursor is idle, Neovim checks if files have changed externally and reloads them.

#### Auto-save on Text Change
**Augroup**: `AutoSave`

Automatically saves your work as you type. This feature only affects:
- Modifiable buffers
- Modified buffers
- Normal file buffers (excludes special buffers like quickfix, help, terminals)

**Triggers**: `TextChangedI`, `TextChanged`

**Behavior**: Uses `silent! update` to save without showing messages, and only saves if the buffer has actually been modified.

### LSP Integration

#### LSP Attach Configuration
**Augroup**: `UserLspConfig`

When an LSP server attaches to a buffer, this autocommand:

1. **Configures Inlay Hint Highlighting**: Sets custom colors for LSP inlay hints
   - Foreground: `#565f89`
   - Background: `#292e42`
   - Style: Italic with 30% blend

2. **Sets Up Buffer-local Keybindings**:
   - `K`: Hover documentation with rounded borders
   - `ge`: Show diagnostics in floating window with rounded borders

**Trigger**: `LspAttach`

### Terminal Settings

#### Terminal Keybindings
**Augroup**: `TerminalSettings`

Automatically configures keybindings when opening a terminal:

- `jj` in terminal mode: Exit to normal mode (same as insert mode)
- `<C-w>` in terminal mode: Prefix for window navigation commands
- Sets `timeoutlen` to 300ms for better responsiveness

**Pattern**: `term://*`
**Trigger**: `TermOpen`

### Plugin-specific Autocommands

#### Oil.nvim File Operations
**Augroup**: `OilActions`

Integrates Oil.nvim file operations with Snacks.nvim's rename functionality. When you rename or move a file using Oil:

1. Detects the `move` action
2. Notifies Snacks.rename to update references throughout the project
3. Ensures LSP servers are aware of the file name change

**Pattern**: `OilActionsPost`
**Trigger**: `User` event

This provides a seamless experience when refactoring file structures, automatically updating imports and references.

### Benefits of This Organization

1. **Clear Categorization**: Each autocommand is grouped by purpose (file types, file management, LSP, etc.)
2. **Augroups**: All autocommands use augroups with `clear = true` to prevent duplicates on reload
3. **Type Safety**: Uses Neovim's Lua API instead of vim commands where possible
4. **Maintainability**: Each section is well-documented with descriptions
5. **Performance**: Autocommands are targeted and efficient, only triggering when necessary

### Customizing Autocommands

To add your own autocommands, edit `lua/config/autocmds.lua`:

```lua
-- Create a new augroup
local my_group = vim.api.nvim_create_augroup("MyCustomGroup", { clear = true })

-- Add your autocommand
vim.api.nvim_create_autocmd("EventName", {
    group = my_group,
    pattern = "pattern",
    desc = "Description of what this does",
    callback = function()
        -- Your logic here
    end,
})
```

Or use the command-based approach:
```lua
vim.api.nvim_create_autocmd("BufWritePre", {
    group = my_group,
    pattern = "*.lua",
    desc = "Format Lua files before save",
    callback = function()
        vim.lsp.buf.format({ async = false })
    end,
})
```

## Customization Tips

1. **Override plugin settings**: Create/edit the corresponding file in `lua/plugins/`
2. **Add custom commands**: Add them to `lua/config/userautocmd.lua` or create a new config file
3. **Change theme**: Edit `lua/plugins/colorscheme.lua` and update `lua/config/general.lua`
4. **Modify diagnostics**: Edit `lua/config/general.lua` diagnostic config section
5. **LSP inlay hints**: Configured in `lua/config/keybinding.lua` LspAttach autocmd

## Troubleshooting

### Plugins not loading
```bash
:Lazy sync
```

### LSP not working
```bash
:Mason           # Check if LSP server is installed
:LspInfo         # Check LSP client status
```

### Treesitter highlighting issues
```bash
:TSUpdate        # Update parsers
:TSInstallInfo   # Check installed parsers
```

### Performance issues
- Check `:checkhealth` for diagnostic information
- Snacks.nvim has bigfile detection to disable features for large files

## Dependencies Management

All language servers and formatters are managed through Mason. Install additional tools via:
```bash
:Mason
```

Search, install, or update any LSP server, formatter, or linter from the Mason UI.

## Contributing

Feel free to customize this configuration to your needs. If you find improvements or bugs, please create an issue or pull request.

## License

MIT License - Feel free to use and modify as you wish.
