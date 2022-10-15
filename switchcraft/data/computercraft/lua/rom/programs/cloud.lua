package.preload["argparse"] = function(...)
  local function errorf(msg, ...)
    error(msg:format(...), 0)
  end
  local function setter(arg, result, value)
    result[arg.name] = value or true
  end
  local parser = { __name = "ArgParser" }
  parser.__index = parser
  function parser:add(names, arg)
    if type(names) == "string" then names = { names } end
    arg.names = names
    for i = 1, #names do
      local name = names[i]
      if name:sub(1, 2) == "--" then self.options[name:sub(3)] = arg
      elseif name:sub(1, 1) == "-" then self.flags[name:sub(2)] = arg
      else self.arguments[#self.arguments + 1] = arg; arg.argument = true end
    end
    table.insert(self.list, #self.list, arg)
    if arg.action == nil then arg.action = setter end
    if arg.required == nil then arg.required = names[1]:sub(1, 1) ~= "-" end
    if arg.name == nil then arg.name = names[1]:gsub("^-+", "") end
    if arg.mvar == nil then arg.mvar = arg.name:upper() end
  end
  function parser:parse(...)
    local args = table.pack(...)
    local i, n = 1, #args
    local arg_idx = 1
    local result = {}
    while i <= n do
      local arg = args[i]
      i = i + 1
      if arg:find("^%-%-([^=]+)=(.+)$") then
        local name, value = arg:match("^%-%-([^=]+)=(.+)$")
        local arg = self.options[name]
        if not arg then errorf("Unknown argument %q", name) end
        if not arg.many and result[arg.name] ~= nil then errorf("%s has already been set", name) end
        if not arg.value then errorf("%s does not accept a value", name) end
        arg:action(result, value)
      elseif arg:find("^%-%-(.*)$") then
        local name = arg:match("^%-%-(.*)$")
        local arg = self.options[name]
        if not arg then errorf("Unknown argument %q", name) end
        if not arg.many and result[arg.name] ~= nil then errorf("%s has already been set", name) end
        if arg.value then
          local value = args[i]
          i = i + 1
          if not value then errorf("%s needs a value", name) end
          arg:action(result, value)
        else
          arg:action(result)
        end
      elseif arg:find("^%-(.+)$") then
        local flags = arg:match("^%-(.+)$")
        for j = 1, #flags do
          local name = flags:sub(j, j)
          local arg = self.flags[name]
          if not arg then errorf("Unknown argument %q", name) end
          if not arg.many and result[arg.name] ~= nil then errorf("%s has already been set", name) end
          if arg.value then
            local value
            if j == #flags then
              value = args[i]
              i = i + 1
            else
              value = flags:sub(j + 1)
            end
            if not value then errorf("%s expects a value", name) end
            arg:action(result, value)
            break
          else
            arg:action(result)
          end
        end
      else
        local argument = self.arguments[arg_idx]
        if argument then
          argument:action(result, arg)
          arg_idx = arg_idx + 1
        else
          errorf("Unexpected argument %q", arg)
        end
      end
    end
    for i = 1, #self.list do
      local arg = self.list[i]
      if arg and arg.required and result[arg.name] == nil then
        errorf("%s is required (use -h to see usage)", arg.name)
      end
    end
    return result
  end
  local function get_usage(arg)
    local name
    if arg.argument then name = arg.mvar
    elseif arg.value then name = arg.names[1] .. "=" .. arg.mvar
    else name = arg.names[1]
    end
    if #arg.names > 1 then name = name .. "," .. table.concat(arg.names, ",", 2) end
    return name
  end
  local function create(prefix)
    local parser = setmetatable({
      options = {},
      flags = {},
      arguments = {},
      list = {},
    }, parser)
    parser:add({ "-h", "--help", "-?" }, {
      value = false, required = false,
      doc = "Show this help message",
      action = function()
        if prefix then print(prefix) print() end
        print("USAGE")
        local max = 0
        for i = 1, #parser.list do max = math.max(max, #get_usage(parser.list[i])) end
        local format = " %-" .. max .. "s %s"
        for i = 1, #parser.list do
          local arg = parser.list[i]
          print(format:format(get_usage(arg), arg.doc or ""))
        end
        error("", 0)
      end,
    })
    return parser
  end
  local function is_help(cmd)
    return cmd == "help" or cmd == "--help" or cmd == "-h" or cmd == "-?"
  end
  return { create = create, is_help = is_help }
end
package.preload["framebuffer"] = function(...)
  local stringify = require("json").stringify
  local colour_lookup = {}
  for i = 0, 15 do
    colour_lookup[2 ^ i] = string.format("%x", i)
  end
  local void = function() end
  local function empty(colour, width, height)
    local function is_colour() return colour end
    return {
      write = void, blit = void, clear = void, clearLine = void,
      setCursorPos = void, setCursorBlink = void,
      setPaletteColour = void, setPaletteColor = void,
      setTextColour = void, setTextColor = void, setBackgroundColour = void, setBackgroundColor = void,
      getTextColour = void, getTextColor = void, getBackgroundColour = void, getBackgroundColor = void,
      scroll = void,
      isColour = is_colour, isColor = is_colour,
      getSize = function() return width, height end,
      getPaletteColour = term.native().getPaletteColour, getPaletteColor = term.native().getPaletteColor,
    }
  end
  local function buffer(original)
    local text = {}
    local text_colour = {}
    local back_colour = {}
    local palette = {}
    local palette_24 = {}
    local cursor_x, cursor_y = 1, 1
    local cursor_blink = false
    local cur_text_colour = "0"
    local cur_back_colour = "f"
    local sizeX, sizeY = original.getSize()
    local color = original.isColor()
    local dirty = false
    local redirect = {}
    if original.getPaletteColour then
      for i = 0, 15 do
        local c = 2 ^ i
        palette[c] = { original.getPaletteColour( c ) }
        palette_24[colour_lookup[c]] = colours.rgb8(original.getPaletteColour( c ))
      end
    end
    function redirect.write(writeText)
      writeText = tostring(writeText)
      original.write(writeText)
      dirty = true
      if cursor_y > sizeY or cursor_y < 1 or cursor_x + #writeText <= 1 or cursor_x > sizeX then
        cursor_x = cursor_x + #writeText
        return
      end
      if cursor_x < 1 then
        writeText = writeText:sub(-cursor_x + 2)
        cursor_x = 1
      elseif cursor_x + #writeText > sizeX then
        writeText = writeText:sub(1, sizeX - cursor_x + 1)
      end
      local lineText = text[cursor_y]
      local lineColor = text_colour[cursor_y]
      local lineBack = back_colour[cursor_y]
      local preStop = cursor_x - 1
      local preStart = math.min(1, preStop)
      local postStart = cursor_x + #writeText
      local postStop = sizeX
      local sub, rep = string.sub, string.rep
      text[cursor_y] = sub(lineText, preStart, preStop)..writeText..sub(lineText, postStart, postStop)
      text_colour[cursor_y] = sub(lineColor, preStart, preStop)..rep(cur_text_colour, #writeText)..sub(lineColor, postStart, postStop)
      back_colour[cursor_y] = sub(lineBack, preStart, preStop)..rep(cur_back_colour, #writeText)..sub(lineBack, postStart, postStop)
      cursor_x = cursor_x + #writeText
    end
    function redirect.blit(writeText, writeFore, writeBack)
      original.blit(writeText, writeFore, writeBack)
      dirty = true
      if cursor_y > sizeY or cursor_y < 1 or cursor_x + #writeText <= 1 or cursor_x > sizeX then
        cursor_x = cursor_x + #writeText
        return
      end
      if cursor_x < 1 then
        writeText = writeText:sub(-cursor_x + 2)
        writeFore = writeFore:sub(-cursor_x + 2)
        writeBack = writeBack:sub(-cursor_x + 2)
        cursor_x = 1
      elseif cursor_x + #writeText > sizeX then
        writeText = writeText:sub(1, sizeX - cursor_x + 1)
        writeFore = writeFore:sub(1, sizeX - cursor_x + 1)
        writeBack = writeBack:sub(1, sizeX - cursor_x + 1)
      end
      local lineText = text[cursor_y]
      local lineColor = text_colour[cursor_y]
      local lineBack = back_colour[cursor_y]
      local preStop = cursor_x - 1
      local preStart = math.min(1, preStop)
      local postStart = cursor_x + #writeText
      local postStop = sizeX
      local sub = string.sub
      text[cursor_y] = sub(lineText, preStart, preStop)..writeText..sub(lineText, postStart, postStop)
      text_colour[cursor_y] = sub(lineColor, preStart, preStop)..writeFore..sub(lineColor, postStart, postStop)
      back_colour[cursor_y] = sub(lineBack, preStart, preStop)..writeBack..sub(lineBack, postStart, postStop)
      cursor_x = cursor_x + #writeText
    end
    function redirect.clear()
      for i = 1, sizeY do
        text[i] = string.rep(" ", sizeX)
        text_colour[i] = string.rep(cur_text_colour, sizeX)
        back_colour[i] = string.rep(cur_back_colour, sizeX)
      end
      dirty = true
      return original.clear()
    end
    function redirect.clearLine()
      if cursor_y > sizeY or cursor_y < 1 then
        return
      end
      text[cursor_y] = string.rep(" ", sizeX)
      text_colour[cursor_y] = string.rep(cur_text_colour, sizeX)
      back_colour[cursor_y] = string.rep(cur_back_colour, sizeX)
      dirty = true
      return original.clearLine()
    end
    function redirect.getCursorPos()
      return cursor_x, cursor_y
    end
    function redirect.setCursorPos(x, y)
      if type(x) ~= "number" then error("bad argument #1 (expected number, got " .. type(x) .. ")", 2) end
      if type(y) ~= "number" then error("bad argument #2 (expected number, got " .. type(y) .. ")", 2) end
      if x ~= cursor_x or y ~= cursor_y then
        cursor_x = math.floor(x)
        cursor_y = math.floor(y)
        dirty = true
      end
      return original.setCursorPos(x, y)
    end
    function redirect.setCursorBlink(b)
      if type(b) ~= "boolean" then error("bad argument #1 (expected boolean, got " .. type(b) .. ")", 2) end
      if cursor_blink ~= b then
        cursor_blink = b
        dirty = true
      end
      return original.setCursorBlink(b)
    end
    function redirect.getCursorBlink()
      return cursor_blink
    end
    function redirect.getSize()
      return sizeX, sizeY
    end
    function redirect.scroll(n)
      if type(n) ~= "number" then error("bad argument #1 (expected number, got " .. type(n) .. ")", 2) end
      local empty_text = string.rep(" ", sizeX)
      local empty_text_colour = string.rep(cur_text_colour, sizeX)
      local empty_back_colour = string.rep(cur_back_colour, sizeX)
      if n > 0 then
        for i = 1, sizeY do
          text[i] = text[i + n] or empty_text
          text_colour[i] = text_colour[i + n] or empty_text_colour
          back_colour[i] = back_colour[i + n] or empty_back_colour
        end
      elseif n < 0 then
        for i = sizeY, 1, -1 do
          text[i] = text[i + n] or empty_text
          text_colour[i] = text_colour[i + n] or empty_text_colour
          back_colour[i] = back_colour[i + n] or empty_back_colour
        end
      end
      dirty = true
      return original.scroll(n)
    end
    function redirect.setTextColour(clr)
      if type(clr) ~= "number" then error("bad argument #1 (expected number, got " .. type(clr) .. ")", 2) end
      local new_colour = colour_lookup[clr] or error("Invalid colour (got " .. clr .. ")" , 2)
      if new_colour ~= cur_text_colour then
        dirty = true
        cur_text_colour = new_colour
      end
      return original.setTextColour(clr)
    end
    redirect.setTextColor = redirect.setTextColour
    function redirect.setBackgroundColour(clr)
      if type(clr) ~= "number" then error("bad argument #1 (expected number, got " .. type(clr) .. ")", 2) end
      local new_colour = colour_lookup[clr] or error("Invalid colour (got " .. clr .. ")" , 2)
      if new_colour ~= cur_back_colour then
        dirty = true
        cur_back_colour = new_colour
      end
      return original.setBackgroundColour(clr)
    end
    redirect.setBackgroundColor = redirect.setBackgroundColour
    function redirect.isColour()
      return color == true
    end
    redirect.isColor = redirect.isColour
    function redirect.getTextColour()
      return 2 ^ tonumber(cur_text_colour, 16)
    end
    redirect.getTextColor = redirect.getTextColour
    function redirect.getBackgroundColour()
      return 2 ^ tonumber(cur_back_colour, 16)
    end
    redirect.getBackgroundColor = redirect.getBackgroundColour
    if original.getPaletteColour then
      function redirect.setPaletteColour(colour, r, g, b)
        local palcol = palette[colour]
        if not palcol then error("Invalid colour (got " .. tostring(colour) .. ")", 2) end
        if type(r) == "number" and g == nil and b == nil then
            palcol[1], palcol[2], palcol[3] = colours.rgb8(r)
            palette_24[colour_lookup[colour]] = r
        else
            if type(r) ~= "number" then error("bad argument #2 (expected number, got " .. type(r) .. ")", 2) end
            if type(g) ~= "number" then error("bad argument #3 (expected number, got " .. type(g) .. ")", 2) end
            if type(b) ~= "number" then error("bad argument #4 (expected number, got " .. type(b ) .. ")", 2 ) end
            palcol[1], palcol[2], palcol[3] = r, g, b
            palette_24[colour_lookup[colour]] = colours.rgb8(r, g, b)
        end
        dirty = true
        return original.setPaletteColour(colour, r, g, b)
      end
      redirect.setPaletteColor = redirect.setPaletteColour
      function redirect.getPaletteColour(colour)
        local palcol = palette[colour]
        if not palcol then error("Invalid colour (got " .. tostring(colour) .. ")", 2) end
        return palcol[1], palcol[2], palcol[3]
      end
      redirect.getPaletteColor = redirect.getPaletteColour
    end
    function redirect.is_dirty() return dirty end
    function redirect.clear_dirty() dirty = false end
    function redirect.serialise()
      return stringify {
        packet = 0x10,
        width = sizeX, height = sizeY,
        cursorX = cursor_x, cursorY = cursor_y, cursorBlink = cursor_blink,
        curFore = cur_text_colour, curBack = cur_back_colour,
        palette = palette_24,
        text = text, fore = text_colour, back = back_colour
      }
    end
    redirect.setCursorPos(1, 1)
    redirect.setBackgroundColor(colours.black)
    redirect.setTextColor(colours.white)
    redirect.clear()
    return redirect
  end
  return { buffer = buffer, empty = empty }
end
package.preload["encode"] = function(...)
  local function fletcher_32(str)
    local s1, s2, byte = 0, 0, string.byte
    if #str % 2 ~= 0 then str = str .. "\0" end
    for i = 1, #str, 2 do
      local c1, c2 = byte(str, i, i + 1)
      s1 = (s1 + c1 + (c2 * 0x100)) % 0xFFFF
      s2 = (s2 + s1) % 0xFFFF
    end
    return s2 * 0x10000 + s1
  end
  return {
    fletcher_32 = fletcher_32
  }
end
package.preload["json"] = function(...)
  local tonumber = tonumber
  local function skip_delim(str, pos, delim, err_if_missing)
    pos = pos + #str:match('^%s*', pos)
    if str:sub(pos, pos) ~= delim then
      if err_if_missing then error('Expected ' .. delim) end
      return pos, false
    end
    return pos + 1, true
  end
  local esc_map = { b = '\b', f = '\f', n = '\n', r = '\r', t = '\t' }
  local function parse_str_val(str, pos)
    local out, n = {}, 0
    if pos > #str then error("Malformed JSON (in string)") end
    while true do
      local c = str:sub(pos, pos)
      if c == '"' then return table.concat(out, "", 1, n), pos + 1 end
      n = n + 1
      if c == '\\' then
        local nextc = str:sub(pos + 1, pos + 1)
        if not nextc then error("Malformed JSON (in string)") end
        if nextc == "u" then
          local num = tonumber(str:sub(pos + 2, pos + 5), 16)
          if not num then error("Malformed JSON (in unicode string) ") end
          if num <= 255 then
            pos, out[n] = pos + 6, string.char(num)
          else
            pos, out[n] = pos + 6, "?"
          end
        else
          pos, out[n] = pos + 2, esc_map[nextc] or nextc
        end
      else
        pos, out[n] = pos + 1, c
      end
    end
  end
  local function parse_num_val(str, pos)
    local num_str = str:match('^-?%d+%.?%d*[eE]?[+-]?%d*', pos)
    local val = tonumber(num_str)
    if not val then error('Error parsing number at position ' .. pos .. '.') end
    return val, pos + #num_str
  end
  local null = {}
  local literals = {['true'] = true, ['false'] = false, ['null'] = null }
  local escapes = {}
  for i = 0, 255 do
    local c = string.char(i)
    if i >= 32 and i <= 126
    then escapes[c] = c
    else escapes[c] = ("\\u00%02x"):format(i)
    end
  end
  escapes["\t"], escapes["\n"], escapes["\r"], escapes["\""], escapes["\\"] = "\\t", "\\n", "\\r", "\\\"", "\\\\"
  local function parse(str, pos, end_delim)
    pos = pos or 1
    if pos > #str then error('Reached unexpected end of input.') end
    local pos = pos + #str:match('^%s*', pos)
    local first = str:sub(pos, pos)
    if first == '{' then
      local obj, key, delim_found = {}, true, true
      pos = pos + 1
      while true do
        key, pos = parse(str, pos, '}')
        if key == nil then return obj, pos end
        if not delim_found then error('Comma missing between object items.') end
        pos = skip_delim(str, pos, ':', true)
        obj[key], pos = parse(str, pos)
        pos, delim_found = skip_delim(str, pos, ',')
      end
    elseif first == '[' then
      local arr, val, delim_found = {}, true, true
      pos = pos + 1
      while true do
        val, pos = parse(str, pos, ']')
        if val == nil then return arr, pos end
        if not delim_found then error('Comma missing between array items.') end
        arr[#arr + 1] = val
        pos, delim_found = skip_delim(str, pos, ',')
      end
    elseif first == '"' then
      return parse_str_val(str, pos + 1)
    elseif first == '-' or first:match('%d') then
      return parse_num_val(str, pos)
    elseif first == end_delim then
      return nil, pos + 1
    else
      for lit_str, lit_val in pairs(literals) do
        local lit_end = pos + #lit_str - 1
        if str:sub(pos, lit_end) == lit_str then return lit_val, lit_end + 1 end
      end
      local pos_info_str = 'position ' .. pos .. ': ' .. str:sub(pos, pos + 10)
      error('Invalid json syntax starting at ' .. pos_info_str)
    end
  end
  local format, gsub, tostring, pairs, next, type, concat
      = string.format, string.gsub, tostring, pairs, next, type, table.concat
  local function stringify_impl(t, out, n)
    local ty = type(t)
    if ty == "table" then
      local first_ty = type(next(t))
      if first_ty == "nil" then
          out[n], n = "{}", n + 1
          return n
      elseif first_ty == "string" then
        out[n], n = "{", n + 1
        local first = true
        for k, v in pairs(t) do
          if first then first = false else out[n], n = ",", n + 1 end
          out[n] = format("\"%s\":", k)
          n = stringify_impl(v, out, n + 1)
        end
        out[n], n = "}", n + 1
        return n
      elseif first_ty == "number" then
        out[n], n = "[", n + 1
        for i = 1, #t do
          if i > 1 then out[n], n = ",", n + 1 end
          n = stringify_impl(t[i], out, n)
        end
        out[n], n = "]", n + 1
        return n
      else
        error("Cannot serialize key " .. first_ty)
      end
    elseif ty == "string" then
      if t:match("^[ -~]*$") then
        out[n], n = gsub(format("%q", t), "\n", "n"), n + 1
      else
        out[n], n = "\"" .. gsub(t, ".", escapes) .. "\"", n + 1
      end
      return n
    elseif ty == "number" or ty == "boolean" then
      out[n],n  = tostring(t), n + 1
      return n
    else error("Cannot serialize type " .. ty)
    end
  end
  local function stringify(object)
    local buffer = {}
    local n = stringify_impl(object, buffer, 1)
    return concat(buffer, "", 1, n - 1)
  end
  local function try_parse(msg)
    local ok, res = pcall(parse, msg)
    if ok then return res else return nil, res end
  end
  return {
    stringify = stringify,
    try_parse = try_parse,
    parse = parse,
    null = null
  }
end
local tonumber, type, keys = tonumber, type, keys
local argparse = require "argparse"
local framebuffer = require "framebuffer"
local encode = require "encode"
local json = require "json"
if _G.cloud_catcher then
  local usage = ([[
  cloud: <subcommand> [args]
  Communicate with the cloud-catcher session.
  Subcommands:
    edit <file> Open a file on the remote server.
    token       Display the token for this
                connection.
  ]]):gsub("^%s+", ""):gsub("%s+$", ""):gsub("\n  ", "\n")
  local subcommand = ...
  if subcommand == "edit" or subcommand == "e" then
    local arguments = argparse.create("cloud edit: Edit a file in the remote viewer")
    arguments:add({ "file" }, { doc = "The file to upload", required = true })
    local result = arguments:parse(select(2, ...))
    local file = result.file
    local resolved = shell.resolve(file)
    if not fs.exists(resolved) and not resolved:find("%.") then
      local extension = settings.get("edit.default_extension", "")
      if extension ~= "" and type(extension) == "string" then
          resolved = resolved .. "." .. extension
      end
    end
    if fs.isDir(resolved) then error(("%q is a directory"):format(file), 0) end
    if fs.isReadOnly(resolved) then
      if fs.exists(resolved) then
        print(("%q is read only, will not be able to modify"):format(file))
      else
        error(("%q does not exist"):format(file), 0)
      end
    end
    local ok, err = _G.cloud_catcher.edit(resolved)
    if not ok then error(err, 0) end
  elseif subcommand == "token" or subcommand == "t" then
    print(_G.cloud_catcher.token())
  elseif argparse.is_help(subcommand) then
    print(usage)
  elseif subcommand == nil then
    printError(usage)
    error()
  else
    error(("%q is not a cloud catcher subcommand, run with --help for more info"):format(subcommand), 0)
  end
  return
end
local current_path = shell.getRunningProgram()
local current_name = fs.getName(current_path)
local arguments = argparse.create(current_name .. ": Interact with this computer remotely")
arguments:add({ "token" }, { doc = "The token to use when connecting" })
arguments:add({ "--term", "-t" }, { value = true, doc = "Terminal dimensions or none to hide" })
arguments:add({ "--dir",  "-d" }, { value = true, doc = "The directory to sync to. Defaults to the current one." })
arguments:add({ "--http", "-H" }, { value = false, doc = "Use HTTP instead of HTTPs" })
local args = arguments:parse(...)
local token = args.token
if #token ~= 32 or token:find("[^%a%d]") then
  error("Invalid token (must be 32 alpha-numeric characters)", 0)
end
local capabilities = {}
local term_opts = args.term
local previous_term, parent_term = term.current()
if term_opts == nil then
  parent_term = previous_term
else if term_opts == "none" then
  parent_term = nil
elseif term_opts == "hide" then
  parent_term = framebuffer.empty(true, term.getSize())
elseif term_opts:find("^(%d+)x(%d+)$") then
  local w, h = term_opts:match("^(%d+)x(%d+)$")
  if w == 0 or h == 0 then error("Terminal cannot have 0 size", 0) end
  parent_term = framebuffer.empty(true, tonumber(w), tonumber(h))
else
    error("Unknown format for term: expected \"none\", \"hide\" or \"wxh\"", 0)
  end
end
if parent_term then
  table.insert(capabilities, "terminal:host")
  local w, h = parent_term.getSize()
  if w * h > 5000 then error("Terminal is too large to handle", 0) end
end
local sync_dir = shell.resolve(args.dir or "./")
if not fs.isDir(sync_dir) then error(("%q is not a directory"):format(sync_dir), 0) end
table.insert(capabilities, "file:host")
local url = ("%s://cloud-catcher.squiddev.cc/connect?id=%s&capabilities=%s"):format(
  args.http and "ws" or "wss", token, table.concat(capabilities, ","))
local remote, err = http.websocket(url)
if not remote then error("Cannot connect to cloud-catcher server: " .. err, 0) end
local server_term, server_file_edit, server_file_host = false, false, false
do
  local max_packet_size = 16384
  _G.cloud_catcher = {
    token = function() return token end,
    edit = function(file, force)
      if not server_file_edit then
        return false, "There are no editors connected"
      end
      local contents, exists
      local handle = fs.open(file, "rb")
      if handle then
        contents = handle.readAll()
        handle.close()
        exists = true
      else
        contents = ""
        exists = false
      end
      if #file + #contents + 5 > max_packet_size then
        return false, "This file is too large to be edited remotely"
      end
      local check = encode.fletcher_32(contents)
      local flag = 0x04
      if fs.isReadOnly(file) then flag = flag + 0x01 end
      if not exists then flag = flag + 0x08 end
      remote.send(json.stringify {
        packet = 0x22,
        id = 0,
        actions = {
          { file = file, checksum = check, flags = flag, action = 0, contents = contents }
        }
      })
      return true
    end
  }
  shell.setAlias("cloud", "/" .. current_path)
  local function complete_multi(text, options)
    local results = {}
    for i = 1, #options do
        local option, add_spaces = options[i][1], options[i][2]
        if #option + (add_spaces and 1 or 0) > #text and option:sub(1, #text) == text then
            local result = option:sub(#text + 1)
            if add_spaces then table.insert( results, result .. " " )
            else table.insert( results, result )
            end
        end
    end
    return results
  end
  local subcommands = { { "edit", true }, { "token", false } }
  shell.setCompletionFunction(current_path, function(shell, index, text, previous_text)
    if _G.cloud_catcher == nil then return end
    if index == 1 then
      return complete_multi(text, subcommands)
    elseif index == 2 and previous_text[2] == "edit" then
        return fs.complete(text, shell.dir(), true, false)
    end
  end)
end
local co, buffer
if parent_term ~= nil then
  buffer = framebuffer.buffer(parent_term)
  co = coroutine.create(shell.run)
  term.redirect(buffer)
end
local info_dirty, last_label, get_label = true, nil, os.getComputerLabel
local function send_info()
  last_label = get_label()
  info_dirty = false
  remote.send(json.stringify {
    packet = 0x12,
    id = os.getComputerID(),
    label = last_label,
  })
end
local ok, res = true
if co then ok, res = coroutine.resume(co, "shell") end
local last_change, last_timer = os.clock(), nil
local pending_events, pending_n = {}, 0
local function push_event(event)
  pending_n = pending_n + 1
  pending_events[pending_n] = event
end
while ok and (not co or coroutine.status(co) ~= "dead") do
  if not info_dirty and last_label ~= get_label() then info_dirty = true end
  if server_term and last_timer == nil and (buffer.is_dirty() or info_dirty) then
    local now = os.clock()
    if now - last_change < 0.04 then
      last_timer = os.startTimer(0)
    else
      last_change = os.clock()
      if buffer.is_dirty() then
        remote.send(buffer.serialise())
        buffer.clear_dirty()
      end
      if info_dirty then send_info() end
    end
  end
  local event
  if pending_n >= 1 then
    event = table.remove(pending_events, 1)
    pending_n = pending_n - 1
  else
    event = table.pack(coroutine.yield())
  end
  if event[1] == "timer" and event[2] == last_timer then
    last_timer = nil
    if server_term then
      last_change = os.clock()
      if buffer.is_dirty() then remote.send(buffer.serialise()) buffer.clear_dirty() end
      if info_dirty then send_info() end
    end
  elseif event[1] == "websocket_closed" and event[2] == url then
    ok, res = false, "Connection lost"
    remote = nil
  elseif event[1] == "websocket_message" and event[2] == url then
    local packet = json.try_parse(event[3])
    local code = packet and packet.packet
    if type(code) ~= "number" then code = - 1 end
    if code >= 0x00 and code < 0x10 then
      if code == 0x00 then -- ConnectionUpdate
        server_term, server_file_edit, server_file_host = false, false, false
        for _, cap in ipairs(packet.capabilities) do
          if cap == "terminal:view" and buffer ~= nil then
            server_term = true
            remote.send(buffer.serialise()) buffer.clear_dirty()
            send_info()
            last_change = os.clock()
          elseif cap == "file:host" then
            server_file_host = true
          elseif cap == "file:edit" then
            server_file_edit = true
          end
        end
      elseif code == 0x02 then -- ConnectionPing
        remote.send([[{"packet":2}]])
      end
    elseif server_term and code >= 0x10 and code < 0x20 then
      if code == 0x11 then -- TerminalEvents
        for _, event in ipairs(packet.events) do
          if event.name == "cloud_catcher_key" then
            local key = keys[event.args[1]]
            if type(key) == "number" then push_event { n = 3, "key", key, event.args[2] } end
          elseif event.name == "cloud_catcher_key_up" then
              local key = keys[event.args[1]]
              if type(key) == "number" then push_event { n = 2, "key_up", key } end
          else
            push_event(table.pack(event.name, table.unpack(event.args)))
          end
        end
      end
    elseif code >= 0x20 and code < 0x30 then
      if code == 0x22 then -- FileAction
        local result = {}
        for i, action in pairs(packet.actions) do
          local ok = bit32.band(action.flags, 0x1) == 1
          local expected_checksum = 0
          local handle = fs.open(action.file, "rb")
          if handle then
            local contents = handle.readAll()
            handle.close()
            expected_checksum = encode.fletcher_32(contents)
          end
          if not ok then
            ok = expected_checksum == 0 or action.checksum == expected_checksum
          end
          if not ok then
            result[i] = { file = action.file, checksum = expected_checksum, result = 2 }
          elseif action.action == 0x0 then -- Replace
            handle = fs.open(action.file, "wb")
            if handle then
              handle.write(action.contents)
              handle.close()
              result[i] = { file = action.file, checksum = encode.fletcher_32(action.contents), result = 1 }
            else
              result[i] = { file = action.file, checksum = expected_checksum, result = 3 }
            end
          elseif action.action == 0x1 then -- Patch
            handle = fs.open(action.file, "rb")
            if handle then
              local out, n = {}, 0
              for _, delta in pairs(action.delta) do
                if delta.kind == 0 then -- Same
                  n = n + 1
                  out[n] = handle.read(delta.length)
                elseif delta.kind == 1 then -- Added
                  n = n + 1
                  out[n] = delta.contents
                elseif delta.kind == 2 then -- Removed
                  handle.read(delta.length)
                end
              end
              handle.close()
              handle = fs.open(action.file, "wb")
              if handle then
                local contents = table.concat(out)
                handle.write(contents)
                handle.close()
                result[i] = { file = action.file, checksum = encode.fletcher_32(contents), result = 1 }
              else
                result[i] = { file = action.file, checksum = expected_checksum, result = 3 }
              end
            else
              result[i] = { file = action.file, checksum = expected_checksum, result = 2 }
            end
          elseif action.action == 0x02 then -- Delete
            local ok = fs.delete(action.file)
            result[i] = { file = action.file, checksum = action.checksum, result = ok and 1 or 3 }
          end
        end
        remote.send(json.stringify {
          packet = 0x23,
          id = packet.id,
          files = result,
        })
      end
    end
  elseif res == nil or event[1] == res or event[1] == "terminate" then
    if co then
      ok, res = coroutine.resume(co, table.unpack(event, 1, event.n))
    elseif event[1] == "terminate" then
      ok, res = false, "Terminated"
    end
  end
end
term.redirect(previous_term)
if previous_term == parent_term then
  term.clear()
  term.setCursorPos(1, 1)
  if previous_term.endPrivateMode then previous_term.endPrivateMode() end
end
_G.cloud_catcher = nil
shell.clearAlias("cloud")
shell.getCompletionInfo()[current_path] = nil
if remote ~= nil then remote.close() end
if not ok then error(res, 0) end
