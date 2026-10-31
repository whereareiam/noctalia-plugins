--!nonstrict

local Constants = require("./Core/Constants.luau")
local Adapter = require("./Adapters/RyujinScreen/RyujinScreenAdapter.luau")
local Controller = require("./Services/ScreenController.luau")

local function settings()
  return Adapter.new(noctalia.getConfig("command")), noctalia.getConfig("media_folder")
end

local controller = Controller.new(settings())

-- Poll often only while someone is looking at the panel; the tool takes a moment per call.
local function setPollInterval(panelOpen)
  noctalia.setUpdateInterval(panelOpen and Constants.Poll.PanelOpenMs or Constants.Poll.PanelClosedMs)
end

setPollInterval(noctalia.state.get(Constants.State.PanelOpen) == true)
controller:refresh()
controller:refreshMedia()

noctalia.state.watch(Constants.State.Command, function(command)
  if type(command) ~= "table" or command.action == nil then return end
  controller:command(command)
  noctalia.state.set(Constants.State.Command, {})
end)

noctalia.state.watch(Constants.State.PanelOpen, function(open)
  setPollInterval(open == true)
  if open == true then
    controller:refresh()
    controller:refreshMedia()
  end
end)

function update()
  controller:refresh()
end

function onConfigChanged()
  controller:configure(settings())
  controller:refresh()
  controller:refreshMedia()
end

function onIpc(event, payload)
  local handlers = {
    [Constants.Event.Open] = function() noctalia.togglePanel(Constants.Plugin.ControlPanelId) end,
    [Constants.Event.On] = function() controller:setPower(true) end,
    [Constants.Event.Off] = function() controller:setPower(false) end,
    [Constants.Event.Toggle] = function() controller:setPower(not controller:enabled()) end,
    [Constants.Event.Dashboard] = function() controller:show(Constants.Mode.Dashboard) end,
    [Constants.Event.BuiltIn] = function() controller:show(Constants.Mode.BuiltIn) end,
    [Constants.Event.Brightness] = function() controller:setBrightness(payload) end,
    [Constants.Event.Refresh] = function()
      controller:refresh()
      controller:refreshMedia()
    end,
  }
  local handler = handlers[event]
  if handler ~= nil then handler() end
end
