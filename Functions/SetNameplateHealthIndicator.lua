local GetNamePlateForUnit   = _G.C_NamePlate.GetNamePlateForUnit

-- in line with the own death indicator (health ratio to icon alpha)
NAME_PLATE_HEALTH_INDICATOR_STEPS =  {
  {health = 0.2, alpha = 1.0},
  {health = 0.5, alpha = 0.7},
  {health = 0.7, alpha = 0.4},
  {health = 0.9, alpha = 0.2},
}

-- cache of all nameplate indicators
NAME_PLATE_HEALTH_INDICATOR_FRAMES = {}


function SetNameplateHealthIndicator(enabled, unit)
  if not enabled then
    return
  end

  local nameplateFrame = GetNamePlateForUnit(unit);

  -- hide the default health bar
  nameplateFrame.UnitFrame.healthBar:Hide()
  nameplateFrame.UnitFrame.LevelFrame:Hide()

  -- add the custom health indicator
  local healthIndicator = nameplateFrame:CreateTexture(nil, 'ARTWORK')
  healthIndicator:SetSize(30, 30)
  healthIndicator:SetPoint('BOTTOM', nameplateFrame.UnitFrame, 'TOP', 0, 0)
  healthIndicator:SetTexture('Interface\\AddOns\\UltraHardcore\\Textures\\health-icon-red.png')
  healthIndicator:SetAlpha(0.0)

  -- cache for event lookup
  NAME_PLATE_HEALTH_INDICATOR_FRAMES[unit] = healthIndicator

  -- update the health indicator immidiately
  UpdateHealthIndicator(enabled, unit)
end

function UpdateHealthIndicator(enabled, unit)
  if not enabled then
    return
  end

  local nameplateFrame = GetNamePlateForUnit(unit);
  if nameplateFrame == nil then
    -- this event is called also for units without nameplate
    return
  end

  local healthIndicator = NAME_PLATE_HEALTH_INDICATOR_FRAMES[unit]
  if not healthIndicator then
    -- shouldn't happen
    return
  end

  local health = UnitHealth(unit)
  local maxHealth = UnitHealthMax(unit)
  local healthRatio = health / maxHealth

  local alpha = 0.0
  for _, step in pairs(NAME_PLATE_HEALTH_INDICATOR_STEPS) do
    if healthRatio <= step.health then
      alpha = step.alpha
      break
    end
  end

  healthIndicator:SetAlpha(alpha)
end

function ForceShowFriendlyNameplates(enabled)
  if enabled then
    SetCVar('nameplateShowFriends', 1)
  end
end


-- Ensure that friendly nameplaces are always configured
local frame = CreateFrame('Frame')
frame:RegisterEvent('CVAR_UPDATE')

frame:SetScript('OnEvent', function(self, event, cvar)
  ForceShowFriendlyNameplates(GLOBAL_SETTINGS.showNameplateHealthIndicator)
end)
