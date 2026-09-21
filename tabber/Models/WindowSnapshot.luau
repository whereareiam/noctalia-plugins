--!nonstrict

local Snapshot = {}
Snapshot.SPECIAL_WORKSPACE_PREFIX = "special:"

function Snapshot.address(value)
  local normalized = string.lower(string.match(tostring(value or ""), "^%s*(.-)%s*$") or "")
  if normalized == "" then return "" end
  return string.sub(normalized, 1, 2) == "0x" and normalized or ("0x" .. normalized)
end

function Snapshot.isSpecialWorkspace(workspace)
  local name = type(workspace) == "table" and workspace.name or workspace
  return string.sub(tostring(name or ""), 1, #Snapshot.SPECIAL_WORKSPACE_PREFIX) == Snapshot.SPECIAL_WORKSPACE_PREFIX
end

return Snapshot
