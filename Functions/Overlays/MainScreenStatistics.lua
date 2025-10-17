-- Main Screen Statistics Display
-- Shows the same statistics that appear in the settings panel, but on the main screen at all times

-- Helper function to format numbers with comma separators
local function formatNumberWithCommas(number)
  if type(number) ~= "number" then
    number = tonumber(number) or 0
  end
  
  -- Handle negative numbers
  local isNegative = number < 0
  if isNegative then
    number = -number
  end
  
  -- Convert to string and add commas
  local formatted = tostring(math.floor(number))
  local k
  while true do
    formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
    if k == 0 then
      break
    end
  end
  
  -- Add back negative sign if needed
  if isNegative then
    formatted = "-" .. formatted
  end
  
  return formatted
end

-- Create the main statistics frame (invisible container for positioning)
local statsFrame = CreateFrame('Frame', 'UltraHardcoreStatsFrame', UIParent)
statsFrame:SetSize(200, 345) -- Increased height to accommodate all statistics including rare elites and world bosses
statsFrame:SetPoint('TOPLEFT', UIParent, 'TOPLEFT', 20, -20)

-- Make the frame draggable
MakeFrameDraggable(statsFrame)

-- Create statistics text elements
-- Character Level at the top
local levelLabel = statsFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
levelLabel:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', 10, -5)
levelLabel:SetText('Level:')
levelLabel:SetFont('Fonts\\FRIZQT__.TTF', 14)

local levelValue = statsFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
levelValue:SetPoint('TOPRIGHT', statsFrame, 'TOPRIGHT', -10, -5)
levelValue:SetText(formatNumberWithCommas(1))
levelValue:SetFont('Fonts\\FRIZQT__.TTF', 14)

local lowestHealthLabel = statsFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
lowestHealthLabel:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', 10, -20)
lowestHealthLabel:SetText('Lowest Health:')
lowestHealthLabel:SetFont('Fonts\\FRIZQT__.TTF', 14)

local lowestHealthValue = statsFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
lowestHealthValue:SetPoint('TOPRIGHT', statsFrame, 'TOPRIGHT', -10, -20)
lowestHealthValue:SetText('100.0%')
lowestHealthValue:SetFont('Fonts\\FRIZQT__.TTF', 14)

local sessionHealthLabel = statsFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
sessionHealthLabel:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', 10, -35)
sessionHealthLabel:SetText('Session Lowest:')
sessionHealthLabel:SetFont('Fonts\\FRIZQT__.TTF', 14)

local sessionHealthValue = statsFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
sessionHealthValue:SetPoint('TOPRIGHT', statsFrame, 'TOPRIGHT', -10, -35)
sessionHealthValue:SetText('100.0%')
sessionHealthValue:SetFont('Fonts\\FRIZQT__.TTF', 14)

-- This Level (Beta) statistic
local thisLevelLabel = statsFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
thisLevelLabel:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', 10, -50)
thisLevelLabel:SetText('Level Lowest:')
thisLevelLabel:SetFont('Fonts\\FRIZQT__.TTF', 14)

local thisLevelValue = statsFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
thisLevelValue:SetPoint('TOPRIGHT', statsFrame, 'TOPRIGHT', -10, -50)
thisLevelValue:SetText('100.0%')
thisLevelValue:SetFont('Fonts\\FRIZQT__.TTF', 14)


local enemiesLabel = statsFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
enemiesLabel:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', 10, -65)
enemiesLabel:SetText('Enemies Slain:')
enemiesLabel:SetFont('Fonts\\FRIZQT__.TTF', 14)

local enemiesValue = statsFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
enemiesValue:SetPoint('TOPRIGHT', statsFrame, 'TOPRIGHT', -10, -65)
enemiesValue:SetText(formatNumberWithCommas(0))
enemiesValue:SetFont('Fonts\\FRIZQT__.TTF', 14)


local dungeonsCompletedLabel = statsFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
dungeonsCompletedLabel:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', 10, -80)
dungeonsCompletedLabel:SetText('Dungeons Completed:')
dungeonsCompletedLabel:SetFont('Fonts\\FRIZQT__.TTF', 14)

