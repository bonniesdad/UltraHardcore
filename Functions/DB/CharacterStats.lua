-- 🟢 Character Stats Management
local statsInitialized = false

TotalXPTable = {
  [1]=400, [2]=900, [3]=1400, [4]=2100, [5]=2800, [6]=3600, [7]=4500, [8]=5400, [9]=6500, [10] = 7600,
  [11] = 8800, [12] = 10100, [13] = 11400, [14] = 12900, [15] = 14400, [16] = 16000, [17] = 17700, [18] = 19400, [19] = 21300, [20] = 23200,
  [21] = 25200, [22] = 27300, [23] = 29400, [24] = 31700, [25] = 34000, [26] = 36400, [27] = 38900, [28] = 41400, [29] = 44300, [30] = 47400,
  [31] = 50800, [32] = 54500, [33] = 58600, [34] = 62800, [35] = 67100, [36] = 71600, [37] = 76100, [38] = 80800, [39] = 85700, [40] = 90700,
  [41] = 95800, [42] = 101000, [43] = 106300, [44] = 111800, [45] = 117500, [46] = 123200, [47] = 129100, [48] = 135100, [49] = 141200, [50] = 147500,
  [51] = 153900, [52] = 160400, [53] = 167100, [54] = 173900, [55] = 180800, [56] = 187900, [57] = 195000, [58] = 202300, [59] = 209800, [60] = 217400
}

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
    xpGainedWithoutOptionShowFullHealthIndicatorAudioCue = 0,
    xpGainedWithoutOptionShowIncomingDamageEffect = 0,
    xpGainedWithoutOptionShowHealingIndicator = 0,
    xpGWA = 0, -- Used to track XP gained with the addon
    xpGWOA = 0, -- These variable names are abbreviated to discourage SavedVariable file editing
    xpTotal = 0,
    xpGainedWithoutOptionRoutePlanner = 0,
    -- Survival statistics
    healthPotionsUsed = 0,
    manaPotionsUsed = 0,
    bandagesUsed = 0,
    targetDummiesUsed = 0,
    grenadesUsed = 0,
    partyMemberDeaths = 0,
    closeEscapes = 0,
    duelsTotal = 0,
    duelsWon = 0,
    duelsLost = 0,
    duelsWinPercent = 0,
    playerJumps = 0,
    mapKeyPressesWhileMapBlocked = 0,
    -- Combat statistics
    dungeonBossesKilled = 0,
    dungeonsCompleted = 0,
    highestCritValue = 0,
    highestHealCritValue = 0,
    rareElitesSlain = 0,
    worldBossesSlain = 0,
    -- Add more stats here as needed
  },
}

-- Reset individual stats to default values for current character
function CharacterStats:ResetLowestHealth()
  local stats = self:GetCurrentCharacterStats()
  stats.lowestHealth = self.defaults.lowestHealth
  SaveDBData('characterStats', UltraHardcoreDB.characterStats)
end

-- Set lowest health to a specific value
function CharacterStats:SetLowestHealth(value)
  local numValue = tonumber(value)
  if numValue and numValue >= 0 and numValue <= 100 then
    local stats = self:GetCurrentCharacterStats()
    if numValue < stats.lowestHealth then
      print('UltraHardcore: You cannot set a lowest health lower than the current lowest health.')
      return
    end
    local stats = self:GetCurrentCharacterStats()
    stats.lowestHealth = numValue
    SaveDBData('characterStats', UltraHardcoreDB.characterStats)
    print('UltraHardcore: Set lowest health to ' .. string.format('%.1f', numValue) .. '%')
  else
    print(
      'UltraHardcore: Invalid value. Please enter a number between 0 and 100 (e.g., /setLowestHealth 20)'
    )
  end
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

function CharacterStats:ResetManaPotionsUsed()
  local stats = self:GetCurrentCharacterStats()
  stats.manaPotionsUsed = self.defaults.manaPotionsUsed
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

function CharacterStats:ResetDuelsTotal()
  local stats = self:GetCurrentCharacterStats()
  stats.duelsTotal = self.defaults.duelsTotal
  SaveDBData('characterStats', UltraHardcoreDB.characterStats)
end

function CharacterStats:ResetDuelsWon()
  local stats = self:GetCurrentCharacterStats()
  stats.duelsWon = self.defaults.duelsWon
  SaveDBData('characterStats', UltraHardcoreDB.characterStats)
