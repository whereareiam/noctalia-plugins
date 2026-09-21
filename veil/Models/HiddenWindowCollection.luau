--!nonstrict

local Collection = {}
Collection.__index = Collection

local function normalize(address)
  local value = string.lower(string.match(tostring(address or ""), "^%s*(.-)%s*$") or "")
  if value == "" then return "" end
  return string.sub(value, 1, 2) == "0x" and value or ("0x" .. value)
end

function Collection.new(entries)
  return setmetatable({ entries = Collection.normalize(entries) }, Collection)
end

function Collection.normalize(entries)
  local result, seen = {}, {}
  for _, entry in ipairs(entries or {}) do
    local address = normalize(entry and entry.address)
    if address ~= "" and not seen[address] then
      seen[address] = true
      table.insert(result, {
        address = address,
        appId = tostring(entry.appId or entry.app_id or ""),
        title = tostring(entry.title or entry.appId or "Hidden window"),
        workspace = tostring(entry.workspace or ""),
        output = tostring(entry.output or ""),
        hiddenAt = tonumber(entry.hiddenAt) or os.time(),
      })
    end
  end
  table.sort(result, function(left, right) return left.hiddenAt > right.hiddenAt end)
  return result
end

function Collection.address(value) return normalize(value) end
function Collection:find(address)
  local target = normalize(address)
  for _, entry in ipairs(self.entries) do if entry.address == target then return entry end end
  return nil
end
function Collection:remove(address)
  local target, result, changed = normalize(address), {}, false
  for _, entry in ipairs(self.entries) do if entry.address == target then changed = true else table.insert(result, entry) end end
  self.entries = result
  return changed
end
function Collection:encode()
  return noctalia.json.encode({ version = 1, windows = Collection.normalize(self.entries) })
end

return Collection
