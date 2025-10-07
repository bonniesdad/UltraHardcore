addonName = ...
UltraHardcore = CreateFrame('Frame')

-- DB Values
WELCOME_MESSAGE_CLOSED = false
GLOBAL_SETTINGS = {
  hidePlayerFrame = true,
  hideMinimap = true,
  hideBuffFrame = true,
  hideTargetFrame = true,
  hideTargetTooltip = true,
  showTunnelVision = true,
  tunnelVisionMaxStrata = true,
  showFullHealthIndicator = true,
  hideQuestFrame = true,
  showDazedEffect = true,
  showCritScreenMoveEffect = true,
  showIncomingDamageEffect = true,
  showHealingIndicator = false,
  hideUIErrors = true,
  petsDiePermanently = true,
  hideActionBars = false,
  hideGroupHealth = true,
  hideBreathIndicator = false,
  disableNameplateHealth = true,
  showOnScreenStatistics = true,
}

UltraHardcore:RegisterEvent('UNIT_AURA')
UltraHardcore:RegisterEvent('UNIT_HEALTH_FREQUENT')
UltraHardcore:RegisterEvent('PLAYER_ENTERING_WORLD')
UltraHardcore:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
UltraHardcore:RegisterEvent('ADDON_LOADED')
UltraHardcore:RegisterEvent('QUEST_WATCH_UPDATE')
UltraHardcore:RegisterEvent('QUEST_LOG_UPDATE')
UltraHardcore:RegisterEvent('UI_ERROR_MESSAGE')
UltraHardcore:RegisterEvent('PLAYER_UPDATE_RESTING')
UltraHardcore:RegisterEvent('PLAYER_LEVEL_UP')
UltraHardcore:RegisterEvent('GROUP_ROSTER_UPDATE')
UltraHardcore:RegisterEvent('MIRROR_TIMER_START')
UltraHardcore:RegisterEvent('MIRROR_TIMER_STOP')


-- 🟢 Event handler to apply all funcitons on login
UltraHardcore:SetScript('OnEvent', function(self, event, unit)
  if event == 'PLAYER_ENTERING_WORLD' or event == 'ADDON_LOADED' then
    LoadDBData()
    ShowWelcomeMessage()
    SetPlayerFrameDisplay(GLOBAL_SETTINGS.hidePlayerFrame or false)
    SetMinimapDisplay(GLOBAL_SETTINGS.hideMinimap or false)
    SetCustomBuffFrame(GLOBAL_SETTINGS.hideBuffFrame or false)
    SetTargetFrameDisplay(GLOBAL_SETTINGS.hideTargetFrame or false)
    SetTargetTooltipDisplay(GLOBAL_SETTINGS.hideTargetTooltip or false)
    SetUIErrorsDisplay(GLOBAL_SETTINGS.hideUIErrors or false)
    SetActionBarVisibility(GLOBAL_SETTINGS.hideActionBars or false)
    SetBreathBarDisplay(GLOBAL_SETTINGS.hideBreathIndicator or false)
    SetNameplateDisabled(GLOBAL_SETTINGS.disableNameplateHealth or false)
    SetAllGroupIndicators()
    DisablePetCombatText()
    RepositionPetHappinessTexture()
  elseif event == 'UNIT_HEALTH_FREQUENT' then
    TunnelVision(self, event, unit, GLOBAL_SETTINGS.showTunnelVision or false)
    FullHealthReachedIndicator(GLOBAL_SETTINGS.showFullHealthIndicator, self, event, unit)
    -- Check for pet death/abandonment
    if unit == "pet" and GLOBAL_SETTINGS.petsDiePermanently then
      CheckAndAbandonPet()
    end
  elseif event == 'COMBAT_LOG_EVENT_UNFILTERED' then
    OnCombatLogEvent(self, event)
    HealingIndicator(GLOBAL_SETTINGS.showHealingIndicator, self, event)
  elseif event == 'QUEST_WATCH_UPDATE' or event == 'QUEST_LOG_UPDATE' then
    SetQuestDisplay(GLOBAL_SETTINGS.hideQuestFrame or false)
  elseif event == 'PLAYER_UPDATE_RESTING' then
    OnPlayerUpdateRestingEvent(self, event, GLOBAL_SETTINGS.hideActionBars)
  elseif event == 'PLAYER_LEVEL_UP' then
    OnPlayerLevelUpEvent(self, event, GLOBAL_SETTINGS.hideActionBars, unit)
    AnnounceLevelUpToGuild()
  elseif event == 'GROUP_ROSTER_UPDATE' then
    SetPartyFramesInfo(GLOBAL_SETTINGS.hideGroupHealth or false)
    SetAllGroupIndicators()
  elseif event == 'MIRROR_TIMER_START' then
    -- Start breath monitoring when underwater
    -- Mirror timer events pass timerName as the first parameter after event
    local timerName = unit
    if timerName == 'BREATH' and GLOBAL_SETTINGS.hideBreathIndicator then
      OnBreathStart()
    end
  elseif event == 'MIRROR_TIMER_STOP' then
    -- Stop breath monitoring when surfacing
    local timerName = unit
    if timerName == 'BREATH' then
      OnBreathStop()
    end
  end
end)
