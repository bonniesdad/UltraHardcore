local overlayFrame = nil
local overlayEnabled = false
local characterFrameHooked = false
local manaPowerType = (Enum and Enum.PowerType and Enum.PowerType.Mana) or 0

local overlayEventFrame = CreateFrame('Frame')
overlayEventFrame:RegisterEvent('PLAYER_ENTERING_WORLD')
overlayEventFrame:RegisterEvent('ADDON_LOADED')

local function getVitalsOverlayYOffset()
  -- TBC UI sits slightly differently; move the overlay up a bit only on TBC clients.
  if type(IsTBC) == 'function' and IsTBC() then
    return 15
  end
  return 0
end

local resourceEvents = {
  UNIT_MAXHEALTH = true,
  UNIT_MAXPOWER = true,
  UNIT_DISPLAYPOWER = true,
  PLAYER_LEVEL_UP = true,
  PLAYER_EQUIPMENT_CHANGED = true,
  PLAYER_TALENT_UPDATE = true,
  UPDATE_SHAPESHIFT_FORM = true,
  UNIT_PET = true, -- respond when pet is summoned/desummoned
}

local function formatValue(number)
  if type(formatNumberWithCommas) == 'function' then
    return formatNumberWithCommas(number or 0)
  end
  return tostring(number or 0)
end

local function updateOverlayText()
  if not overlayFrame or not overlayFrame.healthText then return end

  -- Player max health
  local maxHealth = UnitHealthMax('player') or 0
  overlayFrame.healthText:SetText(formatValue(maxHealth))

  -- Player power resource (mana/rage/energy)
  if overlayFrame.manaText then
    local powerType = UnitPowerType('player')
    if powerType == 0 then -- Mana
      local maxMana = UnitPowerMax('player', 0) or 0
      overlayFrame.manaText:SetText(formatValue(maxMana))
      overlayFrame.manaText:SetTextColor(0, 0.78, 1) -- Blue
      overlayFrame.manaText:Show()
      overlayFrame.manaIcon:SetTexture('Interface\\AddOns\\UltraHardcore\\Textures\\mana64.png')
      overlayFrame.manaIcon:Show()
    elseif powerType == 1 then -- Rage
      local maxRage = UnitPowerMax('player', 1) or 0
      overlayFrame.manaText:SetText(formatValue(maxRage))
      overlayFrame.manaText:SetTextColor(1, 0.18, 0.18) -- Red
      overlayFrame.manaText:Show()
      overlayFrame.manaIcon:SetTexture('Interface\\AddOns\\UltraHardcore\\Textures\\rage64.png')
      overlayFrame.manaIcon:Show()
    elseif powerType == 3 then -- Energy
      local maxEnergy = UnitPowerMax('player', 3) or 0
      overlayFrame.manaText:SetText(formatValue(maxEnergy))
      overlayFrame.manaText:SetTextColor(0.98, 1, 0) -- Yellow
      overlayFrame.manaText:Show()
      overlayFrame.manaIcon:SetTexture('Interface\\AddOns\\UltraHardcore\\Textures\\energy64.png')
      overlayFrame.manaIcon:Show()
    else
      overlayFrame.manaText:Hide()
      overlayFrame.manaIcon:Hide()
    end
  end

  -- Pet: update its max health and max power (parented to PetFrame or fallback)
  if overlayFrame.petHealthText and overlayFrame.petManaText and overlayFrame._petParent then
    local petParent = overlayFrame._petParent
    if overlayEnabled and UnitExists('pet') and petParent:IsShown() then
      -- pet max health
      local petMaxHealth = UnitHealthMax('pet') or 0
      overlayFrame.petHealthText:SetText(formatValue(petMaxHealth))
      overlayFrame.petHealthText:Show()
      overlayFrame.petHealthIcon:Show()

      -- pet power type and max
      local petPowerType = UnitPowerType('pet')
      if petPowerType == 0 then -- Mana
        local petMaxMana = UnitPowerMax('pet', 0) or 0
        overlayFrame.petManaText:SetText(formatValue(petMaxMana))
        overlayFrame.petManaText:SetTextColor(0, 0.78, 1)
        overlayFrame.petManaIcon:SetTexture(
          'Interface\\AddOns\\UltraHardcore\\Textures\\mana64.png'
        )
        overlayFrame.petManaText:Show()
        overlayFrame.petManaIcon:Show()
      elseif petPowerType == 1 then -- Rage
        local petMaxRage = UnitPowerMax('pet', 1) or 0
        overlayFrame.petManaText:Hide()
        overlayFrame.petManaIcon:Hide()
      elseif petPowerType == 2 then -- Focus
        overlayFrame.petManaText:Hide()
        overlayFrame.petManaIcon:Hide()
      elseif petPowerType == 3 then -- Energy
        local petMaxEnergy = UnitPowerMax('pet', 3) or 0
        overlayFrame.petManaText:Hide()
        overlayFrame.petManaIcon:Hide()
      else
        -- fallback for Focus/other power types
        local petMaxPower = UnitPowerMax('pet') or 0
        if petMaxPower and petMaxPower > 0 then
          overlayFrame.petManaText:Hide()
          overlayFrame.petManaIcon:Hide()
        else
          overlayFrame.petManaText:Hide()
          overlayFrame.petManaIcon:Hide()
        end
      end
    else
      -- hide pet overlays when no pet or pet frame hidden
      overlayFrame.petHealthText:Hide()
      overlayFrame.petHealthIcon:Hide()
      overlayFrame.petManaText:Hide()
      overlayFrame.petManaIcon:Hide()
    end
  end
