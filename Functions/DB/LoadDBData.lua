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
    routePlanner = false,
    -- Experimental Preset Settings
    hideBreathIndicator = false,
    showCritScreenMoveEffect = false,
    showFullHealthIndicator = false,
    hideCustomResourceBar = false,
    showHealingIndicator = false,
    setFirstPersonCamera = false,
    completelyRemovePlayerFrame = false,
    completelyRemoveTargetFrame = false,
    routePlannerCompass = false,
    showTargetBuffs = false,
    showTargetDebuffs = false,
    showTargetRaidIcon = false,
    -- Misc Settings
    showOnScreenStatistics = true,
    minimapClockPosition = {},
    minimapMailPosition = {},
    statisticsBackgroundOpacity = 0.3,
    minimapClockScale = 1.0,
    minimapMailScale = 1.0,
    announceLevelUpToGuild = true,
    autoJoinUHCChannel = true,
    hideUIErrors = false,
    showClockEvenWhenMapHidden = false,
    showMailEvenWhenMapHidden = false,
    announcePartyDeathsOnGroupJoin = false,
    announceDungeonsCompletedOnGroupJoin = false,
    newHighCritAppreciationSoundbite = false,
    buffBarOnResourceBar = false,
    playPartyDeathSoundbite = false,
    playPlayerDeathSoundbite = false,
    spookyTunnelVision = false,
    roachHearthstoneInPartyCombat = false,
    guildSelfFound = false,
    groupSelfFound = false,
    showDruidFormResourceBar = true,
    -- XP Bar
    showExpBar = false,
    showXpBarToolTip = false,
    hideDefaultExpBar = false,
    xpBarHeight = 3,
    -- Group Found teammate names (locked in at level 2)
    -- groupFoundNames = {},
    -- Statistics Row Visibility Settings
    showMainStatisticsPanelLevel = true,
    showMainStatisticsPanelLowestHealth = true,
    showMainStatisticsPanelSessionHealth = true,
    showMainStatisticsPanelThisLevel = false,
    -- HP/Mana Totals
    showMainStatisticsPanelTotalHP = false,
    showMainStatisticsPanelTotalMana = false,
    -- Fighting stats
    showMainStatisticsPanelEnemiesSlain = true,
    showMainStatisticsPanelDungeonsCompleted = false,
    showMainStatisticsPanelPetDeaths = false,
    showMainStatisticsPanelElitesSlain = false,
    showMainStatisticsPanelDungeonBosses = false,
    showMainStatisticsPanelRareElitesSlain = false,
    showMainStatisticsPanelWorldBossesSlain = false,
    showMainStatisticsPanelHighestCritValue = true,
    showMainStatisticsPanelHighestHealCritValue = false,
    -- Survival Statistics Row Visibility Settings
    showMainStatisticsPanelHealthPotionsUsed = false,
    showMainStatisticsPanelManaPotionsUsed = false,
    showMainStatisticsPanelBandagesUsed = false,
    showMainStatisticsPanelTargetDummiesUsed = false,
    showMainStatisticsPanelGrenadesUsed = false,
    showMainStatisticsPanelPartyMemberDeaths = false,
    showMainStatisticsPanelCloseEscapes = false,
    showMainStatisticsPanelDuelsTotal = false,
    showMainStatisticsPanelDuelsWon = false,
    showMainStatisticsPanelDuelsLost = false,
    showMainStatisticsPanelDuelsWinPercent = false,
    showMainStatisticsPanelPlayerJumps = false,
  }

  -- Backward compatibility: migrate from old GLOBAL_SETTINGS if it exists
  if UltraHardcoreDB.GLOBAL_SETTINGS then
    if not UltraHardcoreDB.characterSettings[characterGUID] then
      UltraHardcoreDB.characterSettings[characterGUID] = UltraHardcoreDB.GLOBAL_SETTINGS
    end
    UltraHardcoreDB.GLOBAL_SETTINGS = nil
  end

  -- Initialize settings for current character if they don't exist
  if not UltraHardcoreDB.characterSettings[characterGUID] then
    UltraHardcoreDB.characterSettings[characterGUID] = defaultSettings
  end

  -- Iterate over the defaults to see if there are any new settings
  -- we need to add to characters that have an existing DB.
  for settingName, settingValue in pairs(defaultSettings) do
    if UltraHardcoreDB.characterSettings[characterGUID][settingName] == nil then
      UltraHardcoreDB.characterSettings[characterGUID][settingName] = settingValue
    end
  end

  -- Load current character's settings
  GLOBAL_SETTINGS = UltraHardcoreDB.characterSettings[characterGUID]
end
