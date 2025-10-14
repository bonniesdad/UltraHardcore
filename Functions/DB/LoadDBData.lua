-- 🟢 Load saved score on login
function LoadDBData()
  if not UltraHardcoreDB then
    UltraHardcoreDB = {} -- Ensure the table exists
  end

  enemiesSlain = UltraHardcoreDB.enemiesSlain or 0
  elitesSlain = UltraHardcoreDB.elitesSlain or 0
  lowestHealthScore = UltraHardcoreDB.lowestHealthScore or 100
  WELCOME_MESSAGE_CLOSED = UltraHardcoreDB.WELCOME_MESSAGE_CLOSED or false

  -- Get current character's GUID for per-character settings
  local characterGUID = UnitGUID('player')
  
  -- Initialize character settings if they don't exist
  if not UltraHardcoreDB.characterSettings then
    UltraHardcoreDB.characterSettings = {}
  end
  
  -- Default settings for new characters (ordered to match settingsCheckboxOptions)
  local defaultSettings = {
    -- Lite Preset Settings
    hidePlayerFrame = true,
    showOnScreenStatistics = true,
    showTunnelVision = true,
    announceLevelUpToGuild = true,
    -- Recommended Preset Settings
    tunnelVisionMaxStrata = true,
    hideTargetFrame = true,
    hideTargetTooltip = true,
    disableNameplateHealth = true,
    showDazedEffect = true,
    hideGroupHealth = true,
    hideMinimap = true,
    hideBreathIndicator = true,
    -- Experimental Preset Settings
    showCritScreenMoveEffect = false,
    hideActionBars = false,
    petsDiePermanently = false,
    showFullHealthIndicator = false,
    showIncomingDamageEffect = false,
    showHealingIndicator = false,
    hideUIErrors = false,
    setFirstPersonCamera = false,
  }
  
  -- Initialize settings for current character if they don't exist
  if not UltraHardcoreDB.characterSettings[characterGUID] then
    UltraHardcoreDB.characterSettings[characterGUID] = defaultSettings
  end
  
  -- Load current character's settings
  GLOBAL_SETTINGS = UltraHardcoreDB.characterSettings[characterGUID]
  
  -- Backward compatibility: migrate from old GLOBAL_SETTINGS if it exists
  if UltraHardcoreDB.GLOBAL_SETTINGS and not UltraHardcoreDB.characterSettings[characterGUID] then
    UltraHardcoreDB.characterSettings[characterGUID] = UltraHardcoreDB.GLOBAL_SETTINGS
    GLOBAL_SETTINGS = UltraHardcoreDB.characterSettings[characterGUID]
    -- Clear old global settings after migration
    UltraHardcoreDB.GLOBAL_SETTINGS = nil
  end
end
