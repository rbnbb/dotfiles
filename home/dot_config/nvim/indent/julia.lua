-- Prevent $VIMRUNTIME/indent/julia.vim from loading (its GetJuliaIndent()
-- mishandles semicolons, nested calls, comprehensions — typing ) ] } on
-- such lines causes spurious re-indent).
vim.b.did_indent = 1

vim.bo.indentexpr = ''
vim.bo.indentkeys = ''
vim.bo.autoindent = true

vim.b.undo_indent = 'setlocal indentexpr< indentkeys< autoindent<'
