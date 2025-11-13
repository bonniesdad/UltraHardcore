--[[
  XP Tracking System - Tracks XP gained for each individual UHC setting
  This system tracks XP when specific settings are disabled
]]

-- Mapping of setting names to their XP tracking variables
-- Organized by preset type: Lite, Recommended, Experimental
local settingToXPVariable = {
  -- Total XP, not tied to settings
  xpGWA = 'xpGWA',
  xpGWOA = 'xpGWOA',
  -- Lite Preset Settings
  hidePlayerFrame = 'xpGainedWithoutOptionHidePlayerFrame',
  showOnScreenStatistics = 'xpGainedWithoutOptionShowOnScreenStatistics',
  showTunnelVision = 'xpGainedWithoutOptionShowTunnelVision',
  announceLevelUpToGuild = 'xpGainedWithoutOptionAnnounceLevelUpToGuild',
  
  -- Recommended Preset Settings
  tunnelVisionMaxStrata = 'xpGainedWithoutOptionTunnelVisionMaxStrata',
  hideTargetFrame = 'xpGainedWithoutOptionHideTargetFrame',
  hideTargetTooltip = 'xpGainedWithoutOptionHideTargetTooltip',
  disableNameplateHealth = 'xpGainedWithoutOptionDisableNameplateHealth',
  showDazedEffect = 'xpGainedWithoutOptionShowDazedEffect',
  hideGroupHealth = 'xpGainedWithoutOptionHideGroupHealth',
  hideMinimap = 'xpGainedWithoutOptionHideMinimap',
  hideBreathIndicator = 'xpGainedWithoutOptionHideBreathIndicator',
  
  -- Experimental Preset Settings
  showCritScreenMoveEffect = 'xpGainedWithoutOptionShowCritScreenMoveEffect',
  hideActionBars = 'xpGainedWithoutOptionHideActionBars',
  petsDiePermanently = 'xpGainedWithoutOptionPetsDiePermanently',
  routePlanner = 'xpGainedWithoutOptionRoutePlanner',
  showFullHealthIndicator = 'xpGainedWithoutOptionShowFullHealthIndicator',
  showFullHealthIndicatorAudioCue = 'xpGainedWithoutOptionShowFullHealthIndicatorAudioCue',
  hideCustomResourceBar = 'xpGainedWithoutOptionHideCustomResourceBar',
  showIncomingDamageEffect = 'xpGainedWithoutOptionShowIncomingDamageEffect',
  showHealingIndicator = 'xpGainedWithoutOptionShowHealingIndicator',
}

-- Session tracking variables for each setting
local sessionStartXP = nil
local lastXPUpdate = nil
local lastXPValue = nil
local xpTrackingInitialized = false

local function InitializeXpGainedWithAddon(playerLevel, lastXPValue, stats)
  if lastXPValue == 0 and playerLevel > 1 then
    -- This shouldn't happen but just in case, don't run until later
    return false
  end

  CharacterStats:UpdateStat("xpTotal", CharacterStats:CalculateTotalXPGained())

  local shouldRecalculate = CharacterStats:ShouldRecalculateXPGainedWithAddon(stats)

  if playerLevel == 1 and lastXPValue == 0 then
    CharacterStats:UpdateStat("xpTotal", 0)
    CharacterStats:UpdateStat("xpGWA", 0)
    CharacterStats:UpdateStat("xpGWOA", 0)
  elseif shouldRecalculate  == true then
    CharacterStats:ResetXPGainedWithAddon(playerLevel, true)
  end
  return true
end

-- Function to initialize XP tracking
local function InitializeXPTracking()
  local playerLevel = UnitLevel("player")
  -- Start tracking from current XP for this session
  lastXPValue = UnitXP("player")
  lastXPUpdate = GetTime()

  -- This code only needs to run once either on login or reload
  if xpTrackingInitialized ~= true then
    local stats = CharacterStats:GetCurrentCharacterStats()
    InitializeXpGainedWithAddon(playerLevel, lastXPValue, stats)
    xpTrackingInitialized = true
  end
