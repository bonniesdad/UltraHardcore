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

-- Function to log stats directly to a specific channel (for slash commands)
function CharacterStats:LogStatsToSpecificChannel(channel)
  local stats = self:GetCurrentCharacterStats()
  local playerName = UnitName("player")
  local playerLevel = UnitLevel("player")
  local playerClass = UnitClass("player")
  
  local function sendMessage(text)
    SendChatMessage(text, channel)
  end
  
  -- if channel == 'GUILD' then
    -- Condensed single line for guild chat to avoid spam
    local condensedMessage = "UHC Stats - " .. playerName .. " (" .. playerClass .. " L" .. playerLevel .. ") - Health: " .. string.format("%.1f", stats.lowestHealth) .. "% - Elites: " .. stats.elitesSlain .. " - Enemies: " .. stats.enemiesSlain .. " - XP Without: " .. stats.xpGainedWithoutAddon
    sendMessage(condensedMessage)
  -- else
  --   -- Multi-line format for say/party chat
  --   sendMessage("-------- UHC STATS --------")
  --   sendMessage(playerName .. " (" .. playerClass .. " Level " .. playerLevel .. ")")
    
  --   -- Send each stat on its own line with lots of spacing and right-aligned numbers
  --   sendMessage("Lowest Health ---------------" .. string.format("%8.1f", stats.lowestHealth) .. "%")
  --   sendMessage("Elites Slain -------------------" .. string.format("%8d", stats.elitesSlain))
  --   sendMessage("Enemies Slain ---------------" .. string.format("%8d", stats.enemiesSlain))
  --   sendMessage("XP Without Addon: --------" .. string.format("%8d", stats.xpGainedWithoutAddon))
  -- end
end

-- Function to show chat channel selection dialog
function CharacterStats:ShowChatChannelDialog()
  local stats = self:GetCurrentCharacterStats()
  local playerName = UnitName("player")
  local playerLevel = UnitLevel("player")
  local playerClass = UnitClass("player")
  
  -- Create dialog frame (slimmer with darker background)
  local dialog = CreateFrame('Frame', nil, UIParent, 'BackdropTemplate')
  dialog:SetSize(250, 140)
  dialog:SetPoint('CENTER', UIParent, 'CENTER')
  dialog:SetFrameStrata('DIALOG')
  dialog:SetBackdrop({
    bgFile = 'Interface\\DialogFrame\\UI-DialogBox-Background-Dark',
    edgeFile = 'Interface\\DialogFrame\\UI-DialogBox-Border',
    tile = true,
    tileSize = 32,
    edgeSize = 12,
    insets = {
      left = 2,
      right = 2,
      top = 2,
      bottom = 2,
    },
  })
  dialog:SetBackdropColor(0, 0, 0, 0.95) -- Darker background
  
  -- Title
  local title = dialog:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  title:SetPoint('TOP', dialog, 'TOP', 0, -20)
  title:SetText('Post UHC Stats to Chat')
  title:SetFont('Fonts\\FRIZQT__.TTF', 16, 'OUTLINE')
  
  -- Close button
  local closeButton = CreateFrame('Button', nil, dialog, 'UIPanelCloseButton')
  closeButton:SetPoint('TOPRIGHT', dialog, 'TOPRIGHT', -4, -4)
  closeButton:SetSize(32, 32)
  closeButton:SetScript('OnClick', function()
    dialog:Hide()
  end)
  
  -- Function to send stats to specific channel
  local function sendStatsToChannel(channel)
    local function sendMessage(text)
      SendChatMessage(text, channel)
    end
    
    -- if channel == 'GUILD' then
      -- Condensed single line for guild chat to avoid spam
    local condensedMessage = "UHC Stats - " .. playerName .. " (" .. playerClass .. " L" .. playerLevel .. ") - Health: " .. string.format("%.1f", stats.lowestHealth) .. "% - Elites: " .. stats.elitesSlain .. " - Enemies: " .. stats.enemiesSlain .. " - XP Without: " .. stats.xpGainedWithoutAddon
    sendMessage(condensedMessage)
    -- else
      -- Multi-line format for say/party chat
      -- sendMessage("-------- UHC STATS --------")
      -- sendMessage(playerName .. " (" .. playerClass .. " Level " .. playerLevel .. ")")
      
      -- -- Send each stat on its own line with lots of spacing and right-aligned numbers
      -- sendMessage("Lowest Health ---------------" .. string.format("%8.1f", stats.lowestHealth) .. "%")
      -- sendMessage("Elites Slain -------------------" .. string.format("%8d", stats.elitesSlain))
      -- sendMessage("Enemies Slain ---------------" .. string.format("%8d", stats.enemiesSlain))
      -- sendMessage("XP Without Addon: --------" .. string.format("%8d", stats.xpGainedWithoutAddon))
    -- end
    
    dialog:Hide()
  end
  
  -- Say button
  local sayButton = CreateFrame('Button', nil, dialog, 'UIPanelButtonTemplate')
  sayButton:SetSize(100, 25)
  sayButton:SetPoint('CENTER', dialog, 'CENTER', 0, 15)
  sayButton:SetText('Say')
  sayButton:SetScript('OnClick', function()
    sendStatsToChannel('SAY')
  end)
  
  -- Party button
  local partyButton = CreateFrame('Button', nil, dialog, 'UIPanelButtonTemplate')
  partyButton:SetSize(100, 25)
  partyButton:SetPoint('CENTER', dialog, 'CENTER', 0, -10)
  partyButton:SetText('Party')
  partyButton:SetScript('OnClick', function()
    sendStatsToChannel('PARTY')
  end)
  
  -- Guild button
  local guildButton = CreateFrame('Button', nil, dialog, 'UIPanelButtonTemplate')
  guildButton:SetSize(100, 25)
  guildButton:SetPoint('CENTER', dialog, 'CENTER', 0, -35)
  guildButton:SetText('Guild')
  guildButton:SetScript('OnClick', function()
    sendStatsToChannel('GUILD')
  end)
  
  -- Disable guild button if not in guild
  if not IsInGuild() then
    guildButton:Disable()
    guildButton:SetText('Guild (Not Available)')
  end
  
  dialog:Show()
end

-- Function to log all current UHC stats to chat (for slash command compatibility)
function CharacterStats:LogStatsToChat()
  self:ShowChatChannelDialog()
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

-- Register slash commands to log stats to specific channels
SLASH_LOGSTATSS1 = "/logstatss"
SlashCmdList["LOGSTATSS"] = function()
  CharacterStats:LogStatsToSpecificChannel('SAY')
end

SLASH_LOGSTATSP1 = "/logstatsp"
SlashCmdList["LOGSTATSP"] = function()
  CharacterStats:LogStatsToSpecificChannel('PARTY')
end

SLASH_LOGSTATSG1 = "/logstatsg"
SlashCmdList["LOGSTATSG"] = function()
  CharacterStats:LogStatsToSpecificChannel('GUILD')
end

-- Keep the general command for backward compatibility
SLASH_LOGSTATS1 = "/logstats"
SLASH_LOGSTATS2 = "/uhcstats"
SlashCmdList["LOGSTATS"] = function()
  CharacterStats:LogStatsToChat()
end 