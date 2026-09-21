--!nonstrict

local Constants = require("../../Core/Constants.luau")
local Adapter = {}

local function decode(result)
  if result.exitCode ~= 0 then return nil end
  local value = noctalia.json.decode(result.stdout or "")
  return type(value) == "table" and value or nil
end

function Adapter.clients(callback)
  noctalia.runAsync({ "hyprctl", "-j", "clients" }, function(result)
    callback(decode(result))
  end)
end

function Adapter.hide(address)
  local expression =
    "hl.dsp.window.move({ workspace = '" .. Constants.Window.HiddenWorkspace
      .. "', window = 'address:" .. address .. "', follow = false })"
  noctalia.runAsync({
    "hyprctl",
    "dispatch",
    expression,
  })
end

function Adapter.restore(address, workspace, callback)
  local escapedWorkspace = string.gsub(tostring(workspace or ""), "'", "\\'")
  if escapedWorkspace == "" then
    callback(false)
    return
  end
  local expression =
    "hl.dsp.window.move({ workspace = '" .. escapedWorkspace
      .. "', window = 'address:" .. address .. "', follow = false })"
  noctalia.runAsync({
    "hyprctl",
    "dispatch",
    expression,
  }, function(result)
    if result.exitCode ~= 0 then
      noctalia.log("failed to restore window: " .. tostring(result.stderr or "unknown error"))
      callback(false)
      return
    end
    noctalia.runAsync({
      "hyprctl",
      "dispatch",
      "hl.dsp.focus({ window = 'address:" .. address .. "' })",
    })
    callback(true)
  end)
end

function Adapter.close(address)
  noctalia.runAsync({
    "hyprctl",
    "dispatch",
    "hl.dsp.window.close({ window = 'address:" .. address .. "' })",
  })
end

return Adapter
