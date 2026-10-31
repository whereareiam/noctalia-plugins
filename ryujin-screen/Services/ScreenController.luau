--!nonstrict

local Constants = require("../Core/Constants.luau")
local Library = require("../Models/MediaLibrary.luau")

local Controller = {}
Controller.__index = Controller

function Controller.new(adapter, mediaFolder)
  return setmetatable({
    adapter = adapter,
    mediaFolder = mediaFolder,
    status = noctalia.state.get(Constants.State.Status) or {},
  }, Controller)
end

function Controller:configure(adapter, mediaFolder)
  self.adapter = adapter
  self.mediaFolder = mediaFolder
end

function Controller:refresh()
  self.adapter:status(function(status)
    self.status = status
    noctalia.state.set(Constants.State.Status, status)
  end)
end

function Controller:refreshMedia()
  noctalia.state.set(Constants.State.Media, Library.scan(self.mediaFolder))
end

function Controller:enabled()
  local selection = self.status.selection
  return type(selection) ~= "table" or selection.enabled ~= false
end

function Controller:show(mode, path)
  local arguments = { "show", mode }
  if path ~= nil and path ~= "" then table.insert(arguments, path) end
  self:run(arguments)
end

function Controller:setPower(on)
  self:run({ on and "on" or "off" })
end

function Controller:setBrightness(percent)
  local value = math.clamp(math.floor(tonumber(percent) or 0), 0, 100)
  self:run({ "brightness", value })
end

function Controller:startService()
  self.adapter:startService(function() self:refresh() end)
end

function Controller:run(arguments)
  self.adapter:command(arguments, function() self:refresh() end)
end

function Controller:command(command)
  if type(command) ~= "table" then return end
  local action = tostring(command.action or "")
  local handlers = {
    [Constants.Command.Show] = function() self:show(command.mode, command.path) end,
    [Constants.Command.Power] = function() self:setPower(command.on == true) end,
    [Constants.Command.Brightness] = function() self:setBrightness(command.value) end,
    [Constants.Command.StartService] = function() self:startService() end,
    [Constants.Command.Refresh] = function()
      self:refresh()
      self:refreshMedia()
    end,
  }
  local handler = handlers[action]
  if handler ~= nil then handler() end
end

return Controller
