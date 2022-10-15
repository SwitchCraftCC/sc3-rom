-- SwitchCraft monitor-ident
-- Lemmmy 2020

local MONITOR_ADV_COLOURS_BG = { 
  -- colours.black, colours.grey, colours.lightGrey, colours.white, 
  colours.red, colours.orange, colours.yellow, colours.lime, 
  colours.green, colours.cyan, colours.lightBlue, colours.blue, 
  colours.purple, colours.magenta, colours.pink, colours.brown 
}

local MONITOR_ADV_COLOURS_FG = { 
  -- colours.white, colours.white, colours.white, colours.black, 
  colours.white, colours.black, colours.black, colours.black, 
  colours.white, colours.white, colours.black, colours.white, 
  colours.white, colours.white, colours.black, colours.white 
}

local MONITOR_BASIC_COLOURS_BG = { 
  colours.black, colours.grey, colours.lightGrey, colours.white
}

local MONITOR_BASIC_COLOURS_FG = { 
  colours.white, colours.white, colours.white, colours.black
}

local args = { ... }

local oldBG = term.getBackgroundColour()
local oldFG = term.getTextColour()
local textScale = 1

if #args >= 1 then
  local parsedScale = tonumber(args[1])
  if not parsedScale then error("Invalid text scale " .. args[1], 0) end
  
  local flooredScale = math.floor(parsedScale)
  if (parsedScale ~= flooredScale or flooredScale <= 0 or flooredScale > 5) and args[1] ~= "0.5" then -- weird, but whatever
    error("Invalid text scale " .. args[1], 0)
  end

  textScale = parsedScale
  term.setTextColour(colours.lightGrey)
  print("Using text scale " .. parsedScale)
  term.setTextColour(oldFG)
else
  term.setTextColour(colours.lightGrey)
  print("Hint: Pass text scale: `monitor-ident 0.5`")
  term.setTextColour(oldFG)
end

local monitors = {}
local monitorCount = 0

peripheral.find("monitor", function (name, mon)
  table.insert(monitors, {
    name = name,
    mon = mon
  })
end)

if #monitors == 0 then
  error("No monitors found.", 0)
end

local advMonitors = _.reduce(monitors, function(sum, m) return sum + (m.mon.isColour() and 1 or 0) end, 0)
local basicMonitors = #monitors - advMonitors

print(string.format(
  "Found %d basic monitor%s, %d advanced monitor%s:\n", 
  basicMonitors, basicMonitors == 1 and "" or "s", 
  advMonitors, advMonitors == 1 and "" or "s"
))

-- sort the monitors by ID (for semi-consistent results)
local function padnum(d) return ("%03d%s"):format(#d, d) end
table.sort(monitors, function(a, b) return tostring(a.name):gsub("%d+", padnum) < tostring(b.name):gsub("%d+", padnum) end)

local function centerWrite(mon, w, text, y)
  mon.setCursorPos(math.ceil((w - #text) / 2) + 1, y)
  mon.write(text)
end

local i_b = 0
local i_a = 0
for i, m in pairs(monitors) do
  local name = m.name
  local mon = m.mon

  local bgColour = mon.isColour() 
    and MONITOR_ADV_COLOURS_BG[(i_a % #MONITOR_ADV_COLOURS_BG) + 1]
    or MONITOR_BASIC_COLOURS_BG[(i_b % #MONITOR_BASIC_COLOURS_BG) + 1]
  local fgColour = mon.isColour() 
    and MONITOR_ADV_COLOURS_FG[(i_a % #MONITOR_ADV_COLOURS_FG) + 1]
    or MONITOR_BASIC_COLOURS_FG[(i_b % #MONITOR_BASIC_COLOURS_FG) + 1]

  mon.setBackgroundColour(bgColour)
  mon.setTextColour(fgColour)
  mon.setTextScale(textScale)
  mon.clear()

  local w, h = mon.getSize()
  local cy = math.ceil(h / 2)

  centerWrite(mon, w, name, cy)
  centerWrite(mon, w, string.format("%dx%d", w, h), cy + 1)

  if h >= 3 then
    centerWrite(mon, w, string.format("px: %dx%d", w * 2, h * 3), cy + 2)
  end

  term.setBackgroundColour(bgColour)
  term.setTextColour(fgColour)
  write(name)
  term.setBackgroundColour(oldBG)
  term.setTextColour(oldFG)
  write(" ")

  if mon.isColour() then i_a = i_a + 1
  else i_b = i_b + 1 end
end

-- remove overflowing colour on the last line
local w, h = term.getSize()
local x, y = term.getCursorPos()
if x < w then
  write((" "):rep(w - x + 1))
end

print("")