end

function CharacterStats:ResetDuelsLost()
  local stats = self:GetCurrentCharacterStats()
  stats.duelsLost = self.defaults.duelsLost
  SaveDBData('characterStats', UltraHardcoreDB.characterStats)
end

function CharacterStats:ResetDuelsWinPercent()
  local stats = self:GetCurrentCharacterStats()
  stats.duelsWinPercent = self.defaults.duelsWinPercent
  SaveDBData('characterStats', UltraHardcoreDB.characterStats)
end

function CharacterStats:ResetPlayerJumps()
  local stats = self:GetCurrentCharacterStats()
  stats.playerJumps = self.defaults.playerJumps
  SaveDBData('characterStats', UltraHardcoreDB.characterStats)
end

function CharacterStats:ResetPartyMemberDeaths()
  local stats = self:GetCurrentCharacterStats()
  stats.partyMemberDeaths = self.defaults.partyMemberDeaths
  SaveDBData('characterStats', UltraHardcoreDB.characterStats)
end

function CharacterStats:ResetHighestCritValue()
  local stats = self:GetCurrentCharacterStats()
  stats.highestCritValue = self.defaults.highestCritValue
  SaveDBData('characterStats', UltraHardcoreDB.characterStats)
end

function CharacterStats:ResetHighestHealCritValue()
  local stats = self:GetCurrentCharacterStats()
  stats.highestHealCritValue = self.defaults.highestHealCritValue
  SaveDBData('characterStats', UltraHardcoreDB.characterStats)
end

function CharacterStats:ResetRareElitesSlain()
  local stats = self:GetCurrentCharacterStats()
  stats.rareElitesSlain = self.defaults.rareElitesSlain
  SaveDBData('characterStats', UltraHardcoreDB.characterStats)
end

function CharacterStats:ResetWorldBossesSlain()
  local stats = self:GetCurrentCharacterStats()
  stats.worldBossesSlain = self.defaults.worldBossesSlain
  SaveDBData('characterStats', UltraHardcoreDB.characterStats)
end

function CharacterStats:ReportXPWithoutAddon()
  local stats = CharacterStats:GetCurrentCharacterStats()
  local xpGainedWithoutAddon = stats.xpGWOA
  if xpGainedWithoutAddon ~= nil then
    return xpGainedWithoutAddon
  else
    print('Cannot load XP Gained without addon stat')
    return false
  end
end

function CharacterStats:CalculateTotalXPGained()
    local stats = CharacterStats:GetCurrentCharacterStats()
    local currentLevel = UnitLevel("player")
    local totalXP = 0

    for i, xp in ipairs(TotalXPTable) do
      if i < currentLevel then
        totalXP = totalXP + xp
      end
    end
    local currentXP = UnitXP('player')
    totalXP = totalXP + currentXP
    CharacterStats:UpdateStat("xpTotal", totalXP)
    if stats.xpGWA ~= nil and stats.xpGWA > 0 then
      CharacterStats:UpdateStat("xpGWOA", totalXP - stats.xpGWA)
    end
    return totalXP
end

-- This will retroactively figure out the amount of XP gained _with_ the addon
function CharacterStats:ResetXPGainedWithAddon(forceReset)
  local stats = self:GetCurrentCharacterStats()

  if stats.xpGWA == nil or forceReset ~= nil then
    local lowestXP = 9999999 -- Start with a high number

    for statName, _ in pairs(self.defaults) do
      local xpForStat = stats[statName] 

      -- Only use XP Gained Without stats for finding lowest XP value
      local startIdx = string.find(statName, "xpGainedWithoutOption")

      if startIdx == 1 then
        -- xpGainedWithoutOption stats that have never get incremented seem to be nil in the stats for some characters
        if xpForStat == nil then xpForStat = 0 end
        if xpForStat < lowestXP then
          lowestXP = xpForStat
        end
      end
    end

    if lowestXP < 9999999 then
      -- This calculates XP gained in the current level + the previous levels
      local totalXP = self.CalculateTotalXPGained()
      -- This subtracts the lowest "xpGainedWithout" stat value from current XP to figure out
      -- how much XP was gained with the addon.
      local xpDiff = totalXP - lowestXP
      local xpWithoutAddon = totalXP - xpDiff
      --[[print('You have ' .. formatNumberWithCommas(totalXP) .. ' total XP. ') 
      print(formatNumberWithCommas(xpDiff) .. ' gained with addon.') 
      print(formatNumberWithCommas(xpWithoutAddon) .. ' gained without addon.  ') 
      print('Validate: ' .. formatNumberWithCommas(xpWithoutAddon + xpDiff) .. ' should equal ' .. formatNumberWithCommas(totalXP))]]
      CharacterStats:UpdateStat("xpGWA", xpDiff)
      CharacterStats:UpdateStat("xpGWOA", xpWithoutAddon)
    end
  end
