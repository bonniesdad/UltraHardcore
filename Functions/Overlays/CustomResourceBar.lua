local resourceBar = CreateFrame('StatusBar', 'UltraHardcoreResourceBar', UIParent)
if not resourceBar then
  print('UltraHardcore: Failed to create resource bar')
  return
end

resourceBar:SetSize(225, PlayerFrameManaBar:GetHeight())
resourceBar:SetPoint('CENTER', UIParent, 'BOTTOM', 0, 140)
resourceBar:SetStatusBarTexture('Interface\\TargetingFrame\\UI-StatusBar')

-- Cache power type colors and max values
local POWER_COLORS = {
  ENERGY = { 1, 1, 0 },
  RAGE = { 1, 0, 0 },
  MANA = { 0, 0, 1 },
}

-- Position persistence functions
local function SaveResourceBarPosition()
  if not UltraHardcoreDB then
    UltraHardcoreDB = {}
  end

  local point, relativeTo, relativePoint, xOfs, yOfs = resourceBar:GetPoint()
  -- Always save UIParent as the relativeTo frame to avoid reference issues
  UltraHardcoreDB.resourceBarPosition = {
    point = point,
    relativeTo = 'UIParent',
    relativePoint = relativePoint,
    xOfs = xOfs,
    yOfs = yOfs,
  }

  SaveDBData('resourceBarPosition', UltraHardcoreDB.resourceBarPosition)
end

local function LoadResourceBarPosition()
  if not UltraHardcoreDB then
    UltraHardcoreDB = {}
  end

  local pos = UltraHardcoreDB.resourceBarPosition
  -- Clear existing points first to avoid anchor conflicts
  resourceBar:ClearAllPoints()

  -- If no saved position exists, use default position and save it
  if not pos then
    -- Set default position (center bottom)
    resourceBar:SetPoint('CENTER', UIParent, 'BOTTOM', 0, 140)
    -- Save the default position for future loads
    SaveResourceBarPosition()
    print('UltraHardcore: Resource bar position initialized to default')
  else
    -- Always anchor to UIParent to avoid frame reference issues
    resourceBar:SetPoint(pos.point, UIParent, pos.relativePoint, pos.xOfs, pos.yOfs)
  end
end

-- Make the resource bar draggable with position saving
resourceBar:SetMovable(true)
resourceBar:EnableMouse(true)
resourceBar:RegisterForDrag('LeftButton')
resourceBar:SetScript('OnDragStart', function(self)
  self:StartMoving()
end)
resourceBar:SetScript('OnDragStop', function(self)
  self:StopMovingOrSizing()
  SaveResourceBarPosition()
end)

-- Create a frame for the combo points
local comboFrame = CreateFrame('Frame', 'UltraHardcoreComboFrame', UIParent)
if not comboFrame then
  print('UltraHardcore: Failed to create combo frame')
  return
end

comboFrame:SetSize(200, 32)
comboFrame:SetPoint('BOTTOM', resourceBar, 'TOP', 0, 10)

-- Create combo point outlines and fill layers
local resourceOrbs = {}
local COMBO_TEXTURE = 'Interface\\AddOns\\UltraHardcore\\textures\\combopoint'
local COMBO_SHADOW_TEXTURE = COMBO_TEXTURE .. '_outline.blp'

for i = 1, 5 do
  local orb = CreateComboPointOrb(comboFrame, i, 5, COMBO_TEXTURE .. '.blp', COMBO_SHADOW_TEXTURE)
  if not orb then
    print('UltraHardcore: Failed to create combo point orb ' .. i)
    return
  end
  resourceOrbs[i] = orb
end

-- Function to update combo points
local function UpdateComboPoints()
  if not UnitExists('target') then
    for _, orb in ipairs(resourceOrbs) do
      orb.fill:Hide()
      orb.isFilled = false
    end
    return
  end

  local points = GetComboPoints('player', 'target')
  if not points then
    print('UltraHardcore: Failed to get combo points')
    return
  end

  for i = 1, 5 do
    local orb = resourceOrbs[i]
    if not orb then
      print('UltraHardcore: Missing combo point orb ' .. i)
      return
    end

    if i <= points then
      if not orb.isFilled then
        SmoothTextureFadeIn(orb.fill)
        orb.fill:Show()
        orb.isFilled = true
      end
    else
      orb.fill:Hide()
      orb.isFilled = false
    end
  end
end

-- Add a border around the resource bar
local border = resourceBar:CreateTexture(nil, 'OVERLAY')
if not border then
  print('UltraHardcore: Failed to create resource bar border')
  return
end

border:SetTexture('Interface\\CastingBar\\UI-CastingBar-Border')
border:SetPoint('CENTER', resourceBar, 'CENTER', 0, 0)
border:SetSize(300, 64)

-- Create pet resource bar
local petResourceBar = CreateFrame('StatusBar', 'UltraHardcorePetResourceBar', UIParent)
if not petResourceBar then
  print('UltraHardcore: Failed to create pet resource bar')
  return
