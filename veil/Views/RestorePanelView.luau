--!nonstrict

local Header = require("../Components/PanelHeader.luau")
local Row = require("../Components/HiddenWindowRow.luau")
local View = {}

function View.render(hiddenWindows)
  local rows = {}
  for _, entry in ipairs(hiddenWindows or {}) do
    table.insert(rows, Row.create(entry))
  end

  local body = #rows > 0
    and ui.scroll({
      flexGrow = 1,
      gap = 6,
      align = "stretch",
    }, rows)
    or ui.label({
      text = noctalia.tr("panel.empty"),
      color = "on_surface_variant",
    })

  return ui.column({
    flexGrow = 1,
    gap = 12,
    align = "stretch",
  }, {
    Header.create(),
    body,
  })
end

return View
