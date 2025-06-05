
-- Get the color for a power type
function GetPowerTypeColor(powerType)
    if not powerType or type(powerType) ~= "string" then
        print("UltraHardcore: Invalid power type provided to GetPowerTypeColor")
        return unpack(POWER_COLORS.MANA)
    end

    return unpack(POWER_COLORS[powerType] or POWER_COLORS.MANA)
end