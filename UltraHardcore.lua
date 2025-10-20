addonName = ...
UltraHardcore = CreateFrame('Frame')

-- DB Values
WELCOME_MESSAGE_CLOSED = false
GLOBAL_SETTINGS = {} -- Will be populated by LoadDBData()

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
UltraHardcore:SetScript('OnEvent', function(self, event, ...)
  if event == 'PLAYER_ENTERING_WORLD' or event == 'ADDON_LOADED' then
    LoadDBData()
    ShowWelcomeMessage()
    ShowVersionUpdateDialog()
    SetPlayerFrameDisplay(GLOBAL_SETTINGS.hidePlayerFrame or false)
    SetMinimapDisplay(GLOBAL_SETTINGS.hideMinimap or false, GLOBAL_SETTINGS.showClockEvenWhenMapHidden or false)
    SetTargetFrameDisplay(GLOBAL_SETTINGS.hideTargetFrame or false)
    SetTargetTooltipDisplay(GLOBAL_SETTINGS.hideTargetTooltip or false)
    SetUIErrorsDisplay(GLOBAL_SETTINGS.hideUIErrors or false)
    SetActionBarVisibility(GLOBAL_SETTINGS.hideActionBars or false)
    SetBreathBarDisplay(GLOBAL_SETTINGS.hideBreathIndicator or false)
    SetNameplateDisabled(GLOBAL_SETTINGS.disableNameplateHealth or false)
    ForceFirstPersonCamera(GLOBAL_SETTINGS.setFirstPersonCamera or false)
    SetAllGroupIndicators()
    DisablePetCombatText()
    RepositionPetHappinessTexture()
  elseif event == 'UNIT_HEALTH_FREQUENT' then
    local unit = ...
    TunnelVision(self, event, unit, GLOBAL_SETTINGS.showTunnelVision or false)
    FullHealthReachedIndicator(GLOBAL_SETTINGS.showFullHealthIndicator, self, event, unit)
    -- Check for pet death/abandonment
    if unit == "pet" then
      CheckAndAbandonPet()
    end
  elseif event == 'COMBAT_LOG_EVENT_UNFILTERED' then
    OnCombatLogEvent(self, event)
    HealingIndicator(GLOBAL_SETTINGS.showHealingIndicator, self, event)
  elseif event == 'PLAYER_UPDATE_RESTING' then
    OnPlayerUpdateRestingEvent(self)
  elseif event == 'PLAYER_LEVEL_UP' then
    OnPlayerLevelUpEvent(self, event, ...)
    AnnounceLevelUpToGuild(GLOBAL_SETTINGS.announceLevelUpToGuild)
  elseif event == 'GROUP_ROSTER_UPDATE' then
    SetPartyFramesInfo(GLOBAL_SETTINGS.hideGroupHealth or false)
    SetAllGroupIndicators()
  elseif event == 'MIRROR_TIMER_START' then
    -- Start breath monitoring when underwater
    -- Mirror timer events pass timerName as the first parameter after event
    local timerName = ...
    if timerName == 'BREATH' and GLOBAL_SETTINGS.hideBreathIndicator then
      OnBreathStart()
    end
  elseif event == 'MIRROR_TIMER_STOP' then
    -- Stop breath monitoring when surfacing
    local timerName = ...
    if timerName == 'BREATH' then
      OnBreathStop()
    end
  end
end)
