--!nonstrict

local Constants = require("./Core/Constants.luau")
local OverlayView = require("./Views/OverlayView.luau")
local view = noctalia.state.get(Constants.State.View) or { groups = {}, displayGroups = {}, selectedIndex = 1 }
local sessionId = view.sessionId
local panelSessionId = sessionId
local closeRequestedSessionId = nil
local commandSequence = 0

local function render() panel.render(OverlayView.render(view)) end

local function send(action, values)
  local payload = values or {}
  payload.action = action
  commandSequence = commandSequence + 1
  payload.sequence = commandSequence
  local queue = noctalia.state.get(Constants.State.CommandQueue)
  if type(queue) ~= "table" then queue = {} end
  table.insert(queue, payload)
  noctalia.state.set(Constants.State.CommandQueue, queue)
end

render()

noctalia.state.watch(Constants.State.View, function(value)
  if type(value) == "table" then
    view = value
    sessionId = value.sessionId
    render()
    -- A panel callback can belong to an older switcher session. Close based on
    -- the authoritative view state, once for each hidden session, so an old
    -- callback cannot leave an invisible exclusive-focus surface behind.
    if view.overlayVisible == true then
      closeRequestedSessionId = nil
    elseif closeRequestedSessionId ~= sessionId then
      closeRequestedSessionId = sessionId
      panel.close()
    end
  end
end)

function onOpen()
  view = noctalia.state.get(Constants.State.View) or view
  sessionId = view.sessionId
  panelSessionId = sessionId
  render()
  send(Constants.Command.PanelOpened, { [Constants.State.SessionId] = panelSessionId })
  if view.overlayVisible ~= true then
    closeRequestedSessionId = panelSessionId
    panel.close()
  end
end
function onClose()
  send(Constants.Command.Hide, { [Constants.State.SessionId] = panelSessionId })
end
function onKey(chord, pressed)
  if pressed ~= true then
    if chord == Constants.Key.Tab or chord == Constants.Key.ShiftTab then
      send(Constants.Command.TriggerRelease)
    end
    if chord == Constants.Key.AltLeft or chord == Constants.Key.AltRight then
      send(Constants.Command.Release)
    end
    return
  end
  local handlers = {
    [Constants.Key.Tab] = function() send(Constants.Command.Trigger, { direction = Constants.Direction.Next }) end,
    [Constants.Key.ShiftTab] = function() send(Constants.Command.Trigger, { direction = Constants.Direction.Previous }) end,
    [Constants.Key.Escape] = function()
      closeRequestedSessionId = panelSessionId
      panel.close()
    end,
    [Constants.Key.Grave] = function() send(Constants.Command.EnterGroup) end,
  }
  local handler = handlers[chord]
  if handler ~= nil then
    handler()
    return
  end
end
