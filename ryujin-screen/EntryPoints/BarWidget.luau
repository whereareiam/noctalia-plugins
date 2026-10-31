--!nonstrict

local Constants = require("./Core/Constants.luau")

local status = noctalia.state.get(Constants.State.Status) or {}

local function render()
  local selection = type(status.selection) == "table" and status.selection or {}
  local enabled = status.connected == true and selection.enabled ~= false

  barWidget.render(ui.glyph({
    name = "device-desktop",
    size = 16,
    color = enabled and "primary" or "on_surface_variant",
  }))
  if status.connected ~= true then
    barWidget.setTooltip(noctalia.tr("bar.disconnected"))
  elseif not enabled then
    barWidget.setTooltip(noctalia.tr("bar.off"))
  else
    barWidget.setTooltip(noctalia.tr("bar.on", { mode = noctalia.tr("mode." .. tostring(selection.mode or "dashboard")) }))
  end
end

noctalia.state.watch(Constants.State.Status, function(value)
  status = type(value) == "table" and value or {}
  render()
end)

render()

function onClick()
  noctalia.togglePanel(Constants.Plugin.ControlPanelId)
end
