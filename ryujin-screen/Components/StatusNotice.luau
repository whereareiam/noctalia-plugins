--!nonstrict

local Notice = {}

local function notice(glyph, text, action)
  local children = {
    ui.glyph({ name = glyph, size = 18, color = "error" }),
    ui.label({ text = text, flexGrow = 1 }),
  }
  if action ~= nil then table.insert(children, action) end
  return ui.row({
    gap = 10,
    padding = 10,
    align = "center",
    fill = "error/0.12",
    radius = 8,
  }, children)
end

-- Explains why the screen cannot be controlled, or nil when everything is in place.
function Notice.create(status)
  if status.available == nil then
    return nil
  end
  if not status.available then
    return notice("alert-triangle", noctalia.tr("notice.missing"))
  end
  if not status.connected then
    return notice("plug-connected-x", noctalia.tr("notice.disconnected"))
  end
  if not status.running then
    return notice("player-pause", noctalia.tr("notice.stopped"), ui.button({
      text = noctalia.tr("notice.start"),
      variant = "primary",
      controlSize = "sm",
      onClick = "onStartService",
    }))
  end
  return nil
end

return Notice