end

local function updateOverlayVisibility()
  if not overlayFrame or not overlayFrame.healthText then return end

  -- Player overlays remain tied to CharacterFrame visibility
  if overlayEnabled and CharacterFrame and CharacterFrame:IsShown() then
    overlayFrame.healthText:Show()
    overlayFrame.healthIcon:Show()
    overlayFrame.manaText:Show() -- text visibility may be corrected in updateOverlayText
    overlayFrame.manaIcon:Show()
  else
    overlayFrame.healthText:Hide()
    overlayFrame.healthIcon:Hide()
    if overlayFrame.manaText then
      overlayFrame.manaText:Hide()
      overlayFrame.manaIcon:Hide()
    end
  end

  -- Pet overlays: show only if pet exists and the pet parent frame is shown
  if overlayFrame.petHealthText and overlayFrame.petManaText and overlayFrame._petParent then
    local petParent = overlayFrame._petParent
    if overlayEnabled and UnitExists('pet') and petParent:IsShown() then
      -- updateOverlayText will show the actual pet elements
      updateOverlayText()
    else
      overlayFrame.petHealthText:Hide()
      overlayFrame.petHealthIcon:Hide()
      overlayFrame.petManaText:Hide()
      overlayFrame.petManaIcon:Hide()
    end
  end
end

local function hookCharacterFrame()
  if characterFrameHooked or not CharacterFrame then return end

  CharacterFrame:HookScript('OnShow', function()
    updateOverlayVisibility()
  end)

  CharacterFrame:HookScript('OnHide', function()
    if overlayFrame then
      if overlayFrame.healthText then
        overlayFrame.healthText:Hide()
        overlayFrame.healthIcon:Hide()
      end
      if overlayFrame.manaText then
        overlayFrame.manaText:Hide()
        overlayFrame.manaIcon:Hide()
      end
    end
  end)

  characterFrameHooked = true
end

