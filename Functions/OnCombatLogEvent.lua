function OnCombatLogEvent(self, event)
  local _, subEvent, _, sourceGUID, _, _, _, destGUID, enemyName, _, _, spellID, a, b, c, d, e, f =
    CombatLogGetCurrentEventInfo()

  -- Extract amount based on damage type
  local amount
  if subEvent == 'SWING_DAMAGE' then
    amount = select(12, CombatLogGetCurrentEventInfo())
  elseif subEvent == 'SPELL_DAMAGE' or subEvent == 'RANGE_DAMAGE' then
    amount = select(15, CombatLogGetCurrentEventInfo())
  else
    amount = select(12, CombatLogGetCurrentEventInfo()) -- fallback
  end

  -- Handle incoming damage overlays
  DamageOverlayHandler.HandleIncomingDamage(subEvent, destGUID)

  -- Handle critical hit effects and tracking
  CritTracker.HandleCriticalHit(subEvent, sourceGUID, destGUID, amount)
  CritTracker.TrackCriticalHit(subEvent, sourceGUID, amount)

  -- Handle party kills
  if subEvent == 'PARTY_KILL' then
    KillTracker.HandlePartyKill(destGUID)
  end

  -- Handle dazed effect
  DazedEffectHandler.HandleDazedEffect(subEvent, destGUID, spellID)

  -- Handle item usage tracking
  ItemTracker.HandleItemUsage(subEvent, sourceGUID, destGUID, spellID)

  -- Handle party member deaths
  if subEvent == 'UNIT_DIED' then
    PartyDeathTracker.HandlePartyMemberDeath(destGUID)
  end
  
  -- Handle buff application tracking for rejecting buffs from others
  if _G.TrackBuffApplication then
    _G.TrackBuffApplication(subEvent, sourceGUID, destGUID, spellID)
  end
end
