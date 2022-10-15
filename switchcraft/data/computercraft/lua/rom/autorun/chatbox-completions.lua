local completion = require("cc.completion")

shell.setCompletionFunction("rom/programs/chatbox.lua", function(shell, nIndex, sText, tPreviousText)
  if nIndex == 1 then
    return completion.choice(sText, {"register ", "remove", "debug"})
  elseif nIndex == 2 and tPreviousText[2] == "register" then
    return completion.choice(sText, {"guest"})
  end
end)
