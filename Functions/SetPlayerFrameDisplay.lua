-- Variables to store XP bar elements
local xpBarFrame = nil
local xpBarTexture = nil
local xpBarText = nil
local healthBarPosition = nil

-- Variables to store main XP bar replacement
local mainXpBarFrame = nil
local mainXpBarTexture = nil
local mainXpBarText = nil

-- Variable to store original statusText setting
local originalStatusText = nil

function SetPlayerFrameDisplay(value)
  if value then
    HidePlayerFrameHealthMana()
    -- Set Interface Status Text to None when hiding player frame
    SetStatusTextDisplay(false)
  else
    ShowPlayerFrameHealthMana()
    -- Restore Interface Status Text when showing player frame
    SetStatusTextDisplay(true)
  end
end

function SetStatusTextDisplay(enable)
  if enable then
    -- Restore original statusText setting if we have it stored
    if originalStatusText then
      SetCVar("statusText", originalStatusText)
    end
  else
    -- Store current statusText setting before disabling it
    if not originalStatusText then
      originalStatusText = GetCVar("statusText")
    end
    -- Set statusText to None (0) to disable status text display
    SetCVar("statusText", "0")
  end
end

function HidePlayerFrameHealthMana()
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
      height = PlayerFrameHealthBar:GetHeight()
    }
  end
  
  -- No need to store pet frame positions since we are not creating a replacement
  
  -- Hide player health and mana bars
  if PlayerFrameHealthBar then
    ForceHideFrame(PlayerFrameHealthBar)
  end
  if PlayerFrameManaBar then
    ForceHideFrame(PlayerFrameManaBar)
  end
  
  -- Hide player frame texture and background
  if PlayerFrameTexture then
    ForceHideFrame(PlayerFrameTexture)
  end
  if PlayerFrameBackground then
    ForceHideFrame(PlayerFrameBackground)
  end

  -- Hide player level text
  if PlayerLevelText then
    ForceHideFrame(PlayerLevelText)
  end
  
  -- Hide player and pet names on the player frame
  if PlayerName then
    ForceHideFrame(PlayerName)
  end
  if PetName then
    ForceHideFrame(PetName)
  end
  
  -- Hide player status texture (resting/combat overlay)
  if PlayerStatusTexture then
    ForceHideFrame(PlayerStatusTexture)
  end
  
  -- Hide pet health and mana bars
  if PetFrameHealthBar then
    ForceHideFrame(PetFrameHealthBar)
  end
  if PetFrameManaBar then
    ForceHideFrame(PetFrameManaBar)
  end
  
  -- Hide pet frame texture and background
  if PetFrameTexture then
    ForceHideFrame(PetFrameTexture)
  end
  if PetFrameBackground then
    ForceHideFrame(PetFrameBackground)
  end
  
  -- Hide pet attack mode texture
  if PetAttackModeTexture then
    ForceHideFrame(PetAttackModeTexture)
  end
  
  -- Hide target frame health/mana bars
  if TargetFrameToT then
    ForceHideFrame(TargetFrameToT)
  end
  
  -- Keep main XP bar normal (no modifications)
  
  -- Hide HP/mana text in character panel that overlaps with our XP bars
  HideCharacterPanelText()
end


-- Removed player XP replacement logic and guild name text

-- Removed player XP/guild text updates

-- Removed pet XP bar logic

function HideCharacterPanelText()
  -- Hide HP/mana text elements in character panel that overlap with our XP bars
  local textElementsToHide = {
    "PlayerFrameHealthBarText",
    "PlayerFrameManaBarText", 
    "PetFrameHealthBarText",
    "PetFrameManaBarText"
  }
  
  for _, elementName in ipairs(textElementsToHide) do
    local element = _G[elementName]
    if element then
      ForceHideFrame(element)
    end
  end
end

function DisablePetCombatText()
  -- Disable floating combat text over pet frame
  local petCombatTextElements = {
    "PetFrameHealthBarText",
    "PetFrameManaBarText",
    "PetFrameCombatText",
    "PetFrameFloatingCombatText"
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
  
  -- Also disable combat text CVar for pets specifically
  if SetCVar then
    -- Disable floating combat text for pets
    SetCVar("floatingCombatTextCombatDamage", "0")
    SetCVar("floatingCombatTextCombatHealing", "0")
    SetCVar("floatingCombatTextCombatDamageAllAutos", "0")
    SetCVar("floatingCombatTextCombatHealingAllAutos", "0")
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

function ShowCharacterPanelText()
  -- Show HP/mana text elements in character panel
  local textElementsToShow = {
    "PlayerFrameHealthBarText",
    "PlayerFrameManaBarText", 
    "PetFrameHealthBarText",
    "PetFrameManaBarText"
  }
  
  for _, elementName in ipairs(textElementsToShow) do
    local element = _G[elementName]
    if element then
      RestoreAndShowFrame(element)
    end
  end
end

function ShowPlayerFrameHealthMana()
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
  
  -- Show target frame health/mana bars
  if TargetFrameToT then
    RestoreAndShowFrame(TargetFrameToT)
  end
  
  -- Keep main XP bar normal (no modifications needed)
  
  -- Show HP/mana text in character panel
  ShowCharacterPanelText()
end
