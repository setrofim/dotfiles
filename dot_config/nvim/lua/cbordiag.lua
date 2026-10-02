---@diagnostic disable-next-line: undefined-global
local vim = vim
local M = {}

local function tokenize(text)
  local tokens = {}
  local i, n = 1, #text

  while i <= n do
    local c = text:sub(i, i)

    if c:match("%s") then
      i = i + 1

    elseif c == ";" then
      local j = text:find("\n", i) or (n + 1)
      table.insert(tokens, { type = "comment", value = text:sub(i, j - 1) })
      i = j

    elseif c == "/" then
      local j = text:find("/", i + 1)
      if j then
        table.insert(tokens, { type = "comment", value = text:sub(i, j) })
        i = j + 1
      else
        table.insert(tokens, { type = "punct", value = c })
        i = i + 1
      end

    elseif c == '"' then
      local j = i + 1
      while j <= n do
        local cj = text:sub(j, j)
        if cj == "\\" then j = j + 2
        elseif cj == '"' then break
        else j = j + 1 end
      end
      table.insert(tokens, { type = "string", value = text:sub(i, j) })
      i = j + 1

    elseif text:sub(i, i + 1) == "h'" or text:sub(i, i + 3) == "b64'" then
      local start = i
      local j = text:find("'", i + (text:sub(i, i + 1) == "h'" and 2 or 4))
      j = j or n
      table.insert(tokens, { type = "bytestring", value = text:sub(start, j) })
      i = j + 1

    elseif c:match("[{}%[%](),:]") then
      table.insert(tokens, { type = "punct", value = c })
      i = i + 1

    elseif c:match("[%d%-]") then
      local j = i
      while j <= n and text:sub(j, j):match("[%d%.%-]") do j = j + 1 end
      -- a bare digit sequence immediately followed by '(' is a CBOR tag,
      -- e.g. 32( ... ) — keep it as its own token type so it stays
      -- glued to the following '('
      table.insert(tokens, { type = "number", value = text:sub(i, j - 1) })
      i = j

    else
      local j = i
      while j <= n and text:sub(j, j):match("[%w_]") do j = j + 1 end
      if j == i then j = i + 1 end
      table.insert(tokens, { type = "word", value = text:sub(i, j - 1) })
      i = j
    end
  end

  return tokens
end

local function pretty_print(tokens, shiftwidth)
  local out = {}
  local indent = 0
  local line = ""

  local function flush()
    table.insert(out, line)
    line = ""
  end

  local function pad()
    return string.rep(" ", indent * shiftwidth)
  end

  for idx, tok in ipairs(tokens) do
    local nxt = tokens[idx + 1]

    if tok.type == "punct" and (tok.value == "{" or tok.value == "[") then
      line = line .. tok.value
      flush()
      indent = indent + 1
      line = pad()

    elseif tok.type == "punct" and (tok.value == "}" or tok.value == "]") then
      -- trim trailing content on current line before closing
      if line:match("%S") then flush() end
      indent = math.max(indent - 1, 0)
      line = pad() .. tok.value

    elseif tok.type == "punct" and tok.value == "," then
      line = line .. ","
      flush()
      line = pad()

    elseif tok.type == "punct" and tok.value == ":" then
      line = line .. ": "

    elseif tok.type == "punct" and tok.value == "(" then
      line = line .. "("

    elseif tok.type == "punct" and tok.value == ")" then
      line = line .. ")"

    else
      if line ~= "" and not line:match("[%(:%s]$") then
        line = line .. " "
      end
      line = line .. tok.value
    end
  end

  if line:match("%S") then flush() end
  return out
end

function M.format()
  local start_line = vim.v.lnum
  local end_line = vim.v.lnum + vim.v.count - 1
  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
  local text = table.concat(lines, "\n")
  local shiftwidth = vim.fn.shiftwidth()

  local ok, result = pcall(function()
    local tokens = tokenize(text)
    return pretty_print(tokens, shiftwidth)
  end)

  if not ok then
    vim.notify("cbordiag format error: " .. tostring(result), vim.log.levels.ERROR)
    return 1
  end

  local set_ok, set_err = pcall(vim.api.nvim_buf_set_lines, 0, start_line - 1, end_line, false, result)
  if not set_ok then
    vim.notify("cbordiag buf_set_lines error: " .. tostring(set_err), vim.log.levels.ERROR)
    return 1
  end

  return 0
end

function M.indent()
  local lnum = vim.v.lnum
  if lnum == 1 then
    return 0
  end

  local prev_lnum = vim.fn.prevnonblank(lnum - 1)
  if prev_lnum == 0 then
    return 0
  end

  local prev_line = vim.fn.getline(prev_lnum)
  local cur_line = vim.fn.getline(lnum)
  local shiftwidth = vim.fn.shiftwidth()

  local prev_indent = vim.fn.indent(prev_lnum)

  -- strip trailing comments before counting brackets, so a comment
  -- containing a stray { or [ doesn't throw off the count
  local function strip_comment(line)
    line = line:gsub(";.*$", "")
    line = line:gsub("/[^/]*/", "")
    return line
  end

  local prev_stripped = strip_comment(prev_line)
  local cur_stripped = strip_comment(cur_line)

  local opens = select(2, prev_stripped:gsub("[{%[]", ""))
  local closes = select(2, prev_stripped:gsub("[}%]]", ""))
  local net_prev = opens - closes

  local indent = prev_indent + (net_prev * shiftwidth)

  -- dedent if the current line starts with a closing bracket
  if cur_stripped:match("^%s*[}%]]") then
    indent = indent - shiftwidth
  end

  return math.max(indent, 0)
end

return M