local dungeonsCompletedValue = statsFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
dungeonsCompletedValue:SetPoint('TOPRIGHT', statsFrame, 'TOPRIGHT', -10, -80)
dungeonsCompletedValue:SetText(formatNumberWithCommas(0))
dungeonsCompletedValue:SetFont('Fonts\\FRIZQT__.TTF', 14)

-- Additional statistics rows
local petDeathsLabel = statsFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
petDeathsLabel:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', 10, -95)
petDeathsLabel:SetText('Pet Deaths:')
petDeathsLabel:SetFont('Fonts\\FRIZQT__.TTF', 14)

local petDeathsValue = statsFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
petDeathsValue:SetPoint('TOPRIGHT', statsFrame, 'TOPRIGHT', -10, -95)
petDeathsValue:SetText(formatNumberWithCommas(0))
petDeathsValue:SetFont('Fonts\\FRIZQT__.TTF', 14)

local elitesSlainLabel = statsFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
elitesSlainLabel:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', 10, -110)
elitesSlainLabel:SetText('Elites Slain:')
elitesSlainLabel:SetFont('Fonts\\FRIZQT__.TTF', 14)

local elitesSlainValue = statsFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
elitesSlainValue:SetPoint('TOPRIGHT', statsFrame, 'TOPRIGHT', -10, -110)
elitesSlainValue:SetText(formatNumberWithCommas(0))
elitesSlainValue:SetFont('Fonts\\FRIZQT__.TTF', 14)

local rareElitesSlainLabel = statsFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
rareElitesSlainLabel:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', 10, -125)
rareElitesSlainLabel:SetText('Rare Elites Slain:')
rareElitesSlainLabel:SetFont('Fonts\\FRIZQT__.TTF', 14)

local rareElitesSlainValue = statsFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
rareElitesSlainValue:SetPoint('TOPRIGHT', statsFrame, 'TOPRIGHT', -10, -125)
rareElitesSlainValue:SetText(formatNumberWithCommas(0))
rareElitesSlainValue:SetFont('Fonts\\FRIZQT__.TTF', 14)

local worldBossesSlainLabel = statsFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
worldBossesSlainLabel:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', 10, -140)
worldBossesSlainLabel:SetText('World Bosses Slain:')
worldBossesSlainLabel:SetFont('Fonts\\FRIZQT__.TTF', 14)

local worldBossesSlainValue = statsFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
worldBossesSlainValue:SetPoint('TOPRIGHT', statsFrame, 'TOPRIGHT', -10, -140)
worldBossesSlainValue:SetText(formatNumberWithCommas(0))
worldBossesSlainValue:SetFont('Fonts\\FRIZQT__.TTF', 14)

local dungeonBossesLabel = statsFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
dungeonBossesLabel:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', 10, -155)
dungeonBossesLabel:SetText('Dungeon Bosses:')
dungeonBossesLabel:SetFont('Fonts\\FRIZQT__.TTF', 14)

local dungeonBossesValue = statsFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
dungeonBossesValue:SetPoint('TOPRIGHT', statsFrame, 'TOPRIGHT', -10, -155)
dungeonBossesValue:SetText(formatNumberWithCommas(0))
dungeonBossesValue:SetFont('Fonts\\FRIZQT__.TTF', 14)

-- Survival statistics rows
local healthPotionsLabel = statsFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
healthPotionsLabel:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', 10, -170)
healthPotionsLabel:SetText('Health Potions:')
healthPotionsLabel:SetFont('Fonts\\FRIZQT__.TTF', 14)

local healthPotionsValue = statsFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
healthPotionsValue:SetPoint('TOPRIGHT', statsFrame, 'TOPRIGHT', -10, -170)
healthPotionsValue:SetText(formatNumberWithCommas(0))
healthPotionsValue:SetFont('Fonts\\FRIZQT__.TTF', 14)

