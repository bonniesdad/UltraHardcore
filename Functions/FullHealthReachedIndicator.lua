local lastHealthPercent = 100

function FullHealthReachedIndicator(enabled, self, event, unit)
    if not enabled then return end
    if not unit then return end
    if unit ~= "player" then return end
    
    local currentHealth = UnitHealth("player")
    local maxHealth = UnitHealthMax("player")
    
    if not currentHealth or not maxHealth or maxHealth == 0 then return end
    
    local currentHealthPercent = (currentHealth / maxHealth) * 100
    
    -- Check if we went from <100% to 100%
    if currentHealthPercent == 100 and lastHealthPercent < 100 then
        ShowFullHealthOverlay()
    end
    
    lastHealthPercent = currentHealthPercent
end 