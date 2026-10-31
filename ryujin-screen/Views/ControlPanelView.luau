--!nonstrict

local Brightness = require("../Components/BrightnessControl.luau")
local Grid = require("../Components/MediaGrid.luau")
local Header = require("../Components/PanelHeader.luau")
local Notice = require("../Components/StatusNotice.luau")
local Picker = require("../Components/ModePicker.luau")
local View = {}

-- The brightness to show: the cooler's own while on, the saved one while off.
local function brightness(status, selection)
  if selection.enabled ~= false and status.brightness ~= nil then return status.brightness end
  return selection.brightness or status.brightness or 100
end

function View.render(status, media, draftBrightness)
  local selection = type(status.selection) == "table" and status.selection or {}
  local enabled = selection.enabled ~= false
  local controllable = status.available == true and status.connected == true

  local children = { Header.create(enabled, controllable) }
  local notice = Notice.create(status)
  if notice ~= nil then table.insert(children, notice) end
  table.insert(children, Brightness.create(draftBrightness or brightness(status, selection), controllable and enabled))
  table.insert(children, Picker.create(selection, controllable))
  table.insert(children, ui.separator({}))
  table.insert(children, Grid.create(media, selection, controllable))

  return ui.column({
    flexGrow = 1,
    gap = 14,
    align = "stretch",
  }, children)
end

return View
