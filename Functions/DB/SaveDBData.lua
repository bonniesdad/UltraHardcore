-- 🟢 Save score persistently
function UHC_SaveDBData(name, newValue)
  UltraHardcoreDB[name] = newValue
end

-- 🟢 Save settings for current character
function UHC_SaveCharacterSettings(settings)
  local characterGUID = UnitGUID('player')

  -- Initialize character settings if they don't exist
  if not UltraHardcoreDB.characterSettings then
    UltraHardcoreDB.characterSettings = {}
  end

  -- Save settings for current character
  UltraHardcoreDB.characterSettings[characterGUID] = settings
end
