--!nonstrict

local Constants = require("../Core/Constants.luau")
local Settings = require("../Config/TabberSettings.luau")
local Header = {}

function Header.create(groupCount)
  local alignment = Settings.get(Constants.Setting.HeaderAlignment, "space-between")
  local justify = {
    ["left"] = "start",
    ["center"] = "center",
    ["space-between"] = "space_between",
  }
  local horizontalPadding = math.max(
    tonumber(Settings.get(Constants.Setting.HeaderPaddingLeft, 0)) or 0,
    tonumber(Settings.get(Constants.Setting.HeaderPaddingRight, 0)) or 0
  )
  local verticalPadding = math.max(
    tonumber(Settings.get(Constants.Setting.HeaderPaddingTop, 0)) or 0,
    tonumber(Settings.get(Constants.Setting.HeaderPaddingBottom, 0)) or 0
  )
  local children = {
    ui.label({
      text = Settings.get(Constants.Setting.HeaderText, "Tabber"),
      fontSize = 16,
      fontWeight = "bold",
      flexGrow = alignment == "space-between" and 1 or 0,
    }),
  }
  if Settings.get(Constants.Setting.HeaderShowCount, true) then
    table.insert(children, ui.label({
      text = tostring(groupCount) .. " window" .. (groupCount == 1 and "" or "s"),
      color = "on_surface_variant",
    }))
  end
  return ui.row({
    gap = 8,
    paddingH = horizontalPadding,
    paddingV = verticalPadding,
    align = "center",
    justify = justify[alignment] or "space_between",
  }, children)
end

return Header