end

function CharacterStats:XPChecksum(playerXP, deficit, playerLevel)
  local stats = self:GetCurrentCharacterStats()

  if playerXP == nil then playerXP = stats.xpTotal end
  if deficit == nil then deficit = stats.xpGWOA end
  if playerLevel == nil then playerLevel = UnitLevel("player") end

  local digits = getDigitsFromString(playerXP - deficit)
  local checkTotal = 0 
  for i, digit in ipairs(digits) do
    checkTotal = checkTotal + (i * digit)
  end

  return string.format("%.2f", (checkTotal / playerLevel))
end

-- Get the current character's stats
function CharacterStats:GetCurrentCharacterStats()
  local characterGUID = UnitGUID('player')

  if statsInitialized then
    return UltraHardcoreDB.characterStats[characterGUID]
  end

  -- Initialize character stats if they don't exist
  if not UltraHardcoreDB.characterStats then
    UltraHardcoreDB.characterStats = {}
  end

  if not UltraHardcoreDB.characterStats[characterGUID] then
    UltraHardcoreDB.characterStats[characterGUID] = self.defaults
  end

  -- Initialize new stats for existing characters (backward compatibility)
  if not statsInitialized then
    for statName, _ in pairs(self.defaults) do
      if UltraHardcoreDB.characterStats[characterGUID][statName] == nil then
        UltraHardcoreDB.characterStats[characterGUID][statName] = self.defaults[statName]
      end
    end
    statsInitialized = true
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
  local playerName = UnitName('player')
  local playerLevel = UnitLevel('player')
  local playerClass = UnitClass('player')

  local function sendMessage(text)
    SendChatMessage(text, channel)
  end

  -- if channel == 'GUILD' then
  -- Condensed single line for guild chat to avoid spam
  local condensedMessage =
    '[ULTRA] ' .. playerName .. ' (' .. playerClass .. ' L' .. playerLevel .. ') - Health: ' .. string.format(
      '%.1f',
      stats.lowestHealth
    ) .. ' - Elites: ' .. formatNumberWithCommas(
      stats.elitesSlain
    ) .. ' - Enemies: ' .. formatNumberWithCommas(stats.enemiesSlain)
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
  local playerName = UnitName('player')
  local playerLevel = UnitLevel('player')
  local playerClass = UnitClass('player')

  -- Create dialog frame positioned above the main settings panel
  local dialog = CreateFrame('Frame', nil, UIParent, 'BackdropTemplate')
  dialog:SetSize(400, 310)
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
  contentFrame:SetSize(380, 200)
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
  statsPreview:SetSize(340, 140)
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
  playerInfoText:SetText(playerName .. ' (' .. playerClass .. ' Level ' .. playerLevel .. ')')

  -- Stats breakdown
  local lowestHealthText = statsPreview:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  lowestHealthText:SetPoint('TOPLEFT', statsPreview, 'TOPLEFT', 12, -28)
  lowestHealthText:SetText('Lowest Health: ' .. string.format('%.1f', stats.lowestHealth) .. '%')

  local partyDeathsText = statsPreview:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  partyDeathsText:SetPoint('TOPLEFT', statsPreview, 'TOPLEFT', 12, -48)
  partyDeathsText:SetText('Party Deaths Witnessed: ' .. stats.partyMemberDeaths)

  local elitesText = statsPreview:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  elitesText:SetPoint('TOPLEFT', statsPreview, 'TOPLEFT', 12, -68)
  elitesText:SetText('Elites Slain: ' .. stats.elitesSlain)

  local enemiesText = statsPreview:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  enemiesText:SetPoint('TOPLEFT', statsPreview, 'TOPLEFT', 12, -88)
  enemiesText:SetText('Enemies Slain: ' .. stats.enemiesSlain)

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
    local condensedMessage =
      '[ULTRA] ' .. playerName .. ' (' .. playerClass .. ' L' .. playerLevel .. ') - Health: ' .. string.format(
        '%.1f',
        stats.lowestHealth
      ) .. '%' .. ' - Party Deaths Witnessed: ' .. stats.partyMemberDeaths .. ' - Elites: ' .. stats.elitesSlain .. ' - Enemies: ' .. stats.enemiesSlain
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
SLASH_RESETLOWESTHEALTH1 = '/resetlowesthealth'
SlashCmdList['RESETLOWESTHEALTH'] = function()
  CharacterStats:ResetLowestHealth()
