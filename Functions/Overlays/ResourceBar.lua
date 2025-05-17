local resourceBar = CreateFrame('StatusBar', nil, UIParent)
resourceBar:SetSize(225, PlayerFrameManaBar:GetHeight())
resourceBar:SetPoint('CENTER', UIParent, 'BOTTOM', 0, 140)
resourceBar:SetStatusBarTexture('Interface\\TargetingFrame\\UI-StatusBar')
resourceBar:SetMinMaxValues(0, UnitPowerMax('player', Enum.PowerType.Mana))

-- Make the resource bar draggable
resourceBar:SetMovable(true)
resourceBar:EnableMouse(true)
resourceBar:RegisterForDrag('LeftButton')
resourceBar:SetScript('OnDragStart', function(self)
    self:StartMoving()
end)
resourceBar:SetScript('OnDragStop', function(self)
    self:StopMovingOrSizing()
end)

-- Create a frame for the combo points
local comboFrame = CreateFrame('Frame', nil, UIParent)
comboFrame:SetSize(200, 32)
comboFrame:SetPoint('BOTTOM', resourceBar, 'TOP', 0, 10) -- Positioned above the resource bar
-- Create combo point outlines and fill layers
local resourceOrbs = {}
for i = 1, 5 do
  local container = CreateFrame('Frame', nil, comboFrame)
  container:SetSize(32, 32)
  container:SetPoint('CENTER', comboFrame, 'CENTER', (i - 3) * 40, 0)

  -- Outline (always visible)
  local outline = container:CreateTexture(nil, 'BACKGROUND')
  outline:SetTexture('Interface\\AddOns\\UltraHardcore\\textures\\flare1_tc_shadowcombo22.blp') -- Blizzard's default combo point texture
  outline:SetVertexColor(0.3, 0.3, 0.3) -- Greyed out outline
  outline:SetAllPoints(container)

  -- Fill (only visible when active)
  local fill = container:CreateTexture(nil, 'ARTWORK')
  fill:SetTexture('Interface\\AddOns\\UltraHardcore\\textures\\flare1_tc_shadowcombo.blp') -- Same texture
  fill:SetAllPoints(container)
  fill:Hide() -- Start by hiding the fill texture
  resourceOrbs[i] = {
    fill = fill,
    outline = outline,
    isFilled = false, -- Track the fill status
  }
end

-- Function to fade in new fill texture only if it's not already filled
local function SmoothTextureUpdate(orb, newTexture)
  if orb.fill:GetTexture() ~= newTexture then
    -- Set the new texture
    orb.fill:SetTexture(newTexture) -- Change texture
    UIFrameFadeIn(orb.fill, 0.2, 0, 1) -- Fade in
    orb.isFilled = true -- Mark the orb as filled
  end
end

local function CanGainComboPoints()
  local _, playerClass = UnitClass('player')
  local form = GetShapeshiftFormID()
  if playerClass == 'ROGUE' or (playerClass == 'DRUID' and form == 1) then
    return true
  end
  return nil
end

-- Function to update combo points
local function UpdateComboPoints()
  local points = GetComboPoints('player', 'target') -- Get combo points
  for i = 1, 5 do
    if i <= points then
      -- Only fade in the texture if it's not already filled
      if not resourceOrbs[i].isFilled then
        SmoothTextureUpdate(
          resourceOrbs[i],
          'Interface\\AddOns\\UltraHardcore\\textures\\flare1_tc_shadowcombo.blp'
        )
        resourceOrbs[i].fill:Show() -- Make sure to show the fill texture
      end
    else
      resourceOrbs[i].fill:Hide() -- Hide the fill texture when no combo point
      resourceOrbs[i].isFilled = false -- Mark the orb as not filled
    end
  end
end

-- Add a border around the resource bar
local border = resourceBar:CreateTexture(nil, 'OVERLAY')
border:SetTexture('Interface\\CastingBar\\UI-CastingBar-Border')
border:SetPoint('CENTER', resourceBar, 'CENTER', 0, 0)
border:SetSize(300, 64) -- Adjust as needed
-- Functions to update energy, rage, and mana
local function UpdateEnergyPoints()
  local value = UnitPower('player', Enum.PowerType.Energy)
  resourceBar:SetValue(value)
end

local function UpdateRagePoints()
  local value = UnitPower('player', Enum.PowerType.Rage)
  resourceBar:SetValue(value)
end

local function UpdateManaPoints()
  local value = UnitPower('player', Enum.PowerType.Mana)
  resourceBar:SetValue(value)
end

-- Function to hide combo points for non-users
local function HideComboPointsForNonUsers()
  local canUseCombo = CanGainComboPoints()
  if not canUseCombo then
    comboFrame:Hide() -- Hide the combo point frame if combo points are not available
  else
    comboFrame:Show() -- Otherwise, show the frame
  end
end

-- Event Handling
resourceBar:RegisterEvent('PLAYER_ENTERING_WORLD')
resourceBar:RegisterEvent('UNIT_POWER_FREQUENT')
comboFrame:RegisterEvent('PLAYER_TARGET_CHANGED')

resourceBar:SetScript('OnEvent', function(self, event, unit)
  local powerType = GetCurrentResourceType()

  if not GLOBAL_SETTINGS.hidePlayerFrame then
    resourceBar:Hide()
    comboFrame:Hide()
  end

  if unit == 'player' or event == 'PLAYER_TARGET_CHANGED' then
    UpdateComboPoints()
  end

  if event == 'PLAYER_ENTERING_WORLD' then
    HideComboPointsForNonUsers() -- Call the function to hide combo points for non-users
    if powerType == 'ENERGY' then
      resourceBar:SetMinMaxValues(0, UnitPowerMax('player', Enum.PowerType.Energy))
      resourceBar:SetStatusBarColor(1, 1, 0)
      UpdateEnergyPoints()
    elseif powerType == 'RAGE' then
      resourceBar:SetMinMaxValues(0, UnitPowerMax('player', Enum.PowerType.Rage))
      resourceBar:SetStatusBarColor(1, 0, 0)
      UpdateRagePoints()
    elseif powerType == 'MANA' then
      resourceBar:SetMinMaxValues(0, UnitPowerMax('player', Enum.PowerType.Mana))
      resourceBar:SetStatusBarColor(0, 0, 1)
      UpdateManaPoints()
    end
  elseif event == 'UNIT_POWER_FREQUENT' then
    if unit == 'player' and powerType == 'ENERGY' then
      UpdateEnergyPoints()
    elseif unit == 'player' and powerType == 'RAGE' then
      UpdateRagePoints()
    elseif unit == 'player' and powerType == 'MANA' then
      UpdateManaPoints()
    end
  end
end)

-- Hide the default combo points (Blizzard UI)
ComboFrame:Hide()
ComboFrame:UnregisterAllEvents() -- Prevent it from updating
ComboFrame:SetScript('OnUpdate', nil)
