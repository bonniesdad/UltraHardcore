-- Damage Overlay Handler
-- Handles incoming damage overlay effects based on damage type and school

-- Initialize global table
DamageOverlayHandler = {}

-- School names mapping for spell damage
local schoolNames = {
  [2] = 'Fire',
  [3] = 'Fire',
  [4] = 'Fire',
  [5] = 'Shadow',
  [8] = 'Nature',
  [11] = 'Physical',
  [12] = 'Physical',
  [16] = 'Frost',
  [32] = 'Shadow',
  [64] = 'Arcane',
}

-- Handle incoming damage overlay effects
function DamageOverlayHandler.HandleIncomingDamage(subEvent, destGUID)
  if not GLOBAL_SETTINGS.showIncomingDamageEffect then return end

  -- Physical damage (swing damage)
  if subEvent == 'SWING_DAMAGE' then
    if destGUID == UnitGUID('player') then
      ShowPhysicalDamageOverlay()
    end
  end

  -- Spell damage
  if subEvent == 'SPELL_DAMAGE' or subEvent == 'SPELL_PERIODIC_DAMAGE' then
    if destGUID == UnitGUID('player') then
      local school = select(15, CombatLogGetCurrentEventInfo())
      local schoolName = schoolNames[school] or 'Unknown'

      -- Use OverTime variant for periodic damage
      if subEvent == 'SPELL_PERIODIC_DAMAGE' then
        DamageOverlayHandler.ShowPeriodicDamageOverlay(schoolName)
      else
        DamageOverlayHandler.ShowInstantDamageOverlay(schoolName)
      end
    end
  end
end

-- Show periodic damage overlay based on school
function DamageOverlayHandler.ShowPeriodicDamageOverlay(schoolName)
  if schoolName == 'Physical' then
    ShowPhysicalDamageOverTimeOverlay()
  elseif schoolName == 'Shadow' then
    ShowShadowDamageOverTimeOverlay()
  elseif schoolName == 'Holy' then
    ShowHolyDamageOverTimeOverlay()
  elseif schoolName == 'Arcane' then
    ShowArcaneDamageOverTimeOverlay()
  elseif schoolName == 'Nature' then
    ShowNatureDamageOverTimeOverlay()
  elseif schoolName == 'Fire' then
    ShowFireDamageOverTimeOverlay()
  end
end

-- Show instant damage overlay based on school
function DamageOverlayHandler.ShowInstantDamageOverlay(schoolName)
  if schoolName == 'Shadow' then
    ShowShadowDamageOverlay()
  elseif schoolName == 'Holy' then
    ShowHolyDamageOverlay()
  elseif schoolName == 'Arcane' then
    ShowArcaneDamageOverlay()
  elseif schoolName == 'Nature' then
    ShowNatureDamageOverlay()
  elseif schoolName == 'Fire' then
    ShowFireDamageOverlay()
  end
end
