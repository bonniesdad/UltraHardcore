-- 🟢 Character Stats Management
local CharacterStats = {
  -- Default values for new characters
  defaults = {
    lowestHealth = 100,
    lowestHealthThisLevel = 100,
    lowestHealthThisSession = 100,
    petDeaths = 0,
    elitesSlain = 0,
    enemiesSlain = 0,
    lastSessionXP = 0, -- XP at the end of last session
    -- XP tracking for each UHC setting
    xpGainedWithoutOptionHidePlayerFrame = 0,
    xpGainedWithoutOptionShowOnScreenStatistics = 0,
    xpGainedWithoutOptionShowTunnelVision = 0,
    xpGainedWithoutOptionAnnounceLevelUpToGuild = 0,
    xpGainedWithoutOptionTunnelVisionMaxStrata = 0,
    xpGainedWithoutOptionHideTargetFrame = 0,
    xpGainedWithoutOptionHideTargetTooltip = 0,
    xpGainedWithoutOptionDisableNameplateHealth = 0,
    xpGainedWithoutOptionShowDazedEffect = 0,
    xpGainedWithoutOptionHideGroupHealth = 0,
    xpGainedWithoutOptionHideMinimap = 0,
    xpGainedWithoutOptionHideQuestFrame = 0,
    xpGainedWithoutOptionHideBuffFrame = 0,
    xpGainedWithoutOptionHideBreathIndicator = 0,
    xpGainedWithoutOptionShowCritScreenMoveEffect = 0,
    xpGainedWithoutOptionHideActionBars = 0,
    xpGainedWithoutOptionPetsDiePermanently = 0,
    xpGainedWithoutOptionShowFullHealthIndicator = 0,
    xpGainedWithoutOptionShowIncomingDamageEffect = 0,
    xpGainedWithoutOptionShowHealingIndicator = 0,
    -- Survival statistics
    healthPotionsUsed = 0,
    bandagesUsed = 0,
    targetDummiesUsed = 0,
    grenadesUsed = 0,
    partyMemberDeaths = 0,
    -- Combat statistics
    dungeonBossesKilled = 0,
    dungeonsCompleted = 0,
    -- Add more stats here as needed
  }
}

-- Reset individual stats to default values for current character
function CharacterStats:ResetLowestHealth()
  local stats = self:GetCurrentCharacterStats()
  stats.lowestHealth = self.defaults.lowestHealth
  SaveDBData('characterStats', UltraHardcoreDB.characterStats)
end

function CharacterStats:ResetLowestHealthThisLevel()
  local stats = self:GetCurrentCharacterStats()
  stats.lowestHealthThisLevel = self.defaults.lowestHealthThisLevel
  SaveDBData('characterStats', UltraHardcoreDB.characterStats)
end

function CharacterStats:ResetLowestHealthThisSession()
  local stats = self:GetCurrentCharacterStats()
  stats.lowestHealthThisSession = self.defaults.lowestHealthThisSession
  SaveDBData('characterStats', UltraHardcoreDB.characterStats)
end


function CharacterStats:ResetPetDeaths()
  local stats = self:GetCurrentCharacterStats()
  stats.petDeaths = self.defaults.petDeaths
  SaveDBData('characterStats', UltraHardcoreDB.characterStats)
end


function CharacterStats:ResetElitesSlain()
  local stats = self:GetCurrentCharacterStats()
  stats.elitesSlain = self.defaults.elitesSlain
  SaveDBData('characterStats', UltraHardcoreDB.characterStats)
end

function CharacterStats:ResetEnemiesSlain()
  local stats = self:GetCurrentCharacterStats()
  stats.enemiesSlain = self.defaults.enemiesSlain
  SaveDBData('characterStats', UltraHardcoreDB.characterStats)
end

-- Reset survival statistics
function CharacterStats:ResetHealthPotionsUsed()
  local stats = self:GetCurrentCharacterStats()
  stats.healthPotionsUsed = self.defaults.healthPotionsUsed
  SaveDBData('characterStats', UltraHardcoreDB.characterStats)
end

