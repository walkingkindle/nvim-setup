return {
  dir = ".",
  ft = "cs",
  config = function()
    vim.api.nvim_create_autocmd({ "BufNewFile", "BufReadPost" }, {
      pattern = "*.cs",
      callback = function(args)
        local lines = vim.api.nvim_buf_get_lines(args.buf, 0, -1, false)
        local is_empty = #lines == 0 or (#lines == 1 and lines[1] == "")
        if not is_empty then
          return
        end

        local filename = vim.fn.expand("%:t:r")
        local name_lower = filename:lower()

        -- build namespace from relative path
        local rel_dir = vim.fn.expand("%:.:h")
        local ns
        if rel_dir == "" or rel_dir == "." then
          ns = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
        else
          ns = rel_dir:gsub("[/\\]", ".")
        end

        local result = {}

        if name_lower:find("controller") then
          table.insert(result, "using Microsoft.AspNetCore.Mvc;")
          table.insert(result, "")
          table.insert(result, "namespace " .. ns .. ";")
          table.insert(result, "")
          table.insert(result, "[ApiController]")
          table.insert(result, '[Route("[controller]")]')
          table.insert(result, "public class " .. filename .. " : ControllerBase")
          table.insert(result, "{")
          table.insert(result, "    ")
          table.insert(result, "}")
        elseif name_lower:find("test") then
          table.insert(result, "using Xunit;")
          table.insert(result, "")
          table.insert(result, "namespace " .. ns .. ";")
          table.insert(result, "")
          table.insert(result, "public class " .. filename)
          table.insert(result, "{")
          table.insert(result, "    [Fact]")
          table.insert(result, "    public void Test1()")
          table.insert(result, "    {")
          table.insert(result, "        ")
          table.insert(result, "    }")
          table.insert(result, "}")
        else
          table.insert(result, "namespace " .. ns .. ";")
          table.insert(result, "")
          table.insert(result, "public class " .. filename)
          table.insert(result, "{")
          table.insert(result, "    ")
          table.insert(result, "}")
        end

        vim.api.nvim_buf_set_lines(args.buf, 0, -1, false, result)
      end,
    })
  end,
}
