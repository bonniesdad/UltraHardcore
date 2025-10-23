-- Nameplate disable function with prevention hook
-- Sets cvars and prevents players from re-enabling nameplates

local nameplateCVars =
  {
    'nameplateShowEnemies',
    'nameplateShowAll',
    'nameplateShowFriends',
    'nameplateShowMinions',
    'nameplateShowMinor',
    'nameplateShowEnemyMinus',
    'nameplateShowEnemyMinions',
    'nameplateShowEnemyPets',
    'nameplateShowEnemyGuardians',
    'nameplateShowEnemyTotems',
    'nameplateShowFriendlyMinions',
    'nameplateShowFriendlyPets',
    'nameplateShowFriendlyGuardians',
    'nameplateShowFriendlyTotems',
  }

local originalSetCVar = SetCVar

-- Safe SetCVar wrapper that checks for protected state
local function SafeSetCVar(cvar, value)
  if InCombatLockdown() then
    -- If in combat, queue the CVar change for later
    C_Timer.After(0.1, function()
      if not InCombatLockdown() then
        originalSetCVar(cvar, value)
      end
    end)
  else
    originalSetCVar(cvar, value)
  end
end

function SetNameplateDisabled(disabled)
  if disabled then
    -- Disable all nameplate types
    for _, cvar in ipairs(nameplateCVars) do
      SafeSetCVar(cvar, 0)
    end

    -- Hook SetCVar to prevent nameplate enabling
    SetCVar = function(cvar, value)
      -- Check if this is a nameplate CVar
      for _, nameplateCvar in ipairs(nameplateCVars) do
        if cvar == nameplateCvar then
          -- Always set nameplate CVars to 0 (disabled)
          SafeSetCVar(cvar, 0)
          return
        end
      end
      -- Allow other CVars to work normally
      SafeSetCVar(cvar, value)
    end
  else
    -- Restore original SetCVar function
    SetCVar = originalSetCVar
  end
end
