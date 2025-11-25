local resourceBar = CreateFrame('StatusBar', 'UltraHardcoreResourceBar', UIParent)
if not resourceBar then
  print('UltraHardcore: Failed to create resource bar')
  return
end

resourceBar:SetSize(225, PlayerFrameManaBar:GetHeight())
resourceBar:SetPoint('CENTER', UIParent, 'BOTTOM', 0, 140)
resourceBar:SetStatusBarTexture('Interface\\TargetingFrame\\UI-StatusBar')

-- Colors are provided by GetPowerTypeColor() which respects user overrides

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
  if not self:IsMovable() then return end
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
  if not resourceBar:IsMovable() then return end
  resourceBar:StartMoving()
end)
petResourceBar:SetScript('OnDragStop', function(self)
  resourceBar:StopMovingOrSizing()
  SaveResourceBarPosition()
end)

-- Create druid form resource bar (for shapeshifted druids)
local druidFormResourceBar = CreateFrame('StatusBar', 'UltraHardcoreDruidFormResourceBar', UIParent)
if not druidFormResourceBar then
  print('UltraHardcore: Failed to create druid form resource bar')
  return
end
druidFormResourceBar:SetSize(125, PlayerFrameManaBar:GetHeight() - 5)
druidFormResourceBar:SetPoint('TOP', resourceBar, 'BOTTOM', 0, -5)
druidFormResourceBar:SetStatusBarTexture('Interface\\TargetingFrame\\UI-StatusBar')
druidFormResourceBar:Hide() -- Initially hidden
-- Add a border around the druid form resource bar
local druidFormBorder = druidFormResourceBar:CreateTexture(nil, 'OVERLAY')
if not druidFormBorder then
  print('UltraHardcore: Failed to create druid form resource bar border')
  return
end
druidFormBorder:SetTexture('Interface\\CastingBar\\UI-CastingBar-Border')
druidFormBorder:SetPoint('CENTER', druidFormResourceBar, 'CENTER', 0, 0)
druidFormBorder:SetSize(171, 50)

-- Position persistence functions for druid form resource bar
local function SaveDruidFormResourceBarPosition()
  if not UltraHardcoreDB then
    UltraHardcoreDB = {}
  end

  local point, relativeTo, relativePoint, xOfs, yOfs = druidFormResourceBar:GetPoint()
  UltraHardcoreDB.druidFormResourceBarPosition = {
    point = point,
    relativeTo = 'UIParent',
    relativePoint = relativePoint,
    xOfs = xOfs,
    yOfs = yOfs,
  }

  SaveDBData('druidFormResourceBarPosition', UltraHardcoreDB.druidFormResourceBarPosition)
end

local function LoadDruidFormResourceBarPosition()
  if not UltraHardcoreDB then
    UltraHardcoreDB = {}
  end

  local pos = UltraHardcoreDB.druidFormResourceBarPosition
  druidFormResourceBar:ClearAllPoints()
  -- Always anchor to the main resource bar, matching the pet bar
  druidFormResourceBar:SetPoint('TOP', resourceBar, 'BOTTOM', 0, -5)
end

-- Make the druid form resource bar draggable with position saving
druidFormResourceBar:SetMovable(true)
druidFormResourceBar:EnableMouse(true)
druidFormResourceBar:RegisterForDrag('LeftButton')
druidFormResourceBar:SetScript('OnDragStart', function(self)
  if not resourceBar:IsMovable() then return end
  resourceBar:StartMoving()
end)
druidFormResourceBar:SetScript('OnDragStop', function(self)
  resourceBar:StopMovingOrSizing()
  SaveResourceBarPosition()
end)

local function ApplyResourceBarLockState(lockOverride)
  local locked = lockOverride
  if locked == nil then
    locked = GLOBAL_SETTINGS and GLOBAL_SETTINGS.lockResourceBar
  end

  local enableDrag = not locked

  resourceBar:SetMovable(enableDrag)
  resourceBar:EnableMouse(enableDrag)
  petResourceBar:SetMovable(enableDrag)
  petResourceBar:EnableMouse(enableDrag)
  druidFormResourceBar:SetMovable(enableDrag)
  druidFormResourceBar:EnableMouse(enableDrag)
end

