-- Display options for the guild leaderboard (embedded in the Leaderboard tab sync bar).

function InitializeGuildLeaderboardOptions(syncBar)
  if not syncBar or syncBar.guildLeaderboardOptionsInit then
    return
  end
  syncBar.guildLeaderboardOptionsInit = true

  local function getShowOnScreen()
    if not UltraHardcoreDB or UltraHardcoreDB.showOnScreenGuildLeaderboard == nil then
      return true
    end
    return UltraHardcoreDB.showOnScreenGuildLeaderboard ~= false
  end

  local showCheck = CreateFrame('CheckButton', nil, syncBar, 'UICheckButtonTemplate')
  showCheck:SetSize(24, 24)
  showCheck:SetPoint('BOTTOMLEFT', syncBar, 'BOTTOMLEFT', 4, -2)
  showCheck:SetChecked(getShowOnScreen())
  showCheck:SetScript('OnClick', function(btn)
    if not UltraHardcoreDB then
      return
    end
    local on = btn:GetChecked() and true or false
    UltraHardcoreDB.showOnScreenGuildLeaderboard = on
    if _G.UHC_ApplyMainScreenGuildLeaderboardVisibility then
      _G.UHC_ApplyMainScreenGuildLeaderboardVisibility()
    end
  end)
  showCheck:SetScript('OnEnter', function(self)
    GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
    GameTooltip:SetText('Show guild leaderboard on the main screen', 1, 1, 1)
    GameTooltip:Show()
  end)
  showCheck:SetScript('OnLeave', GameTooltip_Hide)

  local showLabel = syncBar:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
  showLabel:SetPoint('LEFT', showCheck, 'RIGHT', 0, 0)
  showLabel:SetText('On-screen panel')
  showLabel:SetTextColor(0.85, 0.82, 0.75)

  syncBar.optionsShowCheck = showCheck
end
