-- 🟢 Save score persistently
function SaveDBData(name, newValue)
  UltraHardcoreDB[name] = newValue
end

-- 🟢 Save settings for current character
function SaveCharacterSettings(settings)
  local characterGUID = UnitGUID('player')
  
  -- Initialize character settings if they don't exist
  if not UltraHardcoreDB.characterSettings then
    UltraHardcoreDB.characterSettings = {}
  end
  
  -- Save settings for current character
  UltraHardcoreDB.characterSettings[characterGUID] = settings
end