function CharacterStats:ResetBandagesUsed()
  local stats = self:GetCurrentCharacterStats()
  stats.bandagesUsed = self.defaults.bandagesUsed
  SaveDBData('characterStats', UltraHardcoreDB.characterStats)
end

function CharacterStats:ResetTargetDummiesUsed()
  local stats = self:GetCurrentCharacterStats()
  stats.targetDummiesUsed = self.defaults.targetDummiesUsed
  SaveDBData('characterStats', UltraHardcoreDB.characterStats)
end

function CharacterStats:ResetGrenadesUsed()
  local stats = self:GetCurrentCharacterStats()
  stats.grenadesUsed = self.defaults.grenadesUsed
  SaveDBData('characterStats', UltraHardcoreDB.characterStats)
end

function CharacterStats:ResetPartyMemberDeaths()
  local stats = self:GetCurrentCharacterStats()
  stats.partyMemberDeaths = self.defaults.partyMemberDeaths
  SaveDBData('characterStats', UltraHardcoreDB.characterStats)
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
  
  -- Initialize new stats for existing characters (backward compatibility)
  local stats = UltraHardcoreDB.characterStats[characterGUID]
  if stats.lowestHealthThisLevel == nil then
    stats.lowestHealthThisLevel = self.defaults.lowestHealthThisLevel
  end
  if stats.lowestHealthThisSession == nil then
    stats.lowestHealthThisSession = self.defaults.lowestHealthThisSession
  end
  if stats.petDeaths == nil then
    stats.petDeaths = self.defaults.petDeaths
  end
  
  return stats
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
    local condensedMessage = "[ULTRA] " .. playerName .. " (" .. playerClass .. " L" .. playerLevel .. ") - Health: " .. string.format("%.1f", stats.lowestHealth) .. "% - Pet Deaths: " .. stats.petDeaths .. " - Elites: " .. stats.elitesSlain .. " - Enemies: " .. stats.enemiesSlain
    sendMessage(condensedMessage)
  -- else
  --   -- Multi-line format for say/party chat
  --   sendMessage("-------- UHC STATS --------")
  --   sendMessage(playerName .. " (" .. playerClass .. " Level " .. playerLevel .. ")")
    
  --   -- Send each stat on its own line with lots of spacing and right-aligned numbers
  --   sendMessage("Lowest Health ---------------" .. string.format("%8.1f", stats.lowestHealth) .. "%")
  --   sendMessage("Elites Slain -------------------" .. string.format("%8d", stats.elitesSlain))
  --   sendMessage("Enemies Slain ---------------" .. string.format("%8d", stats.enemiesSlain))
  -- end
end

