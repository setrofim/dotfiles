-- The following re-definition is to suppress undefined-global warnings just for "vim" throughout the file
---@diagnostic disable-next-line: undefined-global
local vim = vim
local dap = require('dap')
local dapui = require('dapui')

dapui.setup({
  layouts = {
    {
      elements = {
        -- Elements can be strings or table with id and size keys.
        "stacks",
        "watches",
        "breakpoints",
      },
      size = 40, -- 40 columns
      position = "left",
    },
    {
      elements = {
        "repl",
        "console",
        "scopes",
      },
      size = 0.25, -- 25% of total lines
      position = "bottom",
    },
  },
  controls = {
    enabled = true,
    element = "repl",
    icons = {
      pause = "",
      play = "",
      step_into = "",
      step_over = "",
      step_out = "",
      step_back = "",
      run_last = "",
      terminate = "",
    },
  },
  floating = {
    max_height = nil, -- These can be integers or a float between 0 and 1.
    max_width = nil, -- Floats will be treated as percentage of your screen.
    border = "single", -- Border style. Can be "single", "double" or "rounded"
    mappings = {
      close = { "q", "<Esc>" },
    },
  },
  windows = { indent = 1 },
  render = {
    max_type_length = nil, -- Can be integer or nil.
    max_value_lines = 100, -- Can be integer or nil.
  }
})

dap.listeners.after.event_initialized["dapui_config"]=function() dapui.open() end
-- do not close automatically so that I can examine console output
--dap.listeners.before.event_terminated["dapui_config"]=function() dapui.close() end
--dap.listeners.before.event_exited["dapui_config"]=function() dapui.close() end
vim.keymap.set('n', '<leader>do', require 'dapui'.open, { desc = 'open debugger UI' })
vim.keymap.set('n', '<leader>dc', require 'dapui'.close, { desc = 'close debugger UI' })

vim.fn.sign_define('DapBreakpoint',{ text ='🔴', texthl ='', linehl ='', numhl =''})

vim.keymap.set('n', '<leader>dg', require 'dap'.continue, { desc = 'continue debugger' })
vim.keymap.set('n', '<leader>dt', require 'dap'.terminate, { desc = 'terminate debugger' })
vim.keymap.set('n', '<leader>dn', require 'dap'.step_over, { desc = 'debugger step over' })
vim.keymap.set('n', '<leader>di', require 'dap'.step_into, { desc = 'debugger step into' })
vim.keymap.set('n', '<leader>dO', require 'dap'.step_out, { desc = 'debugger step out' })
vim.keymap.set('n', '<leader>db', require 'dap'.toggle_breakpoint, { desc = 'toggle breakpoint' })
vim.keymap.set('n', '<leader>dC', require 'dap'.clear_breakpoints, { desc = 'clear breakpoints' })

-- legacy non <leader>d alternatives
vim.keymap.set('n', '<F5>', require 'dap'.continue, { desc = 'continue debugger' })
vim.keymap.set('n', '<F6>', require 'dap'.terminate, { desc = 'terminate debugger' })
vim.keymap.set('n', '<F9>', require 'dap'.step_over, { desc = 'debugger step over' })
vim.keymap.set('n', '<F10>', require 'dap'.step_into, { desc = 'debugger step into' })
vim.keymap.set('n', '<F11>', require 'dap'.step_out, { desc = 'debugger step out' })
vim.keymap.set('n', '<leader>bb', require 'dap'.toggle_breakpoint, { desc = 'toggle breakpoint' })
vim.keymap.set('n', '<leader>cb', require 'dap'.clear_breakpoints,{ desc = 'clear breakpoints' })

vim.keymap.set("n", "<leader>di", function()
  dap.repl.open()
  dap.repl.execute(vim.fn.expand("<cexpr>"))
end, { desc = 'debugger repl cexpr' })
vim.keymap.set("v", "<leader>di", function()
  local lines = vim.fn.getregion(vim.fn.getpos("."), vim.fn.getpos("v"))
  dap.repl.open()
  dap.repl.execute(table.concat(lines, "\n"))
end, { desc = 'debugger repl visual selection' })

-- Python
require('dap-python').setup('python')

-- Go
require('dap-go').setup({
  dap_configurations = {
    {
      type = "go",
      name = "Test (Build Flags)",
      request = "launch",
      mode = "test",
      program = "./${relativeFileDirname}",
      buildFlags = require('dap-go').get_build_flags,
    },
    {
      type = "go",
      name = "Test (Build Flags & Arguments)",
      request = "launch",
      mode = "test",
      program = "./${relativeFileDirname}",
      args = require('dap-go').get_arguments,
      buildFlags = require('dap-go').get_build_flags,
    },
  },
})

-- Rust
dap.adapters.lldb = {
  type = 'server',
  port = "${port}",
  executable = {
    command = '/usr/bin/codelldb',
    args = {"--port", "${port}"},
  },
}

local function get_executable()
  return coroutine.create(function(dap_run_co)
    local path = ''
    vim.ui.input({ prompt = "Executable name: " }, function(input)
      path = 'target/debug/' .. (input or "")
      coroutine.resume(dap_run_co, path)
    end)
  end)
end

local function get_arguments()
  return coroutine.create(function(dap_run_co)
    local args = {}
    vim.ui.input({ prompt = "Args: " }, function(input)
      args = vim.split(input or "", " ")
      coroutine.resume(dap_run_co, args)
    end)
  end)
end

local function get_unittests_executable()
    local handle = io.popen('cargo test --no-run 2>&1')
    if handle == nil then
        return "[error running cargo (is it inatlled?)]"
    end
    for line in handle:lines() do
      for match in string.gmatch(line, 'Executable unittests [^%s]+ %(([^%s]+)%)') do
        handle:close()
        return match
      end
    end
    handle:close()
    return "[test executable not found]"
end

dap.configurations.rust = {
    {
        name = "executable",
        type = "lldb",
        request = "launch",
        program = get_executable,
        cwd = "${workspaceFolder}",
        stopOnEntry = false,
    },
    {
        name = "executable with args",
        type = "lldb",
        request = "launch",
        program = get_executable,
        args = get_arguments,
        cwd = "${workspaceFolder}",
        stopOnEntry = false,
    },
    {
        name = "unit tests",
        type = "lldb",
        request = "launch",
        program = get_unittests_executable,
        cwd = "${workspaceFolder}",
        stopOnEntry = false,
    },
}

--per-project config
require('nvim-dap-projects').search_project_config()

-- vim: set et sts=2  sw=2:
