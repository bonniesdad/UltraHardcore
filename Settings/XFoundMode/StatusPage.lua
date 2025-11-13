-- 🟢 X Found Mode - Status Page
-- Shows the player's current X Found status for non-level 1 players

local function CreateStatusPage(parentFrame)
  local statusPage = CreateFrame('Frame', nil, parentFrame)
  statusPage:SetAllPoints(parentFrame)
  statusPage:Hide()

  -- Title
  local titleText = statusPage:CreateFontString(nil, 'OVERLAY', 'GameFontNormalHuge')
  titleText:SetPoint('TOP', statusPage, 'TOP', 0, -60)
  titleText:SetText('Your X Found Status (BETA)')
  titleText:SetTextColor(1, 1, 0.5) -- Light yellow
  -- Status Frame
  local statusFrame = CreateFrame('Frame', nil, statusPage, 'BackdropTemplate')
  statusFrame:SetSize(450, 500)
  statusFrame:SetPoint('CENTER', statusPage, 'CENTER', 0, 0)

  statusFrame:SetBackdrop({
    bgFile = 'Interface\\DialogFrame\\UI-DialogBox-Background',
    edgeFile = 'Interface\\DialogFrame\\UI-DialogBox-Border',
    tile = true,
    tileSize = 64,
    edgeSize = 16,
    insets = {
      left = 4,
      right = 4,
      top = 4,
      bottom = 4,
    },
  })
  statusFrame:SetBackdropColor(0.1, 0.1, 0.1, 0.9)
  statusFrame:SetBackdropBorderColor(0.6, 0.6, 0.6, 1)

  -- Anchor the title inside the panel and ensure it renders above the backdrop
  titleText:SetParent(statusFrame)
  titleText:ClearAllPoints()
  titleText:SetPoint('TOP', statusFrame, 'TOP', 0, -12)
  if titleText.SetDrawLayer then
    titleText:SetDrawLayer('OVERLAY', 1)
  end
  -- Hide title on this view
  if titleText.Hide then titleText:Hide() end

  -- Current Mode Display
  local modeLabel = statusFrame:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
  modeLabel:SetPoint('TOPLEFT', statusFrame, 'TOPLEFT', 20, -20)
  modeLabel:SetText('Current Mode:')
  modeLabel:SetTextColor(1, 1, 1)

  local modeValue = statusFrame:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
  modeValue:SetPoint('LEFT', modeLabel, 'RIGHT', 10, 0)
  modeValue:SetText('None Selected')
  modeValue:SetTextColor(1, 0.8, 0) -- Orange
  -- Status Icon
  local statusIcon = statusFrame:CreateTexture(nil, 'OVERLAY')
  statusIcon:SetSize(32, 32)
  statusIcon:SetPoint('TOPRIGHT', statusFrame, 'TOPRIGHT', -20, -20)
  statusIcon:SetTexture('Interface\\Icons\\INV_Misc_QuestionMark')

  -- Restrictions List
  local restrictionsLabel = statusFrame:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
  restrictionsLabel:SetPoint('TOPLEFT', modeLabel, 'BOTTOMLEFT', 0, -20)
  restrictionsLabel:SetText('Current Restrictions:')
  restrictionsLabel:SetTextColor(1, 1, 1)

  local restrictionsText = statusFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  restrictionsText:SetPoint('TOPLEFT', restrictionsLabel, 'BOTTOMLEFT', 0, -16)
  restrictionsText:SetWidth(400)
  restrictionsText:SetText('No restrictions active. You can trade freely with all players.')
  restrictionsText:SetJustifyH('LEFT')
  restrictionsText:SetNonSpaceWrap(true)
  restrictionsText:SetTextColor(0.8, 0.8, 0.8)
  
  -- What still works (shown when not in Group Found to reduce empty space)
  local whatWorksLabel = statusFrame:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
  whatWorksLabel:SetPoint('TOPLEFT', restrictionsText, 'BOTTOMLEFT', 0, -20)
  whatWorksLabel:SetText('What still works:')
  whatWorksLabel:SetTextColor(0.8, 1, 0.8)
  whatWorksLabel:Hide()
  
  local whatWorksText = statusFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  whatWorksText:SetPoint('TOPLEFT', whatWorksLabel, 'BOTTOMLEFT', 0, -16)
  whatWorksText:SetWidth(400)
  whatWorksText:SetJustifyH('LEFT')
  whatWorksText:SetNonSpaceWrap(true)
  whatWorksText:SetTextColor(0.75, 0.9, 0.75)
  whatWorksText:Hide()
  
  -- Guild status line (only meaningful for Guild Found)
  local guildStatusText = statusFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
  -- Anchor directly below restrictions (whatWorks section is removed visually)
  guildStatusText:SetPoint('TOPLEFT', restrictionsText, 'BOTTOMLEFT', 0, -20)
  guildStatusText:SetWidth(400)
  guildStatusText:SetJustifyH('LEFT')
  guildStatusText:Hide()
  
  -- Stats block
  local statsLabel = statusFrame:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
  statsLabel:SetPoint('TOPLEFT', guildStatusText, 'BOTTOMLEFT', 0, -20)
  statsLabel:SetText('Stats:')
  statsLabel:SetTextColor(1, 1, 1)
  statsLabel:Hide()
  
  local statsText = statusFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  statsText:SetPoint('TOPLEFT', statsLabel, 'BOTTOMLEFT', 0, -16)
  statsText:SetWidth(400)
  statsText:SetJustifyH('LEFT')
  statsText:SetNonSpaceWrap(true)
  statsText:SetTextColor(0.8, 0.8, 0.8)
  statsText:Hide()

  -- Group Found Teammate Inputs (Only meaningful when Group Found is active)
  local groupSectionLabel = statusFrame:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
  -- Default anchor below stats; will be re-anchored dynamically when Group Found is active
  groupSectionLabel:SetPoint('TOPLEFT', statsText, 'BOTTOMLEFT', 0, -22)
  groupSectionLabel:SetText('Group Found Teammates: (Do not include yourself)')
  groupSectionLabel:SetTextColor(1, 1, 1)

  local editBoxes = {}
  local rowAnchors = {}
  local function CreateNameInput(index)
    local editBox = CreateFrame('EditBox', nil, statusFrame, 'InputBoxTemplate')
    editBox:SetSize(180, 24)
    local column = ((index - 1) % 2) + 1 -- 1 or 2
    local row = math.floor((index - 1) / 2) + 1 -- 1..4
    if not rowAnchors[row] then
      rowAnchors[row] = CreateFrame('Frame', nil, statusFrame)
      rowAnchors[row]:SetSize(1, 1)
      if row == 1 then
        rowAnchors[row]:SetPoint('TOPLEFT', groupSectionLabel, 'BOTTOMLEFT', 0, -18)
      else
        rowAnchors[row]:SetPoint('TOPLEFT', rowAnchors[row - 1], 'BOTTOMLEFT', 0, -36)
      end
    end
    if column == 1 then
      editBox:SetPoint('LEFT', rowAnchors[row], 'LEFT', 0, 0)
    else
      editBox:SetPoint('LEFT', rowAnchors[row], 'LEFT', 210, 0)
    end
    editBox:SetAutoFocus(false)
    editBox:SetMaxLetters(12)
    editBox:ClearFocus()
    return editBox
  end

  for i = 1, 10 do
    editBoxes[i] = CreateNameInput(i)
  end

  local saveNamesButton = CreateFrame('Button', nil, statusFrame, 'UIPanelButtonTemplate')
  saveNamesButton:SetSize(120, 24)
  saveNamesButton:SetPoint('TOPLEFT', rowAnchors[5], 'BOTTOMLEFT', 0, -20)
  saveNamesButton:SetText('Save Names')

  -- Auto-Fill button to populate from current party/raid
  local autofillButton = CreateFrame('Button', nil, statusFrame, 'UIPanelButtonTemplate')
  autofillButton:SetSize(120, 24)
  autofillButton:ClearAllPoints()
  autofillButton:SetPoint('TOPLEFT', saveNamesButton, 'BOTTOMLEFT', 0, -6)
  autofillButton:SetText('Auto-Fill Group')

  -- Description to the right of the Auto-Fill button
  local autofillDesc = statusFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
  autofillDesc:SetPoint('LEFT', autofillButton, 'RIGHT', 10, 0)
  autofillDesc:SetWidth(280)
  autofillDesc:SetJustifyH('LEFT')
  autofillDesc:SetText('Fill with your current party or raid members (excluding you) and save automatically.')
  autofillDesc:SetTextColor(0.9, 0.9, 0.9)

  local lockNote = statusFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
  lockNote:SetPoint('LEFT', saveNamesButton, 'RIGHT', 10, 0)
  lockNote:SetText('Editable at level 1. Locked from level 2.')
  lockNote:SetTextColor(1, 0.8, 0.2)

  -- Back Button (only for level 1 players)
  local backButton = CreateFrame('Button', nil, statusFrame, 'UIPanelButtonTemplate')
  backButton:SetSize(120, 32)
  backButton:SetPoint('BOTTOM', statusFrame, 'BOTTOM', 0, 14)
  backButton:SetText('Back')
  backButton:Hide() -- Hidden by default, will be shown for level 1 players
  local backBtnFS = backButton.GetFontString and backButton:GetFontString()
  if backBtnFS then
    backBtnFS:SetTextColor(1, 1, 0)
  end
  -- Ensure button draws above the panel backdrop
  backButton:SetFrameLevel(statusFrame:GetFrameLevel() + 2)

  -- Styled warning panel with icon and text
  local warningPanel = CreateFrame('Frame', nil, statusFrame, 'BackdropTemplate')
  warningPanel:SetSize(430, 56)
  warningPanel:SetPoint('BOTTOM', backButton, 'TOP', 15)
  warningPanel:SetBackdrop({
    bgFile = 'Interface\\Tooltips\\UI-Tooltip-Background',
    edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border',
    tile = true,
    tileSize = 16,
    edgeSize = 12,
    insets = { left = 6, right = 6, top = 6, bottom = 6 },
  })
  warningPanel:SetBackdropColor(0.08, 0.06, 0.02, 0.9)
  warningPanel:SetBackdropBorderColor(1, 0.8, 0.2, 1)
  warningPanel:SetFrameLevel(statusFrame:GetFrameLevel() + 1)

  local warningIcon = warningPanel:CreateTexture(nil, 'OVERLAY')
  warningIcon:SetSize(24, 24)
  warningIcon:SetPoint('LEFT', warningPanel, 'LEFT', 10, 0)
  warningIcon:SetTexture('Interface\\DialogFrame\\UI-Dialog-Icon-AlertNew')

  local warningText = warningPanel:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightLarge')
  warningText:ClearAllPoints()
  warningText:SetPoint('LEFT', warningIcon, 'RIGHT', 16, 0)
  warningText:SetPoint('RIGHT', warningPanel, 'RIGHT', -18, 0)
  warningText:SetWidth(380)
  warningText:SetText(
    'Note: X Found modes can only be selected at level 1. Your current mode is locked.'
  )
  warningText:SetJustifyH('LEFT')
  warningText:SetNonSpaceWrap(true)
  warningText:SetTextColor(1, 0.85, 0.2)
  if warningText.SetDrawLayer then
    warningText:SetDrawLayer('OVERLAY', 2)
  end
  
  -- Simple note used for post-level-1 (no alert box)
  local lockedNote = statusFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
  lockedNote:SetPoint('BOTTOM', statusFrame, 'BOTTOM', 0, 16)
  lockedNote:SetWidth(420)
  lockedNote:SetJustifyH('CENTER')
  lockedNote:SetNonSpaceWrap(true)
  lockedNote:SetText(
    'Note: X Found modes can only be selected at level 1. Your current mode is locked.'
  )
  lockedNote:SetTextColor(0.9, 0.9, 0.9)
  lockedNote:Hide()
  -- Back button click handler
  backButton:SetScript('OnClick', function()
    if XFoundModeManager and XFoundModeManager.ShowIntroPage then
      XFoundModeManager:ShowIntroPage()
    end
  end)

  -- Update function
  local function UpdateStatus()
    -- Get current player level
    local playerLevel = UnitLevel('player')

    -- Show/hide back button based on player level
    if playerLevel == 1 then
      backButton:Show()
      warningText:SetText('Note: You can still change your X Found mode selection at level 1.')
      warningText:SetTextColor(1, 0.95, 0.4) -- Bright yellow for level 1
      if warningPanel and warningPanel.SetBackdropBorderColor then
        warningPanel:SetBackdropBorderColor(1, 0.9, 0.3, 1)
      end
      if warningPanel and warningPanel.Show then warningPanel:Show() end
      if lockedNote and lockedNote.Hide then lockedNote:Hide() end
    else
      backButton:Hide()
      if warningPanel and warningPanel.Hide then warningPanel:Hide() end
      if lockedNote and lockedNote.Show then
        lockedNote:SetText('Note: X Found modes can only be selected at level 1. Your current mode is locked.')
        lockedNote:SetTextColor(0.9, 0.9, 0.9)
        lockedNote:Show()
      end
    end

    -- Get current X Found mode from settings
    local currentMode = 'None Selected'
    local currentIcon = 'Interface\\Icons\\INV_Misc_QuestionMark'
    local restrictions = 'No restrictions active. You can trade freely with all players.'
    local stats = 'Mode activated: Never\nTrades completed: 0\nRestrictions triggered: 0'
    local whatWorks = 'All normal gameplay functions are available.'
    local showGuildStatus = false
    local guildStatusLine = ''

    -- Check if guild found is enabled
    if GLOBAL_SETTINGS and GLOBAL_SETTINGS.guildSelfFound then
      currentMode = 'Guild Found'
      currentIcon = 'Interface\\Icons\\INV_Misc_Note_01'
      restrictions =
        'Trading and mail restricted to guild members only.\nAuction house is unavailable.'
      stats =
        'Mode activated: Level 1\nTrades completed: ' .. (CharacterStats and CharacterStats:GetStat(
          'guildTradesCompleted'
        ) or 0) .. '\nRestrictions triggered: ' .. (CharacterStats and CharacterStats:GetStat(
          'guildRestrictionsTriggered'
        ) or 0)
      whatWorks =
        '• Trading with guild members\n• Quest rewards and vendors\n• Crafting your own items\n• Partying with anyone (trade rules still apply)'
      showGuildStatus = true
      local gName = GetGuildInfo and GetGuildInfo('player')
      if gName then
        guildStatusLine = 'Current Guild: |cff00ff00' .. gName .. '|r'
      else
        guildStatusLine = '|cffff5555You are not in a guild.|r Join a guild to trade.'
      end
      -- Check if group found is enabled
    elseif GLOBAL_SETTINGS and GLOBAL_SETTINGS.groupSelfFound then
      currentMode = 'Group Found'
      currentIcon = 'Interface\\Icons\\INV_Misc_GroupLooking'
      restrictions =
        'Trading and mail restricted to manually selected players only.\nAuction house is unavailable.'
      stats =
        'Mode activated: Level 1\nTrades completed: ' .. (CharacterStats and CharacterStats:GetStat(
          'groupTradesCompleted'
        ) or 0) .. '\nRestrictions triggered: ' .. (CharacterStats and CharacterStats:GetStat(
          'groupRestrictionsTriggered'
        ) or 0)
      whatWorks =
        '• Trading with selected teammates\n• Quest rewards and vendors\n• Crafting your own items\n• Partying with anyone (trade rules still apply)'
    end

    -- Update display
    modeValue:SetText(currentMode)
    if currentMode == 'None Selected' then
      modeValue:SetTextColor(1, 0.8, 0) -- Orange
    else
      modeValue:SetTextColor(0.5, 1, 0.5) -- Green
    end
    statusIcon:SetTexture(currentIcon)
    restrictionsText:SetText(restrictions)
    
    -- Show/hide supplemental sections to reduce empty space
    local isGroup = GLOBAL_SETTINGS and GLOBAL_SETTINGS.groupSelfFound
    if isGroup then
      -- Hide all supplemental sections in Group Found for now
      guildStatusText:Hide()
      whatWorksLabel:Hide()
      whatWorksText:Hide()
      statsLabel:Hide()
      statsText:Hide()
      -- Ensure group section anchors directly under restrictions
      groupSectionLabel:ClearAllPoints()
      groupSectionLabel:SetPoint('TOPLEFT', restrictionsText, 'BOTTOMLEFT', 0, -20)
    else
      -- Show supplemental sections
      -- Remove "What still works" section entirely
      whatWorksLabel:Hide()
      whatWorksText:Hide()
      if showGuildStatus then
        guildStatusText:SetText(guildStatusLine)
        guildStatusText:Show()
      else
        guildStatusText:Hide()
      end
      statsLabel:Show()
      statsText:Show()
      statsText:SetText(stats)
      -- Keep group section below the stats (even though hidden)
      groupSectionLabel:ClearAllPoints()
      groupSectionLabel:SetPoint('TOPLEFT', statsText, 'BOTTOMLEFT', 0, -22)
    end

    -- Group Found UI state
    if isGroup then
      groupSectionLabel:Show()
      for i = 1, 10 do
        editBoxes[i]:Show()
      end
      lockNote:Show()

      -- Prefill from saved settings
      local names = (GLOBAL_SETTINGS and GLOBAL_SETTINGS.groupFoundNames) or {}
      for i = 1, 10 do
        local value = names[i] or ''
        editBoxes[i]:SetText(value)
      end

      -- Enable or lock based on level
      local canEdit = playerLevel == 1
      for i = 1, 10 do
        if canEdit then
          editBoxes[i]:Enable()
        else
          editBoxes[i]:Disable()
        end
      end
      saveNamesButton:SetEnabled(canEdit)
      if autofillButton then autofillButton:SetEnabled(canEdit) end
      if canEdit then
        lockNote:SetText('Editable at level 1. Locked from level 2.')
        lockNote:SetTextColor(1, 0.8, 0.2)
        -- Position next to buttons for level 1
        lockNote:ClearAllPoints()
        lockNote:SetPoint('LEFT', saveNamesButton, 'RIGHT', 10, 0)
        lockNote:SetJustifyH('LEFT')
        saveNamesButton:Show()
        if autofillButton then autofillButton:Show() end
        if autofillDesc then autofillDesc:Show() end
      else
        -- Hide the red lock message entirely when above level 1
        lockNote:Hide()
        saveNamesButton:Hide()
        if autofillButton then autofillButton:Hide() end
        if autofillDesc then autofillDesc:Hide() end
      end
    else
      groupSectionLabel:Hide()
      for i = 1, 10 do
        editBoxes[i]:Hide()
      end
      saveNamesButton:Hide()
      if autofillButton then autofillButton:Hide() end
      if autofillDesc then autofillDesc:Hide() end
      lockNote:Hide()
    end
    
    -- Adjust panel size based on mode to reduce empty space
    local desiredHeight = 500
    if GLOBAL_SETTINGS and GLOBAL_SETTINGS.guildSelfFound and playerLevel > 1 and not isGroup then
      desiredHeight = 420
    end
    if statusFrame.GetHeight and statusFrame.SetHeight then
      if math.floor(statusFrame:GetHeight() + 0.5) ~= desiredHeight then
        statusFrame:SetHeight(desiredHeight)
      end
    end
    -- Center panel with mode-specific vertical offset (move down by 30 for Group Found)
    if statusFrame.ClearAllPoints and statusFrame.SetPoint then
      statusFrame:ClearAllPoints()
      local yOffset = (isGroup and -40) or 0
      statusFrame:SetPoint('CENTER', statusPage, 'CENTER', 0, yOffset)
    end
  end

  -- Store update function for external access
  statusPage.UpdateStatus = UpdateStatus

  -- Refresh UI when player levels up (e.g., from 1 to 2)
  local levelEventFrame = CreateFrame('Frame', nil, statusPage)
  levelEventFrame:RegisterEvent('PLAYER_LEVEL_UP')
  levelEventFrame:RegisterEvent('UNIT_LEVEL')
  levelEventFrame:SetScript('OnEvent', function(_, event, arg1)
    if event == 'PLAYER_LEVEL_UP' then
      if XFoundModeManager and XFoundModeManager.currentPage == 'status' and statusPage.UpdateStatus then
        statusPage:UpdateStatus()
      end
    elseif event == 'UNIT_LEVEL' then
      if arg1 == 'player' and XFoundModeManager and XFoundModeManager.currentPage == 'status' and statusPage.UpdateStatus then
        statusPage:UpdateStatus()
      end
    end
  end)

  -- Save handler
  saveNamesButton:SetScript('OnClick', function()
    if not GLOBAL_SETTINGS then return end
    if UnitLevel('player') ~= 1 then return end
    local names = {}
    for i = 1, 10 do
      local raw = editBoxes[i]:GetText() or ''
      raw = string.gsub(raw, '^%s+', '')
      raw = string.gsub(raw, '%s+$', '')
      if raw ~= '' then
        table.insert(names, raw)
      end
    end
    GLOBAL_SETTINGS.groupFoundNames = names
    if SaveCharacterSettings then
      SaveCharacterSettings(GLOBAL_SETTINGS)
    end
    print('|cff00ff00[ULTRA]|r Group Found teammate names saved.')
  end)

  -- Helper to collect current party/raid member names (excluding player)
  local function GetCurrentGroupMemberNames()
    local names = {}
    local seen = {}
    local playerName = UnitName('player')

    local function addName(name)
      if not name then return end
      name = string.match(name, '([^%-]+)') or name
      if name ~= '' and name ~= playerName then
        local key = string.lower(name)
        if not seen[key] then
          table.insert(names, name)
          seen[key] = true
        end
      end
    end

    if IsInRaid and IsInRaid() then
      local num = (GetNumGroupMembers and GetNumGroupMembers()) or 0
      for i = 1, num do
        local n = GetRaidRosterInfo and GetRaidRosterInfo(i)
        addName(n)
      end
    else
      -- Party (classic compatible: party1..party4)
      for i = 1, 4 do
        local unit = 'party' .. i
        if UnitExists and UnitExists(unit) then
          local n = UnitName(unit)
          addName(n)
        end
      end
    end

    return names
  end

  -- Auto-Fill click handler
  autofillButton:SetScript('OnEnter', function(self)
    GameTooltip:SetOwner(self, 'ANCHOR_TOP')
    GameTooltip:SetText('Auto-Fill from Group')
    GameTooltip:AddLine('Copy current party/raid members into the fields (excludes you).', 1, 1, 1, true)
    GameTooltip:Show()
  end)
  autofillButton:SetScript('OnLeave', function()
    GameTooltip:Hide()
  end)
  autofillButton:SetScript('OnClick', function()
    if UnitLevel('player') ~= 1 then return end
    local groupNames = GetCurrentGroupMemberNames()
    if not groupNames or #groupNames == 0 then
      print('|cffffd000[ULTRA]|r No party/raid members found to add.')
      return
    end

    local existing = {}
    for i = 1, 10 do
      local raw = editBoxes[i]:GetText() or ''
      raw = string.gsub(raw, '^%s+', '')
      raw = string.gsub(raw, '%s+$', '')
      if raw ~= '' then
        existing[string.lower(raw)] = true
      end
    end

    local filled = 0
    local nextIndex = 1
    local function isEmpty(idx)
      local t = editBoxes[idx]:GetText() or ''
      t = string.gsub(t, '^%s+', '')
      t = string.gsub(t, '%s+$', '')
      return t == ''
    end

    for _, name in ipairs(groupNames) do
      local key = string.lower(name)
      if not existing[key] then
        while nextIndex <= 10 and not isEmpty(nextIndex) do
          nextIndex = nextIndex + 1
        end
        if nextIndex > 10 then break end
        editBoxes[nextIndex]:SetText(name)
        existing[key] = true
        filled = filled + 1
        nextIndex = nextIndex + 1
      end
    end

    if filled > 0 then
      print('|cff00ff00[ULTRA]|r Auto-filled ' .. filled .. ' names from your group.')
    else
      print('|cffffd000[ULTRA]|r No empty slots or all names already present.')
    end

    -- Persist the current input values immediately after auto-fill
    if GLOBAL_SETTINGS then
      local namesToSave = {}
      for i = 1, 10 do
        local raw = editBoxes[i]:GetText() or ''
        raw = string.gsub(raw, '^%s+', '')
        raw = string.gsub(raw, '%s+$', '')
        if raw ~= '' then table.insert(namesToSave, raw) end
      end
      GLOBAL_SETTINGS.groupFoundNames = namesToSave
      if SaveCharacterSettings then
        SaveCharacterSettings(GLOBAL_SETTINGS)
      end
      if filled > 0 then
        print('|cff00ff00[ULTRA]|r Group Found names saved.')
      end
    end
  end)

  return statusPage
end

-- Export the function
if not XFoundModePages then
  XFoundModePages = {}
end
XFoundModePages.CreateStatusPage = CreateStatusPage