_G.UltraHardcoreApplyResourceBarLockState = ApplyResourceBarLockState

-- Unified function to update resource points
local function UpdateResourcePoints()
  local powerType = GetCurrentResourceType()
  local value = UnitPower('player', Enum.PowerType[powerType])
  local maxValue = UnitPowerMax('player', Enum.PowerType[powerType])

  resourceBar:SetMinMaxValues(0, maxValue)
  resourceBar:SetValue(value)
  resourceBar:SetStatusBarColor(GetPowerTypeColor(powerType))
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

    -- Use user-selected pet color (default to purple)
    local pr, pg, pb = 0.5, 0, 1
    if GLOBAL_SETTINGS and GLOBAL_SETTINGS.resourceBarColors and GLOBAL_SETTINGS.resourceBarColors.PET then
      local c = GLOBAL_SETTINGS.resourceBarColors.PET
      if type(c) == 'table' and #c >= 3 then
        pr, pg, pb = c[1], c[2], c[3]
      end
    end
    petResourceBar:SetStatusBarColor(pr, pg, pb)
    petResourceBar:Show()
  else
    petResourceBar:Hide()
  end
end

-- Helper function to check if player is a druid
local function IsDruid()
  local _, classFilename = UnitClass('player')
  return classFilename == 'DRUID'
end

-- Helper function to check if player is shapeshifted
local function IsShapeshifted()
  -- 1 - Cat Form
  -- 5 - Bear Form
  -- 8 - Dire Bear Form
  local form = GetShapeshiftFormID()
  if form == 5 or form == 8 or form == 1 then
    return true
  end
  return false
end

-- Function to update druid form resource bar
local function UpdateDruidFormResourceBar()
  if not IsDruid() then
    druidFormResourceBar:Hide()
    return
  end

  if not IsShapeshifted() then
    druidFormResourceBar:Hide()
    return
  end

  -- Check if the druid form resource bar is enabled in settings
  if GLOBAL_SETTINGS and not GLOBAL_SETTINGS.showDruidFormResourceBar then
    druidFormResourceBar:Hide()
    return
  end

  -- For druids in form, show mana on the druid form bar (not the form resource)
  -- Mana is Enum.PowerType.Mana (which is typically index 0)
  local manaValue = UnitPower('player', Enum.PowerType.Mana)
  local manaMaxValue = UnitPowerMax('player', Enum.PowerType.Mana)

  druidFormResourceBar:SetMinMaxValues(0, manaMaxValue)
  druidFormResourceBar:SetValue(manaValue)
  druidFormResourceBar:SetStatusBarColor(GetPowerTypeColor('MANA'))

  if GLOBAL_SETTINGS and not GLOBAL_SETTINGS.hidePlayerFrame or GLOBAL_SETTINGS.hideCustomResourceBar then
    druidFormResourceBar:Hide()
  else
    druidFormResourceBar:Show()
  end
end

-- Backwards-compat: called on shapeshift or display power changes for druids
-- Keeps the druid form mana bar synchronized with current form changes.
local function UpdateDruidShiftResourcePoints()
  UpdateDruidFormResourceBar()
end

-- Function to hide combo points for non-users
local function HideComboPointsForNonUsers()
  comboFrame:SetShown(CanGainComboPoints())
end

-- Helper function to check if buff bar should be repositioned
local function ShouldRepositionBuffBar()
  return GLOBAL_SETTINGS and GLOBAL_SETTINGS.hidePlayerFrame and GLOBAL_SETTINGS.buffBarOnResourceBar
end
local UHCBuffFrame = CreateFrame('Frame', 'UHCBuffFrame', UIParent)
UHCBuffFrame:SetWidth(100)
UHCBuffFrame:SetHeight(32)
UHCBuffFrame:ClearAllPoints()
UHCBuffFrame:SetPoint('BOTTOM', resourceBar, 'TOP', 0, 5)

-- Helper function to check if buff bar should be repositioned
local function ShouldHideBuffs()
  return GLOBAL_SETTINGS and GLOBAL_SETTINGS.hidePlayerFrame and GLOBAL_SETTINGS.hideBuffsCompletely
end

