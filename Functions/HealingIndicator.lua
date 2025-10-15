-- Healing indicator using combat log events
function HealingIndicator(enabled, self, event, ...)
    if not enabled then return end
    if event ~= 'COMBAT_LOG_EVENT_UNFILTERED' then return end
    
    local timestamp, subevent, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags = CombatLogGetCurrentEventInfo()
    
    -- Only process healing events for the player
    if destGUID ~= UnitGUID("player") then return end
    
    -- Check for healing events
    if subevent == "SPELL_HEAL" or subevent == "SPELL_PERIODIC_HEAL" then
        ShowHealingOverlay()
    end
end
