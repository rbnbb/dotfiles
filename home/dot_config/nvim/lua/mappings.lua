local map = vim.keymap.set

map("n", " ", "<Nop>", { silent = true, remap = false })
vim.g.mapleader = " "

map({ "n", "x", "v" }, ";", ":") -- enter command mode without Shift
map({ "n", "x", "v" }, ":", ";") -- enter command mode without Shift
-- j and k for visible lines
local expr_opts = { noremap = true, silent = true, expr = true }
map("n", "j", "v:count == 0 ? 'gj' : 'j'", expr_opts)
map("n", "k", "v:count == 0 ? 'gk' : 'k'", expr_opts)
map("n", "gj", "j", { noremap = true, silent = true })
map("n", "gk", "k", { noremap = true, silent = true })
-- ensure ~ works as expected
map("n", "~", "g~l")

-- map("i", "<Esc>", "<Esc><Esc><Esc>")

map("i", "<c-d>", "<BS>")            -- ctrl d for backspace is easier
map("n", "<C-l>", "ma[s1z=`a")       -- autocorrect spelling normal mode
map("i", "<C-l>", "<Esc>ma[s1z=`ai") -- autocorrect spelling insert mode

-- highlight column limit
map("n", "\\cs", ":set colorcolumn=92<CR>")
map("n", "\\ch", ":set colorcolumn=<CR>")


map("n", "<leader>q", ":bp<bar>sp<bar>bn<bar>bd<CR>")
map("n", "<leader><leader>", ":nohlsearch<Bar>:echo<CR>")
map("n", "<leader>p", "\"+p")
map("v", "<leader>y", "\"+y")

-- adjust vertical spacing of windows
map("n", "g=", ":4wincmd + <CR>")
map("n", "g-", ":4wincmd - <CR>")
-- adjust horizontal spacing of windows
map("n", "g,", ":4wincmd > <CR>")
map("n", "g.", ":4wincmd < <CR>")


-- -- Shortcut for faster save and quit
map("n", "<leader>j", "<cmd>update<cr>", { silent = true, desc = "save buffer" })

-- -- Navigation in the location and quickfix list
map("n", "[l", "<cmd>lprevious<cr>zv", { silent = true, desc = "previous location item" })
map("n", "]l", "<cmd>lnext<cr>zv", { silent = true, desc = "next location item" })

map("n", "[L", "<cmd>lfirst<cr>zv", { silent = true, desc = "first location item" })
map("n", "]L", "<cmd>llast<cr>zv", { silent = true, desc = "last location item" })

map("n", "[q", "<cmd>cprevious<cr>zv", { silent = true, desc = "previous qf item" })
map("n", "]q", "<cmd>cnext<cr>zv", { silent = true, desc = "next qf item" })

map("n", "[Q", "<cmd>cfirst<cr>zv", { silent = true, desc = "first qf item" })
map("n", "]Q", "<cmd>clast<cr>zv", { silent = true, desc = "last qf item" })

-- Close location list or quickfix list if they are present, see https://superuser.com/q/355325/736190
map("n", [[\x]], "<cmd>windo lclose <bar> cclose <cr>", {
    silent = true,
    desc = "close qf and location list",
})

-- Close all windows but current, call only
map("n", [[\o]], "<cmd>only<cr>", {
    silent = true,
    desc = "close all other windows",
})

-- Delete a buffer, without closing the window, see https://stackoverflow.com/q/4465095/6064933
map("n", [[,d]], "<cmd>bprevious <bar> bdelete #<cr>", {
    silent = true,
    desc = "delete buffer",
})

-- -- Insert a blank line below or above current line (do not move the cursor),
-- see https://stackoverflow.com/a/16136133/6064933
map("n", "<space>o", "printf('m`%so<ESC>``', v:count1)", {
    expr = true,
    desc = "insert line below",
})

map("n", "<space>O", "printf('m`%sO<ESC>``', v:count1)", {
    expr = true,
    desc = "insert line above",
})

-- -- Do not include white space characters when using $ in visual mode,
-- -- see https://vi.stackexchange.com/q/12607/15292
map("x", "$", "g_")

-- -- Edit and reload nvim config file quickly
map("n", "<leader>sv", function()
    vim.cmd([[
      update $MYVIMRC
      source $MYVIMRC
    ]])
    vim.notify("Nvim config successfully reloaded!", vim.log.levels.INFO, { title = "nvim-config" })
end, {
    silent = true,
    desc = "reload init.lua",
})

-- Reselect the text that has just been pasted, see also https://stackoverflow.com/a/4317090/6064933.
map("n", "<leader>v", "printf('`[%s`]', getregtype()[0])", {
    expr = true,
    desc = "reselect last pasted area",
})

-- I use Ctrl+v to paste in kitty for conformity, this breaks visual mode
map("n", "<A-v>", "<C-v>")

-- -- Always use very magic mode for searching
-- map("n", "/", [[/\v]])

-- -- Search in selected region
-- -- xnoremap / :<C-U>call feedkeys('/\%>'.(line("'<")-1).'l\%<'.(line("'>")+1)."l")<CR>

-- -- Change current working directory locally and print cwd after that,
-- -- see https://vim.fandom.com/wiki/Set_working_directory_to_the_current_file
-- map("n", "<leader>cd", "<cmd>lcd %:p:h<cr><cmd>pwd<cr>", { desc = "change cwd" })