end

SLASH_RESETPETDEATHS1 = '/resetpetdeaths'
SlashCmdList['RESETPETDEATHS'] = function()
  CharacterStats:ResetPetDeaths()
end

SLASH_RESETELITESSLAIN1 = '/resetelitesslain'
SlashCmdList['RESETELITESSLAIN'] = function()
  CharacterStats:ResetElitesSlain()
end

SLASH_RESETENEMIESSLAIN1 = '/resetenemiesslain'
SlashCmdList['RESETENEMIESSLAIN'] = function()
  CharacterStats:ResetEnemiesSlain()
end

-- Slash commands for survival statistics
SLASH_RESETHEALTHPOTIONS1 = '/resethealthpotions'
SlashCmdList['RESETHEALTHPOTIONS'] = function()
  CharacterStats:ResetHealthPotionsUsed()
end

SLASH_RESETMANAPOTIONS1 = '/resetmanapotions'
SlashCmdList['RESETMANAPOTIONS'] = function()
  CharacterStats:ResetManaPotionsUsed()
end

SLASH_RESETBANDAGES1 = '/resetbandages'
SlashCmdList['RESETBANDAGES'] = function()
  CharacterStats:ResetBandagesUsed()
end

SLASH_RESETTARGETDUMMIES1 = '/resettargetdummies'
SlashCmdList['RESETTARGETDUMMIES'] = function()
  CharacterStats:ResetTargetDummiesUsed()
end

SLASH_RESETGRENADES1 = '/resetgrenades'
SlashCmdList['RESETGRENADES'] = function()
  CharacterStats:ResetGrenadesUsed()
end

SLASH_RESETPARTYMEMBERDEATHS1 = '/resetpartymemberdeaths'
SlashCmdList['RESETPARTYMEMBERDEATHS'] = function()
  CharacterStats:ResetPartyMemberDeaths()
end

SLASH_RESETHIGHESTCRIT1 = '/resethighestcrit'
SlashCmdList['RESETHIGHESTCRIT'] = function()
  CharacterStats:ResetHighestCritValue()
end

SLASH_RESETRAREELITES1 = '/resetrareelites'
SlashCmdList['RESETRAREELITES'] = function()
  CharacterStats:ResetRareElitesSlain()
end

SLASH_RESETWORLDBOSSES1 = '/resetworldbosses'
SlashCmdList['RESETWORLDBOSSES'] = function()
  CharacterStats:ResetWorldBossesSlain()
end

-- Register slash command to reset stats
SLASH_RESETSTATS1 = '/resetstats'
SlashCmdList['RESETSTATS'] = function()
  CharacterStats:ResetStats()
end

-- Register slash commands to log stats to specific channels
SLASH_LOGSTATSS1 = '/logstatss'
SlashCmdList['LOGSTATSS'] = function()
  CharacterStats:LogStatsToSpecificChannel('SAY')
end

SLASH_LOGSTATSP1 = '/logstatsp'
SlashCmdList['LOGSTATSP'] = function()
  CharacterStats:LogStatsToSpecificChannel('PARTY')
end

SLASH_LOGSTATSG1 = '/logstatsg'
SlashCmdList['LOGSTATSG'] = function()
  CharacterStats:LogStatsToSpecificChannel('GUILD')
end

-- Keep the general command for backward compatibility
SLASH_LOGSTATS1 = '/logstats'
SLASH_LOGSTATS2 = '/uhcstats'
SlashCmdList['LOGSTATS'] = function()
  CharacterStats:LogStatsToChat()
