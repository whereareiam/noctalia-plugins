--!nonstrict

local Constants = require("../Core/Constants.luau")
local Grid = {}

local Columns = 3
local ThumbnailWidth = 104
local ThumbnailHeight = 78

local function tile(item, selected, enabled)
  local caption = item.mode == Constants.Mode.Gif and ("GIF · " .. item.name) or item.name
  return ui.column({
    key = item.path,
    gap = 4,
    width = ThumbnailWidth,
    onClick = enabled and function()
      noctalia.state.set(Constants.State.Command, {
        action = Constants.Command.Show,
        mode = item.mode,
        path = item.path,
      })
    end or nil,
  }, {
    ui.image({
      path = item.path,
      width = ThumbnailWidth,
      height = ThumbnailHeight,
      fit = "cover",
      radius = 8,
      border = selected and "primary" or "outline/0.4",
      borderWidth = selected and 3 or 1,
    }),
    ui.label({
      text = caption,
      fontSize = 11,
      maxLines = 1,
      color = selected and "primary" or "on_surface_variant",
    }),
  })
end

local function header(media)
  return ui.row({ gap = 8, align = "center" }, {
    ui.column({ gap = 2, flexGrow = 1 }, {
      ui.label({ text = noctalia.tr("media.title"), fontWeight = "bold" }),
      ui.label({
        text = tostring(media.folder or Constants.Media.DefaultFolder),
        fontSize = 11,
        maxLines = 1,
        color = "on_surface_variant",
      }),
    }),
    ui.button({
      glyph = "refresh",
      variant = "ghost",
      tooltip = noctalia.tr("media.refresh"),
      onClick = "onRefreshClicked",
    }),
    ui.button({
      glyph = "folder",
      variant = "ghost",
      tooltip = noctalia.tr("media.choose_folder"),
      onClick = "onChooseFolderClicked",
    }),
  })
end

function Grid.create(media, selection, enabled)
  local items = media.items or {}
  local body
  if #items == 0 then
    body = ui.label({ text = noctalia.tr("media.empty"), color = "on_surface_variant" })
  else
    local rows, row = {}, {}
    for _, item in ipairs(items) do
      local selected = item.path == selection.path and item.mode == selection.mode
      table.insert(row, tile(item, selected, enabled))
      if #row == Columns then
        table.insert(rows, ui.row({ gap = 8, align = "start" }, row))
        row = {}
      end
    end
    if #row > 0 then table.insert(rows, ui.row({ gap = 8, align = "start" }, row)) end
    body = ui.scroll({ flexGrow = 1, gap = 8 }, rows)
  end

  return ui.column({ gap = 10, flexGrow = 1 }, { header(media), body })
end

return Grid
