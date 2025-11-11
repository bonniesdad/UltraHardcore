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

-- Function to initialize XP tracking
local function InitializeXPTracking()
  local playerLevel = UnitLevel("player")
  -- Start tracking from current XP for this session
  lastXPValue = UnitXP("player")
  lastXPUpdate = GetTime()
  -- Frequently player XP reports as 0 when entering the game, wait a sec and retry
  if lastXPValue == 0 and playerLevel > 1 then
    C_Timer.After(1.0, function() 
      lastXPValue = UnitXP("player")
      lastXPUpdate = GetTime()
    end)
  end
  -- Do this to preload all stats
  local stats = CharacterStats:GetCurrentCharacterStats()
  CharacterStats:UpdateStat("XpTotal", CharacterStats:CalculateTotalXPGained())

  if stats.xpGWA == nil and lastXPValue > 0 then
    -- It looks like sometimes player XP is reported as 0 as you enter the world
    CharacterStats:ResetXPGainedWithAddon(true)
  end
end

-- Function to update XP tracking for each setting
local function UpdateXPTracking()
  local currentXP = UnitXP("player")
  local currentTime = GetTime()
  
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
    
    -- NOTE: We do NOT update the general "without addon" tracking here
    -- That should be handled by the original XPGainedTracker.lua system
    
    lastXPValue = currentXP
    lastXPUpdate = currentTime
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
    UpdateXPTracking()
  elseif event == "PLAYER_LEVEL_UP" then
    -- Reset tracking when leveling up
    InitializeXPTracking()
  elseif event == "PLAYER_LOGIN" then
    InitializeXPTracking()
  elseif event == "ADDON_LOADED" and select(1, ...) == "UltraHardcore" then
    InitializeXPTracking()
  end
end)

