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
  xpTotal = 'xpTotal', -- DO NOT REMOVE THIS IT IS IMPORTANT FOR XP TRACKING!
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
  AddonXPTracking:Initialize(lastXPValue)
end

-- Function to update XP tracking for each setting
local function UpdateXPTracking(levelUp)
  if levelUp == nil then levelUp = false end

  local currentXP = AddonXPTracking:GetXP(levelUp)
  local currentTime = GetTime()
  AddonXPTracking:XPTrackingDebug("XP Check " .. lastXPValue .. " vs " .. currentXP)
  -- Only update if XP has increased and enough time has passed (prevent spam)
  if currentXP > lastXPValue and (currentTime - lastXPUpdate) > 1 then
    local xpGained = currentXP - lastXPValue
    AddonXPTracking:XPTrackingDebug("UpdateXPTracking conditional passed. XP gained = " .. xpGained)
    local statsChanged = 0 
    local stats = CharacterStats:GetCurrentCharacterStats()

    -- Update XP tracking for each setting that is currently disabled
    for settingName, xpVariable in pairs(settingToXPVariable) do
      -- Check if this setting is currently disabled (meaning we're gaining XP "without" it)
      local isSettingEnabled = GLOBAL_SETTINGS[settingName]
       
      -- For boolean settings, if they're false, we're gaining XP "without" that option
      if not isSettingEnabled or AddonXPTracking:ShouldTrackStat(xpVariable) then
        if AddonXPTracking:ShouldStoreStat(xpVariable) then 
          --[[ Original Code
          local currentXPForSetting = CharacterStats:GetStat(xpVariable) or 0
          local newXPForSetting = currentXPForSetting + xpGained
          CharacterStats:UpdateStat(xpVariable, newXPForSetting) 
          ]]

          -- Access character stats directly from our local variable to minimize calls
          local currentXPForSetting = stats[xpVariable] or 0
          local newXPForSetting = currentXPForSetting + xpGained
          stats[xpVariable] = newXPForSetting
          statsChanged = statsChanged + 1
        end
      end
    end

    if statsChanged > 0 then
      -- Instead of repeatedly calling UpdateStat in the loop above (which resaves CharacterStats over and over)
      -- Call SaveDBData once at the end
      SaveDBData('characterStats', UltraHardcoreDB.characterStats)
    end
    
    lastXPValue = AddonXPTracking:NewLastXPValue(levelUp, currentXP)
    lastXPUpdate = AddonXPTracking:NewLastXPUpdate(levelUp, currentTime)
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
xpTrackingFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
xpTrackingFrame:RegisterEvent("PLAYER_LEVEL_UP")
xpTrackingFrame:RegisterEvent("PLAYER_LOGIN")
xpTrackingFrame:RegisterEvent("ADDON_LOADED")

xpTrackingFrame:SetScript("OnEvent", function(self, event, ...)
  if event == "PLAYER_REGEN_ENABLED" then
    AddonXPTracking:XPTrackingDebug("PLAYER_REGEN_ENABLED event fired")
    C_Timer.After(3.0, function() 
      UpdateXPTracking(false)
      if AddonXPTracking:ValidateTotalStoredXP() ~= true then
        AddonXPTracking:PrintXPVerificationWarning()
      end
    end)
  elseif event == "PLAYER_XP_UPDATE" then
    AddonXPTracking:XPTrackingDebug("PLAYER_XP_UPDATE event fired")
    UpdateXPTracking(false)
  elseif event == "PLAYER_LEVEL_UP" then
    AddonXPTracking:XPTrackingDebug("PLAYER_LEVEL_UP event fired")
    UpdateXPTracking(true)
  elseif event == "PLAYER_LOGIN" then
    InitializeXPTracking()
    AddonXPTracking:XPReport()
  elseif event == "ADDON_LOADED" and select(1, ...) == "UltraHardcore" then
    -- This event is too soon to load player XP immediately but it is the only one called with a /reload
    -- So use a timer to call InitializeXPTracking 
    C_Timer.After(3.0, function() 
      InitializeXPTracking()
    end)
  end
end)

