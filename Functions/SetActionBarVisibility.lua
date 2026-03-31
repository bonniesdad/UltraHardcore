--[[
  Action Bar Visibility Controller
  - Hides action bars when not resting (or below level threshold)
  - Shows them when resting or under Cozy Fire (spell ID 7353)
]]

-- with lvl6, hide bars and show popup to explain how to get to them
MIN_LEVEL_HIDE_ACTION_BARS = 6

-- all frames to hide
ACTIOBAR_FRAMES_TO_HIDE = { -- Classic Frames
MainMenuBar, MultiBarBottomLeft, MultiBarBottomRight, MultiBarLeft, MultiBarRight, PetActionBar, StanceBar, MicroMenu, MainActionBar, BagsBar, MainStatusTrackingBarContainer, MultiBar5, MultiBar6, MultiBar7 } -- TBC Frames

-- TBC-only: remember which Blizzard UI elements were enabled/visible before Ultra hides them,
-- so when we "show bars" in rested areas we don't force-show bars the user has hidden via
-- Blizzard options (e.g. edit mode / hide bar art).
local tbcBlizzVisibilitySnapshot = {}
local function IsTBCClient()
  return type(IsTBC) == 'function' and IsTBC()
end

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
  if IsTBCClient() then
    for _, frame in ipairs(ACTIOBAR_FRAMES_TO_HIDE) do
      if frame and frame.IsShown then
        -- Snapshot what the Blizzard UI is currently showing (before we hide everything).
        tbcBlizzVisibilitySnapshot[frame] = frame:IsShown() == true
      end
    end
    -- Mark initialized here because this snapshot is taken from the true Blizzard state
    -- (before Ultra hides frames). If we don't, ShowActionBars() can overwrite the snapshot
    -- while everything is hidden, causing bars to never reappear.
    tbcBlizzVisibilitySnapshot._initialized = true
  end

  for _, frame in ipairs(ACTIOBAR_FRAMES_TO_HIDE) do
    -- Force Hide will unregister to avoid protected function errors
    ForceHideFrame(frame)
  end
end

function ShowActionBars()
  if IsTBCClient() then
    -- If we haven't taken a snapshot yet (e.g. login while resting), take one now.
    -- In that case the bars are still in their Blizzard-configured state.
    if not tbcBlizzVisibilitySnapshot._initialized then
      for _, frame in ipairs(ACTIOBAR_FRAMES_TO_HIDE) do
        if frame and frame.IsShown then
          tbcBlizzVisibilitySnapshot[frame] = frame:IsShown() == true
        end
      end
      tbcBlizzVisibilitySnapshot._initialized = true
    end

    for _, frame in ipairs(ACTIOBAR_FRAMES_TO_HIDE) do
      if frame then
        -- Restore parent first (so Hide() doesn't leave it under UltraHiddenParent).
        RestoreAndShowFrame(frame)
        -- Then respect Blizzard's visibility choice.
        local shouldShow = tbcBlizzVisibilitySnapshot[frame]
        if shouldShow == false and frame.Hide then
          frame:Hide()
        end
      end
    end
    return
  end

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
f:RegisterEvent('PLAYER_LOGIN') -- ensure state correct on reload/login (after UI is available)
f:SetScript('OnEvent', function(self, event, ...)
  if event == 'UNIT_AURA' then
    OnPlayerUnitAuraEvent(self, ...)
  elseif event == 'PLAYER_REGEN_DISABLED' or event == 'PLAYER_REGEN_ENABLED' then
    SetActionBarVisibility(GLOBAL_SETTINGS.hideActionBars)
  elseif event == 'PLAYER_LOGIN' then
    -- Small delay to let UltraHardcore's PLAYER_LOGIN handler load DB/settings first.
    if C_Timer and C_Timer.After then
      C_Timer.After(0.1, function()
        if IsTBCClient() then
          -- TBC: briefly show bars on login/reload, then apply the normal visibility rules.
          -- This helps users quickly access bars after /reload or logging in.
          ShowActionBars()
          C_Timer.After(1, function()
            SetActionBarVisibility(GLOBAL_SETTINGS.hideActionBars or false)
          end)
        else
          SetActionBarVisibility(GLOBAL_SETTINGS.hideActionBars or false)
        end
      end)
    else
      -- Fallback: apply immediately
      SetActionBarVisibility(GLOBAL_SETTINGS.hideActionBars or false)
    end
  elseif event == 'PLAYER_CONTROL_GAINED' or event == 'PLAYER_CONTROL_LOST' then
    -- We need a slight delay after getting on a taxi before UnitOnTaxi will return true
    if C_Timer and C_Timer.After then
      C_Timer.After(0.2, function()
        SetActionBarVisibility(GLOBAL_SETTINGS.hideActionBars)
      end)
    end
  end
end)
