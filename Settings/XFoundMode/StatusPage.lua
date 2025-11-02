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
  statusFrame:SetPoint('TOP', statusPage, 'TOP', 0, -70)

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

  -- Current Mode Display
  local modeLabel = statusFrame:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
  modeLabel:SetPoint('TOPLEFT', statusFrame, 'TOPLEFT', 20, -60)
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
  restrictionsLabel:SetPoint('TOPLEFT', modeLabel, 'BOTTOMLEFT', 0, -14)
  restrictionsLabel:SetText('Current Restrictions:')
  restrictionsLabel:SetTextColor(1, 1, 1)

  local restrictionsText = statusFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  restrictionsText:SetPoint('TOPLEFT', restrictionsLabel, 'BOTTOMLEFT', 0, -10)
  restrictionsText:SetWidth(400)
  restrictionsText:SetText('No restrictions active. You can trade freely with all players.')
  restrictionsText:SetJustifyH('LEFT')
  restrictionsText:SetNonSpaceWrap(true)
  restrictionsText:SetTextColor(0.8, 0.8, 0.8)

  -- Group Found Teammate Inputs (Only meaningful when Group Found is active)
  local groupSectionLabel = statusFrame:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
  groupSectionLabel:SetPoint('TOPLEFT', restrictionsText, 'BOTTOMLEFT', 0, -15)
  groupSectionLabel:SetText('Group Found: Teammates')
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
        rowAnchors[row]:SetPoint('TOPLEFT', groupSectionLabel, 'BOTTOMLEFT', 0, -20)
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
  saveNamesButton:SetSize(100, 24)
  saveNamesButton:SetPoint('TOPLEFT', rowAnchors[5], 'BOTTOMLEFT', 0, -14)
  saveNamesButton:SetText('Save Names')

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
  -- Warning Text
  local warningText = statusFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightLarge')
  warningText:SetPoint('BOTTOM', backButton, 'TOP', 0, 8)
  warningText:SetWidth(430)
  warningText:SetText(
    'Note: X Found modes can only be selected at level 1. Your current mode is locked.'
  )
  warningText:SetJustifyH('CENTER')
  warningText:SetNonSpaceWrap(true)
  warningText:SetTextColor(1, 0.6, 0.1) -- Brighter color
  if warningText.SetDrawLayer then
    warningText:SetDrawLayer('OVERLAY', 2)
  end
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
      warningText:SetTextColor(1, 1, 0) -- Bright yellow for level 1
    else
      backButton:Hide()
      warningText:SetText(
        'Note: X Found modes can only be selected at level 1. Your current mode is locked.'
      )
      warningText:SetTextColor(1, 0.6, 0.6) -- Brighter red for higher levels
    end

    -- Get current X Found mode from settings
    local currentMode = 'None Selected'
    local currentIcon = 'Interface\\Icons\\INV_Misc_QuestionMark'
    local restrictions = 'No restrictions active. You can trade freely with all players.'
    local stats = 'Mode activated: Never\nTrades completed: 0\nRestrictions triggered: 0'

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

    -- Group Found UI state
    local isGroup = GLOBAL_SETTINGS and GLOBAL_SETTINGS.groupSelfFound
    if isGroup then
      groupSectionLabel:Show()
      for i = 1, 10 do
        editBoxes[i]:Show()
      end
      saveNamesButton:Show()
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
      if canEdit then
        lockNote:SetText('Editable at level 1. Locked from level 2.')
        lockNote:SetTextColor(1, 0.8, 0.2)
      else
        lockNote:SetText('Names locked. Changes disabled from level 2.')
        lockNote:SetTextColor(1, 0.4, 0.4)
      end
    else
      groupSectionLabel:Hide()
      for i = 1, 10 do
        editBoxes[i]:Hide()
      end
      saveNamesButton:Hide()
      lockNote:Hide()
    end
  end

  -- Store update function for external access
  statusPage.UpdateStatus = UpdateStatus

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

  return statusPage
end

-- Export the function
if not XFoundModePages then
  XFoundModePages = {}
end
XFoundModePages.CreateStatusPage = CreateStatusPage
