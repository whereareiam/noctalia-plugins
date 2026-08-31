--!nonstrict

local Constants = require("./Core/Constants.luau")

local hiddenWindows = noctalia.state.get(Constants.State.Hidden) or {}

local function render()
  local count = #hiddenWindows
  local children = {
    ui.glyph({
      name = "eye-off",
      size = 16,
      color = count > 0 and "primary" or "on_surface_variant",
    }),
  }
  if count > 0 then
    table.insert(children, ui.label({
      text = tostring(count),
      color = "primary",
      fontWeight = "bold",
    }))
  end

  local container = barWidget.isVertical() and ui.column or ui.row
  barWidget.render(container({
    gap = 5,
    align = "center",
    onClick = "openRestoreMenu",
  }, children))
  barWidget.setTooltip(noctalia.trp("bar.tooltip", count))
end

noctalia.state.watch(Constants.State.Hidden, function(value)
  hiddenWindows = type(value) == "table" and value or {}
  render()
end)

function update()
  render()
end

function openRestoreMenu()
  noctalia.togglePanel(Constants.Plugin.RestorePanelId)
end