-- -- Use Esc to quit builtin terminal
map("t", "<Esc>", [[<c-\><c-n>]])

-- -- Toggle spell checking
map("n", "<F11>", "<cmd>set spell!<cr>", { desc = "toggle spell" })
map("i", "<F11>", "<c-o><cmd>set spell!<cr>", { desc = "toggle spell" })

-- Change text without putting it into the vim register,
-- see https://stackoverflow.com/q/54255/6064933
map("n", "c", '"_c')
map("n", "C", '"_C')
map("n", "cc", '"_cc')
map("x", "c", '"_c')

-- personal paranthesis stuff
local function replace_parentheses(open_par, close_par)
    return function()
        local _, col = unpack(vim.api.nvim_win_get_cursor(0)) -- Get current cursor position
        local line = vim.api.nvim_get_current_line()          -- Get the current line content
        local char = line:sub(col + 1, col + 1)               -- Get the character under the cursor
        if char == "(" or char == "{" or char == "[" then
            vim.api.nvim_command("normal! %r" .. close_par .. "``r" .. open_par)
        elseif char == ")" or char == "}" or char == "]" then
            vim.api.nvim_command("normal! %r" .. open_par .. "``r" .. close_par)
        end
    end
end
map("n", "dsd", "%x``x") --  delete paranthesis using matchit
map("n", "cs(", replace_parentheses("(", ")"))
map("n", "cs[", replace_parentheses("[", "]"))
map("n", "cs{", replace_parentheses("{", "}"))
map("n", "ds%", "V<Plug>(matchup-%)<Esc>`<ddmm`>ddkV'm<") --  delete if block using matchit




-- -- check the syntax group of current cursor position
-- map("n", "<leader>st", "<cmd>call utils#SynGroup()<cr>", { desc = "check syntax group" })

-- -- Copy entire buffer.
-- map("n", "<leader>y", "<cmd>%yank<cr>", { desc = "yank entire buffer" })

-- -- Toggle cursor column
-- map("n", "<leader>cl", "<cmd>call utils#ToggleCursorCol()<cr>", { desc = "toggle cursor column" })

-- -- Move current line up and down
-- map("n", "<A-k>", '<cmd>call utils#SwitchLine(line("."), "up")<cr>', { desc = "move line up" })
-- map("n", "<A-j>", '<cmd>call utils#SwitchLine(line("."), "down")<cr>', { desc = "move line down" })

-- -- Move current visual-line selection up and down
-- map("x", "<A-k>", '<cmd>call utils#MoveSelection("up")<cr>', { desc = "move selection up" })

-- map("x", "<A-j>", '<cmd>call utils#MoveSelection("down")<cr>', { desc = "move selection down" })

-- -- Replace visual selection with text in register, but not contaminate the register,
-- -- see also https://stackoverflow.com/q/10723700/6064933.
-- map("x", "p", '"_c<Esc>p')

-- -- Go to a certain buffer
-- map("n", "gb", '<cmd>call buf_utils#GoToBuffer(v:count, "forward")<cr>', {
--   desc = "go to buffer (forward)",
-- })
-- map("n", "gB", '<cmd>call buf_utils#GoToBuffer(v:count, "backward")<cr>', {
--   desc = "go to buffer (backward)",
-- })

-- -- Switch windows
-- map("n", "<left>", "<c-w>h")
-- map("n", "<Right>", "<C-W>l")
-- map("n", "<Up>", "<C-W>k")
-- map("n", "<Down>", "<C-W>j")

-- -- Text objects for URL
-- map({ "x", "o" }, "iu", "<cmd>call text_obj#URL()<cr>", { desc = "URL text object" })

-- -- Text objects for entire buffer
-- map({ "x", "o" }, "iB", ":<C-U>call text_obj#Buffer()<cr>", { desc = "buffer text object" })

-- Do not move my cursor when joining lines.
map("n", "J", function()
    vim.cmd([[
      normal! mzJ`z
      delmarks z
    ]])
end, {
    desc = "join lines without moving cursor",
})

-- map("n", "gJ", function()
--   -- we must use `normal!`, otherwise it will trigger recursive mapping
--   vim.cmd([[
--       normal! mzgJ`z
--       delmarks z
--     ]])
-- end, {
--   desc = "join lines without moving cursor",
-- })

-- -- Break inserted text into smaller undo units when we insert some punctuation chars.
-- local undo_ch = { ",", ".", "!", "?", ";", ":" }
-- for _, ch in ipairs(undo_ch) do
--   keymap.set("i", ch, ch .. "<c-g>u")
-- end

-- -- insert semicolon in the end
-- map("i", "<A-;>", "<Esc>miA;<Esc>`ii")

-- -- Go to the beginning and end of current line in insert mode quickly
-- map("i", "<C-A>", "<HOME>")
-- map("i", "<C-E>", "<END>")

-- -- Go to beginning of command in command-line mode
-- map("c", "<C-A>", "<HOME>")

-- -- Delete the character to the right of the cursor
-- map("i", "<C-D>", "<DEL>")

-- map("n", "<leader>cb", function()
--   local cnt = 0
--   local blink_times = 7
--   local timer = uv.new_timer()

--   timer:start(0, 100, vim.schedule_wrap(function()
--     vim.cmd[[
--       set cursorcolumn!
--       set cursorline!
--     ]]

--     if cnt == blink_times then
--       timer:close()
--     end

--     cnt = cnt + 1
--   end))
-- end)
