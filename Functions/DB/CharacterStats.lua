-- 🟢 Character Stats Management
local CharacterStats = {
  -- Default values for new characters
  defaults = {
    lowestHealth = 100,
    elitesSlain = 0,
    enemiesSlain = 0,
    xpGainedWithoutAddon = 0, -- XP gained without addon active
    lastSessionXP = 0, -- XP at the end of last session
    -- Add more stats here as needed
  }
}

-- Reset individual stats to default values for current character
function CharacterStats:ResetLowestHealth()
  local stats = self:GetCurrentCharacterStats()
  stats.lowestHealth = self.defaults.lowestHealth
  SaveDBData('characterStats', UltraHardcoreDB.characterStats)
  print("UHC - Lowest health has been reset to " .. self.defaults.lowestHealth)
end

function CharacterStats:ResetElitesSlain()
  local stats = self:GetCurrentCharacterStats()
  stats.elitesSlain = self.defaults.elitesSlain
  SaveDBData('characterStats', UltraHardcoreDB.characterStats)
  print("UHC - Elites slain has been reset to " .. self.defaults.elitesSlain)
end

function CharacterStats:ResetEnemiesSlain()
  local stats = self:GetCurrentCharacterStats()
  stats.enemiesSlain = self.defaults.enemiesSlain
  SaveDBData('characterStats', UltraHardcoreDB.characterStats)
  print("UHC - Enemies slain has been reset to " .. self.defaults.enemiesSlain)
end

function CharacterStats:ResetXPWithoutAddon()
  local stats = self:GetCurrentCharacterStats()
  stats.xpGainedWithoutAddon = self.defaults.xpGainedWithoutAddon
  stats.lastSessionXP = UnitXP("player") -- Reset to current XP
  SaveDBData('characterStats', UltraHardcoreDB.characterStats)
  print("UHC - XP gained without addon has been reset to " .. self.defaults.xpGainedWithoutAddon)
end

-- Reset stats to default values for current character
function CharacterStats:ResetStats()
  local characterGUID = UnitGUID('player')
  
  if not UltraHardcoreDB.characterStats then
    UltraHardcoreDB.characterStats = {}
  end
  
  UltraHardcoreDB.characterStats[characterGUID] = self.defaults
  SaveDBData('characterStats', UltraHardcoreDB.characterStats)
  print("UHC - Character stats have been reset to default values.")
end

-- Get the current character's stats
function CharacterStats:GetCurrentCharacterStats()
  local characterGUID = UnitGUID('player')
  
  -- Initialize character stats if they don't exist
  if not UltraHardcoreDB.characterStats then
    UltraHardcoreDB.characterStats = {}
  end
  
  if not UltraHardcoreDB.characterStats[characterGUID] then
    UltraHardcoreDB.characterStats[characterGUID] = self.defaults
  end
  
  return UltraHardcoreDB.characterStats[characterGUID]
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

-- Get stats for a specific character by GUID
function CharacterStats:GetCharacterStatsByGUID(characterGUID)
  if UltraHardcoreDB.characterStats and UltraHardcoreDB.characterStats[characterGUID] then
    return UltraHardcoreDB.characterStats[characterGUID]
  end
  return self.defaults
end

-- Get all characters that have stats
function CharacterStats:GetAllCharacters()
  if not UltraHardcoreDB.characterStats then
    return {}
  end
  
  local characters = {}
  for characterGUID, _ in pairs(UltraHardcoreDB.characterStats) do
    table.insert(characters, characterGUID)
  end
  return characters
end

-- Export the CharacterStats object
_G.CharacterStats = CharacterStats

-- Register slash commands for individual stat resets
SLASH_RESETLOWESTHEALTH1 = "/resetlowesthealth"
SlashCmdList["RESETLOWESTHEALTH"] = function()
  CharacterStats:ResetLowestHealth()
end

SLASH_RESETELITESSLAIN1 = "/resetelitesslain"
SlashCmdList["RESETELITESSLAIN"] = function()
  CharacterStats:ResetElitesSlain()
end

SLASH_RESETENEMIESSLAIN1 = "/resetenemiesslain"
SlashCmdList["RESETENEMIESSLAIN"] = function()
  CharacterStats:ResetEnemiesSlain()
end

SLASH_RESETXP1 = "/resetxp"
SlashCmdList["RESETXP"] = function()
  CharacterStats:ResetXPWithoutAddon()
end

-- Register slash command to reset stats
SLASH_RESETSTATS1 = "/resetstats"
SlashCmdList["RESETSTATS"] = function()
  CharacterStats:ResetStats()
end 