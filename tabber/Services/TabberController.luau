--!nonstrict

local ActionRunner = require("../Actions/ActionRunner.luau")
local Constants = require("../Core/Constants.luau")
local Settings = require("../Config/TabberSettings.luau")
local Groups = require("../Models/WindowGroupBuilder.luau")
local SelectionModel = require("../Models/SelectionModel.luau")

local Controller = {}
Controller.__index = Controller

local triggerDebounceMs = 70
local panelCloseTimeoutMs = 250
local earlyAcceptGraceMs = 140

local function nowMs()
  return noctalia.nowMs and noctalia.nowMs() or math.floor(os.clock() * 1000)
end

local function normalizeDirection(direction)
  return direction == Constants.Direction.Previous and Constants.Direction.Previous or Constants.Direction.Next
end

function Controller.new(windowCatalog, integrations)
  local self = setmetatable({
    model = SelectionModel.new(),
    windowCatalog = windowCatalog,
    integrations = integrations,
    view = { overlayVisible = false },
    panelOpen = false,
    panelOpening = false,
    panelOpeningAt = 0,
    refreshInFlight = false,
    refreshPending = false,
    refreshPendingKeepSelection = nil,
    refreshCallbacks = {},
    initialDirection = nil,
    pendingDirections = {},
    pendingAccept = false,
    earlyAcceptAt = 0,
    opening = false,
    sessionOutput = "",
    continuousStartedAt = 0,
    lastContinuousAt = 0,
    iconCache = {},
    sessionId = 0,
    panelClosing = false,
    panelClosingAt = 0,
    pendingOpenDirection = nil,
    lastTriggerDirection = "",
    lastTriggerAt = 0,
  }, Controller)
  self:refresh(false)
  return self
end

function Controller:publish()
  local group = self.model:selectedGroup()
  self.view.groups = self.model.groups
  self.view.displayGroups = self.model:displayGroups()
  self.view.selectedIndex = self.model.selectedIndex
  self.view.selectedWindowId = self.model.selectedWindowId
  self.view.windowSelectionActive = self.model.windowSelectionActive
  self.integrations:publishTarget(self.view.overlayVisible and group and {
    windowId = self.model:targetWindowId(group),
    groupId = group.groupId,
  } or {})
  noctalia.state.set(Constants.State.View, self.view)
end

function Controller:refresh(keepSelection, onComplete)
  if self.refreshInFlight then
    self.refreshPending = true
    if self.refreshPendingKeepSelection == nil then
      self.refreshPendingKeepSelection = keepSelection
    else
      self.refreshPendingKeepSelection = self.refreshPendingKeepSelection and keepSelection
    end
    if onComplete ~= nil then table.insert(self.refreshCallbacks, onComplete) end
    return
  end
  self.refreshInFlight = true
  self.windowCatalog:snapshot(function(snapshot)
    if snapshot ~= nil then
      local options = Settings.windowCatalogOptions()
      if options.restrictToCurrentMonitor then
        -- On an empty monitor Hyprland keeps the previous window focused on a
        -- different output. The pointer identifies the monitor where the
        -- switcher was invoked; retain it for this session after opening.
        if self.sessionOutput == "" then self.sessionOutput = self.windowCatalog:pointerOutput(snapshot) end
        options.focusedOutput = self.sessionOutput
      end
      local integrationEntries = self.integrations:entries(options)
      local function buildGroups()
        return Groups.build(
          snapshot,
          options,
          integrationEntries,
          self.model.recentIds,
          self.model.lastFocusedByGroup,
          self.iconCache,
          function(window, monitors) return self.windowCatalog:monitorName(window, monitors) end
        )
      end
      local groups = buildGroups()
      -- v4 promoted only the currently focused group. Reordering every group
      -- from focusHistoryID makes the list jump as Hyprland refreshes clients.
      self.model:rememberFocusedGroup(groups)
      groups = buildGroups()
      self.model:setGroups(groups, keepSelection, self.initialDirection)

      self.initialDirection = nil
      if onComplete ~= nil then onComplete() end
      self:publish()
    end
    if snapshot == nil then
      if onComplete ~= nil then onComplete() end
    end
    self.refreshInFlight = false
    if self.refreshPending then
      local pendingKeepSelection = self.refreshPendingKeepSelection ~= false
      local callbacks = self.refreshCallbacks
      self.refreshPending = false
      self.refreshPendingKeepSelection = nil
      self.refreshCallbacks = {}
      self:refresh(pendingKeepSelection, function()
        for _, callback in ipairs(callbacks) do callback() end
      end)
    end
  end)
