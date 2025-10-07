--[[ 
  Action Bar Visibility Controller
  - Hides action bars when not resting (or below level threshold)
  - Shows them when resting or under Cozy Fire (spell ID 7353)
]]

-- with lvl6, hide bars and show popup to explain how to get to them
MIN_LEVEL_HIDE_ACTION_BARS = 6

-- all frames to hide
ACTIOBAR_FRAMES_TO_HIDE = {
  MainMenuBar,
  MultiBarBottomLeft,
  MultiBarBottomRight,
  MultiBarLeft,
  MultiBarRight,
}

--[[
  Main functions
]]
  
local function HasCozyFire()
  for i = 1, 40 do
    local name, _, _, _, _, _, _, _, _, spellId = UnitBuff("player", i)
    if not name then break end
    if spellId == 7353 or name == "Cozy Fire" then
      return true
    end
  end
  return false
end

function SetActionBarVisibility(hideActionBars, playerLevel)
  if playerLevel == nil then
    playerLevel = UnitLevel("player")
  end

  if hideActionBars and playerLevel >= MIN_LEVEL_HIDE_ACTION_BARS then
    local inCombat = UnitAffectingCombat("player") == true
    if (IsResting() or HasCozyFire()) and not inCombat then
      ShowActionBars()
    else
      HideActionBars()
    end
  end
end

function HideActionBars()
  for _, frame in ipairs(ACTIOBAR_FRAMES_TO_HIDE) do
    ForceHideFrame(frame)
  end
end

function ShowActionBars()
  for _, frame in ipairs(ACTIOBAR_FRAMES_TO_HIDE) do
    RestoreAndShowFrame(frame)
  end
end

function ShowHideActionBarsIntro()
  StaticPopupDialogs['ULTRA_HARDCORE_ACTION_BARS'] = {
    text = "Congratulations! You have reached level " .. MIN_LEVEL_HIDE_ACTION_BARS .. "!\n\nYour action bars will now be hidden. Visit an inn or travel to a capital to change them.",
    button1 = "I Understand",
    OnAccept = function()
      SetActionBarVisibility(GLOBAL_SETTINGS.hideActionBars, MIN_LEVEL_HIDE_ACTION_BARS)
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
  }
  StaticPopup_Show('ULTRA_HARDCORE_ACTION_BARS')
end

--[[
  Event handlers
]]

function OnPlayerUpdateRestingEvent(self)
  SetActionBarVisibility(GLOBAL_SETTINGS.hideActionBars)
end

function OnPlayerLevelUpEvent(self, _, playerLevel)
  SetActionBarVisibility(GLOBAL_SETTINGS.hideActionBars, playerLevel)
  if GLOBAL_SETTINGS.hideActionBars and playerLevel == MIN_LEVEL_HIDE_ACTION_BARS then
    ShowHideActionBarsIntro()
  end
end

local function OnPlayerUnitAuraEvent(self, unit)
  if unit == "player" then
    SetActionBarVisibility(GLOBAL_SETTINGS.hideActionBars)
  end
end

-- Self-contained event registration
local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")  -- ensure correct state on login/reload
f:RegisterEvent("PLAYER_UPDATE_RESTING")
f:RegisterEvent("PLAYER_LEVEL_UP")
f:RegisterEvent("UNIT_AURA")
f:RegisterEvent("PLAYER_REGEN_DISABLED") -- entering combat
f:RegisterEvent("PLAYER_REGEN_ENABLED")  -- leaving combat

f:SetScript("OnEvent", function(self, event, ...)
  if event == "PLAYER_ENTERING_WORLD" then
    SetActionBarVisibility(GLOBAL_SETTINGS.hideActionBars)
  elseif event == "PLAYER_UPDATE_RESTING" then
    OnPlayerUpdateRestingEvent(self, ...)
  elseif event == "PLAYER_LEVEL_UP" then
    OnPlayerLevelUpEvent(self, ...)
  elseif event == "UNIT_AURA" then
    OnPlayerUnitAuraEvent(self, ...)
  elseif event == "PLAYER_REGEN_DISABLED" or event == "PLAYER_REGEN_ENABLED" then
    SetActionBarVisibility(GLOBAL_SETTINGS.hideActionBars)
  end
end)