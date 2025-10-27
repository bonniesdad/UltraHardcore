-- Nameplate disable function using monitoring approach
-- Sets cvars and monitors for changes without hooking SetCVar globally

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

local nameplateMonitorFrame = nil
local nameplateDisabled = false

-- Safe SetCVar wrapper that checks for protected state
local function SafeSetCVar(cvar, value)
  if InCombatLockdown() then
    -- If in combat, queue the CVar change for later
    C_Timer.After(0.1, function()
      if not InCombatLockdown() then
        SetCVar(cvar, value)
      end
    end)
  else
    SetCVar(cvar, value)
  end
end

-- Function to disable all nameplate CVars
local function DisableAllNameplates()
  for _, cvar in ipairs(nameplateCVars) do
    SafeSetCVar(cvar, 0)
  end
end

-- Function to check and reset nameplate CVars if they've been changed
local function CheckNameplateCVars()
  if not nameplateDisabled then return end

  -- Check each nameplate CVar and reset if enabled
  for _, cvar in ipairs(nameplateCVars) do
    local currentValue = GetCVar(cvar)
    if currentValue and currentValue ~= '0' then
      SafeSetCVar(cvar, 0)
    end
  end
end

-- Start monitoring nameplate CVars
local function StartNameplateMonitoring()
  if nameplateMonitorFrame then
    return -- Already monitoring
  end

  nameplateMonitorFrame = CreateFrame('Frame')
  nameplateMonitorFrame:SetScript('OnUpdate', function(self, elapsed)
    -- Check every 0.5 seconds to avoid performance issues
    self.timer = (self.timer or 0) + elapsed
    if self.timer >= 0.5 then
      self.timer = 0
      CheckNameplateCVars()
    end
  end)
end

-- Stop monitoring nameplate CVars
local function StopNameplateMonitoring()
  if nameplateMonitorFrame then
    nameplateMonitorFrame:SetScript('OnUpdate', nil)
    nameplateMonitorFrame = nil
  end
end

function SetNameplateDisabled(disabled)
  nameplateDisabled = disabled

  if disabled then
    -- Disable all nameplate types
    DisableAllNameplates()
    -- Start monitoring to prevent re-enabling
    StartNameplateMonitoring()
  else
    -- Stop monitoring
    StopNameplateMonitoring()
  end
end
