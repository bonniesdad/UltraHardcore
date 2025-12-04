local healthBarPosition = nil

local function SetStatusTextDisplay(setStatusTextDisplayToNone)
  if setStatusTextDisplayToNone then
    SetCVar('statusText', '0')
    SetCVar('statusTextDisplay', 'NONE')
  end
end

local function HideCharacterPanelText()
  -- Hide HP/mana text elements in character panel that overlap with our XP bars
  local textElementsToHide =
    {
      'PlayerFrameHealthBarText',
      'PlayerFrameManaBarText',
      'PetFrameHealthBarText',
      'PetFrameManaBarText',
    }

  for _, elementName in ipairs(textElementsToHide) do
    local element = _G[elementName]
    if element then
      element:SetAlpha(0)
    end
  end
end

local function HidePlayerFrameHealthMana()
  -- Store health bar position before hiding it
  if PlayerFrameHealthBar and not healthBarPosition then
    local point, relativeTo, relativePoint, xOfs, yOfs = PlayerFrameHealthBar:GetPoint()
    healthBarPosition = {
      point = point,
      relativeTo = relativeTo,
      relativePoint = relativePoint,
      xOfs = xOfs,
      yOfs = yOfs,
      width = PlayerFrameHealthBar:GetWidth(),
      height = PlayerFrameHealthBar:GetHeight(),
    }
  end

  -- No need to store pet frame positions since we are not creating a replacement

  -- Hide player health and mana bars
  if PlayerFrameHealthBar then
    PlayerFrameHealthBar:SetAlpha(0)
  end
  if PlayerFrameManaBar then
    PlayerFrameManaBar:SetAlpha(0)
  end

  -- Hide player frame texture and background
  if PlayerFrameTexture then
    PlayerFrameTexture:SetAlpha(0)
  end
  if PlayerFrameBackground then
    PlayerFrameBackground:SetAlpha(0)
  end

  -- Hide player level text
  if PlayerLevelText then
    PlayerLevelText:SetAlpha(0)
  end

  -- Hide player and pet names on the player frame
  if PlayerName then
    PlayerName:SetAlpha(0)
  end
  if PetName then
    PetName:SetAlpha(0)
  end

  -- Hide player status texture (resting/combat overlay)
  if PlayerStatusTexture then
    ForceHideFrame(PlayerStatusTexture)
  end

  -- Hide pet health and mana bars
  if PetFrameHealthBar then
    PetFrameHealthBar:SetAlpha(0)
  end
  if PetFrameManaBar then
    PetFrameManaBar:SetAlpha(0)
  end

  -- Hide pet frame texture and background
  if PetFrameTexture then
    PetFrameTexture:SetAlpha(0)
  end
  if PetFrameBackground then
    PetFrameBackground:SetAlpha(0)
  end

  -- Hide pet attack mode texture
  if PetAttackModeTexture then
    PetAttackModeTexture:SetAlpha(0)
  end

  -- Keep main XP bar normal (no modifications)

  -- Hide HP/mana text in character panel that overlaps with our XP bars
  HideCharacterPanelText()
end

local function ShowCharacterPanelText()
  -- Show HP/mana text elements in character panel
  local textElementsToShow =
    {
      'PlayerFrameHealthBarText',
      'PlayerFrameManaBarText',
      'PetFrameHealthBarText',
      'PetFrameManaBarText',
    }

  for _, elementName in ipairs(textElementsToShow) do
    local element = _G[elementName]
    if element then
      RestoreAndShowFrame(element)
    end
  end
end

local function ShowPlayerFrameHealthMana()
  -- Show player health bar
  if PlayerFrameHealthBar then
    RestoreAndShowFrame(PlayerFrameHealthBar)
  end

  -- Restore player frame texture and background
  if PlayerFrameTexture then
    RestoreAndShowFrame(PlayerFrameTexture)
  end
  if PlayerFrameBackground then
    RestoreAndShowFrame(PlayerFrameBackground)
  end

  -- Restore player level text
  if PlayerLevelText then
    RestoreAndShowFrame(PlayerLevelText)
  end

  -- No XP bar replacement to manage

  -- Show pet health bar
  if PetFrameHealthBar then
    RestoreAndShowFrame(PetFrameHealthBar)
  end
  -- Show pet mana bar
  if PetFrameManaBar then
    RestoreAndShowFrame(PetFrameManaBar)
  end

  -- Restore pet frame texture and background
  if PetFrameTexture then
    RestoreAndShowFrame(PetFrameTexture)
  end
  if PetFrameBackground then
    RestoreAndShowFrame(PetFrameBackground)
  end

  -- Restore pet attack mode texture
  if PetAttackModeTexture then
    RestoreAndShowFrame(PetAttackModeTexture)
  end

  -- Keep main XP bar normal (no modifications needed)

  -- Show HP/mana text in character panel
  ShowCharacterPanelText()
end

function SetPlayerFrameDisplay(minimalFrameDisplay, completelyRemove)
  if minimalFrameDisplay then
    if completelyRemove then
      -- Completely hide the entire player frame
      CompletelyHidePlayerFrame()
    else
      HidePlayerFrameHealthMana()
    end
    -- Set Interface Status Text to None when hiding player frame
    SetStatusTextDisplay(true)
  else
    if completelyRemove then
      -- Completely restore the entire player frame
      CompletelyShowPlayerFrame()
      SetStatusTextDisplay(false)
    else
      ShowPlayerFrameHealthMana()
      -- Restore Interface Status Text when showing player frame
      SetStatusTextDisplay(false)
    end
  end
end

function DisablePetCombatText()
  -- Disable floating combat text over pet frame
  local petCombatTextElements =
    {
      'PetFrameHealthBarText',
      'PetFrameManaBarText',
      'PetFrameCombatText',
      'PetFrameFloatingCombatText',
    }

  for _, elementName in ipairs(petCombatTextElements) do
    local element = _G[elementName]
    if element then
      -- Set alpha to 0 to hide the text
      element:SetAlpha(0)
      -- Prevent the text from being shown
      element:Hide()
      -- Override the Show function to prevent it from appearing
      element.Show = function() end
    end
  end

  -- Disable combat feedback timing to prevent incoming pet damage text
  COMBATFEEDBACK_FADEINTIME = 0
  COMBATFEEDBACK_HOLDTIME = 0
  COMBATFEEDBACK_FADEOUTTIME = 0
end

function CompletelyHidePlayerFrame()
  -- Hide the entire PlayerFrame
  if PlayerFrame then
    ForceHideFrame(PlayerFrame)
  end

  -- Hide pet frame as well
  if PetFrame then
    ForceHideFrame(PetFrame)
  end
end

function CompletelyShowPlayerFrame()
  -- Show the entire PlayerFrame
  if PlayerFrame then
    RestoreAndShowFrame(PlayerFrame)
  end

  -- Show pet frame as well
  if PetFrame then
    RestoreAndShowFrame(PetFrame)
  end
end

function RepositionPetHappinessTexture()
  -- Move PetFrameHappinessTexture 50 pixels to the left
  local happinessTexture = PetFrameHappinessTexture
  if happinessTexture then
    -- Clear any existing points to avoid conflicts
    happinessTexture:ClearAllPoints()
    -- Position relative to PetFrame, 50 pixels to the left of its default position
    happinessTexture:SetPoint('CENTER', PetFrame, 'CENTER', -70, -5)
  end
end
