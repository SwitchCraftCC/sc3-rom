local GITHUB_API_URL = "https://api.github.com"

function githubLimits(key)
  key = key or _G._GIT_API_KEY or "guest"
  local headers = {}

  local url = GITHUB_API_URL .. "/rate_limit"
  if key ~= "guest" then
    headers.Authorization =  'token ' .. key
  end

  local h, err = http.get(url, headers)
  if not h or err then
    error("Error contacting GitHub API: " .. err)
  end

  return textutils.unserializeJSON(h.readAll())
end
