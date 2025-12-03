
-- Check if a unit can gain combo points
function CanGainComboPoints(unit)
    unit = unit or 'player'
    if not UnitExists(unit) then
        print("Ultra: Invalid unit provided to CanGainComboPoints")
        return false
    end

    local _, playerClass = UnitClass(unit)
    if not playerClass then
        print("Ultra: Failed to get unit class")
        return false
    end

    local form = GetShapeshiftFormID()
    return playerClass == 'ROGUE' or (playerClass == 'DRUID' and form == 1)
end 