-- Function to show chat channel selection dialog
function CharacterStats:ShowChatChannelDialog()
  local stats = self:GetCurrentCharacterStats()
  local playerName = UnitName("player")
  local playerLevel = UnitLevel("player")
  local playerClass = UnitClass("player")
  
  -- Create dialog frame positioned above the main settings panel
  local dialog = CreateFrame('Frame', nil, UIParent, 'BackdropTemplate')
  dialog:SetSize(400, 280)
  dialog:SetPoint('CENTER', UIParent, 'CENTER', 0, 100) -- Positioned above main settings
  dialog:SetFrameStrata('DIALOG')
  dialog:SetFrameLevel(25) -- Higher than main settings panel
  
  -- Create solid black background wrapper
  local blackBackground = CreateFrame('Frame', nil, dialog, 'BackdropTemplate')
  blackBackground:SetAllPoints(dialog)
  blackBackground:SetFrameStrata('DIALOG')
  blackBackground:SetFrameLevel(24) -- Just below the main dialog
  blackBackground:SetBackdrop({
    bgFile = 'Interface\\Buttons\\WHITE8X8',
    edgeFile = 'Interface\\Buttons\\WHITE8X8',
    tile = true,
    tileSize = 1,
    edgeSize = 1,
    insets = {
      left = 0,
      right = 0,
      top = 0,
      bottom = 0,
    },
  })
  blackBackground:SetBackdropColor(0, 0, 0, 1) -- Pure black
  blackBackground:SetBackdropBorderColor(0, 0, 0, 1) -- Pure black border
  
  dialog:SetBackdrop({
    bgFile = 'Interface\\Tooltips\\UI-Tooltip-Background',
    edgeFile = 'Interface\\DialogFrame\\UI-DialogBox-Border',
    tile = true,
    tileSize = 32,
    edgeSize = 16,
    insets = {
      left = 4,
      right = 4,
      top = 4,
      bottom = 4,
    },
  })
  dialog:SetBackdropColor(0, 0, 0, 1) -- Make fully opaque
  dialog:SetBackdropBorderColor(0.6, 0.6, 0.6, 1) -- Ensure border is also opaque
  
  -- Create title bar matching main settings style
  local titleBar = CreateFrame('Frame', nil, dialog, 'BackdropTemplate')
  titleBar:SetSize(400, 50)
  titleBar:SetPoint('TOP', dialog, 'TOP')
  titleBar:SetFrameStrata('DIALOG')
  titleBar:SetFrameLevel(30) -- Higher than main dialog
  titleBar:SetBackdrop({
    bgFile = 'Interface\\DialogFrame\\UI-DialogBox-Background',
    edgeFile = 'Interface\\DialogFrame\\UI-DialogBox-Border',
    tile = true,
    tileSize = 64,
    edgeSize = 16,
    insets = {
      left = 4,
      right = 4,
      top = 4,
      bottom = 4,
    },
  })
  titleBar:SetBackdropColor(0, 0, 0, 1) -- Pure black background, fully opaque
  titleBar:SetBackdropBorderColor(0.6, 0.6, 0.6, 1) -- Light grey border
  
  -- Create title image matching main settings
  local dialogTitleImage = titleBar:CreateTexture(nil, 'OVERLAY')
  dialogTitleImage:SetSize(300, 40)
  dialogTitleImage:SetPoint('CENTER', titleBar, 'CENTER', 0, 0)
  dialogTitleImage:SetTexture('Interface\\AddOns\\UltraHardcore\\Textures\\ultra-hc-title.png')
  dialogTitleImage:SetTexCoord(0, 1, 0, 1)
  
  -- Close button
  local closeButton = CreateFrame('Button', nil, titleBar, 'UIPanelCloseButton')
  closeButton:SetPoint('RIGHT', titleBar, 'RIGHT', -4, 0)
  closeButton:SetSize(32, 32)
  closeButton:SetScript('OnClick', function()
    dialog:Hide()
  end)
  
  -- Create content area with proper styling
  local contentFrame = CreateFrame('Frame', nil, dialog)
  contentFrame:SetSize(380, 210)
  contentFrame:SetPoint('TOP', dialog, 'TOP', 0, -50)
  
  -- Create stats preview section
  local statsHeader = CreateFrame('Frame', nil, contentFrame, 'BackdropTemplate')
  statsHeader:SetSize(360, 28)
  statsHeader:SetPoint('TOP', contentFrame, 'TOP', 0, -10)
  statsHeader:SetBackdrop({
    bgFile = 'Interface\\DialogFrame\\UI-DialogBox-Background',
    edgeFile = 'Interface\\DialogFrame\\UI-DialogBox-Border',
    tile = true,
    tileSize = 32,
    edgeSize = 16,
    insets = {
      left = 4,
      right = 4,
      top = 4,
      bottom = 4,
    },
  })
  statsHeader:SetBackdropColor(0.2, 0.2, 0.2, 0.9)
  statsHeader:SetBackdropBorderColor(0.6, 0.6, 0.6, 1)
  
  local statsHeaderText = statsHeader:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  statsHeaderText:SetPoint('LEFT', statsHeader, 'LEFT', 12, 0)
  statsHeaderText:SetText('Stats Preview')
  
  -- Create stats preview content
  local statsPreview = CreateFrame('Frame', nil, contentFrame, 'BackdropTemplate')
  statsPreview:SetSize(340, 100)
  statsPreview:SetPoint('TOP', contentFrame, 'TOP', 0, -38)
  statsPreview:SetBackdrop({
    bgFile = 'Interface\\Buttons\\UI-Listbox-Empty',
    edgeFile = 'Interface\\Buttons\\UI-Listbox-Empty',
    tile = true,
    tileSize = 16,
    edgeSize = 8,
    insets = {
      left = 4,
      right = 4,
      top = 4,
      bottom = 4,
    },
  })
  
  -- Player info
  local playerInfoText = statsPreview:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  playerInfoText:SetPoint('TOPLEFT', statsPreview, 'TOPLEFT', 12, -8)
  playerInfoText:SetText(playerName .. " (" .. playerClass .. " Level " .. playerLevel .. ")")
  
  -- Stats breakdown
  local lowestHealthText = statsPreview:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  lowestHealthText:SetPoint('TOPLEFT', statsPreview, 'TOPLEFT', 12, -28)
  lowestHealthText:SetText("Lowest Health: " .. string.format("%.1f", stats.lowestHealth) .. "%")
  
  local petDeathsText = statsPreview:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  petDeathsText:SetPoint('TOPLEFT', statsPreview, 'TOPLEFT', 12, -48)
  petDeathsText:SetText("Pet Deaths: " .. stats.petDeaths)
  
  local partyDeathsText = statsPreview:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  partyDeathsText:SetPoint('TOPLEFT', statsPreview, 'TOPLEFT', 12, -68)
  partyDeathsText:SetText("Roach index: " .. stats.partyMemberDeaths)
  
  local elitesText = statsPreview:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  elitesText:SetPoint('TOPLEFT', statsPreview, 'TOPLEFT', 12, -88)
  elitesText:SetText("Elites Slain: " .. stats.elitesSlain)
  
  local enemiesText = statsPreview:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  enemiesText:SetPoint('TOPLEFT', statsPreview, 'TOPLEFT', 12, -108)
  enemiesText:SetText("Enemies Slain: " .. stats.enemiesSlain)
  
  -- Create channel selection section
  local channelHeader = CreateFrame('Frame', nil, contentFrame, 'BackdropTemplate')
  channelHeader:SetSize(360, 28)
  channelHeader:SetPoint('TOP', contentFrame, 'TOP', 0, -160)
  channelHeader:SetBackdrop({
    bgFile = 'Interface\\DialogFrame\\UI-DialogBox-Background',
    edgeFile = 'Interface\\DialogFrame\\UI-DialogBox-Border',
    tile = true,
    tileSize = 32,
    edgeSize = 16,
    insets = {
      left = 4,
      right = 4,
      top = 4,
      bottom = 4,
    },
  })
  channelHeader:SetBackdropColor(0.2, 0.2, 0.2, 0.9)
  channelHeader:SetBackdropBorderColor(0.6, 0.6, 0.6, 1)
  
  local channelHeaderText = channelHeader:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  channelHeaderText:SetPoint('LEFT', channelHeader, 'LEFT', 12, 0)
  channelHeaderText:SetText('Select Channel')
  
  -- Function to send stats to specific channel
  local function sendStatsToChannel(channel)
    local function sendMessage(text)
      SendChatMessage(text, channel)
    end
    
    -- Single line format for all channels
    local condensedMessage = "[ULTRA] " .. playerName .. " (" .. playerClass .. " L" .. playerLevel .. ") - Health: " .. string.format("%.1f", stats.lowestHealth) .. "% - Pet Deaths: " .. stats.petDeaths .. " - Roach index: " .. stats.partyMemberDeaths .. " - Elites: " .. stats.elitesSlain .. " - Enemies: " .. stats.enemiesSlain
    sendMessage(condensedMessage)
    
    dialog:Hide()
  end
  
  -- Create button container
  local buttonContainer = CreateFrame('Frame', nil, contentFrame)
  buttonContainer:SetSize(340, 80)
  buttonContainer:SetPoint('TOP', contentFrame, 'TOP', 0, -188)
  
  -- Say button
  local sayButton = CreateFrame('Button', nil, buttonContainer, 'UIPanelButtonTemplate')
  sayButton:SetSize(100, 30)
  sayButton:SetPoint('TOPLEFT', buttonContainer, 'TOPLEFT', 10, -10)
  sayButton:SetText('Say')
  sayButton:SetScript('OnClick', function()
    sendStatsToChannel('SAY')
  end)
  
  -- Party button
  local partyButton = CreateFrame('Button', nil, buttonContainer, 'UIPanelButtonTemplate')
  partyButton:SetSize(100, 30)
  partyButton:SetPoint('TOPLEFT', buttonContainer, 'TOPLEFT', 120, -10)
  partyButton:SetText('Party')
  partyButton:SetScript('OnClick', function()
    sendStatsToChannel('PARTY')
  end)
  
  -- Guild button
  local guildButton = CreateFrame('Button', nil, buttonContainer, 'UIPanelButtonTemplate')
  guildButton:SetSize(100, 30)
  guildButton:SetPoint('TOPLEFT', buttonContainer, 'TOPLEFT', 230, -10)
  guildButton:SetText('Guild')
  guildButton:SetScript('OnClick', function()
    sendStatsToChannel('GUILD')
  end)
  
  -- Disable guild button if not in guild
  if not IsInGuild() then
    guildButton:Disable()
    guildButton:SetText('Guild (N/A)')
  end
  
  -- Add tooltips for buttons
  sayButton:SetScript('OnEnter', function()
    GameTooltip:SetOwner(sayButton, 'ANCHOR_TOP')
    GameTooltip:SetText('Post stats to /say channel')
    GameTooltip:AddLine('Single-line condensed format', 1, 1, 1, true)
    GameTooltip:Show()
  end)
  sayButton:SetScript('OnLeave', function()
    GameTooltip:Hide()
  end)
  
  partyButton:SetScript('OnEnter', function()
    GameTooltip:SetOwner(partyButton, 'ANCHOR_TOP')
    GameTooltip:SetText('Post stats to party chat')
    GameTooltip:AddLine('Single-line condensed format', 1, 1, 1, true)
    GameTooltip:Show()
  end)
  partyButton:SetScript('OnLeave', function()
    GameTooltip:Hide()
  end)
  
  guildButton:SetScript('OnEnter', function()
    GameTooltip:SetOwner(guildButton, 'ANCHOR_TOP')
    GameTooltip:SetText('Post stats to guild chat')
    GameTooltip:AddLine('Single-line condensed format', 1, 1, 1, true)
    GameTooltip:Show()
  end)
  guildButton:SetScript('OnLeave', function()
    GameTooltip:Hide()
  end)
  
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