end

-- Register slash command to set lowest health
SLASH_SETLOWESTHEALTH1 = '/setlowesthealth'
SlashCmdList['SETLOWESTHEALTH'] = function(msg)
  CharacterStats:SetLowestHealth(msg)
end

-- We do not want a reset command for this in a release
--[[SLASH_RESETXPGWA1 = '/resetxpgwa'
SlashCmdList['RESETXPGWA'] = function()
  CharacterStats:ResetXPGainedWithAddon(true)
end

SLASH_XPREPORT1 = '/uhcxp'
SlashCmdList['XPREPORT'] = function()
  local stats = CharacterStats:GetCurrentCharacterStats()
  print('You have earned ' .. formatNumberWithCommas(stats.xpGWA) .. ' XP with the addon enabled and ' .. formatNumberWithCommas(stats.xpTotal - stats.xpGWA) .. ' without.')
end]]

SLASH_CHECKXPREPORT1 = '/uhccheckxp'
SlashCmdList['CHECKXPREPORT'] = function(msg)
  local playerXP = 0
  local deficit = 0
  local level = 0
  if msg == nil or msg == '' then 
    print('Check for a valid /uhcv message.  If the checksum from this command does not match theirs, it might be fake.')
    print('Usage: /uhccheckxp total_xp xp_without_uhc player_level')
  else
    local results = {}
    for part in string.gmatch(msg, "([^ ]+)") do
        table.insert(results, part)
    end
    playerXP = results[1]
    deficit = results[2]
    level = results[3]

    if playerXP ~= nil and deficit ~= nil and level ~= nil then
      local checksum = CharacterStats:XPChecksum(playerXP, deficit, level)
      print('Player checksum should be ' .. checksum)
    else
      print('Cannot check XP report, run /uhcxp by itself to see usage')
    end
  end
end
-- Slash command to post version to current chat
SLASH_POSTVERSION1 = '/uhcversion'
SLASH_POSTVERSION2 = '/uhcv'
SlashCmdList['POSTVERSION'] = function()
  local version = GetAddOnMetadata('UltraHardcore', 'Version') or 'Unknown'
  local playerName = UnitName('player')
  local message = playerName .. ' is using UltraHardcore version ' .. version

  local xpDeficit = CharacterStats:ReportXPWithoutAddon()

  if xpDeficit ~= false then
    local stats = CharacterStats:GetCurrentCharacterStats()
    local playerXP = stats.xpTotal
    message = message
              .. ' [Total XP: ' .. formatNumberWithCommas(playerXP) .. ']' 
              .. ' [XP w/o UHC: ' .. formatNumberWithCommas(xpDeficit) .. ']'
              .. ' (Checksum: '.. CharacterStats:XPChecksum() .. ')'
  end
  -- Determine the best chat channel to use
  local chatType = nil
  local chatTarget = nil
  local detectedType = nil

  -- Check main chat frame's edit box for the current chat type
  if ChatFrame1 and ChatFrame1.editBox then
    detectedType = ChatFrame1.editBox:GetAttribute('chatType')
    chatTarget = ChatFrame1.editBox:GetAttribute('tellTarget')

    if detectedType then
      if detectedType == 'WHISPER' and chatTarget then
        -- WHISPER requires a target
        chatType = detectedType
      elseif detectedType == 'CHANNEL' then
        -- CHANNEL requires a channel number (get it from the edit box attribute)
        local channelNum = ChatFrame1.editBox:GetAttribute('channelTarget')
        if channelNum then
          chatType = 'CHANNEL'
          chatTarget = channelNum
        end
      else
        -- Other chat types (SAY, PARTY, RAID, GUILD, etc.)
        chatType = detectedType
      end
    end
  end

  -- If no valid chat type was detected, prioritize group channels
  if not chatType then
    if IsInRaid() then
      chatType = 'RAID'
    elseif IsInGroup() then
      chatType = 'PARTY'
    elseif IsInGuild() then
      chatType = 'GUILD'
    else
      chatType = 'SAY' -- Default to SAY
    end
  end

  -- Send the message to the determined chat channel
  if chatTarget then
    SendChatMessage(message, chatType, nil, chatTarget)
  else
    SendChatMessage(message, chatType)
  end
end
