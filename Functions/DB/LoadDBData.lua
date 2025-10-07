-- 🟢 Load saved score on login
function LoadDBData()
  if not UltraHardcoreDB then
    UltraHardcoreDB = {} -- Ensure the table exists
  end

  enemiesSlain = UltraHardcoreDB.enemiesSlain or 0
  elitesSlain = UltraHardcoreDB.elitesSlain or 0
  lowestHealthScore = UltraHardcoreDB.lowestHealthScore or 100
  WELCOME_MESSAGE_CLOSED = UltraHardcoreDB.WELCOME_MESSAGE_CLOSED or false

  if not UltraHardcoreDB.GLOBAL_SETTINGS then
    UltraHardcoreDB.GLOBAL_SETTINGS = {
      hidePlayerFrame = true,
      hideMinimap = true,
      hideBuffFrame = true,
      hideTargetFrame = true,
      hideTargetTooltip = true,
      hideQuestFrame = true,
      showTunnelVision = true,
      showFullHealthIndicator = true,
      showDazedEffect = true,
      showCritScreenMoveEffect = true,
      showIncomingDamageEffect = true,
      hideActionBars = true,
      hideGroupHealth = true,
      petsDiePermanently = true,
      disableNameplateHealth = true,
      hideUIErrors = true,
    }
  end

  GLOBAL_SETTINGS = UltraHardcoreDB.GLOBAL_SETTINGS
end
