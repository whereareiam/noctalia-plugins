--!nonstrict

local Constants = require("../Core/Constants.luau")
local Color = require("../Core/Color.luau")
local Settings = require("../Config/TabberSettings.luau")
local Title = require("./WindowTitle.luau")
local Card = {}

local function iconFor(group, selected, iconSize)
  if group.iconPath ~= nil then
    return ui.image({ path = group.iconPath, width = iconSize, height = iconSize, fit = "contain" })
  end
  return ui.glyph({ name = "window", size = iconSize, color = selected and "on_primary" or "on_surface_variant" })
end

local function countBadge(group, selected, highlighted, accent)
  if (tonumber(group.windowCount) or 0) <= 1 then return nil end
  local badgeColor = selected and "on_primary" or (highlighted and accent or "primary")
  local badgeFill = Color.withAlpha(badgeColor, 0.18)
  local badgeBorder = Color.withAlpha(badgeColor, 0.42)
  return ui.row({
    width = 24,
    height = 24,
    align = "center",
    justify = "center",
    fill = badgeFill,
    radius = 12,
    border = badgeBorder,
    borderWidth = 1,
  }, {
    ui.label({
      text = tostring(group.windowCount),
      color = badgeColor,
      fontWeight = "bold",
    }),
  })
end

function Card.create(group, selected, onSelect)
  local cardSize = tonumber(Settings.get(Constants.Setting.CardSize, 108)) or 108
  local iconSize = tonumber(Settings.get(Constants.Setting.IconSize, 64)) or 64
  local cardContentSize = cardSize + 12
  local iconLeftInset = math.max(0, math.min(
    (cardContentSize - iconSize) / 2,
    cardContentSize - 24 - iconSize
  ))
  local accent = tostring(group.selectionCardAccentColor or "")
  local highlighted = group.selectionCardHighlighted == true and accent ~= ""
  local badge = countBadge(group, selected, highlighted, accent)
  local rightLane
  if badge ~= nil then
    rightLane = ui.column({
      width = 24,
      height = cardContentSize,
      align = "center",
      justify = "start",
    }, { badge })
  else
    rightLane = ui.spacer({ width = 24 })
  end
  local cardChildren = {
    ui.spacer({ width = iconLeftInset }),
    iconFor(group, selected, iconSize),
    rightLane,
  }

  local card = ui.column({
    key = group.groupId .. "-card",
    width = cardSize + 28,
    height = cardSize + 28,
    padding = 8,
    align = "center",
    justify = "center",
    fill = selected and "primary" or (highlighted and Color.withAlpha(accent, 0.16) or "surface/0.90"),
    radius = 10,
    border = highlighted and accent or (selected and "on_primary/0.65" or "outline/0.45"),
    borderWidth = selected and 2 or 1,
  }, {
    ui.row({
      width = cardContentSize,
      height = cardContentSize,
      align = "stretch",
    }, cardChildren),
  })

  local visibility = Settings.get(Constants.Setting.TitleVisibility, "selected")
  local titleHeight = Title.height()
  local children = { card }
  if visibility == "all" then
    table.insert(children, Title.create(group, selected))
  else
    if visibility == "selected" then
      if selected then
        table.insert(children, Title.create(group, true))
      else
        table.insert(children, ui.spacer({ height = titleHeight }))
      end
    end
  end

  return ui.column({
    key = group.groupId,
    width = cardSize + 28,
    align = "center",
    gap = 8,
    onClick = function() onSelect(group.groupId) end,
    onHover = function(state)
      if state ~= "true" then return end
      if not Settings.get(Constants.Setting.RequirePointerMovement, true) then
        onSelect(group.groupId)
        return
      end
      onSelect(group.groupId)
    end,
  }, children)
end

return Card
