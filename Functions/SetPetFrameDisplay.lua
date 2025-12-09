-- All things Pet

local HIDEABLE_PET_ELEMENTS = {
  "PetFrameHealthBar",
  "PetFrameHealthBarText",
  "PetFrameHealthBarTextLeft",
  "PetFrameHealthBarTextRight",
  "PetFrameManaBar",
  "PetFrameManaBarText",
  "PetFrameManaBarTextLeft",
  "PetFrameManaBarTextRight",
  "PetFrameCombatText",
  "PetFrameFloatingCombatText",
  "PetName",
  "PetFrameTexture",
  "PetFrameBackground",
  "PetAttackModeTexture",
}

-- Optional: disable pet combat text
function DisablePetCombatText()
  local elements = {
    "PetFrameHealthBarText",
    "PetFrameManaBarText",
    "PetFrameCombatText",
    "PetFrameFloatingCombatText",
  }
  
  for _, name in ipairs(elements) do
    local e = _G[name]
    if e then
      e:SetAlpha(0)
      e:Hide()
      e.Show = function() end
    end
  end
  
  COMBATFEEDBACK_FADEINTIME = 0
  COMBATFEEDBACK_HOLDTIME = 0
  COMBATFEEDBACK_FADEOUTTIME = 0
end

-- Optional: reposition pet happiness
function RepositionPetHappiness()
  local tex = PetFrameHappinessTexture
  if tex and PetFrame then
    tex:ClearAllPoints()
    tex:SetPoint("CENTER", PetFrame, "CENTER", -70, -5)
  end
end

-- Reposition PetFrameHappinessTexture (combat-safe)
function RepositionPetHappinessTexture()
  local happinessTexture = PetFrameHappinessTexture
  if happinessTexture and PetFrame then
    happinessTexture:ClearAllPoints()
    -- Position relative to PetFrame, offset 50-70 pixels to the left, slightly down
    happinessTexture:SetPoint("CENTER", PetFrame, "CENTER", -70, -5)
  end
end

-- Hide pet frame pieces
if PetFrame then
  for _, name in ipairs(HIDEABLE_PET_ELEMENTS) do
    local f = _G[name]
    if f then
      f:SetAlpha(0)
    end
  end
end