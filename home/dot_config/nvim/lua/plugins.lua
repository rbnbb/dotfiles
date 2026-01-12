local utils = require("utils")

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
    vim.fn.system {
        "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath
    }
end
vim.opt.rtp:prepend(lazypath)

-- python path for UltiSnips, etc.
require("config.providers")

-- check if firenvim is active
-- local firenvim_not_active = function()
--     return not vim.g.started_by_firenvim
-- end

local plugin_specs = {
    { -- auto-completion engine
        "hrsh7th/nvim-cmp",
        -- event = 'InsertEnter',
        event = "VeryLazy",
        dependencies = {
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-nvim-lsp",
            "onsails/lspkind-nvim",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-omni",
            "hrsh7th/cmp-emoji",
            "hrsh7th/cmp-nvim-lsp-signature-help",
            "quangnguyen30192/cmp-nvim-ultisnips",
            "saadparwaiz1/cmp_luasnip",
        },
        config = function()
            require("config.nvim-cmp")
        end,
    },
    {
        "neovim/nvim-lspconfig",
        event = { "BufRead", "BufNewFile" },
        config = function()
            require("config.lsp")
        end,
    },
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
        build = ":TSUpdate",
        event = "VeryLazy",
        config = function()
            require("nvim-treesitter").setup({
                ensure_installed = { "vimdoc", "julia", "python", "cpp", "lua", "vim", "json", "toml" },
            })

            -- Filetypes to disable highlighting
            local highlight_disabled = { "markdown", "help", "vimdoc", "tex" }
            -- Filetypes to disable indentation
            local indent_disabled = { "julia", "json" }

            vim.api.nvim_create_autocmd("FileType", {
                callback = function(ev)
                    local buf = ev.buf
                    local ft = vim.bo[buf].filetype

                    -- Try to start treesitter highlighting
                    local ok = pcall(vim.treesitter.start, buf)
                    if not ok then return end

                    -- Disable highlighting for specific filetypes
                    if vim.tbl_contains(highlight_disabled, ft) then
                        vim.treesitter.stop(buf)
                    end

                    -- Enable treesitter indentation (unless disabled)
                    if not vim.tbl_contains(indent_disabled, ft) then
                        vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                    end
                end,
            })
        end,
    },
    -- Python indent (follows the PEP8 style)
    { "Vimjas/vim-python-pep8-indent", ft = { "python" } },
    -- fix built-in spellfile downloader if netrw is disabled
    { "cuducos/spellfile.nvim" },
    -- Python-related text object
    { "jeetsukumaran/vim-pythonsense", ft = { "python" } },
    { "machakann/vim-swap",            event = "VeryLazy" },
    -- Super fast buffer jump
    {
        "smoka7/hop.nvim",
        event = "VeryLazy",
        config = function()
            require("config.nvim_hop")
        end,
        enable_in_kitty_scrollback = true,
    },
    { "nvim-lua/plenary.nvim" },
    {
        "nvim-telescope/telescope.nvim",
        dependencies = {
            "nvim-telescope/telescope-symbols.nvim",
        },
        config = function()
            require("config.telescope")
        end,
    },
    -- {  -- horizontal nightlights for markdown filetypes
    --     "lukas-reineke/headlines.nvim",
    --     dependencies = "nvim-treesitter/nvim-treesitter",
    --     config = true, -- or `opts = {}`
    -- },
    -- A list of common colorscheme plugins
    -- { "navarasu/onedark.nvim",       lazy = true },
    -- { "sainnhe/edge",                lazy = true },
    -- { "sainnhe/sonokai",             lazy = true },
    -- { "sainnhe/gruvbox-material",    lazy = true },
    -- { "sainnhe/everforest",          lazy = true },
    -- { "EdenEast/nightfox.nvim",      lazy = true },
    -- { "olimorris/onedarkpro.nvim",   lazy = true },
    -- { "marko-cerovac/material.nvim", lazy = true },
    {
        "catppuccin/nvim",
        name = "catppuccin",
        lazy = false,
        opts = {
            transparent_background = true,
            -- custom_highlights = function(colors)
            -- cusomize colors a bit
            -- return {
            -- NormalFloat = { bg = "NONE" },
            -- Floatborder = { bg = "NONE" },
            -- Pmenu = { bg = "NONE" },
            -- PmenuSel = { bg = colors.surface0 },
            -- TelescopeNormal = { bg = "NONE"},
            -- TelescopeBorder = { bg = "NONE"},
            --     }
            -- end,
        },
        enable_in_kitty_scrollback = true,
    },
    { -- fancy start screen
        "nvimdev/dashboard-nvim",
        event = 'VimEnter',
        -- cond = firenvim_not_active,
        config = function()
            require("dashboard").setup {
                theme = "hyper",
                vim.keymap.set('n', '<leader>d', ':Dashboard<CR>')
            }
        end,
        -- requires = {'nvim-tree/nvim-web-devicons'},
    },
    {
        "rcarriga/nvim-notify",
        event = "VeryLazy",
        config = function()
            require("config.nvim-notify")
        end,
        enable_in_kitty_scrollback = true,
    },
    -- Snippet engine and snippet template
    {
        "SirVer/ultisnips",
        event = "InsertEnter"
    },
    -- Comment plugin
    -- { "tpope/vim-commentary",   event = "VeryLazy" },
    -- Show undo history visually
    { "simnalamburt/vim-mundo", cmd = { "MundoToggle", "MundoShow" } },
    -- better UI for some nvim actions
    { "stevearc/dressing.nvim" },
    -- Manage your yank history
    {
        "gbprod/yanky.nvim",
        cmd = { "YankyRingHistory" },
        config = function()
            require("config.yanky")
        end,
    },
    -- Repeat vim motions
    { "tpope/vim-repeat", event = "VeryLazy" },
    -- me: only on mac is good, actually
    {
        "lyokha/vim-xkbswitch",
        enabled = function()
            if vim.g.is_mac and utils.executable("xkbswitch") then
                return true
            end
            return false
        end,
        event = { "InsertEnter" },
        enable_in_kitty_scrollback = true,
    },
    -- me: why only on windos though ?
    -- {
    --     "Neur1n/neuims",
    --     enabled = function()
    --         if vim.g.is_win then
    --             return true
    --         end
    --         return false
    --     end,
    --     event = { "InsertEnter" },
    -- },
    -- Auto format tools
    { "sbdchd/neoformat", cmd = { "Neoformat" } },
    -- me: Make quickfix look better
    {
        "kevinhwang91/nvim-bqf",
        ft = "qf",
        config = function()
            require("config.bqf")
        end,
    },
    { "chrisbra/unicode.vim", event = "VeryLazy" },
    -- Additional powerful text object for vim, this plugin should be studied
    -- carefully to use its full power
    { "wellle/targets.vim",   event = "VeryLazy", enable_in_kitty_scrollback = true, },
    -- Add indent object for vim (useful for languages like Python)
    -- { "michaeljsmith/vim-indent-object", event = "VeryLazy" },
    {
        "barreiroleo/ltex_extra.nvim",
        ft = { "text", "plaintex", "tex", "markdown" },
        dependencies = { "neovim/nvim-lspconfig" },
        event = "VeryLazy"
    },
    {
        "ray-x/lsp_signature.nvim",
        event = "InsertEnter",
        opts = {
            bind = true,
            handler_opts = {
                border = "rounded"
            },
            toggle_key = '<C-,>'
        }
    },
    {
        "lervag/vimtex",
        enabled = function()
            if utils.executable("latex") then
                return true
            end
            return false
        end,
        config = function()
            require("config.vimtex")
        end,
        ft = { "tex" },
        lazy = false,
    },
    {
        "lervag/wiki.vim",
        dependencies = { "nvim-telescope/telescope.nvim" },
        config = function()
            vim.g.wiki_root = "~/wiki"
            vim.g.wiki_filetypes = { "md", "typ" } -- typst is cool 4 notes
            vim.keymap.set('n', '<leader>fw',
                function() require('telescope.builtin').live_grep({ cwd = "~/wiki", prompt_title = "Wiki Search" }) end,
                { noremap = true })
            vim.keymap.set('n', '<leader>wp', ":WikiPages<CR>", { noremap = true })
            vim.keymap.set('n', ']j', ":WikiJournalNext<CR>", { noremap = true })
            vim.keymap.set('n', '[j', ":WikiJournalPrev<CR>", { noremap = true })
        end,
    },
    -- Modern matchit implementation
    {
        "andymass/vim-matchup",
        event = "BufRead",
        enable_in_kitty_scrollback = true,
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        config = function()
            vim.keymap.set('n', '%', '<Plug>(matchup-%)', { noremap = true })
            vim.keymap.set('n', '<space>h', ':MatchupWhereAmI<cr>', { noremap = true })
        end,
    },
    { "tpope/vim-scriptease",     cmd = { "Scriptnames", "Message", "Verbose" } },
    -- Asynchronous command execution
    { "skywind3000/asyncrun.vim", lazy = true,                                  cmd = { "AsyncRun" }, ft = { "typst", "mermaid" } },
    { "cespare/vim-toml",         ft = { "toml" },                              branch = "main" },
    {
        'chomosuke/typst-preview.nvim',
        ft = 'typst',
        version = '1.*',
        opts = {}, -- lazy.nvim will implicitly calls `setup {}`
        cmd = { "TypstPreviewToggle", "TypstPreview", "TypstPreviewStop" },
        config = function()
            vim.keymap.set('n', '\\ll', ":TypstPreviewToggle<CR>", { noremap = true })
            -- require 'typst-preview'.setup{
            -- open_cmd = 'firefox --new-window "%s" -P typst-preview --class typst-preview'
            -- }
        end,
    },
    {
        "iamcco/markdown-preview.nvim",
        cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
        build = "cd app && yarn install",
        init = function()
            vim.g.mkdp_filetypes = { "markdown" }
        end,
        ft = { "markdown" },
    },
    --     -- Edit text area in browser using nvim
    --     {
    --         "glacambre/firenvim",
    --         enabled = function()
    --             if vim.g.is_win or vim.g.is_mac then
    --                 return true
    --             end
    --             return false
    --         end,
    --         build = function()
    --             vim.fn["firenvim#install"](0)
    --         end,
    --         lazy = true,
    --     },

    --     -- Debugger plugin
    --     {
    --         "sakhnik/nvim-gdb",
    --         enabled = function()
    --             if vim.g.is_win or vim.g.is_linux then
    --                 return true
    --             end
    --             return false
    --         end,
    --         build = { "bash install.sh" },
    --         lazy = true,
    --     },

    -- The missing auto-completion for cmdline!
    {
        "gelguy/wilder.nvim",
        build = ":UpdateRemotePlugins",
    },
    { -- file explorer
        "nvim-tree/nvim-tree.lua",
        keys = { ",s" },
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("config.nvim-tree")
        end,
    },
    { "ii14/emmylua-nvim",       ft = "lua" }, -- make luals neovim aware
    -- {
    --     "j-hui/fidget.nvim",
    --     event = "VeryLazy",
    --     tag = "legacy",
    --     config = function()
    --         require("config.fidget-nvim")
    --     end,
    -- },
    -- { "pierreglaser/folding-nvim" },
    {
        'kevinhwang91/nvim-ufo',
        dependencies = 'kevinhwang91/promise-async',
        config = function()
            require("config.nvim-ufo")
        end,
    },
    { "farmergreg/vim-lastplace" },
    { "AndrewRadev/linediff.vim" },
    -- for project root with Telescope integration
    -- { "ahmedkhalf/project.nvim",
    --     event = "VeryLazy",
    --     config = function()
    --     require("project_nvim").setup {
    --     } end
    -- },
    {
        "greggh/claude-code.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim", -- Required for git operations
        },
        config = function()
            require("config.claude-code")
        end
    },
    {
        'mikesmithgh/kitty-scrollback.nvim',
        enabled = true,
        lazy = true,
        cmd = { 'KittyScrollbackGenerateKittens', 'KittyScrollbackCheckHealth', 'KittyScrollbackGenerateCommandLineEditing' },
        event = { 'User KittyScrollbackLaunch' },
        -- version = '*', -- latest stable version, may have breaking changes if major version changed
        -- version = '^6.0.0', -- pin major version, include fixes and features that do not have breaking changes
        config = function()
            require('kitty-scrollback').setup()
            -- Set custom mappings using space explicitly
            vim.keymap.set('n', '<Space>y', '<Plug>(KsbNormalYank)', { desc = 'Yank to clipboard' })
            vim.keymap.set('n', '<Space>yy', '<Plug>(KsbNormalYankLine)', { desc = 'Yank line to clipboard' })
            vim.keymap.set('n', '<Space>Y', '<Plug>(KsbNormalYankEnd)', { desc = 'Yank to end of line to clipboard' })
            vim.keymap.set('v', '<Space>y', '<Plug>(KsbVisualYank)', { desc = 'Yank selection to clipboard' })
            vim.keymap.set('v', '<Space>Y', '<Plug>(KsbVisualYankLine)', { desc = 'Yank lines to clipboard' })
        end,
    },
}

-- Transform specs to disable most plugins in KittyScrollback.nvim mode
for _, spec in ipairs(plugin_specs) do
    if not spec.enable_in_kitty_scrollback then
        local old_cond = spec.cond
        spec.cond = function()
            local base_ok = (old_cond == nil) or old_cond() -- no condion treated as true
            local not_kitty = vim.env.KITTY_SCROLLBACK_NVIM ~= 'true'
            return base_ok and not_kitty
        end
    end
end

-- configuration for lazy itself.
local lazy_opts = {
    ui = {
        border = "rounded",
        title = "Plugin Manager",
        title_pos = "center",
    },
    {
        rocks = {
            enabled = false,
        },
    },
}

require("lazy").setup(plugin_specs, lazy_opts)
