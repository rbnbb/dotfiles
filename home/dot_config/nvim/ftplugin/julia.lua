vim.bo.cindent = false
vim.bo.smartindent = false
vim.bo.indentexpr = ''

vim.api.nvim_create_user_command("Enumerify", function()
  local line_num = vim.api.nvim_win_get_cursor(0)[1]
  local line = vim.api.nvim_buf_get_lines(0, line_num - 1, line_num, false)[1]

  local new_line = line:gsub(
    [[^(%s*)for%s+([%a_][%w_]*)%s+in%s+(.+)]],
    function(indent, var, iter)
      return string.format("%sfor (j, %s) in enumerate(%s)", indent, var, iter)
    end
  )

  if new_line == line then
    vim.notify("No `for <var> in <iter>` pattern found on this line.", vim.log.levels.INFO)
  else
    vim.api.nvim_buf_set_lines(0, line_num - 1, line_num, false, { new_line })
    vim.notify("Enumerified!", vim.log.levels.INFO)
  end
end, { desc = "Replace Julia `for x in ...` with `for (j, x) in enumerate(...)`" })

