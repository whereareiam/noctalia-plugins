--!nonstrict

local Constants = require("../Core/Constants.luau")
local Header = require("../Components/SwitcherHeader.luau")
local Settings = require("../Config/TabberSettings.luau")
local Strip = require("../Components/SwitcherStrip.luau")

local View = {}

local function send(action, values)
  local payload = values or {}
  payload.action = action
  local queue = noctalia.state.get(Constants.State.CommandQueue)
  if type(queue) ~= "table" then queue = {} end
  table.insert(queue, payload)
  noctalia.state.set(Constants.State.CommandQueue, queue)
end

local function cardRow(groups, state)
  return Strip.create(groups, state, function(id)
    send(Constants.Command.Select, { id = id })
  end)
end

function View.render(state)
  local groups = state.displayGroups or state.groups or {}
  local children = { cardRow(groups, state) }

  if Settings.get(Constants.Setting.HeaderShow, true) then
    table.insert(children, 1, Header.create(#groups))
  end


  local content = ui.column({
    gap = 12,
    align = "center",
    justify = "center",
  }, children)
  local top = tonumber(Settings.get(Constants.Setting.ContainerPaddingTop, 18)) or 18
  local right = tonumber(Settings.get(Constants.Setting.ContainerPaddingRight, 18)) or 18
  local bottom = tonumber(Settings.get(Constants.Setting.ContainerPaddingBottom, 18)) or 18
  local left = tonumber(Settings.get(Constants.Setting.ContainerPaddingLeft, 18)) or 18
  local inner = ui.column({
    gap = 0,
    align = "center",
    justify = "center",
    fill = "surface/0.74",
    radius = 12,
    border = "outline/0.45",
    borderWidth = 1,
    minWidth = Settings.get(Constants.Setting.ContainerWidth, 0),
  }, {
    ui.column({ height = top }),
    ui.row({ align = "center", justify = "center" }, {
      ui.row({ width = left }),
      content,
      ui.row({ width = right }),
    }),
    ui.column({ height = bottom }),
  })

  return ui.column({
    flexGrow = 1,
    align = "center",
    justify = "center",
    fill = "surface/" .. tostring(Settings.get(Constants.Setting.DimOpacity, 0.36)),
  }, { inner })
end

return View
