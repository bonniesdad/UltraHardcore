-- 🟢 Character Stats Management
local CharacterStats = {
  -- Default values for new characters
  defaults = {
    lowestHealth = 100,
    elitesSlain = 0,
    enemiesSlain = 0,
    -- Add more stats here as needed
  }
}

-- Get the current character's stats
function CharacterStats:GetCurrentCharacterStats()
  local characterName = UnitName('player')
  local realmName = GetRealmName()
  local fullCharacterKey = characterName .. '-' .. realmName
  
  -- Initialize character stats if they don't exist
  if not UltraHardcoreDB.characterStats then
    UltraHardcoreDB.characterStats = {}
  end
  
  if not UltraHardcoreDB.characterStats[fullCharacterKey] then
    UltraHardcoreDB.characterStats[fullCharacterKey] = self.defaults
  end
  
  return UltraHardcoreDB.characterStats[fullCharacterKey]
end

-- Update a specific stat for the current character
function CharacterStats:UpdateStat(statName, value)
  local stats = self:GetCurrentCharacterStats()
  stats[statName] = value
  SaveDBData('characterStats', UltraHardcoreDB.characterStats)
end

-- Get a specific stat for the current character
function CharacterStats:GetStat(statName)
  local stats = self:GetCurrentCharacterStats()
  return stats[statName]
end

-- Get all stats for the current character
function CharacterStats:GetAllStats()
  return self:GetCurrentCharacterStats()
end

-- Get stats for a specific character
function CharacterStats:GetCharacterStats(characterName, realmName)
  local fullCharacterKey = characterName .. '-' .. realmName
  if UltraHardcoreDB.characterStats and UltraHardcoreDB.characterStats[fullCharacterKey] then
    return UltraHardcoreDB.characterStats[fullCharacterKey]
  end
  return self.defaults
end

-- Get all characters that have stats
function CharacterStats:GetAllCharacters()
  if not UltraHardcoreDB.characterStats then
    return {}
  end
  
  local characters = {}
  for characterKey, _ in pairs(UltraHardcoreDB.characterStats) do
    table.insert(characters, characterKey)
  end
  return characters
end

-- Export the CharacterStats object
_G.CharacterStats = CharacterStats 