--!nonstrict

local Header = {}

function Header.create(enabled, controllable)
  return ui.row({
    gap = 8,
    align = "center",
  }, {
    ui.glyph({
      name = "device-desktop",
      size = 20,
      color = enabled and "primary" or "on_surface_variant",
    }),
    ui.label({
      text = noctalia.tr("panel.title"),
      fontSize = 16,
      fontWeight = "bold",
      flexGrow = 1,
    }),
    ui.toggle({
      checked = enabled,
      enabled = controllable,
      onChange = "onPowerChanged",
    }),
    ui.button({
      glyph = "close",
      variant = "ghost",
      tooltip = noctalia.tr("panel.close"),
      onClick = "onCloseClicked",
    }),
  })
end

return Header
