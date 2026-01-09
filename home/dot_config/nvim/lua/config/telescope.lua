local builtin = require('telescope.builtin')
local actions = require('telescope.actions')

vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})

require('telescope').setup{
    defaults = {
        mappings = {
            i = {
                ["<A-q>"] = function(prompt_bufnr)
                    actions.send_selected_to_qflist(prompt_bufnr)
                    actions.open_qflist(prompt_bufnr)
                end,
                ["<M-q>"] = false, -- disables the default mapping
            }
        }
    }
}
