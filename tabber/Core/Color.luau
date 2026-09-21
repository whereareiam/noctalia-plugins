--!nonstrict

local Color = {}

function Color.withAlpha(value, alpha)
  local color = tostring(value or "")
  if color == "" then return color end

  local clamped = math.max(0, math.min(1, tonumber(alpha) or 1))
  local suffix = string.format("%02X", math.floor(clamped * 255 + 0.5))
  if string.sub(color, 1, 1) == "#" then
    return string.sub(color, 1, 7) .. suffix
  end
  return color .. "/" .. tostring(alpha)
end

return Color
