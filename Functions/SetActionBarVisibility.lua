--[[
  Action Bar Visibility Controller
  - Hides action bars when not resting (or below level threshold)
  - Shows them when resting or under Cozy Fire (spell ID 7353)
]]

-- with lvl6, hide bars and show popup to explain how to get to them
MIN_LEVEL_HIDE_ACTION_BARS = 6

-- all frames to hide
ACTIOBAR_FRAMES_TO_HIDE =
  { MainMenuBar, MultiBarBottomLeft, MultiBarBottomRight, MultiBarLeft, MultiBarRight }

--[[
  Main functions
]]
function SetActionBarVisibility(hideActionBars, playerLevel)
  if playerLevel == nil then
    playerLevel = UnitLevel('player')
  end

  if hideActionBars and playerLevel >= MIN_LEVEL_HIDE_ACTION_BARS then
    local inCombat = UnitAffectingCombat('player') == true
    if (IsResting() or HasCozyFire() or UnitOnTaxi('player') or UnitIsDead(
      'player'
    )) and not inCombat then
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
    text = 'Congratulations! You have reached level ' .. MIN_LEVEL_HIDE_ACTION_BARS .. '!\n\nYour action bars will now be hidden. Visit an inn or travel to a capital to change them.',
    button1 = 'I Understand',
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

function OnPlayerLevelUpEvent(self, event, newLevel)
  SetActionBarVisibility(GLOBAL_SETTINGS.hideActionBars, newLevel)
  if GLOBAL_SETTINGS.hideActionBars and newLevel == MIN_LEVEL_HIDE_ACTION_BARS then
    ShowHideActionBarsIntro()
  end
end

local function OnPlayerUnitAuraEvent(self, unit)
  if unit == 'player' then
    SetActionBarVisibility(GLOBAL_SETTINGS.hideActionBars)
  end
end

-- Self-contained event registration (only for events not handled by main addon)
local f = CreateFrame('Frame')
f:RegisterEvent('UNIT_AURA')
f:RegisterEvent('PLAYER_REGEN_DISABLED') -- entering combat
f:RegisterEvent('PLAYER_REGEN_ENABLED') -- leaving combat
f:RegisterEvent('PLAYER_CONTROL_LOST') -- starting taxi/control loss
f:RegisterEvent('PLAYER_CONTROL_GAINED') -- ending taxi/control gain
f:RegisterEvent('PLAYER_ENTERING_WORLD') -- ensure state correct on reload/login
f:SetScript('OnEvent', function(self, event, ...)
  if event == 'UNIT_AURA' then
    OnPlayerUnitAuraEvent(self, ...)
  elseif event == 'PLAYER_REGEN_DISABLED' or event == 'PLAYER_REGEN_ENABLED' then
    -- Defer action bar visibility changes when entering/leaving combat to avoid protected frame errors
    if C_Timer and C_Timer.After then
      C_Timer.After(0.5, function()
        SetActionBarVisibility(GLOBAL_SETTINGS.hideActionBars)
      end)
    end
  elseif event == 'PLAYER_ENTERING_WORLD' then
    SetActionBarVisibility(GLOBAL_SETTINGS.hideActionBars)
  elseif event == 'PLAYER_CONTROL_GAINED' or event == 'PLAYER_CONTROL_LOST' then
    -- We need a slight delay after getting on a taxi before UnitOnTaxi will return true
    if C_Timer and C_Timer.After then
      C_Timer.After(0.2, function()
        SetActionBarVisibility(GLOBAL_SETTINGS.hideActionBars)
      end)
    end
  end
end)
