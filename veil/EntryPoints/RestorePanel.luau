--!nonstrict

local Constants = require("./Core/Constants.luau")
local RestorePanelView = require("./Views/RestorePanelView.luau")

local hiddenWindows = noctalia.state.get(Constants.State.Hidden) or {}

local function render()
  panel.render(RestorePanelView.render(hiddenWindows))
end

noctalia.state.watch(Constants.State.Hidden, function(value)
  hiddenWindows = type(value) == "table" and value or {}
  render()
end)

function onOpen()
  hiddenWindows = noctalia.state.get(Constants.State.Hidden) or {}
  render()
end

function onCloseClicked()
  panel.close()
end