end

petResourceBar:SetSize(125, PlayerFrameManaBar:GetHeight() - 5)
petResourceBar:SetPoint('TOP', resourceBar, 'BOTTOM', 0, -5)
petResourceBar:SetStatusBarTexture('Interface\\TargetingFrame\\UI-StatusBar')
petResourceBar:Hide() -- Initially hidden
-- Add border around pet resource bar
local petBorder = petResourceBar:CreateTexture(nil, 'OVERLAY')
if not petBorder then
  print('UltraHardcore: Failed to create pet resource bar border')
  return
end

petBorder:SetTexture('Interface\\CastingBar\\UI-CastingBar-Border')
petBorder:SetPoint('CENTER', petResourceBar, 'CENTER', 0, 0)
petBorder:SetSize(171, 50)

-- Make the pet resource bar draggable (moves both bars together)
petResourceBar:SetMovable(true)
petResourceBar:EnableMouse(true)
petResourceBar:RegisterForDrag('LeftButton')
petResourceBar:SetScript('OnDragStart', function(self)
  resourceBar:StartMoving()
end)
petResourceBar:SetScript('OnDragStop', function(self)
  resourceBar:StopMovingOrSizing()
  SaveResourceBarPosition()
end)

-- Unified function to update resource points
local function UpdateResourcePoints()
  local powerType = GetCurrentResourceType()
  local value = UnitPower('player', Enum.PowerType[powerType])
  local maxValue = UnitPowerMax('player', Enum.PowerType[powerType])

  resourceBar:SetMinMaxValues(0, maxValue)
  resourceBar:SetValue(value)
  resourceBar:SetStatusBarColor(unpack(POWER_COLORS[powerType]))
end

-- Function to update pet resource points
local function UpdatePetResourcePoints()
  if not UnitExists('pet') then
    petResourceBar:Hide()
    return
  end

  -- Get pet's power type (usually mana for most pets)
  local petPowerType = UnitPowerType('pet')
  local petValue = UnitPower('pet', petPowerType)
  local petMaxValue = UnitPowerMax('pet', petPowerType)

  if petMaxValue > 0 then
    petResourceBar:SetMinMaxValues(0, petMaxValue)
    petResourceBar:SetValue(petValue)

    -- Use purple color for pet resource bar
    petResourceBar:SetStatusBarColor(0.5, 0, 1) -- Purple color
    petResourceBar:Show()
  else
    petResourceBar:Hide()
  end
end

-- Function to hide combo points for non-users
local function HideComboPointsForNonUsers()
  comboFrame:SetShown(CanGainComboPoints())
end

-- Helper function to check if buff bar should be repositioned
local function ShouldRepositionBuffBar()
  return GLOBAL_SETTINGS and GLOBAL_SETTINGS.hidePlayerFrame and GLOBAL_SETTINGS.buffBarOnResourceBar
end

-- Function to center buff bar above the resource bar when # of auras change
local function CenterPlayerBuffBar()
  if not ShouldRepositionBuffBar() then return end
  if BuffFrame then
    local buffCount = 0
    local debuffCount = 0
    local pixelsToMove = 13.25
    local xOffset = 0
    local yOffset = 5
    local buffRows = 1

    -- NOTE:  Buffs do not get put into "slots" sequentially.  My frost mage has arcane int and frost armor in slot 1 and 2
    -- but when a paladin gives me blessing of wisdom it goes into slot 18.  Other lua code I found via google used 40 slots
    -- when iterating to count buffs, so I'm doing the same.
    for i = 0, 40 do
      local aura = C_UnitAuras.GetAuraDataBySlot('PLAYER', i)

      if aura and aura.isHarmful ~= true then
        buffCount = buffCount + 1
        if buffCount > 10 and buffCount % 10 == 0 then
          -- Once we count our 20th or 30th buff, add a row
          -- Unfortunately this is going to move the debuffs up as well
          buffRows = buffRows + 1
        end
      end
    end

    if buffCount == 0 then return end
    local firstBuffButton = _G['BuffButton1']

    -- We're no longer calculating a xOffset to try to move the buff bar around
    -- Instead, we're going to figure out how wide each buff icon is and calculate a newWidth
    -- and just resize the frame to fit exactly.
    if firstBuffButton then
      local width = firstBuffButton:GetWidth()
      local height = firstBuffButton:GetHeight()

      -- buffCount + width is the total width of all buff icons
      -- (buffCount - 1) * 5 is the spacing between each icon (~5 pixels each)
      -- 5 pixels is subtracted to account for spacing in front of the first icon
      local newWidth = (buffCount * width) + (buffCount * 5) - 5
      if buffCount < debuffCount then
        newWidth = debuffCount * width
      end

      BuffFrame:SetScale(1.0)
      BuffFrame:SetWidth(newWidth)

      if buffRows > 1 then
        yOffset = ((buffRows - 1) * height) + ((buffRows - 1) * 5)
      end

      local anchor = CanGainComboPoints() and comboFrame or resourceBar

      BuffFrame:ClearAllPoints()
      BuffFrame:SetPoint('BOTTOM', anchor, 'TOP', 0, yOffset)
    end
  end
