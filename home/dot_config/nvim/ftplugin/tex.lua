-- Alternative ftplugin/tex.lua using vim.paste override
-- This intercepts paste events directly

if vim.b.tex_drop_fig_loaded then
  return
end
vim.b.tex_drop_fig_loaded = true

-- Store original paste function
local orig_paste = vim.paste or function(lines, phase) 
  return false 
end

-- Override paste for this buffer
vim.paste = function(lines, phase)
  -- Only intercept in tex buffers
  if vim.bo.filetype ~= "tex" then
    return orig_paste(lines, phase)
  end
  
  -- Check if paste contains a single image path
  if phase == 1 or phase == -1 then  -- Start or single-phase paste
    if #lines == 1 then
      local line = lines[1]
      -- Check if it looks like an image path
      if line:match("%.[pP][nN][gG]$") or 
         line:match("%.[pP][dD][fF]$") or 
         line:match("%.[jJ][pP][eE]?[gG]$") or 
         line:match("%.[eE][pP][sS]$") or
         line:match("%.[sS][vV][gG]$") then
        
        -- print("[tex_drop_fig] Image path detected in paste: " .. line)
        
        -- Process the image path
        local current = vim.api.nvim_buf_get_name(0)
        local base_dir = vim.fn.fnamemodify(current, ":h")
        local fig_dir = base_dir .. "/figures"
        vim.fn.mkdir(fig_dir, "p")
        
        -- Copy file
        local src = vim.fn.expand(line:gsub("^%s+", ""):gsub("%s+$", ""))
        local fname = vim.fn.fnamemodify(src, ":t")
        local dest = fig_dir .. "/" .. fname
        
        if vim.fn.filereadable(src) == 1 then
          local cp_result = vim.fn.system({"cp", "-f", src, dest})
          local success = vim.v.shell_error == 0
          
          if success then
            -- Generate snippet
            local relpath = "./figures/" .. fname
            local label = "fig:" .. fname:gsub("[^%w_%-]", "_"):gsub("%.[^.]+$", "")
            local snippet = string.format(
              [[\begin{figure}[H]
  \centering
  \includegraphics[width=0.8\textwidth]{%s}
  \caption{<describe figure>}
  \label{%s}
\end{figure}]], relpath, label)
            
            -- Insert snippet instead of path
            local snippet_lines = vim.split(snippet, "\n")
            local start_row = vim.api.nvim_win_get_cursor(0)[1]
            
            vim.api.nvim_put(snippet_lines, "l", true, true)
            
            -- print("[tex_drop_fig] Inserted LaTeX snippet")
            
            -- Find and position cursor on the caption line
            vim.schedule(function()
              for i, line in ipairs(snippet_lines) do
                if line:match("<describe figure>") then
                  local target_row = start_row + i
                  local col_start = line:find("<") - 1
                  vim.api.nvim_win_set_cursor(0, {target_row, col_start})
                  
                  -- Select the placeholder text in visual mode
                  vim.cmd("normal! v" .. (#"<describe figure>" - 1) .. "l")
                  break
                end
              end
            end)
            
            -- Don't call original paste - we handled it
            return true
          end
        end
      end
    end
  end
  
  -- Fall back to original paste
  return orig_paste(lines, phase)
end

-- Restore original paste when buffer is unloaded
vim.api.nvim_create_autocmd("BufUnload", {
  buffer = 0,
  callback = function()
    vim.paste = orig_paste
  end,
})
