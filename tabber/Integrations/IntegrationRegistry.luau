--!nonstrict

local Registry = {}
Registry.__index = Registry

function Registry.new(providers)
  return setmetatable({ providers = providers or {} }, Registry)
end

function Registry:entries(options)
  local result = {}
  for _, provider in ipairs(self.providers) do
    for _, entry in ipairs(provider:entries(options)) do table.insert(result, entry) end
  end
  return result
end

function Registry:activate(entry)
  for _, provider in ipairs(self.providers) do
    if provider:id() == entry.integrationId then return provider:activate(entry) end
  end
  return false
end

function Registry:publishTarget(target)
  for _, provider in ipairs(self.providers) do provider:publishTarget(target) end
end

return Registry