end

function Controller:open(direction)
  direction = normalizeDirection(direction)
  if self.opening then
    table.insert(self.pendingDirections, direction)
    return
  end
  -- The panel API is a toggle. Never send a second toggle while the previous
  -- panel instance is opening, open, or closing; it would invert its state.
  if self.panelOpening or self.panelOpen or self.panelClosing then
    self.pendingOpenDirection = direction
    if self.panelOpen and not self.panelClosing then
      self.panelClosing = true
      self.panelClosingAt = nowMs()
      noctalia.togglePanel(Constants.Plugin.OverlayPanelId)
    end
    return
  end
  self.sessionId = self.sessionId + 1
  local sessionId = self.sessionId
  local earlyAccept = self.earlyAcceptAt ~= 0
    and nowMs() - self.earlyAcceptAt <= earlyAcceptGraceMs
  self.earlyAcceptAt = 0
  self.initialDirection = direction
  self.pendingDirections = { direction }
  self.pendingAccept = earlyAccept
  self.opening = true
  self.sessionOutput = ""
  self.model:exitGroup()
  self.continuousStartedAt, self.lastContinuousAt = os.clock(), 0
  self:refresh(false, function()
    -- A snapshot may complete after the panel has closed or after a later
    -- session started. It must not mutate either one.
    if sessionId ~= self.sessionId or not self.opening then return end
    for _, pendingDirection in ipairs(self.pendingDirections) do self.model:move(pendingDirection, true) end
    self.pendingDirections = {}
    self.opening = false
    local shouldAccept = self.pendingAccept
    self.pendingAccept = false
    self.view.overlayVisible = true
    self.view.sessionId = sessionId
    self:publish()
    if shouldAccept then self:accept(); return end
    -- The panel is opened only after the current focus has been promoted and
    -- the initial move has been selected. This keeps the list fixed under the
    -- cursor instead of showing the previous session's MRU order first.
    self.panelOpening = true
    self.panelOpeningAt = nowMs()
    noctalia.togglePanel(Constants.Plugin.OverlayPanelId)
  end)
end

function Controller:trigger(direction)
  direction = normalizeDirection(direction)
  local now = nowMs()
  if self.view.overlayVisible
      and self.lastTriggerDirection == direction
      and now - self.lastTriggerAt < triggerDebounceMs then return end
  self.lastTriggerDirection = direction
  self.lastTriggerAt = now
  self.view.lastDirection = direction
  if not self.view.overlayVisible then
    self:open(direction)
    return
  end
  if self.opening or self.panelClosing then
    table.insert(self.pendingDirections, direction)
    if self.panelClosing then self.pendingOpenDirection = direction end
    return
  end
  self.model:move(direction, true)
  self:publish()
  self.continuousStartedAt, self.lastContinuousAt = os.clock(), 0
end

function Controller:stopContinuousCycle()
  self.continuousStartedAt = 0
  self.lastContinuousAt = 0
end

function Controller:hide(closePanel)
  if not self.view.overlayVisible and not self.panelOpen and not self.panelOpening then return end
  self:stopContinuousCycle()
  self.view.overlayVisible = false
  self.model:exitGroup()
  self:publish()
  if closePanel ~= false and self.panelOpen and not self.panelClosing then
    self.panelClosing = true
    self.panelClosingAt = nowMs()
    noctalia.togglePanel(Constants.Plugin.OverlayPanelId)
  end
end

