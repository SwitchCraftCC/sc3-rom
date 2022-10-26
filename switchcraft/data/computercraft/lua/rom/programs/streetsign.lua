local oldColour = term.getTextColour()

local program = [[-- SwitchCraft Street Sign
-- Lemmmy 2020

if multishell then
  local tab = multishell.launch({ shell = shell, multishell = multishell, package = package, require = require }, shell.resolveProgram(".streetsign"))
  multishell.setTitle(tab, "Street Sign")
  multishell.setFocus(tab)
else
  shell.run(".streetsign")
end
]]

print()
term.setTextColour(colours.green)
print("SwitchCraft Street Sign")
term.setTextColour(colours.lime)
print("All values are optional. Press enter to skip.")
print()

local function field(key, name)
  term.setTextColour(colours.white)
  term.write(name .. ": ")
  term.setTextColour(colours.lightGrey)
  local value = read()
  value = (value and #value > 0) and value or nil
  if value then
    settings.set(key, value)
  end
  return value
end

local streetName = field("streetsign.streetName", "Street name")
local leftText = field("streetsign.leftText", "Left text")
local rightText = field("streetsign.rightText", "Right text")

settings.set("motd.enable", false)
settings.set("shell.allow_disk_startup", false)
settings.save("/.settings")
term.setTextColour(colours.green)
print()
print("Settings saved.")

if fs.exists("/startup/10_streetsign.lua") then
  error("`/startup/10_streetsign.lua` already exists!", 0)
end

local f = fs.open("/startup/10_streetsign.lua", "w")
f.write(program)
f.close()

if not os.getComputerLabel() then
  local labelParts = {}
  table.insert(labelParts, leftText)
  table.insert(labelParts, streetName)
  table.insert(labelParts, rightText)
  local label = table.concat(labelParts, " ")
  
  os.setComputerLabel(label)
  term.setTextColour(colours.green)
  print("Computer label set to `" .. label .. "`")
end

term.setTextColour(colours.green)
print("Street sign created and added to startup. Reboot now.")
print()

term.setTextColour(oldColour)
