return {
  "mfussenegger/nvim-dap",
  dependencies = {
    "nicholasmata/nvim-dap-cs",
  },
  config = function()
    local dap = require("dap")

    -- Adapter
    dap.adapters.coreclr = {
      type = "executable",
      command = vim.fn.expand("~/.local/share/netcoredbg/netcoredbg"),
      args = { "--interpreter=vscode" },
    }

    -- Launch config
    dap.configurations.cs = {
      {
        type = "coreclr",
        name = "Launch ASP.NET API",
        request = "launch",
        program = function()
          -- Auto build before launching
          local cwd = vim.fn.getcwd()
          local csprojs = vim.fn.glob(cwd .. "/**/*.csproj", false, true)
          for _, proj in ipairs(csprojs) do
            local f = io.open(proj, "r")
            if f then
              local content = f:read("*a")
              f:close()
              if content:match("Microsoft%.NET%.Sdk%.Web") then
                local proj_dir = vim.fn.fnamemodify(proj, ":h")
                local proj_name = vim.fn.fnamemodify(proj, ":t:r")
                print("Building " .. proj_name .. "...")
                vim.fn.system("dotnet build " .. vim.fn.shellescape(proj) .. " --no-restore")
                local dll = vim.fn.glob(proj_dir .. "/bin/Debug/**/" .. proj_name .. ".dll", false, true)
                if #dll >= 1 then
                  return dll[1]
                end
              end
            end
          end
          return vim.fn.input("Path to dll: ", cwd .. "/bin/Debug/", "file")
        end,
        cwd = function()
          local cwd = vim.fn.getcwd()
          local csprojs = vim.fn.glob(cwd .. "/**/*.csproj", false, true)
          for _, proj in ipairs(csprojs) do
            local f = io.open(proj, "r")
            if f then
              local content = f:read("*a")
              f:close()
              if content:match("Microsoft%.NET%.Sdk%.Web") then
                return vim.fn.fnamemodify(proj, ":h")
              end
            end
          end
          return cwd
        end,
        console = "internalConsole",
        stopAtEntry = false,
        env = {
          ASPNETCORE_ENVIRONMENT = "Development",
          ASPNETCORE_URLS = "http://localhost:5233",
        },
      },
    }

    -- Breakpoint icons
    vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError" })
    vim.fn.sign_define("DapBreakpointReject", { text = "○", texthl = "DiagnosticHint" })
    vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DiagnosticOk", linehl = "Visual" })

    -- Keybindings
    local map = vim.keymap.set
    map("n", "<F5>", dap.continue, { desc = "Debug: Start / Continue" })
    map("n", "<F10>", dap.step_over, { desc = "Debug: Step Over" })
    map("n", "<leader>di", dap.step_into, { desc = "Debug: Step Into" })
    map("n", "<leader>do", dap.step_out, { desc = "Debug: Step Out" })
    map("n", "<leader>db", dap.toggle_breakpoint, { desc = "Debug: Toggle Breakpoint" })
    map("n", "<leader>dB", function()
      dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
    end, { desc = "Debug: Conditional Breakpoint" })
    map("n", "<leader>dr", dap.restart, { desc = "Debug: Restart" })
    map("n", "<leader>dx", dap.terminate, { desc = "Debug: Stop" })
  end,
}
