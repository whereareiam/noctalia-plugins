--!nonstrict

local Catalog = {}
Catalog.__index = Catalog

function Catalog.new(adapter)
  return setmetatable({ adapter = adapter }, Catalog)
end

function Catalog:snapshot(callback)
  self.adapter.snapshot(callback)
end

function Catalog:focus(address)
  self.adapter.focus(address)
end

function Catalog:raise(address)
  self.adapter.raise(address)
end

function Catalog:monitorName(window, monitors)
  return self.adapter.monitorName(window, monitors)
end

function Catalog:focusedOutput(snapshot)
  return self.adapter.focusedOutput(snapshot)
end

function Catalog:pointerOutput(snapshot)
  return self.adapter.pointerOutput(snapshot)
end

return Catalog
