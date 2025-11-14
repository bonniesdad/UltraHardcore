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
UltraHardcore:RegisterEvent('UNIT_SPELLCAST_START')
UltraHardcore:RegisterEvent('UNIT_SPELLCAST_STOP')
UltraHardcore:RegisterEvent('UNIT_SPELLCAST_SUCCEEDED')
UltraHardcore:RegisterEvent('UNIT_SPELLCAST_INTERRUPTED')
UltraHardcore:RegisterEvent('CHAT_MSG_SYSTEM') -- Needed for duel winner and loser
UltraHardcore:RegisterEvent('PLAYER_LOGOUT')

-- 🟢 Event handler to apply all funcitons on login
UltraHardcore:SetScript('OnEvent', function(self, event, ...)
  if event == 'PLAYER_ENTERING_WORLD' or event == 'ADDON_LOADED' then
    LoadDBData()
    HidePlayerMapIndicators()
    ShowWelcomeMessage()
    ShowVersionUpdateDialog()
    SetPlayerFrameDisplay(
      GLOBAL_SETTINGS.hidePlayerFrame or false,
      GLOBAL_SETTINGS.completelyRemovePlayerFrame or false
    )
    SetMinimapDisplay(
      GLOBAL_SETTINGS.hideMinimap or false,
      GLOBAL_SETTINGS.showClockEvenWhenMapHidden or false
    )
    ShowResourceTrackingExplainer()
    SetTargetFrameDisplay(
      GLOBAL_SETTINGS.hideTargetFrame or false,
      GLOBAL_SETTINGS.completelyRemoveTargetFrame or false
    )
    SetTargetTooltipDisplay(GLOBAL_SETTINGS.hideTargetTooltip or false)
    SetUIErrorsDisplay(GLOBAL_SETTINGS.hideUIErrors or false)
    SetActionBarVisibility(GLOBAL_SETTINGS.hideActionBars or false)
    SetBreathBarDisplay(GLOBAL_SETTINGS.hideBreathIndicator or false)
    SetNameplateDisabled(GLOBAL_SETTINGS.disableNameplateHealth or false)
    HidePlayerCastBar()
    ForceFirstPersonCamera(GLOBAL_SETTINGS.setFirstPersonCamera or false)
    -- Only update group indicators when not in combat lockdown
    if not InCombatLockdown() then
      SetAllGroupIndicators()
    else
      -- Defer group indicator updates until combat ends
      C_Timer.After(0.1, function()
        if not InCombatLockdown() then
          SetAllGroupIndicators()
        end
      end)
    end
    SetRoutePlanner(GLOBAL_SETTINGS.routePlanner or false)
    SetRoutePlannerCompass(GLOBAL_SETTINGS.routePlannerCompass or false)
    DisablePetCombatText()
    RepositionPetHappinessTexture()
    if GLOBAL_SETTINGS.completelyRemovePlayerFrame or GLOBAL_SETTINGS.completelyRemoveTargetFrame then
      if InitializeGroupButtons then
        InitializeGroupButtons()
      end
    end
    -- Initialize XP Bars at the top of the screen if enabled
    -- Both bars can be active independently
    if GLOBAL_SETTINGS.showExpBar then
      -- Show custom UHC XP bar
      InitializeExpBar()
    else
      -- Hide custom UHC XP bar if not enabled
      HideExpBar()
    end

    if GLOBAL_SETTINGS.hideDefaultExpBar then
      -- Hide default WoW XP bar when setting is enabled
      HideDefaultExpBar()
    else
      -- Show default WoW XP bar by default
      ShowDefaultExpBar()
    end
  elseif event == 'UNIT_HEALTH_FREQUENT' then
    local unit = ...
    TunnelVision(self, event, unit, GLOBAL_SETTINGS.showTunnelVision or false)
    -- FullHealthReachedIndicator is enabled when either screen glow or audio cue is enabled
    FullHealthReachedIndicator(
      (GLOBAL_SETTINGS.showFullHealthIndicator or GLOBAL_SETTINGS.showFullHealthIndicatorAudioCue),
      self, event, unit
    )
    -- Check for pet death/abandonment
    if unit == 'pet' then
      CheckAndAbandonPet()
    end
  elseif event == 'UNIT_AURA' then
    local unit = ...
    if unit == 'player' then
      if GLOBAL_SETTINGS.routePlanner then
        SetRoutePlanner(GLOBAL_SETTINGS.routePlanner)
      end
    end
  elseif event == 'COMBAT_LOG_EVENT_UNFILTERED' then
    OnCombatLogEvent(self, event)
    HealingIndicator(GLOBAL_SETTINGS.showHealingIndicator, self, event)
  elseif event == 'PLAYER_UPDATE_RESTING' then
    OnPlayerUpdateRestingEvent(self)
    SetRoutePlanner(GLOBAL_SETTINGS.routePlanner)
  elseif event == 'PLAYER_LEVEL_UP' then
    OnPlayerLevelUpEvent(self, event, ...)
    AnnounceLevelUpToGuild(GLOBAL_SETTINGS.announceLevelUpToGuild)
  elseif event == 'GROUP_ROSTER_UPDATE' then
    SetPartyFramesInfo(GLOBAL_SETTINGS.hideGroupHealth or false)
    -- Only update group indicators when not in combat lockdown
    if not InCombatLockdown() then
      SetAllGroupIndicators()
    else
      -- Defer group indicator updates until combat ends
      C_Timer.After(0.1, function()
        if not InCombatLockdown() then
          SetAllGroupIndicators()
        end
      end)
    end
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
    if timerName == 'BREATH' and GLOBAL_SETTINGS.hideBreathIndicator then
      OnBreathStop()
    end
  elseif event == 'UNIT_SPELLCAST_START' then
    -- Hide player cast bar if setting is enabled
    local unit = ...
    if unit == 'player' then
      HidePlayerCastBar()
    end
    
    -- Check for Hearthstone casting start
    local unit, castGUID, spellID = ...
    if GLOBAL_SETTINGS.roachHearthstoneInPartyCombat then
      if unit == 'player' and spellID == 8690 then -- 8690 is Hearthstone spell ID
        local affectingCombat = UnitAffectingCombat('player')
        local partyInCombat = false

        --print("Player combat status: " .. tostring(affectingCombat))
        -- party1 is always the player
        for i = 1, 5 do
          local partyUnit = 'party' .. i
          --print("Party member " .. i .. " combat status: " .. tostring(UnitAffectingCombat(partyUnit)))
          if UnitAffectingCombat(partyUnit) then
            partyInCombat = true
            break
          end
        end

        if affectingCombat or partyInCombat then
          ShowHearthingOverlay()
        end
      end
    end
  elseif event == 'UNIT_SPELLCAST_STOP' or event == 'UNIT_SPELLCAST_SUCCEEDED' or event == 'UNIT_SPELLCAST_FAILED' or event == 'UNIT_SPELLCAST_INTERRUPTED' then
    if GLOBAL_SETTINGS.roachHearthstoneInPartyCombat then
      -- Check for Hearthstone casting end
      local unit, castGUID, spellID = ...
      if unit == 'player' and spellID == 8690 then -- 8690 is Hearthstone spell ID
        HideHearthingOverlay()
      end
    end
  elseif event == 'CHAT_MSG_SYSTEM' then
    DuelTracker(...)
  elseif event == 'PLAYER_LOGOUT' then
    -- Cleanup: ensure any hidden map indicators are restored when logging out/reloading
    if RestorePlayerMapIndicators then
      RestorePlayerMapIndicators()
    end
  end
end)