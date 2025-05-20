--[[
  These functions is called when the player is resting and when the player is no longer resting.
  It will hide the action bars when the player is not resting and show them when the player is resting.
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
  Event handlers
]]

function OnPlayerUpdateRestingEvent(self, _, hideActionBars)
  SetActionBarVisibility(hideActionBars)
end

function OnPlayerLevelUpEvent(self, _, hideActionBars, playerLevel)
  SetActionBarVisibility(hideActionBars, playerLevel)

  if hideActionBars and playerLevel == MIN_LEVEL_HIDE_ACTION_BARS then
    ShowHideActionBarsIntro()
  end
end


--[[
  Main functions
]]

function SetActionBarVisibility(hideActionBars, playerLevel)
  if playerLevel == nil then
    playerLevel = UnitLevel("player")
  end

  if hideActionBars and playerLevel >= MIN_LEVEL_HIDE_ACTION_BARS then
    if IsResting() then
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
