-- SwitchCraft Street Sign
-- Lemmmy 2020

local bigfont = require("bigfont")

local leftText = settings.get("streetsign.leftText")
local streetName = settings.get("streetsign.streetName")
local rightText = settings.get("streetsign.rightText")

local unnamedStreet = settings.get("streetsign.unnamedStreet", "New Street")
local unnamedStreetHint = settings.get("streetsign.unnamedStreetHint", "Help name this street!")

local backgroundColourName = settings.get("streetsign.backgroundColour", "green")
local backgroundColour = colours[backgroundColourName]
local textColourName = settings.get("streetsign.textColour", "white")
local textColour = colours[textColourName]

if not colours[backgroundColourName] then
  error(string.format("Street Sign:\nBackground colour `%s` is invalid.", backgroundColourName), 0)
elseif not colours[textColourName] then
  error(string.format("Street Sign:\nText colour `%s` is invalid.", textColourName), 0)
end

local function draw(name, mon)
	mon.setTextScale(1)
	local w, h = mon.getSize()

	mon.setBackgroundColour(backgroundColour)
	mon.setTextColour(textColour)
	mon.clear()

	if streetName then
		bigfont.writeOn(mon, 1, streetName)

    if leftText then
      mon.setCursorPos(math.floor((w - (#streetName * 3)) / 2) - #(leftText), math.floor(h / 2) + 1)
      mon.write(leftText)
    end

    if rightText then
      mon.setCursorPos(math.floor((w - (#streetName * 3)) / 2) + (#streetName * 3) + 2, math.floor(h / 2) + 1)
      mon.write(rightText)
    end
	elseif unnamedStreet then
		bigfont.writeOn(mon, 1, unnamedStreet, nil, 2)

    if unnamedStreetHint then
      mon.setCursorPos(math.floor((w - #unnamedStreetHint) / 2) + 1, math.floor(h / 2) + 3)
      mon.write(unnamedStreetHint)
    end
	end
end

local function redraw()
  peripheral.find("monitor", draw)
end

local function printHelpText()
  local w = term.getSize()
  term.clear()
  term.setCursorPos(1, 1)

  local function writeOn(text, colour, relX, relY)
    local x, y = term.getCursorPos()
    local oldColour = term.getTextColour()

    term.setCursorPos(x + (relX or 0), y + (relY or 0))
    term.setTextColour(colour)
    print(text)
    term.setTextColour(oldColour)
  end

  local function writeCenter(text, colour, relY)
    writeOn(text, colour, math.ceil((w - #text) / 2) - 1, relY)
  end

  writeCenter("SwitchCraft Street Sign", colours.green, 1)

  local labelParts = {}
  table.insert(labelParts, leftText)
  table.insert(labelParts, streetName)
  table.insert(labelParts, rightText)
  local label = table.concat(labelParts, " ")
  writeCenter(streetName and label or "Street not named yet", streetName and colours.yellow or colours.red)

  writeOn(" Settings:", colours.yellow, 0, 1)
  writeOn(" - streetsign.streetName", colours.white)
  writeOn(" - streetsign.leftText", colours.white)
  writeOn(" - streetsign.rightText", colours.white)
  writeOn(" - streetsign.backgroundColour", colours.lightGrey)
  writeOn(" - streetsign.textColour", colours.lightGrey)
  writeOn(" Edit settings: `set <key> <value>`", colours.yellow, 0, 1)
  writeOn(" Customise: `cp /rom/programs/.streetsign.lua`", colours.yellow, 0, 0)
  writeOn(" Credits: `bigfont` API by Wojbie", colours.green, 0, 1)

  if not peripheral.find("monitor") then
    writeOn(" WARNING: No monitors found.", colours.red, 0, 1)
  end
end

printHelpText()
redraw()

while true do
  local _, name = os.pullEvent("peripheral", "peripheral_detach", "monitor_resize")
  printHelpText()
  redraw()
end