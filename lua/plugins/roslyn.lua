local solution_extensions = { sln = true, slnx = true, slnf = true }

---@return string? path to a solution file sitting directly in `dir`
local function find_solution(dir)
  for name, type in vim.fs.dir(dir) do
    if type == "file" and solution_extensions[vim.fs.ext(name)] then
      return vim.fs.normalize(vim.fs.joinpath(dir, name))
    end
  end
end

---Starts the server for the cwd's solution without waiting for a `cs` buffer.
---`attach = false` lets the client warm up on an empty startup screen; when a `cs`
---buffer is later opened, `vim.lsp.enable("roslyn")` resolves the same root_dir and
---reuses this client instead of spawning a second one.
local function start_roslyn()
  if vim.lsp.get_clients({ name = "roslyn" })[1] then
    return
  end

  local solution = find_solution(vim.fn.getcwd())
  if not solution then
    return
  end

  local config = vim.tbl_deep_extend("force", vim.lsp.config["roslyn"], {
    root_dir = vim.fs.dirname(solution),
    on_init = function(client)
      require("roslyn.lsp.on_init").sln(client, solution)
    end,
  })

  local client_id = vim.lsp.start(config, { attach = false })
  if not client_id then
    return
  end

  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].filetype == "cs" then
      vim.lsp.buf_attach_client(buf, client_id)
    end
  end
end

local function restart_roslyn()
  local clients = vim.lsp.get_clients({ name = "roslyn" })
  if #clients == 0 then
    return start_roslyn()
  end

  local remove_listener
  remove_listener = require("roslyn.roslyn_emitter").on("stopped", function()
    if remove_listener then
      remove_listener()
    end
    vim.schedule(start_roslyn)
  end)

  for _, client in ipairs(clients) do
    client:stop(true)
  end
end

return {
  "seblyng/roslyn.nvim",
  enabled = true,
  lazy = false,
  priority = 100,
  config = function()
    vim.lsp.config("roslyn", {
      settings = {
        ["csharp|inlay_hints"] = {
          csharp_enable_inlay_hints_for_implicit_object_creation = true,
          csharp_enable_inlay_hints_for_implicit_variable_types = true,
        },
        ["csharp|code_lens"] = {
          dotnet_enable_references_code_lens = true,
        },
      },
    })

    -- Neovim's libuv watchers miss files created outside the editor and are expensive
    -- on a solution this size; the server's own watcher picks up new .cs files, so a
    -- newly created type resolves without restarting the server.
    require("roslyn").setup({
      filewatching = "roslyn",
    })

    vim.api.nvim_create_user_command("RoslynRestart", restart_roslyn, {
      desc = "Restart the Roslyn language server",
    })
    vim.keymap.set("n", "<leader>cw", restart_roslyn, { desc = "Restart Roslyn (reload workspace)" })

    if vim.v.vim_did_enter == 1 then
      start_roslyn()
    else
      vim.api.nvim_create_autocmd("VimEnter", { once = true, callback = start_roslyn })
    end
  end,
}
