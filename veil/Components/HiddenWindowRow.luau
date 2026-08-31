--!nonstrict

local Constants = require("../Core/Constants.luau")
local Row = {}

function Row.create(entry)
  local address = tostring(entry.address or "")
  local appId = tostring(entry.appId or "")
  local iconPath = noctalia.appIconPath(appId, 24)
  local icon = iconPath ~= nil
    and ui.image({
      path = iconPath,
      width = 24,
      height = 24,
      fit = "contain",
    })
    or ui.glyph({
      name = "window",
      size = 20,
      color = "on_surface_variant",
    })

  return ui.row({
    key = address,
    gap = 10,
    padding = 8,
    align = "center",
    fill = "surface_variant/0.8",
    radius = 8,
  }, {
    icon,
    ui.column({
      gap = 2,
      flexGrow = 1,
    }, {
      ui.label({
        text = tostring(entry.title or appId or address),
        fontWeight = "bold",
        maxLines = 1,
      }),
      ui.label({
        text = tostring(appId ~= "" and appId or entry.workspace or ""),
        color = "on_surface_variant",
        maxLines = 1,
      }),
    }),
    ui.button({
      glyph = "eye",
      variant = "ghost",
      tooltip = "Restore",
      onClick = function()
        noctalia.state.set(Constants.State.Command, {
          action = Constants.Command.Restore,
          address = address,
        })
      end,
    }),
    ui.button({
      glyph = "trash",
      variant = "ghost",
      tooltip = "Close",
      onClick = function()
        noctalia.state.set(Constants.State.Command, {
          action = Constants.Command.Close,
          address = address,
        })
      end,
    }),
  })
end

return Row
