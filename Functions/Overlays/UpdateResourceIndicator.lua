local resourceIndicator = CreateFrame('Frame', 'CustomresourceIndicator', UIParent)
resourceIndicator:SetSize(125, 125) -- Single icon size
resourceIndicator:SetPoint('BOTTOMRIGHT', UIParent, 'BOTTOMRIGHT', -20, 70)
resourceIndicator:Hide()
local icon = resourceIndicator:CreateTexture(nil, 'OVERLAY')
icon:SetSize(125, 125) -- Size of the single icon
icon:SetTexture('Interface\\AddOns\\UltraHardcore\\textures\\bonnie0.png') -- Default texture
icon:SetAlpha(1) -- Fully visible
resourceIndicator.icon = icon
icon:SetPoint('CENTER', resourceIndicator, 'CENTER', 0, 0)

local currentSoundHandle = nil

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
  if resourceIndicator:IsShown() then
    resourceIndicator:Hide()
  else
    resourceIndicator:Show()
  end
end

SLASH_STOPSOUND1 = '/stopsound'
SlashCmdList.STOPSOUND = function()
  if currentSoundHandle then
    StopSound(currentSoundHandle)
    currentSoundHandle = nil
  end
end

SLASH_TESTPARTYDEATHAUDIO1 = '/testpartydeathaudio'
SlashCmdList.TESTPARTYDEATHAUDIO = function()
  local randomNumber = random(1,4)
  local willPlay = nil
  local soundHandle = nil
  -- Play sound file on party death
  willPlay, soundHandle = PlaySoundFile("Interface\\AddOns\\UltraHardcore\\Sounds\\PartyDeath" .. randomNumber .. ".ogg", "SFX")
  if willPlay then
    currentSoundHandle = soundHandle
  end
end

-- Event Handler
resourceIndicator:RegisterEvent('PLAYER_ENTERING_WORLD')
resourceIndicator:RegisterEvent('UNIT_POWER_FREQUENT')
resourceIndicator:SetScript('OnEvent', function(self, event, unit)
  local powerType = GetCurrentResourceType()

  if event == 'PLAYER_ENTERING_WORLD' then
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
