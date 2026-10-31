--!nonstrict

local Constants = require("../Core/Constants.luau")
local Library = {}

local function extension(name)
  return string.lower(string.match(name, "%.([^%.]+)$") or "")
end

-- Images and GIFs directly inside the media folder, sorted by name.
function Library.scan(folder)
  local directory = noctalia.expandPath(folder ~= nil and folder ~= "" and folder or Constants.Media.DefaultFolder)
  local items = {}
  for _, name in ipairs(noctalia.listDir(directory) or {}) do
    local kind = extension(name)
    if kind == Constants.Media.GifExtension then
      table.insert(items, { name = name, path = directory .. "/" .. name, mode = Constants.Mode.Gif })
    elseif Constants.Media.ImageExtensions[kind] then
      table.insert(items, { name = name, path = directory .. "/" .. name, mode = Constants.Mode.Image })
    end
  end
  table.sort(items, function(left, right) return string.lower(left.name) < string.lower(right.name) end)
  return { folder = directory, items = items }
end

return Library
