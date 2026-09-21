--!nonstrict

local ActionScripts = require("../Config/ActionScripts.luau")
local ActionRunner = {}

function ActionRunner.run(actionId, group, selectedWindow)
  local scripts = ActionScripts.load()
  local script = scripts[actionId]
  if script == nil or tostring(script) == "" then return false end
  local path = tostring(script)
  local pluginDir = noctalia.pluginDir()
  if string.sub(path, 1, 1) ~= "/" and pluginDir ~= nil then path = pluginDir .. "/" .. path end
  local payload = {
    actionId = actionId,
    groupId = group and group.groupId or "",
    appId = group and group.appId or "",
    title = group and group.primaryTitle or "",
    windowCount = group and group.windowCount or 0,
    primaryWindowId = group and group.primaryWindowId or "",
    targetWindowId = selectedWindow and selectedWindow.id or (group and (group.focusedWindowId or group.primaryWindowId) or ""),
    windows = group and group.windows or {},
  }
  noctalia.runAsync({ path, noctalia.json.encode(payload) }, function(result)
    if result.exitCode ~= 0 then
      noctalia.log("action " .. tostring(actionId) .. " failed: " .. tostring(result.stderr or "unknown error"))
    end
  end)
  return true
end

return ActionRunner
