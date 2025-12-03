-- 🟢 Save score persistently
function SaveDBData(name, newValue)
  UltraDB[name] = newValue
end

-- 🟢 Save settings for current character
function SaveCharacterSettings(settings)
  local characterGUID = UnitGUID('player')
  
  -- Initialize character settings if they don't exist
  if not UltraDB.characterSettings then
    UltraDB.characterSettings = {}
  end
  
  -- Save settings for current character
  UltraDB.characterSettings[characterGUID] = settings
end
