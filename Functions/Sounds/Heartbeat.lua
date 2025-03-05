local frame = CreateFrame('Frame')
frame:RegisterEvent('UNIT_POWER_UPDATE')

local lastPower = UnitPower('player', Enum.PowerType.Energy) -- Initialize with current value
local function OnEvent(self, event, unit, powerType)
  if unit == 'player' and (powerType == 'ENERGY' or powerType == 'MANA') then
    local currentPower = UnitPower('player', Enum.PowerType[powerType])

    if currentPower > lastPower then
      local volume = 1 -- Adjust this (0.0 = mute, 1.0 = max)
      -- Store the current ambience volume
      local ambienceVolume = GetCVar('Sound_AmbienceVolume')
      SetCVar('Sound_AmbienceVolume', volume) -- Temporarily set new volume
      PlaySoundFile('Interface\\AddOns\\UltraHardcore\\Sounds\\heartbeat.ogg', 'Master')

      -- Restore previous volume after a short delay
      C_Timer.After(0.1, function()
        SetCVar('Sound_AmbienceVolume', ambienceVolume)
      end)
    end

    lastPower = currentPower -- Update for next check
  end
end

frame:SetScript('OnEvent', OnEvent)
