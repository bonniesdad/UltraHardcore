-- Main Screen Statistics Display
-- Shows the same statistics that appear in the settings panel, but on the main screen at all times

-- Create the main statistics frame (invisible container for positioning)
local statsFrame = CreateFrame('Frame', 'UltraHardcoreStatsFrame', UIParent)
statsFrame:SetSize(200, 100)
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
levelValue:SetText('1')
levelValue:SetFont('Fonts\\FRIZQT__.TTF', 14)

local lowestHealthLabel = statsFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
lowestHealthLabel:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', 10, -20)
lowestHealthLabel:SetText('Lowest Health:')
lowestHealthLabel:SetFont('Fonts\\FRIZQT__.TTF', 14)

local lowestHealthValue = statsFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
lowestHealthValue:SetPoint('TOPRIGHT', statsFrame, 'TOPRIGHT', -10, -20)
lowestHealthValue:SetText('100.0%')
lowestHealthValue:SetFont('Fonts\\FRIZQT__.TTF', 14)

local elitesLabel = statsFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
elitesLabel:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', 10, -35)
elitesLabel:SetText('Elites Slain:')
elitesLabel:SetFont('Fonts\\FRIZQT__.TTF', 14)

local elitesValue = statsFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
elitesValue:SetPoint('TOPRIGHT', statsFrame, 'TOPRIGHT', -10, -35)
elitesValue:SetText('0')
elitesValue:SetFont('Fonts\\FRIZQT__.TTF', 14)

local enemiesLabel = statsFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
enemiesLabel:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', 10, -50)
enemiesLabel:SetText('Enemies Slain:')
enemiesLabel:SetFont('Fonts\\FRIZQT__.TTF', 14)

local enemiesValue = statsFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
enemiesValue:SetPoint('TOPRIGHT', statsFrame, 'TOPRIGHT', -10, -50)
enemiesValue:SetText('0')
enemiesValue:SetFont('Fonts\\FRIZQT__.TTF', 14)

local xpLabel = statsFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
xpLabel:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', 10, -65)
xpLabel:SetText('XP Without Addon:')
xpLabel:SetFont('Fonts\\FRIZQT__.TTF', 14)

local xpValue = statsFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
xpValue:SetPoint('TOPRIGHT', statsFrame, 'TOPRIGHT', -10, -65)
xpValue:SetText('0')
xpValue:SetFont('Fonts\\FRIZQT__.TTF', 14)

-- Hide the frame if the statistics setting is off
local function CheckAddonEnabled()
  if not GLOBAL_SETTINGS or not GLOBAL_SETTINGS.showOnScreenStatistics then
    statsFrame:Hide()
  else
    statsFrame:Show()
  end
end

-- Function to update all statistics
local function UpdateStatistics()
  if not UltraHardcoreDB then
    LoadDBData()
  end
  
  -- Update character level
  local playerLevel = UnitLevel('player') or 1
  levelValue:SetText(tostring(playerLevel))
  
  -- Update lowest health
  local currentLowestHealth = CharacterStats:GetStat('lowestHealth') or 100
  lowestHealthValue:SetText(string.format("%.1f", currentLowestHealth) .. '%')
  
  -- Update elites slain
  local elites = CharacterStats:GetStat('elitesSlain') or 0
  elitesValue:SetText(tostring(elites))
  
  -- Update enemies slain
  local enemies = CharacterStats:GetStat('enemiesSlain') or 0
  enemiesValue:SetText(tostring(enemies))
  
  -- Update XP gained without addon
  local xp = CharacterStats:GetStat('xpGainedWithoutAddon') or 0
  xpValue:SetText(string.format("%.1fk", tostring(xp / 1000)))
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

-- Initial update
UpdateStatistics()

-- Initial check with delay to ensure GLOBAL_SETTINGS is loaded
C_Timer.After(1, function()
  CheckAddonEnabled()
end)

-- Also check immediately
CheckAddonEnabled()
