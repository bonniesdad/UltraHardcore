--[[
  XP Tracking System - Tracks XP gained for each individual UHC setting
  This system tracks XP when specific settings are disabled
]]

-- Mapping of setting names to their XP tracking variables
-- Organized by preset type: Lite, Recommended, Experimental
local settingToXPVariable = {
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
  showFullHealthIndicator = 'xpGainedWithoutOptionShowFullHealthIndicator',
  showIncomingDamageEffect = 'xpGainedWithoutOptionShowIncomingDamageEffect',
  showHealingIndicator = 'xpGainedWithoutOptionShowHealingIndicator',
}

-- Session tracking variables for each setting
local sessionStartXP = nil
local lastXPUpdate = nil
local lastXPValue = nil

-- Function to initialize XP tracking
local function InitializeXPTracking()
  -- Start tracking from current XP for this session
  lastXPValue = UnitXP("player")
  lastXPUpdate = GetTime()
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
      if not isSettingEnabled then
        local currentXPForSetting = CharacterStats:GetStat(xpVariable) or 0
        local newXPForSetting = currentXPForSetting + xpGained
        CharacterStats:UpdateStat(xpVariable, newXPForSetting)
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

