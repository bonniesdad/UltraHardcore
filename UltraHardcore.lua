addonName = ...
UltraHardcore = CreateFrame('Frame')

-- DB Values
vengeanceScore = 0
elitesSlain = 0
WELCOME_MESSAGE_CLOSED = false
GLOBAL_SETTINGS = {
  hidePlayerFrame = true,
  hideMinimap = true,
  hideBuffFrame = true,
  hideTargetFrame = true,
  hideTargetTooltip = true,
  hideEnemyNameplates = true,
  guildSelfFound = true,
  showTunnelVision = true,
  hideQuestFrame = true,
  showDazedEffect = true,
  showCritScreenMoveEffect = true,
}

UltraHardcore:RegisterEvent('UNIT_AURA')
UltraHardcore:RegisterEvent('UNIT_HEALTH_FREQUENT')
UltraHardcore:RegisterEvent('PLAYER_ENTERING_WORLD')
UltraHardcore:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
UltraHardcore:RegisterEvent('ADDON_LOADED')
UltraHardcore:RegisterEvent('QUEST_WATCH_UPDATE')
UltraHardcore:RegisterEvent('QUEST_LOG_UPDATE')
UltraHardcore:RegisterEvent('UI_ERROR_MESSAGE')

-- 🟢 Event handler to apply all funcitons on login
UltraHardcore:SetScript('OnEvent', function(self, event, unit)
  if event == 'PLAYER_ENTERING_WORLD' or event == 'ADDON_LOADED' then
    LoadDBData()
    JoinUHCChannel()
    ShowWelcomeMessage()
    SetPlayerFrameDisplay(GLOBAL_SETTINGS.hidePlayerFrame or false)
    SetMinimapDisplay(GLOBAL_SETTINGS.hideMinimap or false)
    SetCustomBuffFrame(GLOBAL_SETTINGS.hideBuffFrame or false)
    SetTargetFrameDisplay(GLOBAL_SETTINGS.hideTargetFrame or false)
    SetTargetTooltipDisplay(GLOBAL_SETTINGS.hideTargetTooltip or false)
    SetUIErrorsDisplay(GLOBAL_SETTINGS.hideUIErrors or false)
  elseif event == 'UNIT_HEALTH_FREQUENT' then
    DeathIndicator(self, event, unit, GLOBAL_SETTINGS.showTunnelVision or false)
  elseif event == 'QUEST_WATCH_UPDATE' or event == 'QUEST_LOG_UPDATE' then
    SetQuestDisplay(GLOBAL_SETTINGS.hideQuestFrame or false)
  elseif event == 'COMBAT_LOG_EVENT_UNFILTERED' then
    OnCombatLogEvent(self, event)
  end
end)
