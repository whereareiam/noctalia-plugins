--!nonstrict

local Brightness = {}

function Brightness.create(percent, enabled)
  return ui.row({
    gap = 10,
    align = "center",
  }, {
    ui.glyph({ name = "sun", size = 18, color = "on_surface_variant" }),
    ui.slider({
      min = 0,
      max = 100,
      step = 5,
      value = percent,
      enabled = enabled,
      flexGrow = 1,
      onChange = "onBrightnessChanged",
      onDragEnd = "onBrightnessReleased",
    }),
    ui.label({
      text = tostring(percent) .. "%",
      minWidth = 40,
      textAlign = "end",
      color = "on_surface_variant",
    }),
  })
end

return Brightness
