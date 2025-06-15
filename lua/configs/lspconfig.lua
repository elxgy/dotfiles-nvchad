require("nvchad.configs.lspconfig").defaults()
local lspconfig = require("lspconfig")

-- Function to auto-detect Python path from virtual environment
local function get_python_path()
  -- Check for VIRTUAL_ENV environment variable (venv/virtualenv)
  local venv = os.getenv("VIRTUAL_ENV")
  if venv then
    return venv .. "/bin/python"
  end
  
  -- Check for CONDA_PREFIX (conda environment)
  local conda_env = os.getenv("CONDA_PREFIX")
  if conda_env then
    return conda_env .. "/bin/python"
  end
  
  -- Check for local venv directory in project root
  local cwd = vim.fn.getcwd()
  local local_venv = cwd .. "/venv/bin/python"
  if vim.fn.executable(local_venv) == 1 then
    return local_venv
  end
  
  -- Check for .venv directory (common alternative)
  local local_dot_venv = cwd .. "/.venv/bin/python"
  if vim.fn.executable(local_dot_venv) == 1 then
    return local_dot_venv
  end
  
  -- Check for env directory
  local env_dir = cwd .. "/env/bin/python"
  if vim.fn.executable(env_dir) == 1 then
    return env_dir
  end
  
  -- Fallback to system python
  return vim.fn.exepath("python3") or vim.fn.exepath("python") or "python"
end

-- Simple servers that don't need custom config
local servers = { "html", "cssls" }
vim.lsp.enable(servers)

-- Go LSP with custom configuration
lspconfig.gopls.setup({
  cmd = {"gopls"},
  filetypes = { "go", "gomod", "gowork", "gotmpl" },
  root_dir = lspconfig.util.root_pattern("go.work", "go.mod", ".git"),
  settings = {
    gopls = {
      completeUnimported = true,
      usePlaceholders = true,
      analyses = {
        unusedparams = true,
        shadow = true,
        nilness = true,
        unusedwrite = true,
        useany = true,
      },
      staticcheck = true,
      gofumpt = true,
      codelenses = {
        gc_details = false,
        generate = true,
        regenerate_cgo = true,
        run_govulncheck = true,
        test = true,
        tidy = true,
        upgrade_dependency = true,
        vendor = true,
      },
      hints = {
        assignVariableTypes = true,
        compositeLiteralFields = true,
        compositeLiteralTypes = true,
        constantValues = true,
        functionTypeParameters = true,
        parameterNames = true,
        rangeVariableTypes = true,
      },
    },
  },
})

-- Python LSP with auto-detected virtual environment
lspconfig.pyright.setup({
  settings = {
    python = {
      pythonPath = get_python_path(),
      analysis = {
        autoSearchPaths = true,
        diagnosticMode = "workspace",
        useLibraryCodeForTypes = true,
        typeCheckingMode = "basic",
        autoImportCompletions = true,
      }
    }
  }
})

-- Optional: Print detected Python path for debugging
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and client.name == "pyright" then
      local python_path = get_python_path()
      print("Pyright using Python: " .. python_path)
    end
  end,
})
