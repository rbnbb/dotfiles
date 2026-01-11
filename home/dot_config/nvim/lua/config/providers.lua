-- Python provider setup
local function setup_python_provider()
    local venv_path = vim.fn.expand("$HOME/.virtualenvs/nvim")
    local python_path = venv_path .. "/bin/python3"

    -- Check if venv already exists and works
    if vim.fn.executable(python_path) == 1 then
        vim.g.python3_host_prog = python_path
        return true
    end

    -- Check if system python3 exists at all
    if vim.fn.executable("python3") ~= 1 then
        vim.notify("Python 3 not found in PATH. Python-based plugins will not work.", vim.log.levels.ERROR)
        return false
    end

    -- Venv missing - notify and provide setup command
    vim.notify(
        "Neovim Python venv not found. Run :SetupPythonProvider to create it.",
        vim.log.levels.WARN
    )
    return false
end

-- Command to create the venv (user must explicitly run this)
vim.api.nvim_create_user_command("SetupPythonProvider", function()
    local venv_path = vim.fn.expand("$HOME/.virtualenvs/nvim")

    if vim.fn.executable("python3") ~= 1 then
        vim.notify("python3 not found in PATH", vim.log.levels.ERROR)
        return
    end

    vim.notify("Creating Python venv for Neovim...", vim.log.levels.INFO)

    -- Run setup in background
    vim.fn.jobstart({
        "sh", "-c",
        string.format(
            "mkdir -p %s && python3 -m venv %s && %s/bin/pip install --upgrade pip pynvim",
            vim.fn.shellescape(venv_path),
            vim.fn.shellescape(venv_path),
            venv_path
        )
    }, {
        on_exit = function(_, code)
            if code == 0 then
                vim.schedule(function()
                    vim.g.python3_host_prog = venv_path .. "/bin/python3"
                    vim.notify("Python provider ready. Restart Neovim to apply.", vim.log.levels.INFO)
                end)
            else
                vim.schedule(function()
                    vim.notify("Failed to create Python venv. Check :messages", vim.log.levels.ERROR)
                end)
            end
        end,
        on_stderr = function(_, data)
            if data and data[1] ~= "" then
                vim.schedule(function()
                    vim.notify(table.concat(data, "\n"), vim.log.levels.WARN)
                end)
            end
        end,
    })
end, { desc = "Create Python virtualenv for Neovim" })

setup_python_provider()
