--!nonstrict

local Constants = require("../Core/Constants.luau")
local Picker = {}

local function modeButton(mode, glyph, current, enabled)
  return ui.button({
    key = mode,
    text = noctalia.tr("mode." .. mode),
    glyph = glyph,
    variant = current == mode and "primary" or "outline",
    enabled = enabled,
    flexGrow = 1,
    onClick = function()
      noctalia.state.set(Constants.State.Command, { action = Constants.Command.Show, mode = mode })
    end,
  })
end

function Picker.create(selection, enabled)
  local current = selection.mode
  return ui.row({ gap = 8 }, {
    modeButton(Constants.Mode.Dashboard, "layout-dashboard", current, enabled),
    modeButton(Constants.Mode.BuiltIn, "movie", current, enabled),
  })
end

return Picker
