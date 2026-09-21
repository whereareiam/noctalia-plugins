--!nonstrict

local Snapshot = require("./WindowSnapshot.luau")
local Constants = require("../Core/Constants.luau")
local Builder = {}

local function nonBlank(value)
  local text = string.match(tostring(value or ""), "^%s*(.-)%s*$") or ""
  return text ~= "" and text or nil
end

local function appIdFor(client)
  return nonBlank(client.class)
    or nonBlank(client.initialClass)
    or nonBlank(client.appId)
    or ""
end

local function titleFor(client)
  local title = nonBlank(client.title) or nonBlank(client.initialTitle)
  if title ~= nil then return title end
  local appId = appIdFor(client)
  return appId ~= "" and appId or Constants.Window.DefaultTitle
end

local function groupIdFor(client, groupByApp)
  if not groupByApp then return "window-" .. Snapshot.address(client.address) end
  local value = string.lower(appIdFor(client) ~= "" and appIdFor(client) or titleFor(client))
  value = string.gsub(value, "[^%w%._-]+", "-")
  return value ~= "" and value or "unknown"
end

local function appendRecent(groups, recentIds)
  local byId, recent, remaining = {}, {}, {}
  for _, group in ipairs(groups) do byId[group.groupId] = group end
  for _, groupId in ipairs(recentIds) do
    if byId[groupId] ~= nil then
      table.insert(recent, byId[groupId])
      byId[groupId] = nil
    end
  end
  local visible, hidden = {}, {}
  for _, group in ipairs(recent) do table.insert(group.hasVisibleWindow and visible or hidden, group) end
  for _, group in ipairs(groups) do
    if byId[group.groupId] ~= nil then
      table.insert(remaining, group)
      byId[group.groupId] = nil
    end
  end
  for _, group in ipairs(remaining) do table.insert(group.hasVisibleWindow and visible or hidden, group) end
  for _, group in ipairs(hidden) do table.insert(visible, group) end
  return visible
end

function Builder.build(snapshot, options, integrationEntries, recentIds, lastFocusedByGroup, iconCache, monitorName)
  local activeAddress = Snapshot.address(snapshot.active and snapshot.active.address)
  local byId, order, visibleIds = {}, {}, {}

  for _, client in ipairs(snapshot.clients or {}) do
    local workspace = client.workspace or {}
    local appId = appIdFor(client)
    local output = monitorName(client, snapshot.monitors)
    local usable = client.mapped ~= false
      and client.hidden ~= true
      and not Snapshot.isSpecialWorkspace(workspace)
      and (appId ~= "" or titleFor(client) ~= "")
      and (options.focusedOutput == "" or output == options.focusedOutput)

    if usable then
      local address = Snapshot.address(client.address)
      local window = {
        id = address,
        title = titleFor(client),
        appId = appId,
        workspaceId = tostring(workspace.name or workspace.id or ""),
        output = output,
        isFocused = address == activeAddress or client.focusHistoryID == 0,
        focusHistoryId = tonumber(client.focusHistoryID),
        width = tonumber((client.size or {})[1]) or 0,
        height = tonumber((client.size or {})[2]) or 0,
        isHidden = false,
      }
      local groupId = groupIdFor(client, options.groupWindowsByApp)
      if byId[groupId] == nil then
        local icon = iconCache[appId]
        if icon == nil and appId ~= "" then
          icon = noctalia.appIconPath(appId, options.iconSize)
          iconCache[appId] = icon or false
        end
        byId[groupId] = {
          groupId = groupId,
          appId = appId,
          iconPath = icon ~= false and icon or nil,
          windows = {},
          hasVisibleWindow = true,
          hasFocusedWindow = false,
          focusedWindowId = "",
        }
        table.insert(order, groupId)
      end
      table.insert(byId[groupId].windows, window)
      byId[groupId].hasFocusedWindow = byId[groupId].hasFocusedWindow or window.isFocused
      if window.isFocused then byId[groupId].focusedWindowId = window.id end
      visibleIds[address] = true
    end
  end

  local groups = {}
  for _, groupId in ipairs(order) do
    local group = byId[groupId]
    local preferred = group.windows[1]
    for _, window in ipairs(group.windows) do
      if window.isFocused or window.id == lastFocusedByGroup[groupId] then
        preferred = window
        break
      end
    end
    group.primaryWindowId = preferred.id
    group.primaryTitle = preferred.title
    group.windowCount = #group.windows
    for _, window in ipairs(group.windows) do
      if window.isFocused then lastFocusedByGroup[groupId] = window.id end
    end
    table.insert(groups, group)
  end

  for _, group in ipairs(integrationEntries or {}) do
    local address = Snapshot.address(group.primaryWindowId)
    if address ~= "" and not visibleIds[address] then table.insert(groups, group) end
  end

  return appendRecent(groups, recentIds)
end

return Builder