SLASH_RESETPETDEATHS1 = "/resetpetdeaths"
SlashCmdList["RESETPETDEATHS"] = function()
  CharacterStats:ResetPetDeaths()
end


SLASH_RESETELITESSLAIN1 = "/resetelitesslain"
SlashCmdList["RESETELITESSLAIN"] = function()
  CharacterStats:ResetElitesSlain()
end

SLASH_RESETENEMIESSLAIN1 = "/resetenemiesslain"
SlashCmdList["RESETENEMIESSLAIN"] = function()
  CharacterStats:ResetEnemiesSlain()
end

-- Slash commands for survival statistics
SLASH_RESETHEALTHPOTIONS1 = "/resethealthpotions"
SlashCmdList["RESETHEALTHPOTIONS"] = function()
  CharacterStats:ResetHealthPotionsUsed()
end

SLASH_RESETBANDAGES1 = "/resetbandages"
SlashCmdList["RESETBANDAGES"] = function()
  CharacterStats:ResetBandagesUsed()
end

SLASH_RESETTARGETDUMMIES1 = "/resettargetdummies"
SlashCmdList["RESETTARGETDUMMIES"] = function()
  CharacterStats:ResetTargetDummiesUsed()
end

SLASH_RESETGRENADES1 = "/resetgrenades"
SlashCmdList["RESETGRENADES"] = function()
  CharacterStats:ResetGrenadesUsed()
end

SLASH_RESETPARTYMEMBERDEATHS1 = "/resetpartymemberdeaths"
SlashCmdList["RESETPARTYMEMBERDEATHS"] = function()
  CharacterStats:ResetPartyMemberDeaths()
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