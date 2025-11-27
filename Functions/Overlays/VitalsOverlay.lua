local overlayFrame = nil
local overlayEnabled = false
local characterFrameHooked = false
local manaPowerType = (Enum and Enum.PowerType and Enum.PowerType.Mana) or 0

local overlayEventFrame = CreateFrame('Frame')
overlayEventFrame:RegisterEvent('PLAYER_ENTERING_WORLD')
overlayEventFrame:RegisterEvent('ADDON_LOADED')

local resourceEvents = {
  UNIT_MAXHEALTH = true,
  UNIT_MAXPOWER = true,
  UNIT_DISPLAYPOWER = true,
  PLAYER_LEVEL_UP = true,
  PLAYER_EQUIPMENT_CHANGED = true,
  PLAYER_TALENT_UPDATE = true,
  UPDATE_SHAPESHIFT_FORM = true,
}

local function formatValue(number)
  if type(formatNumberWithCommas) == 'function' then
    return formatNumberWithCommas(number or 0)
  end
  return tostring(number or 0)
end

local function updateOverlayText()
  if not overlayFrame or not overlayFrame.healthText then return end

  local maxHealth = UnitHealthMax('player') or 0
  overlayFrame.healthText:SetText(formatValue(maxHealth))

  -- Show power resource (mana, rage, or energy) based on power type
  if overlayFrame.manaText then
    local powerType = UnitPowerType('player')
    if powerType == 0 then -- 0 = Mana
      local maxMana = UnitPowerMax('player', 0) or 0
      overlayFrame.manaText:SetText(formatValue(maxMana))
      overlayFrame.manaText:SetTextColor(0, 0.78, 1) -- Blue for mana
      overlayFrame.manaText:Show()
	  overlayFrame.manaIcon:SetTexture("Interface\\AddOns\\UltraHardcore\\Textures\\mana64.png")
    elseif powerType == 1 then -- 1 = Rage
      local maxRage = UnitPowerMax('player', 1) or 0
      overlayFrame.manaText:SetText(formatValue(maxRage))
      overlayFrame.manaText:SetTextColor(1, 0.18, 0.18) -- Red for rage
      overlayFrame.manaText:Show()
	  overlayFrame.manaIcon:SetTexture("Interface\\AddOns\\UltraHardcore\\Textures\\rage64.png")
    elseif powerType == 3 then -- 3 = Energy
      local maxEnergy = UnitPowerMax('player', 3) or 0
      overlayFrame.manaText:SetText(formatValue(maxEnergy))
      overlayFrame.manaText:SetTextColor(0.98, 1, 0) -- Yellow for energy
      overlayFrame.manaText:Show()
	  overlayFrame.manaIcon:SetTexture("Interface\\AddOns\\UltraHardcore\\Textures\\energy64.png")
    else
      overlayFrame.manaText:Hide()
    end
  end
end

local function updateOverlayVisibility()
  if not overlayFrame or not overlayFrame.healthText then return end

  if overlayEnabled and CharacterFrame and CharacterFrame:IsShown() then
    overlayFrame.healthText:Show()
    updateOverlayText() -- This will handle showing/hiding power resource (mana/rage/energy) based on power type
  else
    overlayFrame.healthText:Hide()
    if overlayFrame.manaText then
      overlayFrame.manaText:Hide()
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
      end
      if overlayFrame.manaText then
        overlayFrame.manaText:Hide()
      end
    end
  end)

  characterFrameHooked = true
end

local function createOverlayFrame()
  if not CharacterFrame then return end

  local characterModelFrame = _G.CharacterModelFrame
  local parentFrame = characterModelFrame or CharacterFrame

  if overlayFrame then
    if characterModelFrame and overlayFrame.__usesFallbackParent then
      -- Reposition health text to bottom left
      if overlayFrame.healthText then
        overlayFrame.healthText:SetParent(characterModelFrame)
        overlayFrame.healthText:ClearAllPoints()
        overlayFrame.healthText:SetPoint('BOTTOMLEFT', characterModelFrame, 'BOTTOMLEFT', 6, 34)
      end
      
      -- Reposition power resource text (mana/rage/energy) to bottom right
      if overlayFrame.manaText then
        overlayFrame.manaText:SetParent(characterModelFrame)
        overlayFrame.manaText:ClearAllPoints()
        overlayFrame.manaText:SetPoint('BOTTOMLEFT', characterModelFrame, 'BOTTOMLEFT', 6, 18)
      end
      
      overlayFrame.__usesFallbackParent = false
    end
    return
  end

  -- Create a container frame (for organization, but text will be positioned independently)
  overlayFrame = CreateFrame('Frame', 'UHCVitalsOverlay', parentFrame)
  overlayFrame:SetSize(1, 1) -- Minimal size since we're positioning text directly
  overlayFrame:EnableMouse(false)
  overlayFrame.__usesFallbackParent = (parentFrame ~= characterModelFrame)

  -- Health text in bottom left
  overlayFrame.healthIcon = parentFrame:CreateTexture(nil, 'OVERLAY')
  overlayFrame.healthIcon:SetSize(12, 12)
  overlayFrame.healthIcon:SetPoint('BOTTOMLEFT', parentFrame, 'BOTTOMLEFT', 6, 34)
  overlayFrame.healthIcon:SetTexture("Interface\\AddOns\\UltraHardcore\\Textures\\health64.png")
  overlayFrame.healthText = parentFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
  overlayFrame.healthText:SetPoint('BOTTOMLEFT', parentFrame, 'BOTTOMLEFT', 20, 34)
  overlayFrame.healthText:SetJustifyH('LEFT')
  overlayFrame.healthText:SetJustifyV('BOTTOM')
  overlayFrame.healthText:SetTextColor(0.04, 0.84, 0.13)
  -- FontStrings inherit frame strata/level from their parent frame

  -- Power resource text (mana/rage/energy) in bottom right
  overlayFrame.manaIcon = parentFrame:CreateTexture(nil, 'OVERLAY')
  overlayFrame.manaIcon:SetSize(12, 12)
  overlayFrame.manaIcon:SetPoint('BOTTOMLEFT', parentFrame, 'BOTTOMLEFT', 6, 18)
  overlayFrame.manaIcon:SetTexture("Interface\\AddOns\\UltraHardcore\\Textures\\mana64.png")
  overlayFrame.manaText = parentFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
  overlayFrame.manaText:SetPoint('BOTTOMLEFT', parentFrame, 'BOTTOMLEFT', 20, 18)
  overlayFrame.manaText:SetJustifyH('RIGHT')
  overlayFrame.manaText:SetJustifyV('BOTTOM')
  overlayFrame.manaText:SetTextColor(0.5, 0.8, 1)
  -- FontStrings inherit frame strata/level from their parent frame

  overlayFrame.healthText:Hide()
  overlayFrame.manaText:Hide()
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

  if event == 'UNIT_MAXHEALTH' or event == 'UNIT_MAXPOWER' or event == 'UNIT_DISPLAYPOWER' then
    local unit = ...
    if unit == 'player' then
      updateOverlayText()
    end
  elseif
    event == 'PLAYER_LEVEL_UP' or event == 'PLAYER_EQUIPMENT_CHANGED' or event == 'PLAYER_TALENT_UPDATE' or event == 'UPDATE_SHAPESHIFT_FORM'
  then
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
    end
    return
  end

  updateOverlayVisibility()
end