local bandagesLabel = statsFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
bandagesLabel:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', 10, -185)
bandagesLabel:SetText('Bandages Used:')
bandagesLabel:SetFont('Fonts\\FRIZQT__.TTF', 14)

local bandagesValue = statsFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
bandagesValue:SetPoint('TOPRIGHT', statsFrame, 'TOPRIGHT', -10, -185)
bandagesValue:SetText(formatNumberWithCommas(0))
bandagesValue:SetFont('Fonts\\FRIZQT__.TTF', 14)

local targetDummiesLabel = statsFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
targetDummiesLabel:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', 10, -200)
targetDummiesLabel:SetText('Target Dummies:')
targetDummiesLabel:SetFont('Fonts\\FRIZQT__.TTF', 14)

local targetDummiesValue = statsFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
targetDummiesValue:SetPoint('TOPRIGHT', statsFrame, 'TOPRIGHT', -10, -200)
targetDummiesValue:SetText(formatNumberWithCommas(0))
targetDummiesValue:SetFont('Fonts\\FRIZQT__.TTF', 14)

local grenadesLabel = statsFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
grenadesLabel:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', 10, -215)
grenadesLabel:SetText('Grenades Used:')
grenadesLabel:SetFont('Fonts\\FRIZQT__.TTF', 14)

local grenadesValue = statsFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
grenadesValue:SetPoint('TOPRIGHT', statsFrame, 'TOPRIGHT', -10, -215)
grenadesValue:SetText(formatNumberWithCommas(0))
grenadesValue:SetFont('Fonts\\FRIZQT__.TTF', 14)

local partyDeathsLabel = statsFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
partyDeathsLabel:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', 10, -230)
partyDeathsLabel:SetText('Party Deaths:')
partyDeathsLabel:SetFont('Fonts\\FRIZQT__.TTF', 14)

local partyDeathsValue = statsFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
partyDeathsValue:SetPoint('TOPRIGHT', statsFrame, 'TOPRIGHT', -10, -230)
partyDeathsValue:SetText(formatNumberWithCommas(0))
partyDeathsValue:SetFont('Fonts\\FRIZQT__.TTF', 14)

-- Highest crit value row
local highestCritLabel = statsFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
highestCritLabel:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', 10, -245)
highestCritLabel:SetText('Highest Crit:')
highestCritLabel:SetFont('Fonts\\FRIZQT__.TTF', 14)

local highestCritValue = statsFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
highestCritValue:SetPoint('TOPRIGHT', statsFrame, 'TOPRIGHT', -10, -245)
highestCritValue:SetText(formatNumberWithCommas(0))
highestCritValue:SetFont('Fonts\\FRIZQT__.TTF', 14)

-- Store all statistics elements for easy management
local statsElements = {
  {label = levelLabel, value = levelValue, setting = 'showMainStatisticsPanelLevel'},
  {label = lowestHealthLabel, value = lowestHealthValue, setting = 'showMainStatisticsPanelLowestHealth'},
  {label = thisLevelLabel, value = thisLevelValue, setting = 'showMainStatisticsPanelThisLevel'},
  {label = sessionHealthLabel, value = sessionHealthValue, setting = 'showMainStatisticsPanelSessionHealth'},
  {label = petDeathsLabel, value = petDeathsValue, setting = 'showMainStatisticsPanelPetDeaths'},
  {label = enemiesLabel, value = enemiesValue, setting = 'showMainStatisticsPanelEnemiesSlain'},
  {label = elitesSlainLabel, value = elitesSlainValue, setting = 'showMainStatisticsPanelElitesSlain'},
  {label = rareElitesSlainLabel, value = rareElitesSlainValue, setting = 'showMainStatisticsPanelRareElitesSlain'},
  {label = worldBossesSlainLabel, value = worldBossesSlainValue, setting = 'showMainStatisticsPanelWorldBossesSlain'},
  {label = dungeonBossesLabel, value = dungeonBossesValue, setting = 'showMainStatisticsPanelDungeonBosses'},
  {label = dungeonsCompletedLabel, value = dungeonsCompletedValue, setting = 'showMainStatisticsPanelDungeonsCompleted'},
  {label = healthPotionsLabel, value = healthPotionsValue, setting = 'showMainStatisticsPanelHealthPotionsUsed'},
  {label = bandagesLabel, value = bandagesValue, setting = 'showMainStatisticsPanelBandagesUsed'},
  {label = targetDummiesLabel, value = targetDummiesValue, setting = 'showMainStatisticsPanelTargetDummiesUsed'},
  {label = grenadesLabel, value = grenadesValue, setting = 'showMainStatisticsPanelGrenadesUsed'},
  {label = partyDeathsLabel, value = partyDeathsValue, setting = 'showMainStatisticsPanelPartyMemberDeaths'},
  {label = highestCritLabel, value = highestCritValue, setting = 'showMainStatisticsPanelHighestCritValue'}
}

