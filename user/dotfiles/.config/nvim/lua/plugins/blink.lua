return {
	"saghen/blink.cmp",
	dependencies = {

		"saghen/blink.lib",
		"rafamadriz/friendly-snippets",
		"archie-judd/blink-cmp-words",
	},

	version = "1.*",
	opts = {
		keymap = {
			preset = "default",

			-- ['<Tab>'] = {
			--     'select_next', "fallback" },
			-- ['<S-Tab>'] = {
			--     "select_prev", "fallback" },
			["<C-p>"] = { "show", "fallback" },
			["<CR>"] = { "accept", "fallback" },
			["<C-j>"] = { "select_next", "fallback" },
			["<C-k>"] = { "select_prev", "fallback" },
		},
		appearance = {
			-- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
			nerd_font_variant = "mono",
		},
		sources = {
			default = { "lsp", "path", "snippets" },
			providers = {

				thesaurus = {
					enabled = true,
					name = "blink-cmp-words",
					module = "blink-cmp-words.thesaurus",
					-- All available options
					opts = {
						-- A score offset applied to returned items.
						-- By default the highest score is 0 (item 1 has a score of -1, item 2 of -2 etc..).
						score_offset = 0,

						-- Default pointers define the lexical relations listed under each definition,
						-- see Pointer Symbols below.
						-- Default is as below ("antonyms", "similar to" and "also see").
						definition_pointers = { "!", "&", "^" },

						-- The pointers that are considered similar words when using the thesaurus,
						-- see Pointer Symbols below.
						-- Default is as below ("similar to", "also see" }
						similarity_pointers = { "&", "^" },

						-- The depth of similar words to recurse when collecting synonyms. 1 is similar words,
						-- 2 is similar words of similar words, etc. Increasing this may slow results.
						similarity_depth = 2,
					},
				},

				-- Use the dictionary source
				dictionary = {
					enabled = true,
					name = "blink-cmp-words",
					module = "blink-cmp-words.dictionary",
					-- All available options
					opts = {
						-- The number of characters required to trigger completion.
						-- Set this higher if completion is slow, 3 is default.
						dictionary_search_threshold = 3,

						-- See above
						score_offset = 0,

						-- See above
						definition_pointers = { "!", "&", "^" },
					},
				},
				snippets = {
					enabled = true,
					opts = {
						friendly_snippets = true,
						search_paths = { vim.fn.stdpath("config") .. "/snippets" },
						extended_filetypes = {
							cpp = { "unreal" },
						},
					},
				},
			},

			-- Setup completion by filetype
			per_filetype = {
				text = { "dictionary" },
				markdown = { "thesaurus" },
			},
		},
		completion = {

			keyword = { range = "full" },
			list = { selection = { preselect = true, auto_insert = true } },
			documentation = {
				auto_show = false,
			},
			menu = {
				auto_show_delay_ms = 0,
				auto_show = true,
				draw = {
					columns = {
						{ "kind_icon" },
						{ "label", "label_description", "source_name", gap = 1 },
						-- { "kind_icon", "kind" },
					},
				},
			},
		},
		signature = {
			enabled = true,
			window = {
				min_width = 1,
				max_width = 100,
				max_height = 10,
				winblend = 0,
				winhighlight = "Normal:BlinkCmpSignatureHelp,FloatBorder:BlinkCmpSignatureHelpBorder",
				scrollbar = false, -- Note that the gutter will be disabled when border ~= 'none'
				-- Which directions to show the window,
				-- falling back to the next direction when there's not enough space,
				-- or another window is in the way
				direction_priority = { "n", "s" },
				-- Can accept a function if you need more control
				-- direction_priority = function()
				--   if condition then return { 'n', 's' } end
				--   return { 's', 'n' }
				-- end,

				-- Disable if you run into performance issues
				treesitter_highlighting = true,
			},
		},

		-- Default list of enabled providers defined so that you can extend it
		-- elsewhere in your config, without redefining it, due to `opts_extend`

		fuzzy = { implementation = "rust" },
	},
}
