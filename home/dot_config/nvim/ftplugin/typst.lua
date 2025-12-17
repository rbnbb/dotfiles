-- DEPRACATE my ad-hoc compiler in favor of chomosuke/typst-preview ✨
-- use \ll to start compiling file and launch os viewer
-- local map = vim.keymap.set
-- local uname = vim.loop.os_uname()
-- local pdf_app = "exit"
-- if uname.sysname == 'Darwin' then
--     pdf_app = "open -a sioyek"  -- Skim.app"  -- old app
-- else
--     pdf_app = "okular"
-- end

-- Map it
-- vim.api.nvim_set_keymap('n', '<leader>p', ':lua start_pdf_viewer()<CR>', { noremap = true, silent = true })

-- local start_typst_compiler = ":AsyncStop <CR>:AsyncRun typst watch % <CR>"
-- map("n", "\\ll", start_typst_compiler)
-- map("n", "\\lv", function()
--   local pdf_file = vim.fn.expand('%:r') .. '.pdf'
--   vim.fn.jobstart({'sh', '-c', pdf_app .. ' ' .. pdf_file})
-- end, {noremap=true, silent=false})

-- Function to parse and replace arXiv IDs with Typst links
local function arxiv_to_typst_link()
  -- Get the current line
  local line = vim.api.nvim_get_current_line()
  
  -- Regex pattern to match arXiv URLs like https://arxiv.org/abs/xxxx.xxxxx[vn]
  local pattern = "https?://arxiv%.org/abs/(%d%d%d%d%.%d%d%d%d%d[v%d]?)"
  
  -- Replace matches with Typst link format
  local replaced_line = line:gsub(pattern, function(id)
    return string.format('#link("%s")[%s]', "https://arxiv.org/abs/" .. id, id)
  end)
  
  -- Update the current line if there was a change
  if replaced_line ~= line then
    vim.api.nvim_set_current_line(replaced_line)
  end
end

-- Keymapping: Map <leader>al to call the function
vim.keymap.set('n', '<leader>al', arxiv_to_typst_link, { noremap = true, silent = true, desc = 'Convert arXiv URL to Typst link' })

-- apply basic ~/wiki/.typst-template if necessary
local function tables_are_equal(t1, t2)
    -- Check if both tables are the same size
    if #t1 ~= #t2 then
        return false
    end

    -- Compare elements one by one
    for i = 1, #t1 do
        if t1[i] ~= t2[i] then
            return false
        end
    end

    return true
end

local function maybe_apply_typst_template()
    local bufnr = vim.api.nvim_get_current_buf()
    local filepath = vim.api.nvim_buf_get_name(bufnr)
    local wikidir = vim.loop.os_homedir() .. "/wiki"
    if string.match(filepath, wikidir) == nil then
        return nil -- use template only in ~/wiki
    end
    local nbeg = 0
    local template = io.open(wikidir .. "/.typst-template", "r")
    if template == nil then return nil end
    local raw_template = template:read("*a")
    local lines_template = {}
    for line in raw_template:gmatch("([^\n]+)") do
        table.insert(lines_template, line)
    end
    local lines_buf = vim.api.nvim_buf_get_lines(bufnr, nbeg, nbeg + #lines_template, false)
    if tables_are_equal(lines_buf, lines_template) then
        return nil                                                       -- nothing to do, template is applied already
    end
    vim.api.nvim_buf_set_lines(bufnr, nbeg, nbeg, false, lines_template) -- apply template
end

maybe_apply_typst_template()

-- ============================================================================
-- IMAGE DRAG & DROP HANDLER FOR TYPST
-- Intercepts pasted image paths and converts them to Typst figure snippets
-- Copies images to ./figures/ directory and inserts proper Typst syntax
-- ============================================================================

if not vim.b.typst_drop_fig_loaded then
  vim.b.typst_drop_fig_loaded = true

  local FIG_DIR = "figures"

  -- Store original paste function
  local orig_paste = vim.paste or function(lines, phase) 
    return false 
  end

  -- Override paste for this buffer
  vim.paste = function(lines, phase)
    -- Only intercept in typst buffers
    if vim.bo.filetype ~= "typst" then
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
          
          -- print("[typst_drop_fig] Image path detected in paste: " .. line)
          
          -- Get current file directory and create figures dir
          local current = vim.api.nvim_buf_get_name(0)
          local base_dir = vim.fn.fnamemodify(current, ":h")
          local fig_dir = base_dir .. "/" .. FIG_DIR
          vim.fn.mkdir(fig_dir, "p")
          
          -- Copy file
          local src = vim.fn.expand(line:gsub("^%s+", ""):gsub("%s+$", ""))
          local fname = vim.fn.fnamemodify(src, ":t")
          local dest = fig_dir .. "/" .. fname
          
          if vim.fn.filereadable(src) == 1 then
            local success = pcall(function()
              local data = assert(io.open(src, "rb")):read("*all")
              assert(io.open(dest, "wb")):write(data)
            end)
            
            if success then
              -- Generate Typst snippet
              local relpath = "./" .. FIG_DIR .. "/" .. fname
              local label = fname:gsub("[^%w_%-]", "_"):gsub("%.[^.]+$", "")
              
              local snippet = string.format(
[[#figure(
  image("%s", width: 80%%),
  caption: [-describe figure-]
) <%s>]], relpath, label)
              
              -- Insert snippet instead of path
              local snippet_lines = vim.split(snippet, "\n")
              local start_row = vim.api.nvim_win_get_cursor(0)[1]
              
              vim.api.nvim_put(snippet_lines, "l", true, true)
              
              -- print("[typst_drop_fig] Inserted Typst snippet")
              
              -- Find and position cursor on the caption line
              vim.schedule(function()
                -- Safety check: ensure start_row is valid
                if not start_row then
                  print("[typst_drop_fig] Warning: Could not determine start position")
                  return
                end
                
                for i, l in ipairs(snippet_lines) do
                  if l:match("-describe figure-") then
                    local target_row = start_row + i - 1
                    local col_start = l:find("<")
                    if col_start then
                      col_start = col_start - 1
                      -- Verify the target row is valid
                      local line_count = vim.api.nvim_buf_line_count(0)
                      if target_row <= line_count then
                        vim.api.nvim_win_set_cursor(0, {target_row, col_start})
                        
                        -- Select the placeholder text in visual mode
                        vim.cmd("normal! v" .. (#"-describe figure-" - 1) .. "l")
                      end
                    end
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
end
