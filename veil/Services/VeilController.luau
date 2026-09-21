--!nonstrict

local Constants = require("../Core/Constants.luau")
local Collection = require("../Models/HiddenWindowCollection.luau")
local Compositor = require("./CompositorService.luau")
local Repository = require("./StateRepository.luau")

local Controller = {}
Controller.__index = Controller

function Controller.new(compositor)
  local collection = Collection.new()
  local self = setmetatable({
    collection = collection,
    compositor = compositor,
    repository = Repository.new(collection),
  }, Controller)
  self.repository:load()
  self:publish()
  return self
end

function Controller:publish()
  self.collection.entries = Collection.normalize(self.collection.entries)
  self.repository:save()
end

function Controller:hide(address, client)
  local normalized = Collection.address(address)
  if normalized == "" or self.collection:find(normalized) then return false end

  local workspace = client and client.workspace or {}
  table.insert(self.collection.entries, {
    address = normalized,
    appId = tostring(client and (client.class or client.initialClass) or ""),
    title = tostring(client and (client.title or client.initialTitle or client.class) or Constants.Window.HiddenTitle),
    workspace = tostring(workspace.name or workspace.id or ""),
    output = tostring(client and (client.monitorName or client.monitor) or ""),
    hiddenAt = os.time(),
  })
  self:publish()
  self.compositor:hide(normalized)
  return true
end

function Controller:restore(address)
  local normalized = Collection.address(address)
  if normalized == "" then return false end
  local entry = self.collection:find(normalized)
  if entry == nil then return false end
  local workspace = tostring(entry.workspace or "")
  if workspace == "" then
    noctalia.log("cannot restore window without its original workspace")
    return false
  end
  self.compositor:restore(normalized, workspace, function(restored)
    if not restored then return end
    self.collection:remove(normalized)
    self:publish()
  end)
  return true
end

function Controller:close(address)
  local normalized = Collection.address(address)
  if normalized == "" then return false end
  self.collection:remove(normalized)
  self:publish()
  self.compositor:close(normalized)
  return true
end

function Controller:toggleFocused()
  local target = Collection.address(self.repository:selectedTarget())
  self.compositor:clients(function(clients)
    for _, client in ipairs(clients or {}) do
      local address = Collection.address(client.address)
      if target ~= "" and address == target then
        if self.collection:find(target) then self:restore(target) else self:hide(target, client) end
        return
      end
      if target == "" and client.focusHistoryID == 0 and client.mapped ~= false and client.hidden ~= true then
        self:hide(address, client)
        return
      end
    end
    if target ~= "" and self.collection:find(target) then self:restore(target) end
  end)
end

function Controller:toggle(address)
  local target = Collection.address(address)
  if target == "" then
    self:toggleFocused()
    return
  end
  if self.collection:find(target) then
    self:restore(target)
    return
  end
  self.compositor:clients(function(clients)
    for _, client in ipairs(clients or {}) do
      if Collection.address(client.address) == target then
        self:hide(target, client)
        return
      end
    end
  end)
end

function Controller:prune()
  self.compositor:clients(function(clients)
    local live = {}
    for _, client in ipairs(clients or {}) do
      if client.workspace and client.workspace.name == Constants.Window.HiddenWorkspace then
        live[Collection.address(client.address)] = true
      end
    end

    local kept, changed = {}, false
    for _, entry in ipairs(self.collection.entries) do
      if live[entry.address] then table.insert(kept, entry) else changed = true end
    end
    if changed then
      self.collection.entries = kept
      self:publish()
    end
  end)
end

function Controller:command(command)
  if type(command) ~= "table" then return end
  local action = tostring(command.action or "")
  local handlers = {
    [Constants.Command.Restore] = function() self:restore(command.address) end,
    [Constants.Command.Close] = function() self:close(command.address) end,
    [Constants.Command.ToggleFocused] = function() self:toggleFocused() end,
  }
  local handler = handlers[action]
  if handler ~= nil then handler() end
end

return Controller
