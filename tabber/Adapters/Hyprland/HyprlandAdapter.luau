--!nonstrict

local Adapter = {}
local Snapshot = require("../../Models/WindowSnapshot.luau")

local function decode(result)
  if result.exitCode ~= 0 then return nil end
  local value = noctalia.json.decode(result.stdout or "")
  return type(value) == "table" and value or nil
end

function Adapter.snapshot(callback)
  noctalia.runAsync({ "hyprctl", "-j", "clients" }, function(clientsResult)
    local clients = decode(clientsResult)
    if clients == nil then callback(nil); return end
    noctalia.runAsync({ "hyprctl", "-j", "activewindow" }, function(activeResult)
      noctalia.runAsync({ "hyprctl", "-j", "monitors" }, function(monitorsResult)
        noctalia.runAsync({ "hyprctl", "cursorpos", "-j" }, function(cursorResult)
          callback({
            clients = clients,
            active = decode(activeResult) or {},
            monitors = decode(monitorsResult) or {},
            cursor = decode(cursorResult) or {},
          })
        end)
      end)
    end)
  end)
end

function Adapter.monitorName(window, monitors)
  if window.monitorName ~= nil and tostring(window.monitorName) ~= "" then return tostring(window.monitorName) end
  local monitorId = tonumber(window.monitor)
  for _, monitor in ipairs(monitors or {}) do
    if tonumber(monitor.id) == monitorId then return tostring(monitor.name or "") end
  end
  return ""
end

function Adapter.focus(address)
  local window = type(address) == "table" and address or { id = address }
  local normalized = Snapshot.address(window.id)
  if normalized == "" then return end
  noctalia.runAsync({ "hyprctl", "cursorpos", "-j" }, function(cursorResult)
    local cursor = decode(cursorResult)
    noctalia.runAsync({
      "hyprctl",
      "dispatch",
      "hl.dsp.focus({ window = 'address:" .. normalized .. "' })",
    }, function()
      if cursor == nil then return end
      local x, y = tonumber(cursor.x), tonumber(cursor.y)
      if x == nil or y == nil then return end
      noctalia.runAsync({
        "hyprctl",
        "dispatch",
        "hl.dsp.cursor.move({ x = " .. tostring(x) .. ", y = " .. tostring(y) .. " })",
      })
    end)
  end)
end

function Adapter.focusedOutput(snapshot)
  local activeAddress = Snapshot.address(snapshot.active and snapshot.active.address)
  for _, window in ipairs(snapshot.clients or {}) do
    if Snapshot.address(window.address) == activeAddress then
      return Adapter.monitorName(window, snapshot.monitors)
    end
  end
  return ""
end

function Adapter.pointerOutput(snapshot)
  local cursor = snapshot.cursor or {}
  local x, y = tonumber(cursor.x), tonumber(cursor.y)
  if x == nil or y == nil then return Adapter.focusedOutput(snapshot) end

  for _, monitor in ipairs(snapshot.monitors or {}) do
    local left, top = tonumber(monitor.x) or 0, tonumber(monitor.y) or 0
    local width, height = tonumber(monitor.width) or 0, tonumber(monitor.height) or 0
    if x >= left and x < left + width and y >= top and y < top + height then
      return tostring(monitor.name or "")
    end
  end
  return Adapter.focusedOutput(snapshot)
end

function Adapter.raise(address)
  local normalized = Snapshot.address(address)
  if normalized ~= "" then
    noctalia.runAsync({
      "hyprctl",
      "dispatch",
      "hl.dsp.window.alter_zorder({ mode = 'top', window = 'address:" .. normalized .. "' })",
    })
  end
end

return Adapter
