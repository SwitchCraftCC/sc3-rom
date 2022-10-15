local args = {...}

local function printUsage()
  printError("Usage: github limits [key|guest]")
  error()
end

if args[1] ~= "limits" then
  printUsage()
end

local limits = switchcraft.githubLimits(args[2])
if not limits then error("Unable to get rate limits from GitHub API") end

local function writeLine(caption, value)
  local oldColour = term.getTextColour()

  term.setTextColour(colours.lightGrey)
  write(caption .. ": ")

  local valueColour = type(value) == "number"
    and (value <= 5 and colours.red or colours.white)
    or colours.white
  term.setTextColour(valueColour)
  print(value)

  term.setTextColour(oldColour)
end

print("GitHub API Rate Limits:")
writeLine("Limit", limits.rate.limit)
writeLine("Remaining", limits.rate.remaining)

local resetDate = os.date("%Y-%m-%d %H:%M:%S", limits.rate.reset)
local resetSeconds = limits.rate.reset - math.floor(os.epoch("utc") / 1000)
local resetTime = string.format("%dm %ds", math.floor(resetSeconds / 60), math.floor(resetSeconds % 60))

writeLine("Resets", string.format("%s (in %s)", resetDate, resetTime))
