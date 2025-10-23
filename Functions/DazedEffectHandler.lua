-- Dazed Effect Handler
-- Handles dazed effect overlay when player gets dazed

-- Initialize global table
DazedEffectHandler = {}

-- Handle dazed effect overlay
function DazedEffectHandler.HandleDazedEffect(subEvent, destGUID, spellID)
  if not GLOBAL_SETTINGS.showDazedEffect then return end

  -- Dazed spell ID is 1604
  if spellID == 1604 and destGUID == UnitGUID('player') then
    if subEvent == 'SPELL_AURA_APPLIED' then
      ShowDazedOverlay(true) -- Dazed, enable blur
    elseif subEvent == 'SPELL_AURA_REMOVED' then
      ShowDazedOverlay(false) -- Daze ended, disable blur
    end
  end
end