local function createOverlayFrame()
  if not CharacterFrame then return end

  local characterModelFrame = _G.CharacterModelFrame
  local playerParent = characterModelFrame or CharacterFrame
  local yOffset = getVitalsOverlayYOffset()

  -- Determine pet parent: prefer PetFrame, fallback to characterModelFrame then CharacterFrame
  local petModelFrame = _G.PetModelFrame
  local petParent = petModelFrame

  if overlayFrame then
    -- If switching from using fallback parent references, reparent player elements if needed
    if characterModelFrame and overlayFrame.__usesFallbackParent then
      if overlayFrame.healthText then
        overlayFrame.healthText:SetParent(characterModelFrame)
        overlayFrame.healthText:ClearAllPoints()
        overlayFrame.healthText:SetPoint(
          'BOTTOMLEFT',
          characterModelFrame,
          'BOTTOMLEFT',
          20,
          34 + yOffset
        )
        overlayFrame.healthIcon:SetParent(characterModelFrame)
        overlayFrame.healthIcon:ClearAllPoints()
        overlayFrame.healthIcon:SetPoint(
          'BOTTOMLEFT',
          characterModelFrame,
          'BOTTOMLEFT',
          6,
          34 + yOffset
        )
      end

      if overlayFrame.manaText then
        overlayFrame.manaText:SetParent(characterModelFrame)
        overlayFrame.manaText:ClearAllPoints()
        overlayFrame.manaText:SetPoint(
          'BOTTOMLEFT',
          characterModelFrame,
          'BOTTOMLEFT',
          20,
          18 + yOffset
        )
        overlayFrame.manaIcon:SetParent(characterModelFrame)
        overlayFrame.manaIcon:ClearAllPoints()
        overlayFrame.manaIcon:SetPoint(
          'BOTTOMLEFT',
          characterModelFrame,
          'BOTTOMLEFT',
          6,
          18 + yOffset
        )
      end

      if overlayFrame.petHealthText then
        overlayFrame.petHealthText:SetParent(petModelFrame)
        overlayFrame.petHealthText:ClearAllPoints()
        -- position similar to before but relative to petParent
        overlayFrame.petHealthText:SetPoint('BOTTOMLEFT', petModelFrame, 'BOTTOMLEFT', 20, 6)
        overlayFrame.petHealthIcon:SetParent(petModelFrame)
        overlayFrame.petHealthIcon:ClearAllPoints()
        overlayFrame.petHealthIcon:SetPoint('BOTTOMLEFT', petModelFrame, 'BOTTOMLEFT', 6, 6)
      end

      if overlayFrame.petManaText then
        overlayFrame.petManaText:SetParent(petModelFrame)
        overlayFrame.petManaText:ClearAllPoints()
        overlayFrame.petManaText:SetPoint('BOTTOMLEFT', petModelFrame, 'BOTTOMLEFT', 20, -10)
        overlayFrame.petManaIcon:SetParent(petModelFrame)
        overlayFrame.petManaIcon:ClearAllPoints()
        overlayFrame.petManaIcon:SetPoint('BOTTOMLEFT', petModelFrame, 'BOTTOMLEFT', 6, -10)
      end
    end
    return
  end

  -- Create container frame for player elements
  overlayFrame = CreateFrame('Frame', 'UltraVitalsOverlay', playerParent)
  overlayFrame:SetSize(1, 1)
  overlayFrame:EnableMouse(false)
  overlayFrame.__usesFallbackParent = (playerParent ~= characterModelFrame)

  -- Player health icon + text (bottom-left)
  overlayFrame.healthIcon = playerParent:CreateTexture(nil, 'OVERLAY')
  overlayFrame.healthIcon:SetSize(12, 12)
  overlayFrame.healthIcon:SetPoint('BOTTOMLEFT', playerParent, 'BOTTOMLEFT', 6, 34 + yOffset)
  overlayFrame.healthIcon:SetTexture('Interface\\AddOns\\UltraHardcore\\Textures\\health64.png')
  overlayFrame.healthText = playerParent:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
  overlayFrame.healthText:SetPoint('BOTTOMLEFT', playerParent, 'BOTTOMLEFT', 20, 34 + yOffset)
  overlayFrame.healthText:SetJustifyH('LEFT')
  overlayFrame.healthText:SetJustifyV('BOTTOM')
  overlayFrame.healthText:SetTextColor(0.04, 0.84, 0.13)

  -- Player power icon + text (bottom-left under health)
  overlayFrame.manaIcon = playerParent:CreateTexture(nil, 'OVERLAY')
  overlayFrame.manaIcon:SetSize(12, 12)
  overlayFrame.manaIcon:SetPoint('BOTTOMLEFT', playerParent, 'BOTTOMLEFT', 6, 18 + yOffset)
  overlayFrame.manaIcon:SetTexture('Interface\\AddOns\\UltraHardcore\\Textures\\mana64.png')
  overlayFrame.manaText = playerParent:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
  overlayFrame.manaText:SetPoint('BOTTOMLEFT', playerParent, 'BOTTOMLEFT', 20, 18 + yOffset)
  overlayFrame.manaText:SetJustifyH('LEFT')
  overlayFrame.manaText:SetJustifyV('BOTTOM')
  overlayFrame.manaText:SetTextColor(0.5, 0.8, 1)

  -- Create pet elements parented to the actual pet frame (or fallback)
  overlayFrame._petParent = petParent

  -- Pet health icon + text (attached to petParent)
  overlayFrame.petHealthIcon = petParent:CreateTexture(nil, 'OVERLAY')
  overlayFrame.petHealthIcon:SetSize(12, 12)
  -- position at bottom-left area of pet frame (adjust as desired)
  overlayFrame.petHealthIcon:SetPoint('BOTTOMLEFT', petParent, 'BOTTOMLEFT', 50, 6)
  overlayFrame.petHealthIcon:SetTexture('Interface\\AddOns\\UltraHardcore\\Textures\\health64.png')
  overlayFrame.petHealthText = petParent:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
  overlayFrame.petHealthText:SetPoint('BOTTOMLEFT', petParent, 'BOTTOMLEFT', 64, 6)
  overlayFrame.petHealthText:SetJustifyH('LEFT')
  overlayFrame.petHealthText:SetJustifyV('BOTTOM')
  overlayFrame.petHealthText:SetTextColor(0.04, 0.84, 0.13)

  -- Pet power icon + text (below/under pet health)
  overlayFrame.petManaIcon = petParent:CreateTexture(nil, 'OVERLAY')
  overlayFrame.petManaIcon:SetSize(12, 12)
  overlayFrame.petManaIcon:SetPoint('BOTTOMRIGHT', petParent, 'BOTTOMRIGHT', -50, 6)
  overlayFrame.petManaIcon:SetTexture('Interface\\AddOns\\UltraHardcore\\Textures\\mana64.png')
  overlayFrame.petManaText = petParent:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
  overlayFrame.petManaText:SetPoint('BOTTOMRIGHT', petParent, 'BOTTOMRIGHT', -64, 6)
  overlayFrame.petManaText:SetJustifyH('LEFT')
  overlayFrame.petManaText:SetJustifyV('BOTTOM')
  overlayFrame.petManaText:SetTextColor(0.5, 0.8, 1)

  -- Initially hide everything until the overlay is enabled/frames shown
  overlayFrame.healthText:Hide()
  overlayFrame.healthIcon:Hide()
  overlayFrame.manaText:Hide()
  overlayFrame.manaIcon:Hide()
  overlayFrame.petHealthText:Hide()
  overlayFrame.petHealthIcon:Hide()
  overlayFrame.petManaText:Hide()
  overlayFrame.petManaIcon:Hide()