function Controller:handlePanelClosed(sessionId)
  if sessionId ~= self.sessionId then return end
  if not self.panelOpen and not self.panelOpening and not self.panelClosing then return end
  self:stopContinuousCycle()
  local pendingDirection = self.pendingOpenDirection
  local pendingAccept = self.pendingAccept
  self.panelOpen = false
  self.panelOpening = false
  self.panelOpeningAt = 0
  self.panelClosing = false
  self.panelClosingAt = 0
  self.view.overlayVisible = false
  self.model:exitGroup()
  self.initialDirection = nil
  self.pendingDirections = {}
  self.pendingAccept = pendingDirection ~= nil and pendingAccept or false
  self.opening = false
  self.sessionOutput = ""
  self:publish()
  self.pendingOpenDirection = nil
  if pendingDirection ~= nil then self:open(pendingDirection) end
end

function Controller:accept(allowEarlyAccept)
  if self.panelClosing then
    if self.pendingOpenDirection ~= nil then self.pendingAccept = true end
    return
  end
  if self.opening then
    self.pendingAccept = true
    return
  end
  if not self.view.overlayVisible and not self.panelOpen then
    if allowEarlyAccept then self.earlyAcceptAt = nowMs() end
    return
  end
  self.pendingAccept = false
  local group = self.model:selectedGroup()
  if not group then self:hide(); return end
  local target = self.model.windowSelectionActive
    and self.model:selectedWindow()
    or self.model:targetWindow(group)
  local address = target and target.id or ""
  -- Hyprland focus dispatch is asynchronous. Keep MRU deterministic for a
  -- second, immediate invocation instead of waiting for its next snapshot.
  self.model:rememberGroup(group.groupId)
  self:hide(true)
  if group.isIntegrationEntry then
    self.integrations:activate(group)
    return
  end
  for _, window in ipairs(group.windows or {}) do self.windowCatalog:raise(window.id) end
  self.windowCatalog:focus(target)
end

function Controller:enterGroup()
  if not Settings.get(Constants.Setting.EnterGroupedWindowSelection, false)
      or not Settings.get(Constants.Setting.GroupWindowsByApp, true) then return false end
  local entered = self.model:enterGroup()
  if entered then self:publish() end
  return entered
end

function Controller:runAction(actionId)
  local selected = self.view.overlayVisible and self.model:selectedGroup() or nil
  if selected ~= nil then
    if ActionRunner.run(actionId, selected, self.model:selectedWindow()) then
      -- An exclusive-focus overlay must never remain above the desktop after
      -- its selected action runs. In particular, closing a window otherwise
      -- leaves an input-capturing surface with a stale selection.
      self:hide(true)
    end
    return
  end

  self.windowCatalog:snapshot(function(snapshot)
    if snapshot == nil then return end
    local options = Settings.windowCatalogOptions()
    if options.restrictToCurrentMonitor then
      options.focusedOutput = self.sessionOutput ~= "" and self.sessionOutput or self.windowCatalog:pointerOutput(snapshot)
    end
    local groups = Groups.build(
      snapshot,
      options,
      self.integrations:entries(options),
      self.model.recentIds,
      self.model.lastFocusedByGroup,
      self.iconCache,
      function(window, monitors) return self.windowCatalog:monitorName(window, monitors) end
    )
    for _, group in ipairs(groups) do
      if group.hasFocusedWindow then
        ActionRunner.run(actionId, group)
        return
      end
    end
  end)
end

