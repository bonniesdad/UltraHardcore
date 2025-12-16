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

local function IsInDungeonOrRaidInstance()
  local inInstance, instanceType = IsInInstance()
  return inInstance and (instanceType == "party" or instanceType == "raid")
end

local function ShouldAllowFriendlyPlates()
  -- Only allow friendly plates for wild ally indicators outside dungeon/raid instances
  return GLOBAL_SETTINGS and (GLOBAL_SETTINGS.showWildAllyHealthIndicator or false) and not IsInDungeonOrRaidInstance()
end

local function DesiredCVarValue(cvar)
  if ShouldAllowFriendlyPlates() then
    if cvar == 'nameplateShowEnemies' then
      return '0'
    elseif cvar == 'nameplateShowFriends' or cvar == 'nameplateShowAll' then
      return '1'
    end
  end
  return '0'
end

-- Utility: run a function once combat ends (or immediately if not in combat)
local function RunWhenOutOfCombat(callback)
  if not InCombatLockdown() then
    callback()
    return
  end
  local waitFrame = CreateFrame('Frame')
  waitFrame:RegisterEvent('PLAYER_REGEN_ENABLED')
  waitFrame:SetScript('OnEvent', function(self)
    self:UnregisterEvent('PLAYER_REGEN_ENABLED')
    self:SetScript('OnEvent', nil)
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
    local desired = DesiredCVarValue(cvar)
    SafeSetCVar(cvar, desired)
  end
end

-- Function to check and reset nameplate CVars if they've been changed
local function CheckNameplateCVars()
  if not nameplateDisabled then return end

  -- Check each nameplate CVar and reset if enabled
  for _, cvar in ipairs(nameplateCVars) do
    local currentValue = GetCVar(cvar)
    local desiredValue = DesiredCVarValue(cvar)
    if currentValue and desiredValue and currentValue ~= desiredValue then
      SafeSetCVar(cvar, desiredValue)
    end
  end
end

-- Fallback: if nameplates appear, force them to look like 100% HP with no level
local function GetNamePlateUnitToken(plate)
  if not plate then return nil end
  if type(plate.namePlateUnitToken) == 'string' then
    return plate.namePlateUnitToken
  end
  local unitFrame = plate.UnitFrame or plate.unitFrame
  if unitFrame then
    if type(unitFrame.unit) == 'string' then
      return unitFrame.unit
    end
    if type(unitFrame.displayedUnit) == 'string' then
      return unitFrame.displayedUnit
    end
  end
  return nil
end

local function RestoreFriendlyNpcHealthBarIfNeeded(plate)
  if not plate or not plate._UHC_HideFriendlyNPCHealthBar then return end
  plate._UHC_HideFriendlyNPCHealthBar = nil

  local unitFrame = plate.UnitFrame or plate.unitFrame
  if not unitFrame then return end

  local barCandidates =
    {
      unitFrame.healthBar,
      unitFrame.healthbar,
      unitFrame.healthBarContainer,
      unitFrame.healthBarBackground,
      unitFrame.healthBarContainer and unitFrame.healthBarContainer.healthBar,
    }

  for _, bar in ipairs(barCandidates) do
    if bar then
      if bar.Show then
        bar:Show()
      end
      if bar.SetAlpha then
        bar:SetAlpha(1)
      end
    end
  end
end

local function HideFriendlyNpcHealthBarIfNeeded(plate, unitToken)
  if not plate or not nameplateDisabled then return false end
  if not unitToken or type(unitToken) ~= 'string' then return false end
  if not UnitExists(unitToken) then return false end

  -- Friendly NPC: keep the *name* visible, but hide the healthbar visuals.
  if UnitIsFriend('player', unitToken) and not UnitIsPlayer(unitToken) then
    plate._UHC_HideFriendlyNPCHealthBar = true

    local unitFrame = plate.UnitFrame or plate.unitFrame
    if not unitFrame then return true end

    local nameRegion = unitFrame.name or unitFrame.Name
    if nameRegion then
      if nameRegion.Show then
        nameRegion:Show()
      end
      if nameRegion.SetAlpha then
        nameRegion:SetAlpha(1)
      end
    end

    local barCandidates =
      {
        unitFrame.healthBar,
        unitFrame.healthbar,
        unitFrame.healthBarContainer,
        unitFrame.healthBarBackground,
        unitFrame.healthBarContainer and unitFrame.healthBarContainer.healthBar,
      }

    for _, bar in ipairs(barCandidates) do
      if bar then
        if bar.Hide then
          bar:Hide()
        end
        if bar.SetAlpha then
          bar:SetAlpha(0)
        end
      end
    end

    return true
  end

  -- Not a friendly NPC: undo any prior bar-hiding in case plates are recycled.
  RestoreFriendlyNpcHealthBarIfNeeded(plate)
  return false
end

local function ApplyNameplateFallbackToFrame(plate, unitToken)
  if not plate then return end

  -- If this is a friendly NPC plate, hide its healthbar but keep its name visible.
  -- We still run the rest of the fallback (level hiding, etc.) afterward.
  HideFriendlyNpcHealthBarIfNeeded(plate, unitToken)

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
    local unitToken = GetNamePlateUnitToken(plate)
    ApplyNameplateFallbackToFrame(plate, unitToken)
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
      ApplyNameplateFallbackToFrame(plate, unit)
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
  nameplateMonitorFrame:RegisterEvent('CVAR_UPDATE')
  nameplateMonitorFrame:RegisterEvent('ZONE_CHANGED_NEW_AREA')
  nameplateMonitorFrame:RegisterEvent('PLAYER_DIFFICULTY_CHANGED')
  nameplateMonitorFrame:RegisterEvent('PLAYER_ENTERING_WORLD')
  nameplateMonitorFrame:SetScript('OnEvent', function(self, event, cvar, value)
    -- Instance/zone transitions can change the desired friendly-plate behavior
    if event == 'ZONE_CHANGED_NEW_AREA' or event == 'PLAYER_DIFFICULTY_CHANGED' or event == 'PLAYER_ENTERING_WORLD' then
      if not nameplateDisabled then return end
      RunWhenOutOfCombat(function()
        DisableAllNameplates()
      end)
      return
    end

    -- We only check these three because they have keybinds that can be pressed on accident
    if cvar == 'nameplateShowEnemies' or cvar == 'nameplateShowFriends' or cvar == 'nameplateShowAll' then
      RunWhenOutOfCombat(function()
        local desiredEnemies = DesiredCVarValue('nameplateShowEnemies')
        local desiredFriends = DesiredCVarValue('nameplateShowFriends')
        local desiredAll = DesiredCVarValue('nameplateShowAll')
        if desiredEnemies then
          SetCVar('nameplateShowEnemies', desiredEnemies)
        end
        if desiredFriends then
          SetCVar('nameplateShowFriends', desiredFriends)
        end
        if desiredAll then
          SetCVar('nameplateShowAll', desiredAll)
        end
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
    -- Best-effort: if we hid any friendly NPC healthbars, restore them
    if C_NamePlate and C_NamePlate.GetNamePlates then
      local plates = C_NamePlate.GetNamePlates() or {}
      for _, plate in ipairs(plates) do
        RestoreFriendlyNpcHealthBarIfNeeded(plate)
      end
    end
  end
end
