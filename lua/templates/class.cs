{{_lua:local n=vim.fn.expand('%:t:r'):lower();if n:find('controller')then return 'using Microsoft.AspNetCore.Mvc;\n\n' end;if n:find('test')then return 'using Xunit;\n\n' end;return ''_}}namespace {{_lua:local p=vim.fn.expand('%:.:h'):gsub('[/\\]','.'):gsub('^%.','');if p==''or p=='.'then return vim.fn.fnamemodify(vim.fn.getcwd(),':t')end;return p_}};

{{_lua:local n=vim.fn.expand('%:t:r'):lower();if n:find('controller')then return '[ApiController]\n[Route("[controller]")]\n' end;return ''_}}public class {{_file_name_}}{{_lua:local n=vim.fn.expand('%:t:r'):lower();if n:find('controller')then return ' : ControllerBase' end;return ''_}}
{
{{_lua:local n=vim.fn.expand('%:t:r'):lower();if n:find('test')then return '    [Fact]\n    public void Test1()\n    {\n    }\n' end;return ''_}}    {{_cursor_}}
}
