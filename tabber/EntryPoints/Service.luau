--!nonstrict

local Constants = require("./Core/Constants.luau")
local HyprlandAdapter = require("./Adapters/Hyprland/HyprlandAdapter.luau")
local VeilProvider = require("./Integrations/VeilIntegration.luau")
local IntegrationRegistry = require("./Integrations/IntegrationRegistry.luau")
local WindowCatalog = require("./Services/WindowCatalog.luau")
local Controller = require("./Services/TabberController.luau")

local integrations = IntegrationRegistry.new({ VeilProvider.new() })
local windowCatalog = WindowCatalog.new(HyprlandAdapter)
local controller = Controller.new(windowCatalog, integrations)

noctalia.setUpdateInterval(110)
-- Commands are transient input, never recover events from a previous runtime.
noctalia.state.set(Constants.State.CommandQueue, {})
noctalia.state.watch(Constants.State.CommandQueue, function(commands)
  if type(commands) ~= "table" or #commands == 0 then return end
  local processedCount = #commands
  for _, command in ipairs(commands) do
    if type(command) == "table" and command.action ~= nil and command.action ~= "" then
      controller:command(command)
    end
  end
  -- Keep commands appended while this batch was being handled. This makes
  -- rapid panel key events lossless instead of using a single mailbox value.
  local current = noctalia.state.get(Constants.State.CommandQueue)
  if type(current) == "table" and #current > processedCount then
    local remaining = {}
    for index = processedCount + 1, #current do table.insert(remaining, current[index]) end
    noctalia.state.set(Constants.State.CommandQueue, remaining)
  else
    noctalia.state.set(Constants.State.CommandQueue, {})
  end
end)

function update()
  controller:update()
end

function onIpc(event, payload)
  controller:onIpc(event, payload)
end

function onExit()
  controller:hide()
end
