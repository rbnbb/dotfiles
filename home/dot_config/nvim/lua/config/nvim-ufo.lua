local ufo = require("ufo")

local handler = function(virtText, lnum, endLnum, width, truncate)
    local newVirtText = {}
    local suffix = (' 󰁂 %d '):format(endLnum - lnum)
    local sufWidth = vim.fn.strdisplaywidth(suffix)
    local targetWidth = width - sufWidth
    local curWidth = 0
    for _, chunk in ipairs(virtText) do
        local chunkText = chunk[1]
        local chunkWidth = vim.fn.strdisplaywidth(chunkText)
        if targetWidth > curWidth + chunkWidth then
            table.insert(newVirtText, chunk)
        else
            chunkText = truncate(chunkText, targetWidth - curWidth)
            local hlGroup = chunk[2]
            table.insert(newVirtText, {chunkText, hlGroup})
            chunkWidth = vim.fn.strdisplaywidth(chunkText)
            -- str width returned from truncate() may less than 2nd argument, need padding
            if curWidth + chunkWidth < targetWidth then
                suffix = suffix .. (' '):rep(targetWidth - curWidth - chunkWidth)
            end
            break
        end
        curWidth = curWidth + chunkWidth
    end
    table.insert(newVirtText, {suffix, 'MoreMsg'})
    return newVirtText
end

local handler_with_juliadoc = function(virtText, lnum, endLnum, width, truncate)
  local newVirtText = {}
  local suffix = (' 󰁂 %d '):format(endLnum - lnum)
  local sufWidth = vim.fn.strdisplaywidth(suffix)
  local targetWidth = width - sufWidth
  local curWidth = 0

  -- Check if this is a Julia docstring fold
  local bufnr = vim.api.nvim_get_current_buf()
  local filetype = vim.bo[bufnr].filetype
  local firstLine = vim.api.nvim_buf_get_lines(bufnr, lnum - 1, lnum, false)[1] or ""

  if filetype == "julia" and firstLine:match('^%s*"""') then
      -- Julia docstring: show first line of documentation content (not function signature)
      -- Get the second line of the fold (first line after opening """)
      local docLine = vim.api.nvim_buf_get_lines(bufnr, lnum, lnum + 1, false)[1]

      if docLine and docLine:match("%S") then  -- Has non-whitespace content
          local trimmed = docLine:gsub("^%s+", ""):gsub("%s+$", "")
          -- Only use it if it's not a closing """ and has actual content
          if trimmed ~= '"""' and trimmed ~= "" then
              local displayText = '""" ' .. trimmed
              local chunkText = truncate(displayText, targetWidth)
              table.insert(newVirtText, {chunkText, 'Comment'})
              table.insert(newVirtText, {suffix, 'MoreMsg'})
              return newVirtText
          end
      end
  end

  -- Default behavior for non-docstring folds
  for _, chunk in ipairs(virtText) do
      local chunkText = chunk[1]
      local chunkWidth = vim.fn.strdisplaywidth(chunkText)
      if targetWidth > curWidth + chunkWidth then
          table.insert(newVirtText, chunk)
      else
          chunkText = truncate(chunkText, targetWidth - curWidth)
          local hlGroup = chunk[2]
          table.insert(newVirtText, {chunkText, hlGroup})
          chunkWidth = vim.fn.strdisplaywidth(chunkText)
          if curWidth + chunkWidth < targetWidth then
              suffix = suffix .. (' '):rep(targetWidth - curWidth - chunkWidth)
          end
          break
      end
      curWidth = curWidth + chunkWidth
  end
  table.insert(newVirtText, {suffix, 'MoreMsg'})
  return newVirtText
end


-- Custom fold provider for Julia that extends docstring folds
local function julia_fold_provider(bufnr)
    local ok, ufo_provider = pcall(require, 'ufo.provider.treesitter')
    if not ok then
        return nil
    end

    -- Get treesitter folds
    local ranges = ufo_provider.getFolds(bufnr)
    if not ranges then
        return nil
    end

    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    local extended_ranges = {}

    for _, range in ipairs(ranges) do
        local start_line = range.startLine + 1  -- Convert to 1-indexed
        local end_line = range.endLine + 1

        -- Check if this fold starts with """
        if lines[start_line] and lines[start_line]:match('^%s*"""') then
            -- Check if the next line after fold is the closing """
            if lines[end_line + 1] and lines[end_line + 1]:match('^%s*"""%s*$') then
                -- Extend fold to include closing """
                end_line = end_line + 1
            end
        end

        -- Convert back to 0-indexed and add to results
        table.insert(extended_ranges, {
            startLine = start_line - 1,
            endLine = end_line - 1
        })
    end

    return extended_ranges
end

ufo.setup({
    provider_selector = function(bufnr, filetype, buftype)
        if filetype == 'tex' then
            return ''  -- Disable ufo for tex files
        end
        if filetype == 'julia' then
            return julia_fold_provider
        end
        return {'treesitter', 'indent'}
    end,
    fold_virt_text_handler = handler_with_juliadoc,
    open_fold_hl_timeout = 100,
})

vim.keymap.set('n', 'zR', ufo.openAllFolds)
vim.keymap.set('n', 'zM', ufo.closeAllFolds)
vim.keymap.set('n', 'zr', ufo.openFoldsExceptKinds)
vim.keymap.set('n', 'zm', ufo.closeFoldsWith) -- closeAllFolds == closeFoldsWith(0)
vim.keymap.set('n', 'K', function()
    local winid = ufo.peekFoldedLinesUnderCursor()
    if not winid then
        vim.lsp.buf.hover()
    end
end)
vim.api.nvim_create_user_command("UfoRebirth", function()  -- don't ask!
    vim.cmd("UfoDisable")
    vim.cmd("setlocal foldlevel=99")
    vim.cmd("set foldmethod=syntax")
    vim.cmd("set foldmethod=manual")
    vim.cmd("UfoEnable")
end, {})
