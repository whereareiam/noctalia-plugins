--!nonstrict

local Constants = require("../Core/Constants.luau")
local Settings = require("../Config/TabberSettings.luau")
local Title = {}

function Title.height()
  return Settings.get(Constants.Setting.TitleTruncation, "end") == "two-lines" and 36 or 24
end

function Title.create(group, selected)
  local titleHeight = Title.height()
  return ui.label({
    text = tostring(group.primaryTitle or group.appId or Constants.Window.DefaultTitle),
    width = (tonumber(Settings.get(Constants.Setting.CardSize, 108)) or 108) + 28,
    height = titleHeight,
    maxLines = titleHeight == 36 and 2 or 1,
    textAlign = "center",
    color = selected and "on_surface" or "on_surface_variant",
  })
end

return Title
