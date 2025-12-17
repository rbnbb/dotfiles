local fn = vim.fn
local api = vim.api
local keymap = vim.keymap
local lsp = vim.lsp
local diagnostic = vim.diagnostic

local utils = require("utils")

local capabilities = require('cmp_nvim_lsp').default_capabilities()


-- set quickfix list from diagnostics in a certain buffer, not the whole workspace
local set_qflist = function(buf_num, severity)
    local diagnostics = nil
    diagnostics = diagnostic.get(buf_num, { severity = severity })

    local qf_items = diagnostic.toqflist(diagnostics)
    vim.fn.setqflist({}, ' ', { title = 'Diagnostics', items = qf_items })

    -- open quickfix by default
    vim.cmd [[copen]]
end

local custom_attach = function(client, bufnr)
    -- Mappings.
    local map = function(mode, l, r, opts)
        opts = opts or {}
        opts.silent = true
        opts.buffer = bufnr
        keymap.set(mode, l, r, opts)
    end

    local caps = client.server_capabilities or {}

    if caps.hover then  -- ltex-ls has no hover
        map("n", "K", vim.lsp.buf.hover)
    end
    map("n", "gd", vim.lsp.buf.definition, { desc = "go to definition" })
    map("n", "<C-]>", vim.lsp.buf.definition)
    map("n", "<C-k>", vim.lsp.buf.signature_help)
    map("i", "<C-k>", vim.lsp.buf.signature_help)
    map("n", "<space>rn", vim.lsp.buf.rename, { desc = "variable rename" })
    map("n", "gr", vim.lsp.buf.references, { desc = "show references" })
    map("n", "[d", diagnostic.goto_prev, { desc = "previous diagnostic" })
    map("n", "]d", diagnostic.goto_next, { desc = "next diagnostic" })
    -- this puts diagnostics from opened files to quickfix
    map("n", "<space>qw", diagnostic.setqflist, { desc = "put window diagnostics to qf" })
    -- this puts diagnostics from current buffer to quickfix
    map("n", "<space>qb", function() set_qflist(bufnr) end, { desc = "put buffer diagnostics to qf" })
    map("n", "<space>ca", vim.lsp.buf.code_action, { desc = "LSP code action" })
    map("n", "<space>wa", vim.lsp.buf.add_workspace_folder, { desc = "add workspace folder" })
    map("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, { desc = "remove workspace folder" })
    map("n", "<space>wl", function()
        vim.inspect(vim.lsp.buf.list_workspace_folders())
    end, { desc = "list workspace folder" })

    if caps.documentFormattingProvider then
        map("n", "<space>f", vim.lsp.buf.format, { desc = "format code" })
    end

    -- Don't autocmd on cursor hold, but simply map K key
    -- api.nvim_create_autocmd("CursorHold", {
    --     buffer = bufnr,
    --     callback = function()
    map("n", "<space>k", function()
            local float_opts = {
                focusable = false,
                close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
                border = "rounded",
                source = "always", -- show source in diagnostic popup window
                prefix = " ",
            }

            if not vim.b.diagnostics_pos then
                vim.b.diagnostics_pos = { nil, nil }
            end

            local cursor_pos = api.nvim_win_get_cursor(0)
            if (cursor_pos[1] ~= vim.b.diagnostics_pos[1] or cursor_pos[2] ~= vim.b.diagnostics_pos[2])
                and #diagnostic.get() > 0
            then
                diagnostic.open_float(nil, float_opts)
            end

            vim.b.diagnostics_pos = cursor_pos
        end, { desc = "show current line lsp diagontic in floating window" })
    -- })

    -- The below command will highlight the current variable and its usages in the buffer.
    -- if caps.documentHighlightProvider then
    --     vim.cmd([[
    --   hi! link LspReferenceRead Visual
    --   hi! link LspReferenceText Visual
    --   hi! link LspReferenceWrite Visual
    -- ]])

    --     local gid = api.nvim_create_augroup("lsp_document_highlight", { clear = true })
    --     api.nvim_create_autocmd("CursorHold", {
    --         group = gid,
    --         buffer = bufnr,
    --         callback = function()
    --             lsp.buf.document_highlight()
    --         end
    --     })

    --     api.nvim_create_autocmd("CursorMoved", {
    --         group = gid,
    --         buffer = bufnr,
    --         callback = function()
    --             lsp.buf.clear_references()
    --         end
    --     })
    -- end

    if vim.g.logging_level == "debug" then
        local msg = string.format("Language server %s started!", client.name)
        vim.notify(msg, vim.log.levels.DEBUG, { title = "Nvim-config" })
    end
end

local ltex_attach = function(client, bufnr)
    vim.api.nvim_create_user_command("LtexLangChangeLanguage", function(data)
        local language = data.fargs[1]
        -- local bufnr = vim.api.nvim_get_current_buf()
        -- local client = vim.lsp.get_active_clients({ bufnr = bufnr, name = 'ltex' })
        if #client == 0 then
            vim.notify("No ltex client attached")
        else
            client = client[1]
            client.config.settings = {
                ltex = {
                    language = language
                }
            }
            client.notify('workspace/didChangeConfiguration', client.config.settings)
            vim.notify("Language changed to " .. language)
        end
    end, {
    nargs = 1,
    force = true,
    })
    require("ltex_extra").setup {
        init_check = true,
        load_langs = { "en-US" },
        path = vim.fn.expand("~") .. "/.config/nvim/spell/",
    }
    return custom_attach(client, bufnr)
end


if utils.executable("pylsp") then
    local venv_path = os.getenv('VIRTUAL_ENV')
    local py_path = nil
    -- decide which python executable to use for mypy
    if venv_path ~= nil then
        py_path = venv_path .. "/bin/python3"
    else
        py_path = vim.g.python3_host_prog
    end

    vim.lsp.config('pylsp', {
        settings = {
            pylsp = {
                plugins = {
                    -- formatter options
                    black = { enabled = true , executable="black"},
                    autopep8 = { enabled = false },
                    yapf = { enabled = false },
                    -- linter options
                    pylint = { enabled = true, executable = "pylint" },
                    ruff = { enabled = false },
                    pyflakes = { enabled = false },
                    pycodestyle = { enabled = false },
                    -- type checker
                    pylsp_mypy = {
                        enabled = true,
                        overrides = { "--python-executable", py_path, true },
                        report_progress = true,
                        live_mode = false
                    },
                    -- auto-completion options
                    jedi_completion = { fuzzy = true },
                    -- import sorting
                    isort = { enabled = true },
                },
            },
        },
        flags = {
            debounce_text_changes = 200,
        },
        capabilities = capabilities,
    })
    vim.lsp.enable('pylsp')
else
    vim.notify("pylsp not found!", vim.log.levels.WARN, { title = "Nvim-config" })
end

-- if utils.executable('pyright') then
--   lspconfig.pyright.setup{
--     on_attach = custom_attach,
--     capabilities = capabilities
--   }
-- else
--   vim.notify("pyright not found!", vim.log.levels.WARN, {title = 'Nvim-config'})
-- end

if utils.executable("ltex-ls") then
    vim.lsp.config('ltex', {
        cmd = { "bash", "-c", "ltex-ls 2> >(grep -v 'no common words file' >&2)" },
        filetypes = { "tex" },
        settings = {
            ltex = {
                language = "en-US",
                additionalRules = {
                    enablePickyRules = true,
                }
                -- better yet, create a symplink from lang.utf-8.add
                -- to  ltex.dictionary.lang.txt
                -- dictionary = {
                --     ['en-US'] = {":" .. vim.fn.expand("~") .. "/.config/nvim/spell/en.utf-8.add" },
                -- },
            },  -- vim.lsp.buf_get_clients()[1].config.settings.language="fr"
        },
        flags = { debounce_text_changes = 300 },
    })
    vim.lsp.enable('ltex')
end

if utils.executable("clangd") then
    vim.lsp.config('clangd', {
        capabilities = capabilities,
        filetypes = { "c", "cpp", "cc" },
        flags = {
            debounce_text_changes = 500,
        },
    })
    vim.lsp.enable('clangd')
end

-- -- me: useless
-- if utils.executable("vim-language-server") then
--     lspconfig.vimls.setup {
--         on_attach = custom_attach,
--         flags = {
--             debounce_text_changes = 500,
--         },
--         capabilities = capabilities,
--     }
-- else
--     vim.notify("vim-language-server not found!", vim.log.levels.WARN, { title = "Nvim-config" })
-- end

-- set up bash-language-server
if utils.executable("bash-language-server") then
    vim.lsp.config('bashls', {
        capabilities = capabilities,
    })
    vim.lsp.enable('bashls')
end

if utils.executable("lua-language-server") then
    -- settings for lua-language-server can be found on https://github.com/LuaLS/lua-language-server/wiki/Settings .
    vim.lsp.config('lua_ls', {
        settings = {
            Lua = {
                runtime = {
                    -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
                    version = "LuaJIT",
                },
                diagnostics = {
                    -- Get the language server to recognize the `vim` global
                    globals = { "vim" },
                },
                workspace = {
                    -- Make the server aware of Neovim runtime files,
                    -- see also https://github.com/LuaLS/lua-language-server/wiki/Libraries#link-to-workspace .
                    -- Lua-dev.nvim also has similar settings for lua ls, https://github.com/folke/neodev.nvim/blob/main/lua/neodev/luals.lua .
                    library = {
                        fn.stdpath("data") .. "/lazy/emmylua-nvim",
                        fn.stdpath("config"),
                    },
                    maxPreload = 2000,
                    preloadFileSize = 50000,
                },
            },
        },
        capabilities = capabilities,
    })
    vim.lsp.enable('lua_ls')
end

vim.lsp.config('julials',{
    capabilities=capabilities,
    cmd = {
        "julia",
        "--project=".."~/.julia/environments/lsp/",
        "--startup-file=no",
        "--history-file=no",
        "-e", [[
            using Pkg
            Pkg.instantiate()
            using LanguageServer
        depot_path = get(ENV, "JULIA_DEPOT_PATH", "")
        project_path = let
            dirname(something(
                ## 1. Finds an explicitly set project (JULIA_PROJECT)
                Base.load_path_expand((
                    p = get(ENV, "JULIA_PROJECT", nothing);
                        p === nothing ? nothing : isempty(p) ? nothing : p
                    )),
                        ## 2. Look for a Project.toml file in the current working directory,
                        ##    or parent directories, with $HOME as an upper boundary
                        Base.current_project(),
                        ## 3. First entry in the load path
                        get(Base.load_path(), 1, nothing),
                        ## 4. Fallback to default global environment,
                        ##    this is more or less unreachable
                    Base.load_path_expand("@v#.#"),
                ))
            end
                    @info "Running language server" VERSION pwd() project_path depot_path
                    server = LanguageServer.LanguageServerInstance(stdin, stdout, project_path, depot_path)
        server.runlinter = true
            run(server)
        ]]
    },
    -- This just adds dirname(fname) as a fallback (see nvim-lspconfig#1768).
    -- root_dir = function(fname)
    --     local util = require("lspconfig.util")
    --     return util.root_pattern "Project.toml"(fname) or util.find_git_ancestor(fname) or
    --         util.path.dirname(fname)
    -- end,
    root_markers = { "Project.toml" },
    filetypes = { "julia" },
})
vim.lsp.enable('julials')

-- global config for diagnostic
diagnostic.config {
    underline = true,
    virtual_text = false,
    severity_sort = true,
    update_in_insert = false,
    signs = {
        text = {
            [diagnostic.severity.ERROR] = '🆇',
            [diagnostic.severity.WARN] = '',
            [diagnostic.severity.INFO] = '',
            [diagnostic.severity.HINT] = '',
            } },
}

lsp.handlers["textDocument/publishDiagnostics"] = lsp.with(lsp.diagnostic.on_publish_diagnostics, {
  underline = false,
  virtual_text = false,
  signs = true,
  update_in_insert = false,
})

-- Change border of documentation hover window, See https://github.com/neovim/neovim/pull/13998.
lsp.handlers["textDocument/hover"] = lsp.with(vim.lsp.handlers.hover, {
    border = "rounded",
})

-- enable each server

-- on_attach becomes an autocmd (once, globally)
vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        local bufnr = args.buf
        if not client then return end

        if client.name == 'ltex' then
           ltex_attach(client, bufnr) 
        else
            custom_attach(client, bufnr)
        end
    end,
})


