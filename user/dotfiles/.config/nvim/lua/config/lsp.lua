-- ============================================================================
-- LSP Capabilities Configuration
-- ============================================================================
local capabilities = vim.lsp.protocol.make_client_capabilities()

-- Neovim 0.12 enables document-color requests by default. A client that
-- restarts while a request is queued can leave its internal provider with a
-- stale client id, which then hits an assertion in document_color.lua.
-- Disable the native provider until that race is fixed upstream.
vim.lsp.document_color.enable(false)

-- Enable workspace/didChangeWatchedFiles so LSP can detect external file changes
capabilities.workspace = capabilities.workspace or {}
capabilities.workspace.didChangeWatchedFiles = {
	dynamicRegistration = true,
}

-- ============================================================================
-- Diagnostic Configuration (LSP-specific)
-- ============================================================================
-- Note: This merges with the base diagnostic config in general.lua
vim.diagnostic.config({
	-- Enable real-time diagnostics while typing in insert mode
	update_in_insert = true,
	-- Improve diagnostic update responsiveness
	severity_sort = true,
})

-- ============================================================================
-- Conform (Formatter) Setup
-- ============================================================================
require("conform").setup({
	formatters_by_ft = {
		lua = { "stylua" },
		bash = { "shfmt" },
		zsh = { "shfmt" },
		sh = { "shfmt" },
		java = { "google-java-format" },
		xml = { "xmlformat" },
		yaml = { "prettier" },
		toml = { "taplo" },
		conf = { "prettier" },
		fish = { "fish_indent" },
		typst = { "typstyle" },
		rust = { "rustfmt", "leptosfmt" },
		python = { "ruff_format", "ruff_organize_imports", "ruff_fix" },
		nix = { "nixfmt" },
		json = { "biome", "prettier", stop_after_first = true },
		jsonc = { "biome" },
		javascript = { "prettier", stop_after_first = true },
		typescript = { "prettier", stop_after_first = true },
		javascriptreact = { "prettier", stop_after_first = true },
		typescriptreact = { "prettier", stop_after_first = true },
		cpp = { "clang-format" },
		c = { "clang-format" },
		cmake = { "cmake_format" },
		meson = { "meson_format" },
		vue = { "prettier" },
		css = { "prettier" },
		html = { "prettier" },
		["_"] = { "trim_whitespace", "trim_newlines", "squeeze_blanks" },
	},
	format_on_save = {
		timeout_ms = 500,
		lsp_format = "fallback",
	},
	formatters = {
		meson_format = {
			command = "meson",
			args = { "format", "--source-file-path", "$FILENAME", "-" },
			stdin = true,
		},
	},
})

-- ============================================================================
-- LSP Server Configurations
-- ============================================================================

-- Lua Language Server

vim.lsp.config["lua_ls"] = {
	cmd = { "lua-language-server" },
	filetypes = { "lua" },
	root_markers = { ".luarc.json", ".luarc.jsonc", ".git" },
	settings = {
		Lua = {
			completion = {
				callSnippet = "Replace",
			},
		},
	},
}

vim.lsp.enable("lua_ls")

-- Nix (nixd)
-- local hostname = vim.fn.trim(vim.fn.system("hostname"))
local hostname = "gpunixos"
-- local user = vim.fn.trim(vim.fn.system("whoami"))
local user = "tohno@gpu"
local flake_expr = "builtins.getFlake (toString ./.)"

vim.lsp.config["nixd"] = {
	cmd = { "nixd" },
	filetypes = { "nix" },
	root_markers = { "flake.nix", ".git" },
	settings = {
		nixd = {
			nixpkgs = {
				expr = "import (builtins.getFlake (toString ./.)).inputs.nixpkgs { }",
			},
			formatting = {
				command = { "nixfmt" },
			},
			options = {
				["flake-parts"] = {
					expr = [[(builtins.getFlake (toString ./.)).debug.options]],
				},
			},
		},
	},
}

vim.lsp.enable("nixd")

-- Python (basedpyright)
vim.lsp.config["basedpyright"] = {
	cmd = { "basedpyright-langserver", "--stdio" },
	filetypes = { "python" },
	root_markers = { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", ".git" },
	settings = {
		basedpyright = {
			analysis = {
				typeCheckingMode = "basic",
				diagnosticMode = "workspace",
				autoImportCompletions = true,
			},
		},
	},
}
vim.lsp.enable("basedpyright")

-- typst

vim.lsp.config["tinymist"] = {

	settings = {

		formatterMode = "typstyle",

		exportPdf = "onType",

		semanticTokens = "disable",
	},
}

vim.lsp.enable("tinymist")

-- rust
vim.lsp.config["rust_analyzer"] = {
	settings = {
		["rust-analyzer"] = {
			doctest = {
				enable = true,
			},
			imports = {
				granularity = {
					group = "module",
				},
				prefix = "self",
			},
			cargo = {
				buildScripts = {
					enable = true,
				},
			},
			procMacro = {
				enable = true,
			},
		},
	},
}

vim.lsp.enable("rust_analyzer")

-- Frontend (TS / HTML / CSS / Tailwind / Emmet / ESLint)
vim.lsp.config["tailwindcss"] = {
	cmd = { "tailwindcss-language-server", "--stdio" },
	filetypes = {
		"html",
		"css",
		"scss",
		"javascript",
		"javascriptreact",
		"typescript",
		"typescriptreact",
		"vue",
		"svelte",
		"rust",
	},
	root_markers = {
		"tailwind.config.js",
		"tailwind.config.ts",
		"tailwind.config.cjs",
		"tailwind.config.mjs",
		"postcss.config.js",
		"package.json",
		"Cargo.toml",
		".git",
	},
	init_options = {
		userLanguages = {
			rust = "html",
		},
	},
	settings = {
		tailwindCSS = {
			includeLanguages = {
				rust = "html",
			},
			experimental = {
				classRegex = {
					'class\\s*=\\s*"(.*?)"',
					"class\\s*=\\s*\\((.*?)\\)",
					'class:\\s*"(.*?)"',
					"class:\\s*\\((.*?)\\)",
					'class!\\("(.*?)"\\)',
					'classes!\\("(.*?)"\\)',
					"class:([^=\\s>]+)",
				},
			},
		},
	},
}
vim.lsp.enable({ "vtsls", "html", "cssls", "tailwindcss", "emmet_ls", "eslint" })

-- cpp
vim.lsp.config["clangd"] = {
	cmd = { "clangd", "--query-driver=/nix/store/*/bin/*" },
	filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
	root_markers = {
		".clangd",
		".clang-tidy",
		".clang-format",
		"compile_commands.json",
		"compile_flags.txt",
		"configure.ac", -- AutoTools
		".git",
	},
}
vim.lsp.config["mesonlsp"] = {
	cmd = { "mesonlsp", "--lsp" },
	filetypes = { "meson" },
}
vim.lsp.enable({ "clangd", "neocmake", "mesonlsp" })
