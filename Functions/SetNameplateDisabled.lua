-- Nameplate disable function with prevention hook
-- Sets cvars and prevents players from re-enabling nameplates

local nameplateCVars = {
    "nameplateShowEnemies",
    "nameplateShowAll", 
    "nameplateShowFriends",
    "nameplateShowMinions",
    "nameplateShowMinor",
    "nameplateShowEnemyMinus",
    "nameplateShowEnemyMinions",
    "nameplateShowEnemyPets",
    "nameplateShowEnemyGuardians",
    "nameplateShowEnemyTotems",
    "nameplateShowFriendlyMinions",
    "nameplateShowFriendlyPets",
    "nameplateShowFriendlyGuardians",
    "nameplateShowFriendlyTotems"
}

local originalSetCVar = SetCVar
local nameplatesDisabled = false

function SetNameplateDisabled(disabled)
    nameplatesDisabled = disabled
    
    if disabled then
        -- Disable all nameplate types
        for _, cvar in ipairs(nameplateCVars) do
            originalSetCVar(cvar, 0)
        end
        
        -- Hook SetCVar to prevent nameplate enabling
        SetCVar = function(cvar, value)
            -- Check if this is a nameplate CVar
            for _, nameplateCvar in ipairs(nameplateCVars) do
                if cvar == nameplateCvar then
                    -- Always set nameplate CVars to 0 (disabled)
                    originalSetCVar(cvar, 0)
                    return
                end
            end
            -- Allow other CVars to work normally
            originalSetCVar(cvar, value)
        end
    else
        -- Restore original SetCVar function
        SetCVar = originalSetCVar
    end
end