-- Helper function to check if buff bar should be repositioned
local function ShouldHideDebuffs()
  return GLOBAL_SETTINGS and GLOBAL_SETTINGS.hidePlayerFrame and GLOBAL_SETTINGS.hideDebuffs
end

local function HideBuffs()
  if BuffFrame then
    BuffFrame:Hide()
  end
end

local function HideDebuffs()
  if BuffFrame then
    for i = 0, 40 do
      local debuff = _G['DebuffButton' .. i]

      if debuff ~= nil then
        debuff:Hide()
      end
    end
  end
end

-- Function to center buff bar above the resource bar when # of auras change
local function CenterPlayerBuffBar()
  if ShouldHideBuffs() then
    -- If we're hding all buffs, return because we don't care about repositioning
    HideBuffs()
    return
  end
  if ShouldHideDebuffs() then
    -- If we're hiding debuffs, we might still be repositioning the buffs, so do not return
    HideDebuffs()
  end
  if not ShouldRepositionBuffBar() then return end

  if BuffFrame then
    local newWidth = 0
    local buffsPerRow = 10
    local buffCount = 0
    local debuffCount = 0
    local tempEnchantCount = 0
    local xOffset = 0
    local yOffset = 20
    local buffRows = 1
    local buffWidth = 0
    local buffHeight = 0
    local debuffWidth = 0
    local debuffHeight = 0
    local iconSpacing = 6
    local rowSpacing = 16

    -- Count how many buffs and debuffs we have
    for i = 0, 60 do
      local aura = C_UnitAuras.GetAuraDataBySlot('PLAYER', i)

      if aura and aura.isHarmful ~= true then
        buffCount = buffCount + 1
      elseif aura and aura.isHarmful == true then
        debuffCount = debuffCount + 1
      end
    end

    -- Move buff buttons from the blizz frame to our custom frame
    local buffOffset = 0
    local buffYOffset = 0
    local rowIconsMoved = 0
    local buffsMoved = 0
    for i = 1, buffCount do
      local buff = _G['BuffButton' .. i]
      buff:SetParent(UHCBuffFrame)
      buff:ClearAllPoints()
      buff:SetPoint('BOTTOMLEFT', UHCBuffFrame, 'BOTTOMLEFT', buffOffset, buffYOffset)
      rowIconsMoved = rowIconsMoved + 1
      buffsMoved = i

      if buffWidth == 0 then
        buffWidth = buff:GetWidth()
      end
      if buffHeight == 0 then
        buffHeight = buff:GetHeight()
      end

      -- After placing the current buff (in SetPoint above), calculate the offset of the next buff
      buffOffset = buffOffset + buffWidth

      -- This should prevent icon spacing from being added to the last buff in each row
      if rowIconsMoved < buffsPerRow and i < buffCount then
        buffOffset = buffOffset + iconSpacing
      end

      if buffCount > buffsPerRow and i % buffsPerRow == 0 then
        buffYOffset = buffYOffset + buffHeight + rowSpacing
        buffRows = buffRows + 1
        buffOffset = 0
        rowIconsMoved = 0
      end

    end

    local hasMainHandEnchant, mainHandExpiration, mainHandCharges, mainHandEnchantID,
      hasOffHandEnchant, offHandExpiration, offHandCharges, offHandEnchantID,
      hasRangedEnchant, rangedExpiration, rangedCharges, rangedEnchantID = GetWeaponEnchantInfo()

    if hasMainHandEnchant == true then tempEnchantCount = tempEnchantCount + 1 end
    if hasOffHandEnchant == true then tempEnchantCount = tempEnchantCount + 1 end
    if hasRangedEnchant == true then tempEnchantCount = tempEnchantCount + 1 end

    if tempEnchantCount > 0 then
      -- We need to increase the buff count for temp enchants
      buffCount = buffCount + tempEnchantCount
      local enchantIndex = 1

      if buffsMoved % buffsPerRow ~= 0 then 
        -- This is necessary because buffCount did not include temp enchants in the loop above so iconspacing did not get added
        buffOffset = buffOffset + iconSpacing
      end

      buffsMoved = buffsMoved + 1

      -- Starting from the largest iterator value from the buff loop above, move the weapon enchant icons
      for i = buffsMoved, buffCount do
        local enchant = _G['TempEnchant' .. enchantIndex]
        if enchantIndex <= tempEnchantCount then
          enchant:SetParent(UHCBuffFrame)
          enchant:ClearAllPoints()
          enchant:SetPoint('BOTTOMLEFT', UHCBuffFrame, 'BOTTOMLEFT', buffOffset, buffYOffset)

          rowIconsMoved = rowIconsMoved + 1
          buffOffset = buffOffset + buffWidth

          if rowIconsMoved < buffsPerRow then
            buffOffset = buffOffset + iconSpacing
          end

          if buffCount > buffsPerRow and i % buffsPerRow == 0 then
            buffYOffset = buffYOffset + buffHeight + rowSpacing
            buffRows = buffRows + 1
            buffOffset = 0
            rowIconsMoved = 0
          end

          enchantIndex = enchantIndex + 1
          buffsMoved = buffsMoved + 1
        end
      end
    end

    -- Move debuff buttons into our custom frame (disabled to avoid anchor family loops)
    if buffCount == 0 then return end
    local firstBuffButton = _G['BuffButton1']

    if firstBuffButton then
      local width = firstBuffButton:GetWidth()
      local height = firstBuffButton:GetHeight()

      -- buffCount + width is the total width of all buff icons
      -- (buffCount - 1) * iconSpacing is the spacing between each icon
      -- iconSpacing pixels is subtracted to account for spacing in front of the first icon
      if buffCount < buffsPerRow then
        newWidth = (buffCount * width) + ((buffCount - 1) * iconSpacing)
      else
        newWidth = (buffsPerRow * width) + ((buffsPerRow - 1) * iconSpacing)
      end

      UHCBuffFrame:SetScale(1.0)
      UHCBuffFrame:SetWidth(newWidth)

      if buffRows > 1 then
        -- yOffset = ((buffRows - 1) * height) + ((buffRows - 1) * 5)
        UHCBuffFrame:SetHeight(buffRows * (height + rowSpacing))
      else
        UHCBuffFrame:SetHeight(height + rowSpacing)
      end

      local anchor = CanGainComboPoints() and comboFrame or resourceBar
      if CanGainComboPoints() then
        yOffset = 5
      end

      UHCBuffFrame:ClearAllPoints()
      UHCBuffFrame:SetPoint('BOTTOM', anchor, 'TOP', 0, yOffset)
    end
  end
