--!nonstrict

local Service = {}
Service.__index = Service

function Service.new(adapter)
  return setmetatable({ adapter = adapter }, Service)
end

function Service:clients(callback)
  self.adapter.clients(callback)
end

function Service:hide(address)
  self.adapter.hide(address)
end

function Service:restore(address, workspace, callback)
  self.adapter.restore(address, workspace, callback)
end

function Service:close(address)
  self.adapter.close(address)
end

return Service
