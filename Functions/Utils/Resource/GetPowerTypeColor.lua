-- Get the color for a power type
function GetPowerTypeColor(powerType)
  if not powerType or type(powerType) ~= 'string' then
    print('Ultra: Invalid power type provided to GetPowerTypeColor')
    return unpack(POWER_COLORS.MANA)
  end

  -- Prefer per-character override if present in settings
  if GLOBAL_SETTINGS and GLOBAL_SETTINGS.resourceBarColors and GLOBAL_SETTINGS.resourceBarColors[powerType] then
    local c = GLOBAL_SETTINGS.resourceBarColors[powerType]
    if type(c) == 'table' and #c >= 3 then
      return c[1], c[2], c[3]
    end
  end

  return unpack(POWER_COLORS[powerType] or POWER_COLORS.MANA)
end
