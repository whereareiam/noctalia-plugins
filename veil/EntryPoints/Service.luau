--!nonstrict

local Constants = require("./Core/Constants.luau")
local HyprlandAdapter = require("./Adapters/Hyprland/HyprlandAdapter.luau")
local CompositorService = require("./Services/CompositorService.luau")
local Controller = require("./Services/VeilController.luau")

local compositor = CompositorService.new(HyprlandAdapter)
local controller = Controller.new(compositor)

noctalia.setUpdateInterval(1500)
noctalia.state.watch(Constants.State.Command, function(command)
  controller:command(command)
  noctalia.state.set(Constants.State.Command, {})
end)

function update()
  controller:prune()
end

function onIpc(event, payload)
  local handlers = {
    [Constants.Event.ToggleFocused] = function() controller:toggleFocused() end,
    [Constants.Event.Toggle] = function() controller:toggle(payload) end,
    [Constants.Event.Open] = function() noctalia.togglePanel(Constants.Plugin.RestorePanelId) end,
    [Constants.Event.OpenRestoreMenu] = function() noctalia.togglePanel(Constants.Plugin.RestorePanelId) end,
    [Constants.Event.Hide] = function() controller:hide(payload) end,
    [Constants.Event.Restore] = function() controller:restore(payload) end,
    [Constants.Event.Close] = function() controller:close(payload) end,
    [Constants.Event.List] = function()
      noctalia.log(noctalia.json.encode({
        version = 1,
        windows = controller.collection.entries,
      }))
    end,
    [Constants.Event.Debug] = function()
      noctalia.log(noctalia.json.encode({
        count = #controller.collection.entries,
        repository = controller.repository,
      }))
    end,
  }
  local handler = handlers[event]
  if handler ~= nil then handler() end
end

function onExit()
  controller:publish()
end
