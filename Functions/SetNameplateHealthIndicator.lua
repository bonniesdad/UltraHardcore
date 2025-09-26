local GetNamePlateForUnit   = _G.C_NamePlate.GetNamePlateForUnit

-- in line with the own death indicator (health ratio to icon alpha)
NAME_PLATE_HEALTH_INDICATOR_STEPS =  {
  {health = 0.2, alpha = 1.0, texture = 'Interface\\AddOns\\UltraHardcore\\Textures\\health-icon-red.png'},
  {health = 0.4, alpha = 0.8, texture = 'Interface\\AddOns\\UltraHardcore\\Textures\\health-icon-red.png'},
  {health = 0.5, alpha = 0.6, texture = 'Interface\\AddOns\\UltraHardcore\\Textures\\health-icon-orange.png'},
  {health = 0.7, alpha = 0.4, texture = 'Interface\\AddOns\\UltraHardcore\\Textures\\health-icon-orange.png'},
  {health = 0.9, alpha = 0.2, texture = 'Interface\\AddOns\\UltraHardcore\\Textures\\health-icon-yellow.png'},
  {health = 1, alpha = 0.0, texture = 'Interface\\AddOns\\UltraHardcore\\Textures\\health-icon-yellow.png'},
}

-- cache of all nameplate indicators
NAME_PLATE_HEALTH_INDICATOR_FRAMES = {}


function SetNameplateHealthIndicator(enabled, unit)
  local nameplateFrame = GetNamePlateForUnit(unit);
  if not nameplateFrame then return end

  -- Hide the nameplate UI elements but keep the frame for health indicator
  nameplateFrame.UnitFrame.healthBar:Hide()
  nameplateFrame.UnitFrame.LevelFrame:Hide()
  nameplateFrame.UnitFrame.name:SetAlpha(0) -- Hide NPC name

  -- If health indicator is disabled, we're done
  if not enabled then return end

  -- add the custom health indicator
  local healthIndicator = nameplateFrame:CreateTexture(nil, 'ARTWORK')
  healthIndicator:SetSize(30, 30)
  healthIndicator:SetPoint('BOTTOM', nameplateFrame.UnitFrame, 'TOP', 0, 0)
  healthIndicator:SetAlpha(0.0)

  -- cache for event lookup
  NAME_PLATE_HEALTH_INDICATOR_FRAMES[unit] = healthIndicator

  -- update the health indicator immediately
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
      healthIndicator:SetTexture(step.texture)
      break
    end
  end

  healthIndicator:SetAlpha(alpha)
end

function ForceShowFriendlyNameplates(enabled)
  if enabled then
    -- TODO: This causes names to appear above all NPCs
    SetCVar('nameplateShowFriends', 1)
  end
end


-- Ensure that friendly nameplaces are always configured
local frame = CreateFrame('Frame')
frame:RegisterEvent('CVAR_UPDATE')
frame:RegisterEvent('NAME_PLATE_UNIT_REMOVED')
frame:RegisterEvent('PLAYER_ENTERING_WORLD')

frame:SetScript('OnEvent', function(self, event, unit)
  if event == 'CVAR_UPDATE' then
    ForceShowFriendlyNameplates(true)
  elseif event == 'NAME_PLATE_UNIT_REMOVED' then
    -- Cleanup when nameplate disappears
    local healthIndicator = NAME_PLATE_HEALTH_INDICATOR_FRAMES[unit]
    if healthIndicator then
      healthIndicator:Hide()
      NAME_PLATE_HEALTH_INDICATOR_FRAMES[unit] = nil
    end
  elseif event == 'PLAYER_ENTERING_WORLD' then
    -- Turn off friendly nameplates on login
    SetCVar('nameplateShowFriends', 0)
  end
end)
