--!nonstrict

local Model = {}
Model.__index = Model

function Model.new()
  return setmetatable({
    groups = {},
    selectedIndex = 1,
    windowSelectionActive = false,
    selectedWindowId = "",
    recentIds = {},
    lastFocusedByGroup = {},
  }, Model)
end

function Model:selectedGroup()
  return self.groups[self.selectedIndex]
end

function Model:setGroups(groups, keepSelection, initialDirection)
  local previous = self:selectedGroup()
  self.groups = groups or {}
  local nextIndex = 1

  if keepSelection and previous then
    for index, group in ipairs(self.groups) do
      if group.groupId == previous.groupId then
        nextIndex = index
        break
      end
    end
  else
    if initialDirection then
    for index, group in ipairs(self.groups) do
      if group.hasFocusedWindow then
        nextIndex = index
        break
      end
    end
    end
  end

  self.selectedIndex = math.max(1, math.min(nextIndex, math.max(1, #self.groups)))
  local selected = self:selectedGroup()
  if self.windowSelectionActive and (selected == nil or #selected.windows < 2) then
    self:exitGroup()
  end
end

function Model:rememberSelection()
  local group = self:selectedGroup()
  if group == nil then return end
  self:rememberGroup(group.groupId)
end

function Model:rememberGroup(groupId)
  if groupId == nil or groupId == "" then return end
  for index = #self.recentIds, 1, -1 do
    if self.recentIds[index] == groupId then table.remove(self.recentIds, index) end
  end
  table.insert(self.recentIds, 1, groupId)
end

function Model:rememberFocusedGroup(groups)
  for _, group in ipairs(groups or {}) do
    if group.hasFocusedWindow then
      self:rememberGroup(group.groupId)
      return
    end
  end
end

function Model:displayGroups()
  local group = self:selectedGroup()
  if not self.windowSelectionActive or group == nil then return self.groups end
  local result = {}

  for _, window in ipairs(group.windows or {}) do
    table.insert(result, {
      groupId = window.id,
      appId = window.appId,
      iconPath = group.iconPath,
      primaryWindowId = window.id,
      primaryTitle = window.title,
      windowCount = 1,
      windows = { window },
      hasVisibleWindow = not window.isHidden,
      selectionCardHighlighted = group.selectionCardHighlighted,
      selectionCardAccentColor = group.selectionCardAccentColor,
    })
  end
  return result
end

function Model:move(direction, wrap)
  local groups = self:displayGroups()
  if #groups == 0 then return false end
  local index = self.selectedIndex

  if self.windowSelectionActive then
    for candidateIndex, group in ipairs(groups) do
      if group.primaryWindowId == self.selectedWindowId then
        index = candidateIndex
        break
      end
    end
  end

  local nextIndex = direction == "previous" and index - 1 or index + 1
  if nextIndex < 1 or nextIndex > #groups then
    if not wrap then return false end
    nextIndex = nextIndex < 1 and #groups or 1
  end

  if self.windowSelectionActive then
    self.selectedWindowId = groups[nextIndex].primaryWindowId
  else
    self.selectedIndex = nextIndex
  end
  return true
end

function Model:select(id)
  for index, group in ipairs(self:displayGroups()) do
    if group.groupId == id then
      if self.windowSelectionActive then
        self.selectedWindowId = group.primaryWindowId
      else
        self.selectedIndex = index
      end
      return true
    end
  end
  return false
end

function Model:enterGroup()
  local group = self:selectedGroup()
  if not group or group.isIntegrationEntry or #group.windows < 2 then return false end
  self.windowSelectionActive = true
  self.selectedWindowId = group.primaryWindowId
  return true
end

function Model:exitGroup()
  self.windowSelectionActive = false
  self.selectedWindowId = ""
end

function Model:targetWindowId(group)
  local target = self:targetWindow(group)
  return target and target.id or ""
end

function Model:selectedWindow()
  local group = self:selectedGroup()
  if not self.windowSelectionActive or not group then return nil end
  for _, window in ipairs(group.windows or {}) do
    if window.id == self.selectedWindowId then return window end
  end
  return nil
end

function Model:targetWindow(group)
  if not group then return nil end
  if group.isIntegrationEntry then return { id = group.primaryWindowId, isHidden = true } end
  local best, bestArea = group.windows[1], -1

  for _, window in ipairs(group.windows or {}) do
    local area = (tonumber(window.width) or 0) * (tonumber(window.height) or 0)
    if area > bestArea then best, bestArea = window, area end
  end
  return best or { id = group.primaryWindowId or "" }
end

return Model