end

-- Event Handling
resourceBar:RegisterEvent('PLAYER_ENTERING_WORLD')
resourceBar:RegisterEvent('UNIT_POWER_FREQUENT')
resourceBar:RegisterEvent('UNIT_DISPLAYPOWER')
resourceBar:RegisterEvent('UPDATE_SHAPESHIFT_FORM')
resourceBar:RegisterEvent('UNIT_PET')
resourceBar:RegisterEvent('PET_ATTACK_START')
resourceBar:RegisterEvent('PET_ATTACK_STOP')
resourceBar:RegisterEvent('UNIT_AURA')
resourceBar:RegisterEvent('GROUP_ROSTER_UPDATE')
resourceBar:RegisterEvent('GROUP_JOINED')
resourceBar:RegisterEvent('GROUP_LEFT')
resourceBar:RegisterEvent('PLAYER_LOGIN')
resourceBar:RegisterEvent('UNIT_INVENTORY_CHANGED')
comboFrame:RegisterEvent('PLAYER_TARGET_CHANGED')

-- Register druid form resource bar for events
druidFormResourceBar:RegisterEvent('PLAYER_ENTERING_WORLD')
druidFormResourceBar:RegisterEvent('UNIT_POWER_FREQUENT')
druidFormResourceBar:RegisterEvent('UPDATE_SHAPESHIFT_FORM')

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
    elseif ShouldHideBuffs() then
      HideBuffs()
    elseif ShouldHideDebuffs() then
      HideDebuffs()
    end
    -- When buffBarOnResourceBar is false, do nothing - let other addons control the position
  end
end

