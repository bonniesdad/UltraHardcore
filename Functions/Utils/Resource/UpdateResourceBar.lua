-- Update a status bar with current resource values
function UpdateResourceBar(bar, powerType)
  if not bar or type(bar) ~= 'table' then
    print('UltraHardcore: Invalid status bar provided to UpdateResourceBar')
    return
  end

  if not powerType or type(powerType) ~= 'string' then
    print('UltraHardcore: Invalid power type provided to UpdateResourceBar')
    return
  end

  local powerEnum = Enum.PowerType[powerType]
  if not powerEnum then
    print('UltraHardcore: Invalid power type enum for ' .. powerType)
    return
  end

  local value = UnitPower('player', powerEnum)
  local maxValue = UnitPowerMax('player', powerEnum)

  if not value or not maxValue then
    print('UltraHardcore: Failed to get power values for ' .. powerType)
    return
  end

  bar:SetMinMaxValues(0, maxValue)
  bar:SetValue(value)
  bar:SetStatusBarColor(GetPowerTypeColor(powerType))
end
