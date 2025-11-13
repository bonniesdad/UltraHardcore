local resourceIndicator = CreateFrame('Frame', 'CustomresourceIndicator', UIParent)
resourceIndicator:SetSize(125, 125) -- Single icon size
resourceIndicator:SetPoint('BOTTOMRIGHT', UIParent, 'BOTTOMRIGHT', -20, 70)
resourceIndicator:Hide()
resourceIndicator:SetMovable(true)
resourceIndicator:SetClampedToScreen(true)

-- Position persistence
local function SaveResourceIndicatorPosition()
  if not UltraHardcoreDB then
    UltraHardcoreDB = {}
  end

  local point, _, relPoint, x, y = resourceIndicator:GetPoint()
  UltraHardcoreDB.resourceIndicatorPosition = { point = point, relPoint = relPoint, x = x, y = y }
  if SaveDBData then
    SaveDBData('resourceIndicatorPosition', UltraHardcoreDB.resourceIndicatorPosition)
  end
end

local function LoadResourceIndicatorPosition()
  if not UltraHardcoreDB then
    UltraHardcoreDB = {}
  end

  local pos = UltraHardcoreDB.resourceIndicatorPosition
  resourceIndicator:ClearAllPoints()
  if pos then
    resourceIndicator:SetPoint(pos.point, UIParent, pos.relPoint, pos.x, pos.y)
  else
    resourceIndicator:SetPoint('BOTTOMRIGHT', UIParent, 'BOTTOMRIGHT', -20, 70)
  end
end

-- Make draggable and save position
resourceIndicator:EnableMouse(true)
resourceIndicator:RegisterForDrag('LeftButton')
resourceIndicator:SetScript('OnDragStart', function(self)
  self:StartMoving()
end)
resourceIndicator:SetScript('OnDragStop', function(self)
  self:StopMovingOrSizing()
  SaveResourceIndicatorPosition()
end)
local icon = resourceIndicator:CreateTexture(nil, 'OVERLAY')
icon:SetSize(125, 125) -- Size of the single icon
icon:SetTexture('Interface\\AddOns\\UltraHardcore\\textures\\bonnie0.png') -- Default texture
icon:SetAlpha(1) -- Fully visible
resourceIndicator.icon = icon
icon:SetPoint('CENTER', resourceIndicator, 'CENTER', 0, 0)

-- Function to smoothly fade into a new texture
local function SmoothTextureUpdate(newTexture)
  if icon.currentTexture ~= newTexture then
    icon.currentTexture = newTexture
    UIFrameFadeOut(icon, 0.2, icon:GetAlpha(), 0) -- Fade out
    C_Timer.After(0.2, function()
      icon:SetTexture(newTexture) -- Change texture after fade-out
      UIFrameFadeIn(icon, 0.2, 0, 1) -- Fade in
    end)
  end
end

-- Update for Mana Points
local function UpdateManaPoints()
  local value = UnitPower('player', Enum.PowerType.Mana)
  local maxValue = UnitPowerMax('player', Enum.PowerType.Mana)
  local manaStep = math.ceil((value / maxValue) * 5) -- Scale 0-100% into 5 thresholds
  local newTexture = 'Interface\\AddOns\\UltraHardcore\\textures\\bonnie' .. manaStep .. '.png'
  SmoothTextureUpdate(newTexture)
end

-- Update for Energy Points
local function UpdateEnergyPoints()
  local value = UnitPower('player', Enum.PowerType.Energy)
  local maxValue = UnitPowerMax('player', Enum.PowerType.Energy)
  local energyStep = math.ceil((value / maxValue) * 5) -- Scale 0-100% into 5 thresholds
  local newTexture = 'Interface\\AddOns\\UltraHardcore\\textures\\bonnie' .. energyStep .. '.png'
  SmoothTextureUpdate(newTexture)
end

-- Update for Rage
local function UpdateRagePoints()
  local value = UnitPower('player', Enum.PowerType.Rage)
  local maxValue = UnitPowerMax('player', Enum.PowerType.Rage)
  local rageStep = math.ceil((value / maxValue) * 5) -- Scale 0-100% into 5 thresholds
  local newTexture = 'Interface\\AddOns\\UltraHardcore\\textures\\bonnie' .. rageStep .. '.png'
  SmoothTextureUpdate(newTexture)
end

-- Slash command to toggle the frame
SLASH_TOGGLEBONNIE1 = '/bonnie'
SlashCmdList.TOGGLEBONNIE = function()
  if not UltraHardcoreDB then
    UltraHardcoreDB = {}
  end
  if resourceIndicator:IsShown() then
    resourceIndicator:Hide()
    UltraHardcoreDB.resourceIndicatorShown = false
  else
    resourceIndicator:Show()
    UltraHardcoreDB.resourceIndicatorShown = true
  end
  if SaveDBData then
    SaveDBData('resourceIndicatorShown', UltraHardcoreDB.resourceIndicatorShown)
  end
end


-- Event Handler
resourceIndicator:RegisterEvent('PLAYER_ENTERING_WORLD')
resourceIndicator:RegisterEvent('UNIT_POWER_FREQUENT')
resourceIndicator:SetScript('OnEvent', function(self, event, unit)
  local powerType = GetCurrentResourceType()

  if event == 'PLAYER_ENTERING_WORLD' then
    -- Defer loading position/visibility slightly to ensure DB is ready
    C_Timer.After(0.1, function()
      LoadResourceIndicatorPosition()
      if UltraHardcoreDB and UltraHardcoreDB.resourceIndicatorShown then
        resourceIndicator:Show()
      else
        resourceIndicator:Hide()
      end
    end)
    if powerType == 'ENERGY' then
      icon:SetTexture('Interface\\AddOns\\UltraHardcore\\textures\\bonnie' .. 5 .. '.png')
    elseif powerType == 'RAGE' then
      icon:SetTexture('Interface\\AddOns\\UltraHardcore\\textures\\bonnie' .. 0 .. '.png')
    elseif powerType == 'MANA' then
      icon:SetTexture('Interface\\AddOns\\UltraHardcore\\textures\\bonnie' .. 5 .. '.png')
    end
  elseif unit == 'player' and powerType == 'ENERGY' then
    UpdateEnergyPoints()
  elseif unit == 'player' and powerType == 'RAGE' then
    UpdateRagePoints()
  elseif unit == 'player' and powerType == 'MANA' then
    UpdateManaPoints()
  end
end)
