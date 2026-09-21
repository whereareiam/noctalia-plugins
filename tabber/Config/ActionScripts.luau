--!nonstrict

local ActionScripts = {}

local function defaultScripts()
  return { close = "scripts/close-selected-group.sh" }
end

function ActionScripts.path()
  local dataDir = noctalia.pluginDataDir()
  return dataDir ~= nil and (dataDir .. "/actions.json") or nil
end

function ActionScripts.load()
  local path = ActionScripts.path()
  local raw = path ~= nil and noctalia.readFile(path) or nil
  if raw == nil then
    local defaults = defaultScripts()
    if path ~= nil then noctalia.writeFile(path, noctalia.json.encode(defaults, true)) end
    return defaults
  end
  local decoded = raw ~= nil and noctalia.json.decode(raw) or nil
  if type(decoded) ~= "table" then return {} end

  local scripts = {}
  for actionId, command in pairs(decoded) do
    if type(actionId) == "string" and type(command) == "string" and command ~= "" then
      scripts[actionId] = command
    end
  end
  return scripts
end

return ActionScripts
