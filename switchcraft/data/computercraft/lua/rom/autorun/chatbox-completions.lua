local completion = require("cc.shell.completion")

shell.setCompletionFunction("rom/programs/chatbox.lua", completion.build(
  { completion.choice, { "register ", "remove", "debug", } }
))
