-- 🟢 Load saved score on login
function LoadDBData()
  if not UltraHardcoreDB then
    UltraHardcoreDB = {} -- Ensure the table exists
  end

  enemiesSlain = UltraHardcoreDB.enemiesSlain or 0
  elitesSlain = UltraHardcoreDB.elitesSlain or 0
  lowestHealthScore = UltraHardcoreDB.lowestHealthScore or 100
  WELCOME_MESSAGE_CLOSED = UltraHardcoreDB.WELCOME_MESSAGE_CLOSED or false

  -- Initialize version tracking if it doesn't exist
  if not UltraHardcoreDB.lastSeenVersion then
    UltraHardcoreDB.lastSeenVersion = nil
  end

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
    showTunnelVision = true,
    -- Recommended Preset Settings
    hideMinimap = true,
    hideTargetFrame = true,
    hideTargetTooltip = true,
    disableNameplateHealth = true,
    showDazedEffect = true,
    hideGroupHealth = true,
    -- Ultra Preset Settings
    petsDiePermanently = false,
    hideActionBars = false,
    tunnelVisionMaxStrata = false,
    rejectBuffsFromOthers = false,
    routePlanner = false,
    -- Experimental Preset Settings
    hideBreathIndicator = false,
    showCritScreenMoveEffect = false,
    showFullHealthIndicator = false,
    showIncomingDamageEffect = false,
    showHealingIndicator = false,
    setFirstPersonCamera = false,
    completelyRemovePlayerFrame = false,
    completelyRemoveTargetFrame = false,
    routePlannerCompass = false,
    -- Misc Settings
    showOnScreenStatistics = true,
    -- Opacity for on-screen statistics background (0.0 - 1.0)
    statisticsBackgroundOpacity = 0.0,
    announceLevelUpToGuild = true,
    hideUIErrors = false,
    showClockEvenWhenMapHidden = false,
    announcePartyDeathsOnGroupJoin = true,
    announceDungeonsCompletedOnGroupJoin = true,
    newHighCritAppreciationSoundbite = true,
    buffBarOnResourceBar = false,
    playPartyDeathSoundbite = true,
    playPlayerDeathSoundbite = true,
    spookyTunnelVision = true,
    roachHearthstoneInPartyCombat = true,
    guildSelfFound = false,
    groupSelfFound = false,
    -- Group Found teammate names (locked in at level 2)
    groupFoundNames = {},
    -- Statistics Row Visibility Settings
    showMainStatisticsPanelLevel = true,
    showMainStatisticsPanelLowestHealth = true,
    showMainStatisticsPanelSessionHealth = false,
    showMainStatisticsPanelThisLevel = false,
    showMainStatisticsPanelEnemiesSlain = true,
    showMainStatisticsPanelDungeonsCompleted = true,
    showMainStatisticsPanelPetDeaths = false,
    showMainStatisticsPanelElitesSlain = false,
    showMainStatisticsPanelDungeonBosses = false,
    -- Survival Statistics Row Visibility Settings
    showMainStatisticsPanelHealthPotionsUsed = false,
    showMainStatisticsPanelBandagesUsed = false,
    showMainStatisticsPanelTargetDummiesUsed = false,
    showMainStatisticsPanelGrenadesUsed = false,
    showMainStatisticsPanelPartyMemberDeaths = false,
    showMainStatisticsPanelDuelsTotal = false,
    showMainStatisticsPanelDuelsWon = false,
    showMainStatisticsPanelDuelsLost = false,
    showMainStatisticsPanelDuelsWinPercent = false,
  }

  -- Initialize settings for current character if they don't exist
  if not UltraHardcoreDB.characterSettings[characterGUID] then
    UltraHardcoreDB.characterSettings[characterGUID] = defaultSettings
  end

  -- Load current character's settings
  GLOBAL_SETTINGS = UltraHardcoreDB.characterSettings[characterGUID]

  -- Ensure new keys exist for existing characters
  if GLOBAL_SETTINGS and GLOBAL_SETTINGS.groupFoundNames == nil then
    GLOBAL_SETTINGS.groupFoundNames = {}
  end

  -- Backward compatibility: migrate from old GLOBAL_SETTINGS if it exists
  if UltraHardcoreDB.GLOBAL_SETTINGS and not UltraHardcoreDB.characterSettings[characterGUID] then
    UltraHardcoreDB.characterSettings[characterGUID] = UltraHardcoreDB.GLOBAL_SETTINGS
    GLOBAL_SETTINGS = UltraHardcoreDB.characterSettings[characterGUID]
    -- Clear old global settings after migration
    UltraHardcoreDB.GLOBAL_SETTINGS = nil
  end
end
