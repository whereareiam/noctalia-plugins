--!nonstrict

local Constants = require("../Core/Constants.luau")
local Snapshot = require("../Models/WindowSnapshot.luau")

local Provider = {}
Provider.__index = Provider

function Provider.new()
  local runtimeDir = noctalia.getenv("XDG_RUNTIME_DIR") or ""
  return setmetatable({
    runtimeDir = runtimeDir,
    hiddenPath = runtimeDir ~= "" and (
      runtimeDir .. "/" .. Constants.Integration.VeilRuntimeDirectory .. "/" .. Constants.Integration.VeilStateFile
    ) or nil,
    targetPath = runtimeDir ~= "" and (
      runtimeDir .. "/" .. Constants.Integration.VeilRuntimeDirectory .. "/" .. Constants.Integration.VeilSelectionTargetFile
    ) or nil,
  }, Provider)
end

function Provider:id()
  return Constants.Integration.VeilId
end

function Provider:readState()
  if self.hiddenPath == nil then return {} end
  local raw = noctalia.readFile(self.hiddenPath)
  if raw == nil or raw == "" then return {} end
  local parsed = noctalia.json.decode(raw)
  return type(parsed) == "table" and (parsed.windows or parsed) or {}
end

function Provider:entries(options)
  if not options.veilEnabled then return {} end
  local result = {}
  for _, entry in ipairs(self:readState()) do
    local address = Snapshot.address(entry.address)
    if address ~= "" and (options.focusedOutput == "" or tostring(entry.output or "") == options.focusedOutput) then
      local appId = tostring(entry.appId or "")
      local iconPath = appId ~= "" and noctalia.appIconPath(appId, options.iconSize) or nil
      local window = {
        id = address,
        title = tostring(entry.title or appId or Constants.Window.HiddenTitle),
        appId = appId,
        workspaceId = tostring(entry.workspace or Constants.Window.HiddenWorkspace),
        output = tostring(entry.output or ""),
        isFocused = false,
        width = 0,
        height = 0,
        isHidden = true,
      }
      table.insert(result, {
        groupId = Constants.Window.VeilGroupPrefix .. address,
        appId = appId,
        iconPath = iconPath,
        windows = { window },
        primaryWindowId = address,
        primaryTitle = window.title,
        windowCount = 1,
        hasVisibleWindow = false,
        isIntegrationEntry = true,
        integrationId = self:id(),
        selectionCardHighlighted = options.veilHighlight,
        selectionCardAccentColor = options.veilAccent,
      })
    end
  end
  return result
end

function Provider:activate(entry)
  if entry == nil or entry.primaryWindowId == nil then return false end
  noctalia.runAsync({ "noctalia", "msg", "plugin", Constants.Plugin.VeilServiceId, "all", Constants.Event.Restore, entry.primaryWindowId })
  return true
end

function Provider:publishTarget(target)
  if self.targetPath == nil then return end
  noctalia.mkdirAll(self.runtimeDir .. "/" .. Constants.Integration.VeilRuntimeDirectory)
  noctalia.writeFile(self.targetPath, noctalia.json.encode(target or {}))
end

return Provider
