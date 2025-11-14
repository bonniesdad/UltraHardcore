function PlayerIsSolo()
    -- If not in a group or raid, player is solo
    if not IsInGroup() and not IsInRaid() then 
        return true 
    end
    
    -- Check if in a raid
    if IsInRaid() then
        local numRaidMembers = GetNumGroupMembers()
        for i = 1, numRaidMembers do
            local unit = "raid"..i
            -- Skip the player themselves
            if not UnitIsUnit(unit, "player") and UnitInRange(unit) then
                return false -- Found another player in range, not solo
            end
        end
    else
        -- Check if in a party (but not raid)
        local numPartyMembers = GetNumSubgroupMembers()
        for i = 1, numPartyMembers do
            local unit = "party"..i
            if UnitInRange(unit) then
                return false -- Found another player in range, not solo
            end
        end
    end
    
    -- No other players found in range, player is solo
    return true
end