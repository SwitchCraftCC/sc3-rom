-- Shim for /rom/modules/main/chatbox.lua
-- This is purely for compatibility; if you're writing a new script, use the module.
local chatbox = dofile("/rom/modules/main/chatbox.lua")

SERVER_URL = chatbox.SERVER_URL
closeReasons = chatbox.closeReasons
_shouldStart = chatbox._shouldStart
say = chatbox.say
tell = chatbox.tell
stop = chatbox.stop
run = chatbox.run
getError = chatbox.getError
isConnected = chatbox.isConnected
getLicenseOwner = chatbox.getLicenseOwner
getCapabilities = chatbox.getCapabilities
getPlayers = chatbox.getPlayers
getPlayerList = chatbox.getPlayerList
hasCapability = chatbox.hasCapability
