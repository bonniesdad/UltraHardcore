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
local nameplateFallbackFrame = nil

-- Utility: run a function once combat ends (or immediately if not in combat)
local function RunWhenOutOfCombat(callback)
  if not InCombatLockdown() then
    callback()
    return
  end
  local waitFrame = CreateFrame("Frame")
  waitFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
  waitFrame:SetScript("OnEvent", function(self)
    self:UnregisterEvent("PLAYER_REGEN_ENABLED")
    self:SetScript("OnEvent", nil)
    callback()
  end)
end



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

-- Fallback: if nameplates appear, force them to look like 100% HP with no level
local function ApplyNameplateFallbackToFrame(plate)
  if not plate then return end

  -- Try to locate a health bar on the nameplate
  local unitFrame = plate.UnitFrame or plate.unitFrame
  local healthBar = nil

  if unitFrame then
    healthBar = unitFrame.healthBar or unitFrame.healthbar
    if not healthBar and unitFrame.healthBarContainer and unitFrame.healthBarContainer.healthBar then
      healthBar = unitFrame.healthBarContainer.healthBar
    end
  end

  if not healthBar then
    -- Fallback: search children for a StatusBar
    local numChildren = select('#', plate:GetChildren())
    for i = 1, numChildren do
      local child = select(i, plate:GetChildren())
      if child and child.GetObjectType and child:GetObjectType() == 'StatusBar' then
        healthBar = child
        break
      end
    end
  end

  if healthBar and healthBar.GetMinMaxValues then
    local _, maxValue = healthBar:GetMinMaxValues()
    if maxValue then
      if healthBar.GetValue and healthBar.SetValue then
        if healthBar:GetValue() ~= maxValue then
          healthBar:SetValue(maxValue)
        end
      end
      if not healthBar._UHC_ForcedFull then
        healthBar._UHC_ForcedFull = true
        if healthBar.HookScript then
          healthBar:HookScript('OnValueChanged', function(bar)
            local _, maxV = bar:GetMinMaxValues()
            if maxV and bar.GetValue and bar.SetValue and bar:GetValue() ~= maxV then
              bar:SetValue(maxV)
            end
          end)
        end
      end
    end
  end

  -- Hide potential level displays if present on the unit frame
  if unitFrame then
    if unitFrame.LevelText and unitFrame.LevelText.Hide then
      unitFrame.LevelText:Hide()
    end
    if unitFrame.levelText and unitFrame.levelText.Hide then
      unitFrame.levelText:Hide()
    end
    if unitFrame.LevelFrame and unitFrame.LevelFrame.Hide then
      unitFrame.LevelFrame:Hide()
    end
  end
end

local function ApplyNameplateFallback()
  if not nameplateDisabled then return end
  if not C_NamePlate or not C_NamePlate.GetNamePlates then return end
  local plates = C_NamePlate.GetNamePlates() or {}
  for _, plate in ipairs(plates) do
    ApplyNameplateFallbackToFrame(plate)
  end
end

local function StartNameplateFallback()
  if nameplateFallbackFrame then return end
  if not C_NamePlate or not C_NamePlate.GetNamePlates then return end

  nameplateFallbackFrame = CreateFrame('Frame')
  nameplateFallbackFrame:RegisterEvent('NAME_PLATE_UNIT_ADDED')
  nameplateFallbackFrame:RegisterEvent('NAME_PLATE_UNIT_REMOVED')
  nameplateFallbackFrame:SetScript('OnEvent', function(_, event, unit)
    if not nameplateDisabled then return end
    if event == 'NAME_PLATE_UNIT_ADDED' then
      local plate = C_NamePlate.GetNamePlateForUnit and C_NamePlate.GetNamePlateForUnit(unit)
      ApplyNameplateFallbackToFrame(plate)
    elseif event == 'NAME_PLATE_UNIT_REMOVED' then
    -- nothing needed on remove for now
    end
  end)

  -- Periodic enforcement in case other addons modify plates after creation
  nameplateFallbackFrame:SetScript('OnUpdate', function(self, elapsed)
    self.timer = (self.timer or 0) + elapsed
    if self.timer >= 0.5 then
      self.timer = 0
      ApplyNameplateFallback()
    end
  end)
end

local function StopNameplateFallback()
  if not nameplateFallbackFrame then return end
  nameplateFallbackFrame:UnregisterAllEvents()
  nameplateFallbackFrame:SetScript('OnEvent', nil)
  nameplateFallbackFrame:SetScript('OnUpdate', nil)
  nameplateFallbackFrame = nil
end

-- Start monitoring nameplate CVars
local function StartNameplateMonitoring()
  if nameplateMonitorFrame then
    return -- Already monitoring
  end

  nameplateMonitorFrame = CreateFrame('Frame')
  nameplateMonitorFrame:RegisterEvent("CVAR_UPDATE")
  nameplateMonitorFrame:SetScript("OnEvent", function(self, event, cvar, value)
    -- We only check these three because they have keybinds that can be pressed on accident
    if cvar == "nameplateShowEnemies" or cvar == "nameplateShowFriends" or cvar == "nameplateShowAll" then
        -- force them off again
        RunWhenOutOfCombat(function()
          SetCVar("nameplateShowEnemies", 0)
          SetCVar("nameplateShowFriends", 0)
          SetCVar("nameplateShowAll", 0)
        end)
    end
  end)
  --[[nameplateMonitorFrame:SetScript('OnUpdate', function(self, elapsed)
    -- Check every 0.5 seconds to avoid performance issues
    self.timer = (self.timer or 0) + elapsed
    if self.timer >= 0.5 then
      self.timer = 0
      CheckNameplateCVars()
    end
  end)]]
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
    -- Fallback enforcement in case nameplates appear
    StartNameplateFallback()
  else
    -- Stop monitoring
    StopNameplateMonitoring()
    StopNameplateFallback()
  end
end