end

local function tryInitializeOverlay()
  if not CharacterFrame then return end
  createOverlayFrame()
  hookCharacterFrame()
  updateOverlayVisibility()
end

local function updateEventRegistration()
  for eventName in pairs(resourceEvents) do
    if overlayEnabled then
      overlayEventFrame:RegisterEvent(eventName)
    else
      overlayEventFrame:UnregisterEvent(eventName)
    end
  end
end

overlayEventFrame:SetScript('OnEvent', function(_, event, ...)
  if event == 'ADDON_LOADED' then
    local addonName = ...
    if addonName == 'Blizzard_CharacterFrame' or addonName == 'UltraHardcore' then
      tryInitializeOverlay()
    end
    return
  elseif event == 'PLAYER_ENTERING_WORLD' then
    tryInitializeOverlay()
    return
  end

  if not overlayEnabled then return end

  if event == 'UNIT_MAXHEALTH' or event == 'UNIT_MAXPOWER' or event == 'UNIT_DISPLAYPOWER' or event == 'UNIT_PET' then
    local unit = ...
    if unit == 'player' or unit == 'pet' or unit == nil then
      updateOverlayText()
    end
  elseif event == 'PLAYER_LEVEL_UP' or event == 'PLAYER_EQUIPMENT_CHANGED' or event == 'PLAYER_TALENT_UPDATE' or event == 'UPDATE_SHAPESHIFT_FORM' then
    updateOverlayText()
  end
end)

function SetVitalsOverlayEnabled(shouldEnable)
  overlayEnabled = shouldEnable and true or false
  tryInitializeOverlay()
  updateEventRegistration()

  if not overlayEnabled then
    if overlayFrame then
      if overlayFrame.healthText then
        overlayFrame.healthText:Hide()
        overlayFrame.healthIcon:Hide()
      end
      if overlayFrame.manaText then
        overlayFrame.manaText:Hide()
        overlayFrame.manaIcon:Hide()
      end
      if overlayFrame.petHealthText then
        overlayFrame.petHealthText:Hide()
        overlayFrame.petHealthIcon:Hide()
      end
      if overlayFrame.petManaText then
        overlayFrame.petManaText:Hide()
        overlayFrame.petManaIcon:Hide()
      end
    end
    return
  end

  updateOverlayVisibility()
  updateOverlayText()
end