end

-- Event Handling
resourceBar:RegisterEvent('PLAYER_ENTERING_WORLD')
resourceBar:RegisterEvent('UNIT_POWER_FREQUENT')
resourceBar:RegisterEvent('UPDATE_SHAPESHIFT_FORM')
resourceBar:RegisterEvent('UNIT_PET')
resourceBar:RegisterEvent('PET_ATTACK_START')
resourceBar:RegisterEvent('PET_ATTACK_STOP')
resourceBar:RegisterEvent('UNIT_AURA')
resourceBar:RegisterEvent('ADDON_LOADED')
comboFrame:RegisterEvent('PLAYER_TARGET_CHANGED')

-- Hide the default combo points (Blizzard UI)
if ComboFrame then
  ComboFrame:Hide()
  ComboFrame:UnregisterAllEvents()
  ComboFrame:SetScript('OnUpdate', nil)
end

-- Function to reposition player buff bar
local function RepositionPlayerBuffBar()
  if not ShouldRepositionBuffBar() then return end

  -- Wait for buff frame to be created
  C_Timer.After(0.5, function()
    if BuffFrame and BuffFrame:IsVisible() then
      CenterPlayerBuffBar()
    end
  end)
end

-- Hook into buff frame events to maintain positioning
local function HookBuffFrame()
  if BuffFrame then
    local originalShow = BuffFrame.Show
    BuffFrame.Show = function(self)
      originalShow(self)
      if ShouldRepositionBuffBar() then
        RepositionPlayerBuffBar()
      end
      -- When buffBarOnResourceBar is false, do nothing - let other addons control the position
    end

    local originalHide = BuffFrame.Hide
    BuffFrame.Hide = function(self)
      originalHide(self)
    end
  end
end

-- Function to handle buff bar setting changes
local function HandleBuffBarSettingChange()
  if BuffFrame and BuffFrame:IsVisible() then
    if ShouldRepositionBuffBar() then
      RepositionPlayerBuffBar()
    end
    -- When buffBarOnResourceBar is false, do nothing - let other addons control the position
  end
end

resourceBar:SetScript('OnEvent', function(self, event, unit)
  if not GLOBAL_SETTINGS or not GLOBAL_SETTINGS.hidePlayerFrame then
    resourceBar:Hide()
    comboFrame:Hide()
    petResourceBar:Hide()
    return
  end

  if event == 'ADDON_LOADED' and unit == 'Blizzard_BuffFrame' then
    HookBuffFrame()
    HandleBuffBarSettingChange()
  end

  if unit == 'player' or event == 'PLAYER_TARGET_CHANGED' then
    UpdateComboPoints()
  end

  if event == 'PLAYER_ENTERING_WORLD' then
    HideComboPointsForNonUsers()
    UpdateResourcePoints()
    UpdatePetResourcePoints()
    HandleBuffBarSettingChange()
    -- Load saved position after database is available
    C_Timer.After(0.1, function()
      LoadResourceBarPosition()
    end)
  elseif event == 'UNIT_POWER_FREQUENT' then
    if unit == 'player' then
      UpdateResourcePoints()
    elseif unit == 'pet' then
      UpdatePetResourcePoints()
    end
  elseif event == 'UPDATE_SHAPESHIFT_FORM' then
    -- Update resource bar and combo points when shapeshifting
    UpdateResourcePoints()
    HideComboPointsForNonUsers()
    UpdateComboPoints()
  elseif event == 'UNIT_PET' then
    -- Pet summoned or dismissed
    UpdatePetResourcePoints()
  elseif event == 'PET_ATTACK_START' or event == 'PET_ATTACK_STOP' then
    -- Update pet resource when pet starts/stops attacking
    UpdatePetResourcePoints()
  elseif unit == 'player' and event == 'UNIT_AURA' then
    CenterPlayerBuffBar()
  end
end)

-- Make the buff bar setting change handler globally accessible
_G.UltraHardcoreHandleBuffBarSettingChange = HandleBuffBarSettingChange

-- Reset resource bar position function
local function ResetResourceBarPosition()
  -- Clear existing points first
  resourceBar:ClearAllPoints()
  -- Reset to default position (center bottom)
  resourceBar:SetPoint('CENTER', UIParent, 'BOTTOM', 0, 140)
  -- Save the reset position
  SaveResourceBarPosition()
  print('UltraHardcore: Resource bar position reset to default')
end

-- Slash command to reset resource bar position
SLASH_RESETRESOURCEBAR1 = '/resetresourcebar'
SLASH_RESETRESOURCEBAR2 = '/rrb'
SlashCmdList['RESETRESOURCEBAR'] = ResetResourceBarPosition
