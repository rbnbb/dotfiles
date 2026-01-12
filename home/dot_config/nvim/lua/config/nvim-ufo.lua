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

  -- Check for both regular """ and raw""" docstrings
  local is_raw_docstring = firstLine:match('^%s*raw"""')
  local is_regular_docstring = not is_raw_docstring and firstLine:match('^%s*"""')

  if filetype == "julia" and (is_regular_docstring or is_raw_docstring) then
      -- Julia docstring: show first line of documentation content (not function signature)
      -- Get the second line of the fold (first line after opening """ or raw""")
      local docLine = vim.api.nvim_buf_get_lines(bufnr, lnum, lnum + 1, false)[1]

      if docLine and docLine:match("%S") then  -- Has non-whitespace content
          local trimmed = docLine:gsub("^%s+", ""):gsub("%s+$", "")
          -- Only use it if it's not a closing """ and has actual content
          if trimmed ~= '"""' and trimmed ~= "" then
              local prefix = is_raw_docstring and 'raw""" ' or '""" '
              local displayText = prefix .. trimmed
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


-- Custom fold provider for Julia that extends docstring folds and handles raw"""
local function julia_fold_provider(bufnr)
    local ok, ufo_provider = pcall(require, 'ufo.provider.treesitter')
    if not ok then
        return nil
    end

    -- Get treesitter folds
    local ranges = ufo_provider.getFolds(bufnr)
    if not ranges then
        ranges = {}
    end

    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    local extended_ranges = {}

    -- Track which lines are already covered by treesitter folds
    local covered_lines = {}
    for _, range in ipairs(ranges) do
        for line = range.startLine, range.endLine do
            covered_lines[line] = true
        end
    end

    -- First, extend existing treesitter folds for regular """ docstrings
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

    -- Now find and add folds for raw""" docstrings that treesitter missed
    for i, line in ipairs(lines) do
        if line:match('^%s*raw"""') and not covered_lines[i - 1] then  -- i is 1-indexed, covered_lines is 0-indexed
            -- Found a raw""" docstring, find its closing """
            local start_idx = i
            local end_idx = nil

            for j = i + 1, #lines do
                if lines[j]:match('^%s*"""%s*$') then
                    end_idx = j
                    break
                end
            end

            if end_idx then
                -- Create fold from raw""" to closing """
                table.insert(extended_ranges, {
                    startLine = start_idx - 1,  -- Convert to 0-indexed
                    endLine = end_idx - 1
                })
                -- Mark these lines as covered so we don't double-fold
                for line_num = start_idx - 1, end_idx - 1 do
                    covered_lines[line_num] = true
                end
            end
        end
    end

    -- Sort ranges by start line
    table.sort(extended_ranges, function(a, b)
        return a.startLine < b.startLine
    end)

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
