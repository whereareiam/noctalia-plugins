--!nonstrict

local Constants = require("../../Core/Constants.luau")
local Adapter = {}
Adapter.__index = Adapter

local function resolve(command)
  local configured = command ~= nil and command ~= "" and command or Constants.Service.Executable
  if configured ~= Constants.Service.Executable or noctalia.commandExists(configured) then
    return noctalia.expandPath(configured)
  end
  -- Noctalia may start without ~/.local/bin on PATH, where the README installs the tool.
  local localExecutable = noctalia.expandPath(Constants.Service.LocalExecutable)
  return noctalia.fileExists(localExecutable) and localExecutable or configured
end

local function run(argv, callback)
  local started = noctalia.runAsync(argv, function(result)
    if result.exitCode ~= 0 then
      noctalia.log(table.concat(argv, " ") .. " failed: " .. tostring(result.stderr or ""))
    end
    callback(result)
  end)
  if not started then
    callback({ exitCode = -1, stdout = "", stderr = "cannot start " .. tostring(argv[1]) })
  end
end

function Adapter.new(command)
  return setmetatable({ executable = resolve(command) }, Adapter)
end

function Adapter:status(callback)
  run({ self.executable, "status", "--json" }, function(result)
    local status = result.exitCode == 0 and noctalia.json.decode(result.stdout or "") or nil
    if type(status) == "table" then
      status.available = true
      callback(status)
    else
      callback({ available = false, error = noctalia.string.trim(tostring(result.stderr or "")) })
    end
  end)
end

function Adapter:command(arguments, callback)
  local argv = { self.executable }
  for _, argument in ipairs(arguments) do
    table.insert(argv, tostring(argument))
  end
  run(argv, function(result) callback(result.exitCode == 0) end)
end

function Adapter:startService(callback)
  run({ "systemctl", "--user", "enable", "--now", Constants.Service.Unit }, function(result)
    callback(result.exitCode == 0)
  end)
end

return Adapter
