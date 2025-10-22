-- 🟢 X Found Mode Tab Content

-- Initialize X Found Mode when the tab is first shown
function InitializeXFoundModeTab()
  -- Check if tabContents[4] exists
  if not tabContents or not tabContents[4] then return end

  -- Check if already initialized to prevent duplicates
  if tabContents[4].initialized then return end

  -- Mark as initialized
  tabContents[4].initialized = true

  -- Create the "Coming Soon" message
  local comingSoonText = tabContents[4]:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  comingSoonText:SetPoint('CENTER', tabContents[4], 'CENTER', 0, 0)
  comingSoonText:SetText('Guild/Group Found Coming In Phase 2!')
  comingSoonText:SetFontObject('GameFontNormalLarge')
end