-- Function to update row visibility and positioning
local function UpdateRowVisibility()
  local yOffset = -5
  local visibleRows = 0
  
  for _, element in ipairs(statsElements) do
    local isVisible = false
    
    if GLOBAL_SETTINGS and GLOBAL_SETTINGS[element.setting] ~= nil then
      -- Use the actual setting value
      isVisible = GLOBAL_SETTINGS[element.setting]
    else
      -- Apply default behavior based on the setting
      if element.setting == 'showMainStatisticsPanelLevel' or 
         element.setting == 'showMainStatisticsPanelLowestHealth' or
         element.setting == 'showMainStatisticsPanelEnemiesSlain' or
         element.setting == 'showMainStatisticsPanelDungeonsCompleted' or
         element.setting == 'showMainStatisticsPanelHighestCritValue' then
        -- These default to true (show unless explicitly false)
        isVisible = true
      else
        -- These default to false (hide unless explicitly true)
        isVisible = false
      end
    end
    
    if isVisible then
      element.label:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', 10, yOffset)
      element.value:SetPoint('TOPRIGHT', statsFrame, 'TOPRIGHT', -10, yOffset)
      element.label:Show()
      element.value:Show()
      yOffset = yOffset - 15
      visibleRows = visibleRows + 1
    else
      element.label:Hide()
      element.value:Hide()
    end
  end
  
  -- Adjust frame height based on visible rows
  local newHeight = math.max(20, visibleRows * 15 + 10)
  statsFrame:SetSize(200, newHeight)
end

-- Make UpdateRowVisibility globally accessible
UltraHardcoreStatsFrame = statsFrame
UltraHardcoreStatsFrame.UpdateRowVisibility = UpdateRowVisibility


-- Hide the frame if the statistics setting is off
local function CheckAddonEnabled()
  if not GLOBAL_SETTINGS or not GLOBAL_SETTINGS.showOnScreenStatistics then
    statsFrame:Hide()
  else
    statsFrame:Show()
    UpdateRowVisibility()
  end
end

