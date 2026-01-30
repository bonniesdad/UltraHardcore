-- Statistics Tab Content - Redirect message (statistics moved to Ultra Statistics addon)

function InitializeStatisticsTab(tabContents)
  if not tabContents or not tabContents[1] then return end
  if tabContents[1].initialized then return end

  tabContents[1].initialized = true

  local container = CreateFrame('Frame', nil, tabContents[1])
  container:SetPoint('TOP', tabContents[1], 'TOP', 0, -55)
  container:SetPoint('LEFT', tabContents[1], 'LEFT', 10, 0)
  container:SetPoint('RIGHT', tabContents[1], 'RIGHT', -10, 0)
  container:SetHeight(200)

  local title = container:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
  title:SetPoint('TOP', container, 'TOP', 0, -20)
  title:SetText('Statistics have moved!')
  title:SetTextColor(0.9, 0.85, 0.75, 1)
  title:SetShadowOffset(1, -1)
  title:SetShadowColor(0, 0, 0, 0.8)

  local subtitle = container:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  subtitle:SetPoint('TOP', title, 'BOTTOM', 0, -12)
  subtitle:SetText('We have created a stand alone addon for all things statistics')
  subtitle:SetTextColor(0.8, 0.78, 0.72, 1)
  subtitle:SetShadowOffset(1, -1)
  subtitle:SetShadowColor(0, 0, 0, 0.6)

  local downloadRow = container:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  downloadRow:SetPoint('TOP', subtitle, 'BOTTOM', 0, -16)
  downloadRow:SetText('Download Ultra Statistics by BonniesDad')
  downloadRow:SetTextColor(0.6, 0.75, 1, 1)
  downloadRow:SetShadowOffset(1, -1)
  downloadRow:SetShadowColor(0, 0, 0, 0.6)

  -- No-op stubs so callers (TabManager, Settings) do not error
  _G.UpdateLowestHealthDisplay = function() end
  _G.UpdateXPBreakdown = function() end
end
