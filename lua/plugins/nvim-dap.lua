return {
  "mfussenegger/nvim-dap",
  dependencies = {
    "nicholasmata/nvim-dap-cs",
  },
  config = function()
    local dap = require("dap")

    -- netcoredbg lives in a different place on each machine:
    -- Windows installs it with mason, the Ubuntu box uses a manual tarball install.
    local function netcoredbg_cmd()
      local mason = vim.fn.stdpath("data") .. "/mason/packages/netcoredbg"
      local candidates
      if vim.fn.has("win32") == 1 then
        candidates = { mason .. "/netcoredbg.exe" }
      else
        candidates = {
          mason .. "/libexec/netcoredbg/netcoredbg",
          mason .. "/netcoredbg",
          vim.fn.expand("~/.local/share/netcoredbg/netcoredbg"),
        }
      end
      for _, path in ipairs(candidates) do
        if vim.fn.executable(path) == 1 then
          return path
        end
      end
      return candidates[#candidates]
    end

    -- Adapter
    dap.adapters.coreclr = {
      type = "executable",
      command = netcoredbg_cmd(),
      args = { "--interpreter=vscode" },
    }

    -- A solution can hold several web projects (Auth and SpesanaApp, say). Launching
    -- the wrong one boots an assembly with a different UserSecretsId, so user secrets
    -- silently come up empty. Ask once, then reuse the answer for the whole session.
    local selected = nil

    local function web_projects()
      local found = {}
      for _, proj in ipairs(vim.fn.glob(vim.fn.getcwd() .. "/**/*.csproj", false, true)) do
        if not (proj:match("[/\\]bin[/\\]") or proj:match("[/\\]obj[/\\]")) then
          local f = io.open(proj, "r")
          if f then
            local content = f:read("*a")
            f:close()
            if content:match("Microsoft%.NET%.Sdk%.Web") then
              table.insert(found, proj)
            end
          end
        end
      end
      return found
    end

    local function pick_project()
      if selected then
        return selected
      end

      local found = web_projects()
      if #found == 0 then
        return nil
      end

      local choice = found[1]
      if #found > 1 then
        local items = { "Which project should <F5> debug?" }
        for i, proj in ipairs(found) do
          table.insert(items, string.format("%d. %s", i, vim.fn.fnamemodify(proj, ":.")))
        end
        local idx = vim.fn.inputlist(items)
        if idx < 1 or idx > #found then
          return nil
        end
        choice = found[idx]
      end

      selected = {
        csproj = choice,
        dir = vim.fn.fnamemodify(choice, ":h"),
        name = vim.fn.fnamemodify(choice, ":t:r"),
      }
      return selected
    end

    -- Take the environment from launchSettings.json the way `dotnet run` does, so a
    -- debug session sees the same ASPNETCORE_ENVIRONMENT (and therefore the same user
    -- secrets and ports) as a normal run.
    local function launch_env(proj)
      local env = { ASPNETCORE_ENVIRONMENT = "Development" }

      local f = io.open(proj.dir .. "/Properties/launchSettings.json", "r")
      if not f then
        return env
      end
      local ok, settings = pcall(vim.json.decode, f:read("*a"))
      f:close()
      if not ok or type(settings) ~= "table" or type(settings.profiles) ~= "table" then
        return env
      end

      local profile = settings.profiles[proj.name]
      if not profile then
        for _, p in pairs(settings.profiles) do
          if p.commandName == "Project" then
            profile = p
            break
          end
        end
      end
      if not profile then
        return env
      end

      for key, value in pairs(profile.environmentVariables or {}) do
        env[key] = tostring(value)
      end
      if profile.applicationUrl then
        env.ASPNETCORE_URLS = profile.applicationUrl
      end
      return env
    end

    local function build(proj)
      vim.notify("Building " .. proj.name .. "...", vim.log.levels.INFO)
      local out = vim.fn.system({ "dotnet", "build", proj.csproj })
      if vim.v.shell_error ~= 0 then
        vim.notify("Build failed:\n" .. out, vim.log.levels.ERROR)
        return false
      end
      return true
    end

    -- Launch config
    dap.configurations.cs = {
      {
        type = "coreclr",
        name = "Launch ASP.NET API",
        request = "launch",
        program = function()
          local proj = pick_project()
          if not proj then
            return vim.fn.input("Path to dll: ", vim.fn.getcwd() .. "/bin/Debug/", "file")
          end
          if not build(proj) then
            return dap.ABORT
          end
          local dlls = vim.fn.glob(proj.dir .. "/bin/Debug/**/" .. proj.name .. ".dll", false, true)
          if #dlls == 0 then
            vim.notify("No built dll found for " .. proj.name, vim.log.levels.ERROR)
            return dap.ABORT
          end
          return dlls[1]
        end,
        cwd = function()
          local proj = pick_project()
          return proj and proj.dir or vim.fn.getcwd()
        end,
        env = function()
          local proj = pick_project()
          return proj and launch_env(proj) or { ASPNETCORE_ENVIRONMENT = "Development" }
        end,
        console = "internalConsole",
        stopAtEntry = false,
      },
    }

    -- Breakpoint icons
    vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError" })
    vim.fn.sign_define("DapBreakpointReject", { text = "○", texthl = "DiagnosticHint" })
    vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DiagnosticOk", linehl = "Visual" })

    vim.api.nvim_create_user_command("DapSelectProject", function()
      selected = nil
      local proj = pick_project()
      if proj then
        vim.notify("Debugging " .. vim.fn.fnamemodify(proj.csproj, ":."), vim.log.levels.INFO)
      end
    end, { desc = "Pick which web project <F5> debugs" })

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
    map("n", "<leader>dp", "<cmd>DapSelectProject<cr>", { desc = "Debug: Select Project" })
  end,
}
