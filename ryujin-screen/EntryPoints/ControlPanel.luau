--!nonstrict

local Constants = require("./Core/Constants.luau")
local ControlPanelView = require("./Views/ControlPanelView.luau")

local status = noctalia.state.get(Constants.State.Status) or {}
local media = noctalia.state.get(Constants.State.Media) or {}
local draftBrightness = nil

local function render()
  panel.render(ControlPanelView.render(status, media, draftBrightness))
end

local function send(command)
  noctalia.state.set(Constants.State.Command, command)
end

noctalia.state.watch(Constants.State.Status, function(value)
  status = type(value) == "table" and value or {}
  render()
end)

noctalia.state.watch(Constants.State.Media, function(value)
  media = type(value) == "table" and value or {}
  render()
end)

function onOpen()
  status = noctalia.state.get(Constants.State.Status) or {}
  media = noctalia.state.get(Constants.State.Media) or {}
  draftBrightness = nil
  noctalia.state.set(Constants.State.PanelOpen, true)
  render()
end

function onClose()
  noctalia.state.set(Constants.State.PanelOpen, false)
end

function onCloseClicked()
  panel.close()
end

function onPowerChanged(value)
  local on = value == "true"
  if type(status.selection) == "table" then status.selection.enabled = on end
  render()
  send({ action = Constants.Command.Power, on = on })
end

function onBrightnessChanged(value)
  draftBrightness = math.floor(tonumber(value) or 0)
  render()
end

function onBrightnessReleased(value)
  local percent = math.floor(tonumber(value) or draftBrightness or 0)
  draftBrightness = percent
  if type(status.selection) == "table" then status.selection.brightness = percent end
  status.brightness = percent
  render()
  send({ action = Constants.Command.Brightness, value = percent })
end

function onStartService()
  send({ action = Constants.Command.StartService })
end

function onRefreshClicked()
  send({ action = Constants.Command.Refresh })
end

function onChooseFolderClicked()
  noctalia.openSettings()
end