resourceBar:SetScript('OnEvent', function(self, event, unit)
  if not GLOBAL_SETTINGS or not GLOBAL_SETTINGS.hidePlayerFrame or GLOBAL_SETTINGS.hideCustomResourceBar then
    resourceBar:Hide()
    comboFrame:Hide()
    petResourceBar:Hide()
    druidFormResourceBar:Hide()
    return
  end

  if event == 'PLAYER_LOGIN' and unit == 'Blizzard_BuffFrame' then
    HookBuffFrame()
    HandleBuffBarSettingChange()
  end

  if unit == 'player' or event == 'PLAYER_TARGET_CHANGED' then
    UpdateComboPoints()
  end

  if event == 'PLAYER_ENTERING_WORLD' then
    ApplyResourceBarLockState()
    HideComboPointsForNonUsers()
    UpdateResourcePoints()
    UpdatePetResourcePoints()
    UpdateDruidFormResourceBar()
    HandleBuffBarSettingChange()
    -- Load saved position after database is available
    C_Timer.After(0.1, function()
      LoadResourceBarPosition()
      LoadDruidFormResourceBarPosition()
    end)
  elseif event == 'UNIT_POWER_FREQUENT' then
    if unit == 'player' then
      UpdateResourcePoints()
      UpdateDruidFormResourceBar()
    elseif unit == 'pet' then
      UpdatePetResourcePoints()
    end
  elseif event == 'UNIT_DISPLAYPOWER' then
    if unit == 'player' then
      UpdateResourcePoints()
      UpdateDruidShiftResourcePoints()
    end
  elseif event == 'UPDATE_SHAPESHIFT_FORM' then
    -- Update resource bar and combo points when shapeshifting
    UpdateResourcePoints()
    UpdateDruidFormResourceBar()
    HideComboPointsForNonUsers()
    UpdateComboPoints()
    UpdateDruidShiftResourcePoints()
  elseif event == 'UNIT_PET' then
    -- Pet summoned or dismissed
    UpdatePetResourcePoints()
  elseif event == 'PET_ATTACK_START' or event == 'PET_ATTACK_STOP' then
    -- Update pet resource when pet starts/stops attacking
    UpdatePetResourcePoints()
  elseif unit == 'player' and event == 'UNIT_AURA'
          or event == 'GROUP_ROSTER_UPDATE'
          or event == 'GROUP_JOINED'
          or event == 'GROUP_LEFT' then
    CenterPlayerBuffBar()
  elseif unit == 'player' and event == 'UNIT_INVENTORY_CHANGED' then
    -- This event triggers based on inventory items changing so it needs a small delay
    -- or the normal buffs end up in the BuffFrame instead of the custom frame.
    C_Timer.After(0.1, function()
      CenterPlayerBuffBar()
    end)
  end
end)

-- Event handler for druid form resource bar
druidFormResourceBar:SetScript('OnEvent', function(self, event, unit)
  if event == 'PLAYER_ENTERING_WORLD' then
    UpdateDruidFormResourceBar()
    C_Timer.After(0.1, function()
      LoadDruidFormResourceBarPosition()
    end)
  elseif event == 'UNIT_POWER_FREQUENT' and unit == 'player' then
    UpdateDruidFormResourceBar()
  elseif event == 'UPDATE_SHAPESHIFT_FORM' then
    UpdateDruidFormResourceBar()
  end
end)

-- Make the buff bar setting change handler globally accessible
_G.UltraHardcoreHandleBuffBarSettingChange = HandleBuffBarSettingChange

ApplyResourceBarLockState()

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

-- Reset druid form resource bar position function
local function ResetDruidFormResourceBarPosition()
  -- Clear existing points first
  druidFormResourceBar:ClearAllPoints()
  -- Anchor to the main resource bar, matching the pet bar
  druidFormResourceBar:SetPoint('TOP', resourceBar, 'BOTTOM', 0, -5)
end

-- Slash command to reset resource bar position
SLASH_RESETRESOURCEBAR1 = '/resetresourcebar'
SLASH_RESETRESOURCEBAR2 = '/rrb'
SlashCmdList['RESETRESOURCEBAR'] = ResetResourceBarPosition

-- Slash command to reset druid form resource bar position
SLASH_RESETDRUIDFORMRESOURCEBAR1 = '/resetdruidformresourcebar'
SLASH_RESETDRUIDFORMRESOURCEBAR2 = '/rrdb'
SlashCmdList['RESETDRUIDFORMRESOURCEBAR'] = ResetDruidFormResourceBarPosition