end

-- Function to update XP tracking for each setting
local function UpdateXPTracking(levelUp)
  if levelUp == nil then levelUp = false end

  local currentXP = 0
  local currentTime = GetTime()

  if levelUp then
    -- The game does not report the correct XP amount on level up, so we calculate it
    local newLevel = UnitLevel("player")
    local xpThisLevel = TotalXPTable[newLevel]
    currentXP = xpThisLevel
  else
    currentXP = UnitXP("player")
  end

  
  -- Only update if XP has increased and enough time has passed (prevent spam)
  if currentXP > lastXPValue and (currentTime - lastXPUpdate) > 1 then
    local xpGained = currentXP - lastXPValue
    
    -- Update XP tracking for each setting that is currently disabled
    for settingName, xpVariable in pairs(settingToXPVariable) do
      -- Check if this setting is currently disabled (meaning we're gaining XP "without" it)
      local isSettingEnabled = GLOBAL_SETTINGS[settingName]
      
      -- For boolean settings, if they're false, we're gaining XP "without" that option
      if not isSettingEnabled or xpVariable == "xpGWA" or xpVariable == "xpGWOA" or xpVariable == "xpTotal" then
        -- We do not want to track xpGWOA while the addon is running even though the setting is always false
        if xpVariable ~= "xpGWOA" then 
          local currentXPForSetting = CharacterStats:GetStat(xpVariable) or 0
          local newXPForSetting = currentXPForSetting + xpGained
          CharacterStats:UpdateStat(xpVariable, newXPForSetting)
        end
      end
    end
    
    if levelUp then
      -- We just leveled up so our UnitXP is going to be only the amount in excess of the level up threshhold
      -- Leveling up means our UnitXP is effectively 0, so set that value
      --
      -- Do not reset the time because UpdateXPTracking is going to fire again immediately
      -- after PLAYER_LEVEL_UP and we want to count that XP
      lastXPValue = 0
    else
      lastXPValue = currentXP
      lastXPUpdate = currentTime
    end
  end
end

-- Function to get XP gained for a specific setting
local function GetXPGainedForSetting(settingName)
  local xpVariable = settingToXPVariable[settingName]
  if xpVariable then
    return CharacterStats:GetStat(xpVariable) or 0
  end
  return 0
end


-- Export functions globally
_G.UpdateXPTracking = UpdateXPTracking
_G.InitializeXPTracking = InitializeXPTracking
_G.GetXPGainedForSetting = GetXPGainedForSetting

-- Register events for XP tracking
local xpTrackingFrame = CreateFrame("Frame")
xpTrackingFrame:RegisterEvent("PLAYER_XP_UPDATE")
xpTrackingFrame:RegisterEvent("PLAYER_LEVEL_UP")
xpTrackingFrame:RegisterEvent("PLAYER_LOGIN")
xpTrackingFrame:RegisterEvent("ADDON_LOADED")

xpTrackingFrame:SetScript("OnEvent", function(self, event, ...)
  if event == "PLAYER_XP_UPDATE" then
    UpdateXPTracking(false)
  elseif event == "PLAYER_LEVEL_UP" then
    -- Reset tracking when leveling up
    UpdateXPTracking(true)
    lastXPValue = 0
    lastXPUpdate = lastXPUpdate - 1
    --InitializeXPTracking()
  elseif event == "PLAYER_LOGIN" then
    InitializeXPTracking()
  elseif event == "ADDON_LOADED" and select(1, ...) == "UltraHardcore" then
    -- This event is too soon to load player XP immediately but it is the only one called with a /reload
    -- So use a timer to call InitializeXPTracking 
    C_Timer.After(3.0, function() 
      InitializeXPTracking()
    end)
  end
end)