function Controller:command(command)
  if type(command) ~= "table" then return end
  local action = tostring(command.action or "")
  if action == Constants.Command.Hide and command[Constants.State.SessionId] ~= nil then
    self:handlePanelClosed(command[Constants.State.SessionId])
    return
  end
  local handlers = {
    [Constants.Command.Trigger] = function() self:trigger(command.direction) end,
    [Constants.Command.TriggerRelease] = function() self:stopContinuousCycle() end,
    [Constants.Command.Release] = function() self:accept() end,
    [Constants.Command.PanelOpened] = function()
      if command[Constants.State.SessionId] == self.sessionId then
        self.panelOpen = true
        self.panelOpening = false
        self.panelOpeningAt = 0
        if not self.view.overlayVisible then
          self.panelClosing = true
          self.panelClosingAt = nowMs()
        end
      end
    end,
    [Constants.Command.Accept] = function() self:accept() end,
    [Constants.Command.Hide] = function() self:hide() end,
    [Constants.Command.EnterGroup] = function() self:enterGroup() end,
    [Constants.Command.Select] = function()
      if self.model:select(tostring(command.id or "")) then self:publish() end
    end,
    [Constants.Command.RunAction] = function()
      self:runAction(tostring(command.id or ""))
    end,
  }
  local handler = handlers[action]
  if handler ~= nil then handler() end
end

function Controller:update()
  if self.earlyAcceptAt ~= 0 and nowMs() - self.earlyAcceptAt > earlyAcceptGraceMs then
    self.earlyAcceptAt = 0
  end
  if self.panelOpening and not self.view.overlayVisible
      and nowMs() - self.panelOpeningAt >= panelCloseTimeoutMs then
    self:handlePanelClosed(self.sessionId)
  end
  if self.panelClosing and nowMs() - self.panelClosingAt >= panelCloseTimeoutMs then
    self:handlePanelClosed(self.sessionId)
  end
  if not self.view.overlayVisible then return end
  self:refresh(true)

  if Settings.get(Constants.Setting.CycleWhileHoldingTab, false) and self.continuousStartedAt > 0 then
    local now = os.clock()
    if now - self.continuousStartedAt >= 0.26 and (self.lastContinuousAt == 0 or now - self.lastContinuousAt >= 0.11) then
      self.lastContinuousAt = now
      self.model:move(self.view.lastDirection or Constants.Direction.Next, not Settings.get(Constants.Setting.StopCycleAtEdge, false))
      self:publish()
    end
  end
end

function Controller:debugState()
  local groups = {}
  for _, group in ipairs(self.model.groups) do
    table.insert(groups, { id = group.groupId, title = group.primaryTitle })
  end
  local selected = self.model:selectedGroup()
  return {
    overlayVisible = self.view.overlayVisible == true,
    sessionId = self.sessionId,
    panelOpen = self.panelOpen,
    panelOpening = self.panelOpening,
    panelClosing = self.panelClosing,
    opening = self.opening,
    pendingOpenDirection = self.pendingOpenDirection or "",
    pendingDirectionCount = #self.pendingDirections,
    pendingAccept = self.pendingAccept,
    earlyAcceptPending = self.earlyAcceptAt ~= 0,
    continuousCycling = self.continuousStartedAt > 0,
    selectedIndex = self.model.selectedIndex,
    selectedGroupId = selected and selected.groupId or "",
    groups = groups,
  }
end

function Controller:onIpc(event, payload)
  local handlers = {
    [Constants.Event.Trigger] = function() self:trigger(payload) end,
    [Constants.Event.Next] = function() self:trigger(Constants.Direction.Next) end,
    [Constants.Event.Previous] = function() self:trigger(Constants.Direction.Previous) end,
    [Constants.Event.TriggerRelease] = function() self:stopContinuousCycle() end,
    [Constants.Event.Release] = function() self:accept(payload == "early") end,
    [Constants.Event.Hide] = function() self:hide() end,
    [Constants.Event.Accept] = function() self:accept(payload == "early") end,
    [Constants.Event.EnterGroup] = function() self:enterGroup() end,
    [Constants.Event.Action] = function() self:command({ action = Constants.Command.RunAction, id = payload }) end,
    [Constants.Event.Close] = function() self:runAction(Constants.Action.CloseId) end,
    [Constants.Event.Select] = function()
      if self.model:select(tostring(payload or "")) then self:publish() end
    end,
    [Constants.Event.Refresh] = function() self:refresh(true) end,
    [Constants.Event.Debug] = function() noctalia.log(noctalia.json.encode(self:debugState())) end,
  }
  local handler = handlers[event]
  if handler ~= nil then handler() end
end

return Controller
