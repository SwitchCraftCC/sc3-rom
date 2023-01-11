local chatbox = require("chatbox")

local args = {...}

local events = {"join", "leave", "death", "chat_ingame", "chat_discord", "chat_chatbox", "command", "afk", "afk_return", "server_restart_scheduled", "server_restart_cancelled"}

local function printUsage()
  printError(
    "Usage: \n" ..
    "  chatbox register <license>\n" ..
    "  chatbox register guest\n" ..
    "  chatbox remove\n\n" ..
    "Obtain a license key with /chatbox."
  )
end

if #args < 1 then
  printUsage()
else
  local command = args[1]

  if command == "register" then
    if #args ~= 2 then
      printUsage()
    else
      local key = args[2]:gsub("%s+", "")
      settings.set("chatbox.license_key", key)
      settings.save("/.settings")

      local oldColour = term.getTextColour()

      term.setTextColour(colours.green)
      write("Success! ")
      term.setTextColour(colours.lime)
      print("Your chatbox license key has been changed. A reboot is required for the changes to take effect.")

      term.setTextColour(colours.white)
      write("\nDo you want to reboot now? y/N ")
      term.setTextColour(colours.lightGrey)
      local answer = read()

      if answer:lower():gsub("%s+", "") == "y" then
        os.reboot()
      end

      term.setTextColour(oldColour)
    end
  elseif command == "remove" then
    if chatbox then chatbox.stop() end
    settings.unset("chatbox.license_key")
    settings.save("/.settings")
  elseif command == "debug" then
    while true do
      local eventData = {os.pullEvent()}

      for _, name in pairs(events) do
        if eventData[1] == name then
          for _, value in pairs(eventData) do
            write((type(value) == "table" and "table" or textutils.serialise(value)) .. " ")
          end
          print("")
          break
        end
      end
    end
  else
    printError("Unknown command '" .. command .. "'.\n")
    printUsage()
  end
end
