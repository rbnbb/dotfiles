-- Python provider setup
local function setup_python_provider()
    local venv_path = vim.fn.expand("$HOME/.virtualenvs/nvim")  -- chezmoi script creates it
    local python_path = venv_path .. "/bin/python3"

    -- Check if venv already exists and works
    if vim.fn.executable(python_path) == 1 then
        vim.g.python3_host_prog = python_path
        vim.opt.path:append(venv_path .. "/bin")
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

setup_python_provider()
