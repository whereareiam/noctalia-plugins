--!nonstrict

local Constants = require("../Core/Constants.luau")
local Collection = require("../Models/HiddenWindowCollection.luau")
local Repository = {}
Repository.__index = Repository

function Repository.new(collection)
  local runtimeDir = noctalia.getenv("XDG_RUNTIME_DIR") or ""
  local dataDir = noctalia.pluginDataDir()
  return setmetatable({
    collection = collection,
    runtimeDir = runtimeDir,
    runtimeState = runtimeDir ~= "" and (
      runtimeDir .. "/" .. Constants.Storage.RuntimeDirectory .. "/" .. Constants.Storage.StateFile
    ) or nil,
    persistentState = dataDir ~= nil and (dataDir .. "/" .. Constants.Storage.StateFile) or nil,
    targetState = runtimeDir ~= "" and (
      runtimeDir .. "/" .. Constants.Storage.RuntimeDirectory .. "/" .. Constants.Storage.SelectionTargetFile
    ) or nil,
  }, Repository)
end

function Repository:load()
  local raw = self.runtimeState ~= nil and noctalia.readFile(self.runtimeState) or nil
  if raw == nil or raw == "" then raw = self.persistentState ~= nil and noctalia.readFile(self.persistentState) or nil end
  local parsed = raw ~= nil and noctalia.json.decode(raw) or nil
  self.collection.entries = Collection.normalize(type(parsed) == "table" and (parsed.windows or parsed) or {})
end

function Repository:save()
  local encoded = self.collection:encode()
  noctalia.state.set(Constants.State.Hidden, self.collection.entries)
  if self.runtimeState ~= nil then
    noctalia.mkdirAll(self.runtimeDir .. "/" .. Constants.Storage.RuntimeDirectory)
    noctalia.writeFile(self.runtimeState, encoded)
  end
  if self.persistentState ~= nil then noctalia.writeFile(self.persistentState, encoded) end
end

function Repository:selectedTarget()
  local raw = self.targetState ~= nil and noctalia.readFile(self.targetState) or nil
  local target = raw ~= nil and noctalia.json.decode(raw) or nil
  return type(target) == "table" and target.windowId or nil
end

return Repository
