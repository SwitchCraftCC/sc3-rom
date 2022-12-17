local SC_PASTE_ENDPOINT = "https://p.sc3.io" -- TODO
local SC_PASTE_NAME = "p.sc3.io"
local PASTEBIN_ENDPOINT = "https://pastebin.com"
local PASTEBIN_NAME = "pastebin.com"

local PASTE_ID_PATTERNS = {
  -- Raw ID
  "^([%a%d]+)$",

  -- SCPaste
  "^https?://p.sc3.io/([%a%d]+)$",
  "^p.sc3.io/([%a%d]+)$",
  "^https?://p.sc3.io/api/v1/pastes/([%a%d]+)(/raw/?)?$",
  "^p.sc3.io/api/v1/pastes/([%a%d]+)(/raw/?)?$",

  -- Pastebin
  "^https?://pastebin.com/([%a%d]+)$",
  "^pastebin.com/([%a%d]+)$",
  "^https?://pastebin.com/raw/([%a%d]+)$",
  "^pastebin.com/raw/([%a%d]+)$",
}

local function printUsage()
  local programName = arg[0] or fs.getName(shell.getRunningProgram())
  print("Usages:")
  print(programName .. " put <filename>")
  print(programName .. " get <code> <filename>")
  print(programName .. " run <code> <arguments>")
end

local tArgs = { ... }
if #tArgs < 2 then
  printUsage()
  return
end

if not http then
  printError("Pastebin requires the http API, but it is not enabled")
  printError("Set http.enabled to true in CC: Tweaked's server config")
  return
end

local function writeCol(color, text)
  if (term.isColor()) then
    term.setTextColor(color)
  end

  write(text)
end

--- Attempts to guess the pastebin ID from the given code or URL. Returns the
-- URL of the raw paste content. 8-digit paste IDs will be assumed to be
-- Pastebin and 10-digit paste IDs (and all others) will be assumed to be
-- SCPaste, regardless of the paste URL.
local function extractRawUrl(paste)
  for i = 1, #PASTE_ID_PATTERNS do
    local code = paste:match(PASTE_ID_PATTERNS[i])
    if code then
      local encoded = textutils.urlEncode(code)
      if #code == 8 then
        return PASTEBIN_ENDPOINT .. "/raw/" .. encoded, code, PASTEBIN_NAME
      else
        return SC_PASTE_ENDPOINT .. "/api/v1/pastes/" .. encoded .. "/raw",
          code, SC_PASTE_NAME
      end
    end
  end

  return nil, nil
end

local function printTryAgain(errResponse)
  if errResponse then
    local headers = errResponse.getResponseHeaders()
    if headers["Retry-After"] then
      printError("Try again in " .. headers["Retry-After"] .. " seconds...")
    end
  end
end

local function get(url)
  local rawUrl, paste, siteName = extractRawUrl(url)
  if not rawUrl then
    io.stderr:write("Invalid paste code.\n")
    io.write("The code is the ID at the end of the p.sc3.io or pastebin.com URL.\n")
    return
  end

  writeCol(colors.lightGray, "Connecting to ")
  writeCol(siteName == "p.sc3.io" and colors.lime or colors.yellow, siteName)
  writeCol(colors.lightGray, "... ")

  -- Add a cache buster so that Pastebin spam protection is re-checked
  local cacheBuster = ("%x"):format(math.random(0, 2 ^ 30))
  local response, err, errResponse = http.get(rawUrl .. "?cb=" .. cacheBuster)

  if response then
    -- If Pastebin spam protection is activated, we get redirected to /paste
    -- with Content-Type: text/html
    local headers = response.getResponseHeaders()
    if not headers["Content-Type"] or not headers["Content-Type"]:find("^text/plain") then
      printError("Failed.")

      if siteName == PASTEBIN_NAME then
        printError("Pastebin blocked the download due to spam protection. Please complete the captcha in a web browser: https://pastebin.com/" .. textutils.urlEncode(paste))
      end

      return
    end

    writeCol(colors.lime, "Success.\n")
    term.setTextColor(colors.white)

    local sResponse = response.readAll()
    response.close()
    return sResponse
  else
    printError("Failed.\n")

    printError(err)
    printTryAgain(errResponse)
  end
end

local sCommand = tArgs[1]
if sCommand == "put" then
  -- Upload a file to SCPaste
  -- Determine file to upload
  local sFile = tArgs[2]
  local sPath = shell.resolve(sFile)
  if not fs.exists(sPath) or fs.isDir(sPath) then
    print("No such file")
    return
  end

  -- Read in the file
  local sName = fs.getName(sPath)
  local file = fs.open(sPath, "r")
  local sText = file.readAll()
  file.close()

  local w = term.getSize()
  term.setTextColor(colors.yellow)
  print(("\140"):rep(w))
  write("New! ")
  term.setTextColor(colors.white)
  write("Pastes made on SwitchCraft will be uploaded to our paste site, ")
  writeCol(term.isColor() and colors.lime or colors.white, "SCPaste")
  term.setTextColor(colors.white)
  print(". ")
  term.setTextColor(colors.yellow)
  print(("\140"):rep(w) .. "\n")

  -- POST the contents to pastebin
  writeCol(colors.lightGray, "Connecting to ")
  writeCol(colors.lime, SC_PASTE_NAME)
  writeCol(colors.lightGray, "... ")

  local response, err, errResponse = http.post(
    SC_PASTE_ENDPOINT .. "/api/v1/pastes" ..
    "?language=lua" ..
    "&name=" .. textutils.urlEncode(sName),
    sText,
    { ["Content-Type"] = "text/plain" }
  )

  if response then
    writeCol(colors.lime, "Success.\n")
    term.setTextColor(colors.white)

    local sCode = response.readAll()
    response.close()

    writeCol(colors.white, "Uploaded as ")
    writeCol(colors.blue, SC_PASTE_ENDPOINT .. "/" .. textutils.urlEncode(sCode) .. "\n")
    writeCol(colors.white, "Run \"")
    writeCol(colors.blue, "pastebin get " .. sCode)
    writeCol(colors.white, "\" to download anywhere\n")
  else
    printError("Failed.\n")

    printError(err)
    printTryAgain(errResponse)
  end
elseif sCommand == "get" then
  -- Download a file from the guessed paste service
  if #tArgs < 3 then
    printUsage()
    return
  end

  -- Determine file to download
  local sCode = tArgs[2]
  local sFile = tArgs[3]
  local sPath = shell.resolve(sFile)
  if fs.exists(sPath) then
    printError("File already exists")
    return
  end

  -- GET the contents from the service
  local res = get(sCode)
  if res then
    local file = fs.open(sPath, "w")
    file.write(res)
    file.close()

    print("Downloaded as " .. sFile)
  end
elseif sCommand == "run" then
  local sCode = tArgs[2]

  local res = get(sCode)
  if res then
    local func, err = load(res, sCode, "t", _ENV)
    if not func then
      printError(err)
      return
    end
    local success, msg = pcall(func, select(3, ...))
    if not success then
      printError(msg)
    end
  end
else
  printUsage()
  return
end
