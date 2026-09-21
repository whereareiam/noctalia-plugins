--!nonstrict

local Header = {}

function Header.create()
  return ui.row({
    gap = 8,
    align = "center",
  }, {
    ui.glyph({
      name = "eye-off",
      size = 20,
      color = "primary",
    }),
    ui.label({
      text = noctalia.tr("panel.title"),
      fontSize = 16,
      fontWeight = "bold",
      flexGrow = 1,
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
