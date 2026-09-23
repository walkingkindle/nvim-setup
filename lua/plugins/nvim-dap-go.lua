return {
  "leoluz/nvim-dap-go",
  config = function(_, opts)
    require("dap-go").setup(opts)

    local dap = require("dap")
    dap.configurations.go = dap.configurations.go or {}

    -- Delve's DAP has no `console` attribute (that's a VS Code thing), so the
    -- debuggee inherits dlv's stdio -- which nvim-dap wires to a pipe, giving
    -- an instant EOF on stdin. Feed stdin from a file instead, and use
    -- outputMode="remote" so the program's output comes back as DAP events
    -- (otherwise it goes to dlv's stdout and is invisible inside nvim).
    table.insert(dap.configurations.go, 1, {
      type = "go",
      name = "Debug main package (scripted stdin)",
      request = "launch",
      mode = "debug",
      program = "${workspaceFolder}/main",
      cwd = "${workspaceFolder}",
      stdinFrom = "${workspaceFolder}/.debug-input.txt",
      outputMode = "remote",
    })
  end,
}
