--!nonstrict

local Card = require("./WindowCard.luau")
local Settings = require("../Config/TabberSettings.luau")
local Constants = require("../Core/Constants.luau")
local Strip = {}

function Strip.create(groups, state, onSelect)
  local cards, selectedIndex = {}, state.selectedIndex or 1
  for index, group in ipairs(groups or {}) do
    local selected = state.windowSelectionActive
      and group.primaryWindowId == state.selectedWindowId
      or (not state.windowSelectionActive and index == selectedIndex)
    table.insert(cards, Card.create(group, selected, onSelect))
  end

  if #cards == 0 then
    return ui.label({ text = "No switchable windows", color = "on_surface_variant" })
  end

  local rows = {
    ui.row({
      gap = Settings.get(Constants.Setting.CardGap, 9),
      align = "center",
      justify = "center",
    }, cards),
  }
  return ui.column({ align = "center" }, rows)
end

return Strip
