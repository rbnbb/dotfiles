local uname = vim.loop.os_uname()

local img_app = "exit"
if uname.sysname == 'Darwin' then
    img_app = "open -a Preview"
else
    img_app = "imv"
end

local map = vim.keymap.set

local in_fn = vim.fn.expand("%")
local out_fn = vim.fn.expand("%:r")


local mmdc_cmd = "'mmdc -i " .. in_fn .. " -o " .. out_fn .. ".png --scale 4'"
local start_mermaid_compiler = ":AsyncStop <CR>:AsyncRun echo %|entr -n sh -c " .. mmdc_cmd ..  " <CR>"

local start_viewer =  ":let prev_buf = bufnr('%') | " ..
    "call jobstart(['sh', '-c', 'sleep 0.5 && " ..
    img_app .. " " .. out_fn .. ".png']) | " ..
    ":execute 'buffer' prev_buf <CR><CR>"

map("n", "\\ll", start_mermaid_compiler)
map("n", "\\lv", start_viewer)