-- Function to update all statistics
local function UpdateStatistics()
  if not UltraHardcoreDB then
    LoadDBData()
  end
  
  -- Update character level
  local playerLevel = UnitLevel('player') or 1
  levelValue:SetText(formatNumberWithCommas(playerLevel))
  
  -- Update lowest health
  local currentLowestHealth = CharacterStats:GetStat('lowestHealth') or 100
  lowestHealthValue:SetText(string.format("%.1f", currentLowestHealth) .. '%')
  
  -- Update session lowest health
  local currentSessionLowestHealth = CharacterStats:GetStat('lowestHealthThisSession') or 100
  sessionHealthValue:SetText(string.format("%.1f", currentSessionLowestHealth) .. '%')
  
  -- Update this level lowest health
  local currentThisLevelHealth = CharacterStats:GetStat('lowestHealthThisLevel') or 100
  thisLevelValue:SetText(string.format("%.1f", currentThisLevelHealth) .. '%')
  
  -- Update enemies slain
  local enemies = CharacterStats:GetStat('enemiesSlain') or 0
  enemiesValue:SetText(formatNumberWithCommas(enemies))
  
  -- Update dungeons completed
  local dungeonsCompleted = CharacterStats:GetStat('dungeonsCompleted') or 0
  dungeonsCompletedValue:SetText(formatNumberWithCommas(dungeonsCompleted))
  
  -- Update pet deaths
  local petDeaths = CharacterStats:GetStat('petDeaths') or 0
  petDeathsValue:SetText(formatNumberWithCommas(petDeaths))
  
  -- Update elites slain
  local elitesSlain = CharacterStats:GetStat('elitesSlain') or 0
  elitesSlainValue:SetText(formatNumberWithCommas(elitesSlain))
  
  -- Update rare elites slain
  local rareElitesSlain = CharacterStats:GetStat('rareElitesSlain') or 0
  rareElitesSlainValue:SetText(formatNumberWithCommas(rareElitesSlain))
  
  -- Update world bosses slain
  local worldBossesSlain = CharacterStats:GetStat('worldBossesSlain') or 0
  worldBossesSlainValue:SetText(formatNumberWithCommas(worldBossesSlain))
  
  -- Update dungeon bosses slain
  local dungeonBosses = CharacterStats:GetStat('dungeonBossesKilled') or 0
  dungeonBossesValue:SetText(formatNumberWithCommas(dungeonBosses))
  
  -- Update survival statistics
  local healthPotions = CharacterStats:GetStat('healthPotionsUsed') or 0
  healthPotionsValue:SetText(formatNumberWithCommas(healthPotions))
  
  local bandages = CharacterStats:GetStat('bandagesUsed') or 0
  bandagesValue:SetText(formatNumberWithCommas(bandages))
  
  local targetDummies = CharacterStats:GetStat('targetDummiesUsed') or 0
  targetDummiesValue:SetText(formatNumberWithCommas(targetDummies))
  
  local grenades = CharacterStats:GetStat('grenadesUsed') or 0
  grenadesValue:SetText(formatNumberWithCommas(grenades))
  
  local partyDeaths = CharacterStats:GetStat('partyMemberDeaths') or 0
  partyDeathsValue:SetText(formatNumberWithCommas(partyDeaths))
  
  -- Update highest crit value
  local highestCrit = CharacterStats:GetStat('highestCritValue') or 0
  highestCritValue:SetText(formatNumberWithCommas(highestCrit))
  
  -- Update row visibility after updating values
  UpdateRowVisibility()
end

-- Register events to update statistics when they change
statsFrame:RegisterEvent('PLAYER_ENTERING_WORLD')
statsFrame:RegisterEvent('UNIT_HEALTH_FREQUENT')
statsFrame:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
statsFrame:RegisterEvent('PLAYER_LEVEL_UP')
statsFrame:RegisterEvent('ADDON_LOADED') -- Check setting when addon loads

statsFrame:SetScript('OnEvent', function(self, event, ...)
  if event == 'PLAYER_ENTERING_WORLD' then
    UpdateStatistics()
    CheckAddonEnabled()
  elseif event == 'UNIT_HEALTH_FREQUENT' then
    -- Update lowest health when health changes
    UpdateStatistics()
  elseif event == 'COMBAT_LOG_EVENT_UNFILTERED' then
    -- Update kill counts when combat events occur
    UpdateStatistics()
  elseif event == 'PLAYER_LEVEL_UP' then
    -- Update XP when leveling up
    UpdateStatistics()
  elseif event == 'ADDON_LOADED' then
    -- Check setting when addon loads
    CheckAddonEnabled()
  end
end)

-- Create a timer to periodically check for settings changes
local settingsCheckTimer = C_Timer.NewTicker(1, function()
  if GLOBAL_SETTINGS and GLOBAL_SETTINGS.showOnScreenStatistics then
    UpdateRowVisibility()
  end
end)

-- Initial update
UpdateStatistics()

-- Initial check with delay to ensure GLOBAL_SETTINGS is loaded
C_Timer.After(1, function()
  CheckAddonEnabled()
end)

-- Also check immediately
CheckAddonEnabled()
