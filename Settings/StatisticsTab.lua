-- Statistics Tab Content - Full size scrollable frame

-- Centralized tooltip map for all statistics
local STATISTIC_TOOLTIPS = {
  -- Lowest Health section
  level = 'Your current character level',
  total = "The lowest health percentage you've ever reached across all levels",
  thisLevel = "The lowest health percentage you've reached at your current level",
  thisSession = "The lowest health percentage you've reached in your current play session",
  petDeaths = 'Total number of times your pet has died permanently',
  -- Enemies Slain section
  enemiesSlainTotal = 'Total number of enemies you have killed',
  elitesSlain = 'Number of elite enemies you have killed',
  rareElitesSlain = 'Number of rare elite enemies you have killed',
  worldBossesSlain = 'Number of world bosses you have killed',
  dungeonBossesSlain = 'Number of dungeon bosses you have killed',
  dungeonsCompleted = 'Number of dungeons you have fully completed',
  highestCritValue = 'The highest critical hit damage you have dealt',
  highestHealCritValue = 'The highest critical heal you have done',
  -- Survival section
  healthPotionsUsed = 'Number of health potions you have consumed',
  manaPotionsUsed = 'Number of mana potions you have consumed',
  bandagesApplied = 'Number of bandages you have used to heal',
  targetDummiesUsed = 'Number of target dummies you have used',
  grenadesUsed = 'Number of grenades you have thrown',
  partyDeathsWitnessed = 'Number of party member deaths you have witnessed',
  closeEscapes = "Number of times your health has dropped below " .. closeEscapeHealthPercent .. "%",
  duelsTotal = 'Total number of duels you have done',
  duelsWon = 'Number of duels you have won',
  duelsLost = 'Number of duels you have lost',
  duelsWinPercent = 'Percentage of duels you have won',
  playerJumps = 'Number of jumps you have performed.  Work that jump key!',
  xpGWA = 'XP gained with addon enabled.',
  xpGWOA = 'XP gained with addon disabled or on another device.',
  mapKeyPressesWhileMapBlocked = 'Times you pressed M while Route Planner blocked the map',
}

-- Helper function to attach tooltip to a statistic label
local function AddStatisticTooltip(label, tooltipKey)
  if not label or not tooltipKey then return end

  local tooltipText = STATISTIC_TOOLTIPS[tooltipKey]
  if not tooltipText then return end

  label:SetScript('OnEnter', function()
    GameTooltip:SetOwner(label, 'ANCHOR_RIGHT')
    GameTooltip:SetText(tooltipText, nil, nil, nil, nil, true)
    GameTooltip:Show()
  end)

  label:SetScript('OnLeave', function()
    GameTooltip:Hide()
  end)
end
-- Initialize Statistics Tab when called
function InitializeStatisticsTab()
  -- Check if tabContents[1] exists
  if not tabContents or not tabContents[1] then return end

  -- Check if already initialized to prevent duplicates
  if tabContents[1].initialized then return end

  -- Mark as initialized
  tabContents[1].initialized = true

  local statsFrame = CreateFrame('Frame', nil, tabContents[1], 'BackdropTemplate')
  statsFrame:SetSize(500, 490) -- Back to original height
  statsFrame:SetPoint('TOP', tabContents[1], 'TOP', 0, -55) -- Moved up 10px
  statsFrame:SetBackdrop({
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

  -- Create scroll frame for statistics content
  local statsScrollFrame = CreateFrame('ScrollFrame', nil, statsFrame, 'UIPanelScrollFrameTemplate')
  statsScrollFrame:SetSize(340, 360)
  statsScrollFrame:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', 10, -10)
  statsScrollFrame:SetPoint('BOTTOMRIGHT', statsFrame, 'BOTTOMRIGHT', -2, 10)

  -- Create scroll child frame
  local statsScrollChild = CreateFrame('Frame', nil, statsScrollFrame)
  statsScrollChild:SetSize(500, 300) -- Increased height to accommodate proper bottom spacing for XP section
  statsScrollFrame:SetScrollChild(statsScrollChild)

  -- Current Character section (header)
  local currentHeader = CreateFrame('Frame', nil, statsScrollChild, 'BackdropTemplate')
  currentHeader:SetSize(470, LAYOUT.SECTION_HEADER_HEIGHT)
  currentHeader:SetPoint('TOPLEFT', statsScrollChild, 'TOPLEFT', 0, -5)
  -- Modern WoW row styling with rounded corners and greyish background
  currentHeader:SetBackdrop({
    bgFile = 'Interface\\DialogFrame\\UI-DialogBox-Background',
    edgeFile = 'Interface\\DialogFrame\\UI-DialogBox-Border',
    tile = true,
    tileSize = 32,
    edgeSize = 16,
    insets = {
      left = 4,
      right = 4,
      top = 4,
      bottom = 4,
    },
  })
  currentHeader:SetBackdropColor(0.2, 0.2, 0.2, 0.9)
  currentHeader:SetBackdropBorderColor(0.6, 0.6, 0.6, 1)
  -- Header text
  local currentHeaderLabel = currentHeader:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  currentHeaderLabel:SetPoint('LEFT', currentHeader, 'LEFT', 12, 0)
  currentHeaderLabel:SetText('Ultra Status (BETA)')

  -- Current Character section (content)
  local currentContent = CreateFrame('Frame', nil, statsScrollChild, 'BackdropTemplate')
  currentContent:SetSize(450, 3 * LAYOUT.ROW_HEIGHT + LAYOUT.CONTENT_PADDING * 2)
  currentContent:SetPoint('TOPLEFT', currentHeader, 'BOTTOMLEFT', LAYOUT.CONTENT_INDENT, -LAYOUT.CONTENT_PADDING)
  currentContent:Show()
  currentContent:SetBackdrop({
    bgFile = 'Interface\\Buttons\\UI-Listbox-Empty',
    edgeFile = 'Interface\\Buttons\\UI-Listbox-Empty',
    tile = true,
    tileSize = 16,
    edgeSize = 8,
    insets = {
      left = 4,
      right = 4,
      top = 4,
      bottom = 4,
    },
  })
  -- "Preset:" label and dynamic value
  local currentPresetLabel = currentContent:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  currentPresetLabel:SetPoint('TOPLEFT', currentContent, 'TOPLEFT', LAYOUT.ROW_INDENT, -LAYOUT.CONTENT_PADDING)
  currentPresetLabel:SetText('')
  currentPresetLabel:Hide()
  local currentPresetText = currentContent:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  currentPresetText:ClearAllPoints()
  currentPresetText:SetPoint('TOPLEFT', currentContent, 'TOPLEFT', LAYOUT.ROW_INDENT, -LAYOUT.CONTENT_PADDING)
  currentPresetText:SetJustifyH('LEFT')
  currentPresetText:SetText('')
  currentPresetText:SetShadowOffset(1, -1)
  currentPresetText:SetShadowColor(0, 0, 0, 0.8)

  -- Legitimacy message below preset
  local legitStatusIcon = currentContent:CreateTexture(nil, 'OVERLAY')
  legitStatusIcon:SetSize(14, 14)
  legitStatusIcon:SetPoint('TOPLEFT', currentContent, 'TOPLEFT', LAYOUT.ROW_INDENT, -LAYOUT.CONTENT_PADDING - LAYOUT.ROW_HEIGHT - 2)
  legitStatusIcon:SetTexture('Interface\\AddOns\\UltraHardcore\\Textures\\circle-with-border.png')

  local legitStatusLine1 = currentContent:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  legitStatusLine1:SetPoint('LEFT', legitStatusIcon, 'RIGHT', 6, 0)
  legitStatusLine1:SetShadowOffset(1, -1)
  legitStatusLine1:SetShadowColor(0, 0, 0, 0.8)

  local legitStatusLine2 = currentContent:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
  legitStatusLine2:SetPoint('TOPLEFT', legitStatusLine1, 'BOTTOMLEFT', 0, -2)
  legitStatusLine2:SetShadowOffset(1, -1)
  legitStatusLine2:SetShadowColor(0, 0, 0, 0.8)

  -- Static items verification line (hard-coded, no checks)
  local legitStatusLine3 = currentContent:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
  legitStatusLine3:SetPoint('TOPLEFT', legitStatusLine2, 'BOTTOMLEFT', 0, -2)
  legitStatusLine3:SetText('No items were gained whilst the addon was inactive')
  legitStatusLine3:SetShadowOffset(1, -1)
  legitStatusLine3:SetShadowColor(0, 0, 0, 0.8)
  legitStatusLine3:SetTextColor(0.7, 0.7, 0.7)
  local function UpdateLegitStatusText()
    local xpWithoutAddon = 1
    if CharacterStats and CharacterStats.ReportXPWithoutAddon then
      local reported = CharacterStats:ReportXPWithoutAddon()
      if type(reported) == 'number' then
        xpWithoutAddon = reported
      end
    end

    -- Get total XP gained with addon
    local xpWithAddon = 0
    if CharacterStats and CharacterStats.GetStat then
      xpWithAddon = CharacterStats:GetStat('xpGainedWithAddon') or 0
    end

    -- Check if character has any UHC settings enabled
    local hasUHCSettings = false
    local sections = GetPresetSections('simple', false)
    for _, section in ipairs(sections) do
      for _, settingName in ipairs(section.settings or {}) do
        if GLOBAL_SETTINGS and GLOBAL_SETTINGS[settingName] then
          hasUHCSettings = true
          break
        end
      end
      if hasUHCSettings then break end
    end

    -- Level 1 character with no XP gained at all should be considered verified only if they have UHC settings enabled
    local playerLevel = UnitLevel('player') or 1
    local isLevelOneWithNoXP = (playerLevel == 1 and xpWithAddon == 0 and xpWithoutAddon == 0 and hasUHCSettings)

    if xpWithoutAddon == 0 or isLevelOneWithNoXP then
      legitStatusLine1:SetText('Verified Ultra status')
      legitStatusLine2:SetText('No XP was gained while the addon was inactive')
      legitStatusLine1:SetTextColor(0.2, 0.95, 0.3)
      legitStatusLine2:SetTextColor(0.7, 1.0, 0.7)
      legitStatusIcon:SetVertexColor(0.2, 0.95, 0.3)
      legitStatusLine3:SetTextColor(0.7, 1.0, 0.7)
    else
      legitStatusLine1:SetText('Ultra status failed verification')
      legitStatusLine2:SetText('XP was gained while the addon was inactive')
      legitStatusLine1:SetTextColor(1.0, 0.35, 0.35)
      legitStatusLine2:SetTextColor(0.7, 0.7, 0.7)
      legitStatusIcon:SetVertexColor(1.0, 0.35, 0.35)
      legitStatusLine3:SetTextColor(0.7, 0.7, 0.7)
    end
  end

  -- Helper to update the current preset display
  local function UpdateCurrentPresetDisplay()
    local sections = GetPresetSections('simple', false) -- Exclude Misc
    local function allTrueForSettings(settingsList)
      for _, settingName in ipairs(settingsList or {}) do
        if not GLOBAL_SETTINGS or not GLOBAL_SETTINGS[settingName] then
          return false
        end
      end
      return true
    end
    local lite = sections[1] and sections[1].settings or {}
    local recommended = sections[2] and sections[2].settings or {}
    local extreme = sections[3] and sections[3].settings or {}

    local liteOk = allTrueForSettings(lite)
    local recOk = liteOk and allTrueForSettings(recommended)
    local extOk = recOk and allTrueForSettings(extreme)

    local presetLevel = nil
    if extOk then
      presetLevel = 'Extreme'
    elseif recOk then
      presetLevel = 'Recommended'
    elseif liteOk then
      presetLevel = 'Lite'
    end

    local xpWithoutAddon = 1
    if CharacterStats and CharacterStats.ReportXPWithoutAddon then
      local reported = CharacterStats:ReportXPWithoutAddon()
      if type(reported) == 'number' then
        xpWithoutAddon = reported
      end
    end

    if presetLevel and xpWithoutAddon == 0 then
      -- Only color the preset name in green; keep the rest at normal highlight color
      local text = 'This character is a certified ' .. '|cff33F24C' .. presetLevel .. '|r' .. ' Ultra.'
      currentPresetText:SetText(text)
      currentPresetText:SetTextColor(0.922, 0.871, 0.761)
    else
      currentPresetText:SetText('This character is not a legitimate Ultra.')
      currentPresetText:SetTextColor(1.0, 0.35, 0.35) -- refined red
    end
  end

  -- Initialize the preset display once
  UpdateCurrentPresetDisplay()
  UpdateLegitStatusText()

  -- Create modern WoW-style lowest health section (no accordion functionality)
  local lowestHealthHeader = CreateFrame('Frame', nil, statsScrollChild, 'BackdropTemplate')
  lowestHealthHeader:SetSize(470, LAYOUT.SECTION_HEADER_HEIGHT)
  -- Anchor directly below Current Character content
  lowestHealthHeader:SetPoint('TOPLEFT', currentContent, 'BOTTOMLEFT', -LAYOUT.CONTENT_INDENT, -LAYOUT.SECTION_SPACING)

  -- Modern WoW row styling with rounded corners and greyish background
  lowestHealthHeader:SetBackdrop({
    bgFile = 'Interface\\DialogFrame\\UI-DialogBox-Background',
    edgeFile = 'Interface\\DialogFrame\\UI-DialogBox-Border',
    tile = true,
    tileSize = 32,
    edgeSize = 16,
    insets = {
      left = 4,
      right = 4,
      top = 4,
      bottom = 4,
    },
  })
  lowestHealthHeader:SetBackdropColor(0.2, 0.2, 0.2, 0.9) -- Dark greyish background
  lowestHealthHeader:SetBackdropBorderColor(0.6, 0.6, 0.6, 1) -- Light grey border
  -- Create header text
  local lowestHealthLabel = lowestHealthHeader:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  lowestHealthLabel:SetPoint('LEFT', lowestHealthHeader, 'LEFT', 12, 0)
  lowestHealthLabel:SetText('Lowest Health')

  -- Create content frame for Lowest Health breakdown
  local lowestHealthContent = CreateFrame('Frame', nil, statsScrollChild, 'BackdropTemplate')
  lowestHealthContent:SetSize(450, 5 * LAYOUT.ROW_HEIGHT + LAYOUT.CONTENT_PADDING * 2) -- 5 rows + padding
  -- Position content directly under its header with consistent padding
  lowestHealthContent:SetPoint('TOPLEFT', lowestHealthHeader, 'BOTTOMLEFT', LAYOUT.CONTENT_INDENT, -LAYOUT.CONTENT_PADDING)
  lowestHealthContent:Show() -- Show by default
  -- Modern content frame styling
  lowestHealthContent:SetBackdrop({
    bgFile = 'Interface\\Buttons\\UI-Listbox-Empty',
    edgeFile = 'Interface\\Buttons\\UI-Listbox-Empty',
    tile = true,
    tileSize = 16,
    edgeSize = 8,
    insets = {
      left = 4,
      right = 4,
      top = 4,
      bottom = 4,
    },
  })

  -- Create the level text display
  local levelLabel = lowestHealthContent:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  levelLabel:SetPoint(
    'TOPLEFT',
    lowestHealthContent,
    'TOPLEFT',
    LAYOUT.ROW_INDENT,
    -LAYOUT.CONTENT_PADDING
  )
  levelLabel:SetText('Level:')
  AddStatisticTooltip(levelLabel, 'level')

  local levelText = lowestHealthContent:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  levelText:SetPoint(
    'TOPRIGHT',
    lowestHealthContent,
    'TOPRIGHT',
    -LAYOUT.ROW_INDENT,
    -LAYOUT.CONTENT_PADDING
  )
  levelText:SetText(formatNumberWithCommas(UnitLevel("player")))

  -- Create radio button for showing level in main screen statistics
  local showStatsLevelRadio =
    CreateFrame('CheckButton', nil, lowestHealthContent, 'UIRadioButtonTemplate')
  showStatsLevelRadio:SetPoint('LEFT', levelLabel, 'LEFT', -20, 0)
  showStatsLevelRadio:SetChecked(false) -- Initialize as unchecked, will be updated by updateRadioButtons()
  radioButtons.showMainStatisticsPanelLevel = showStatsLevelRadio
  showStatsLevelRadio:SetScript('OnClick', function(self)
    tempSettings.showMainStatisticsPanelLevel = self:GetChecked()
    GLOBAL_SETTINGS.showMainStatisticsPanelLevel = self:GetChecked()
    -- Trigger immediate update of main screen statistics
    if UltraHardcoreStatsFrame and UltraHardcoreStatsFrame.UpdateRowVisibility then
      UltraHardcoreStatsFrame.UpdateRowVisibility()
    end
  end)

  -- Create the total text display (indented)
  local lowestHealthTotalLabel =
    lowestHealthContent:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  lowestHealthTotalLabel:SetPoint(
    'TOPLEFT',
    lowestHealthContent,
    'TOPLEFT',
    LAYOUT.ROW_INDENT,
    -LAYOUT.CONTENT_PADDING - LAYOUT.ROW_HEIGHT
  )
  lowestHealthTotalLabel:SetText('Total:')
  AddStatisticTooltip(lowestHealthTotalLabel, 'total')

  lowestHealthText = lowestHealthContent:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  lowestHealthText:SetPoint(
    'TOPRIGHT',
    lowestHealthContent,
    'TOPRIGHT',
    -LAYOUT.ROW_INDENT,
    -LAYOUT.CONTENT_PADDING - LAYOUT.ROW_HEIGHT
  )
  lowestHealthText:SetText(string.format('%.1f%%', CharacterStats:GetStat('lowestHealth') or 100))

  -- Create radio button for showing lowest health in main screen statistics
  local showStatsLowestHealthRadio =
    CreateFrame('CheckButton', nil, lowestHealthContent, 'UIRadioButtonTemplate')
  showStatsLowestHealthRadio:SetPoint('LEFT', lowestHealthTotalLabel, 'LEFT', -20, 0)
  showStatsLowestHealthRadio:SetChecked(false) -- Initialize as unchecked, will be updated by updateRadioButtons()
  radioButtons.showMainStatisticsPanelLowestHealth = showStatsLowestHealthRadio
  showStatsLowestHealthRadio:SetScript('OnClick', function(self)
    tempSettings.showMainStatisticsPanelLowestHealth = self:GetChecked()
    GLOBAL_SETTINGS.showMainStatisticsPanelLowestHealth = self:GetChecked()
    -- Trigger immediate update of main screen statistics
    if UltraHardcoreStatsFrame and UltraHardcoreStatsFrame.UpdateRowVisibility then
      UltraHardcoreStatsFrame.UpdateRowVisibility()
    end
  end)

  -- Create the This Level text display
  local lowestHealthThisLevelLabel =
    lowestHealthContent:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  lowestHealthThisLevelLabel:SetPoint(
    'TOPLEFT',
    lowestHealthContent,
    'TOPLEFT',
    LAYOUT.ROW_INDENT,
    -LAYOUT.CONTENT_PADDING - LAYOUT.ROW_HEIGHT * 2
  )
  lowestHealthThisLevelLabel:SetText('This Level:')
  AddStatisticTooltip(lowestHealthThisLevelLabel, 'thisLevel')

  local lowestHealthThisLevelText =
    lowestHealthContent:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  lowestHealthThisLevelText:SetPoint(
    'TOPRIGHT',
    lowestHealthContent,
    'TOPRIGHT',
    -LAYOUT.ROW_INDENT,
    -LAYOUT.CONTENT_PADDING - LAYOUT.ROW_HEIGHT * 2
  )
  lowestHealthThisLevelText:SetText(string.format('%.1f%%', CharacterStats:GetStat('lowestHealthThisLevel') or 100))

  -- Create radio button for showing this level health in main screen statistics
  local showStatsThisLevelRadio =
    CreateFrame('CheckButton', nil, lowestHealthContent, 'UIRadioButtonTemplate')
  showStatsThisLevelRadio:SetPoint('LEFT', lowestHealthThisLevelLabel, 'LEFT', -20, 0)
  showStatsThisLevelRadio:SetChecked(false) -- Initialize as unchecked, will be updated by updateRadioButtons()
  radioButtons.showMainStatisticsPanelThisLevel = showStatsThisLevelRadio
  showStatsThisLevelRadio:SetScript('OnClick', function(self)
    tempSettings.showMainStatisticsPanelThisLevel = self:GetChecked()
    GLOBAL_SETTINGS.showMainStatisticsPanelThisLevel = self:GetChecked()
    -- Trigger immediate update of main screen statistics
    if UltraHardcoreStatsFrame and UltraHardcoreStatsFrame.UpdateRowVisibility then
      UltraHardcoreStatsFrame.UpdateRowVisibility()
    end
  end)

  -- Create the This Session text display
  local lowestHealthThisSessionLabel =
    lowestHealthContent:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  lowestHealthThisSessionLabel:SetPoint(
    'TOPLEFT',
    lowestHealthContent,
    'TOPLEFT',
    LAYOUT.ROW_INDENT,
    -LAYOUT.CONTENT_PADDING - LAYOUT.ROW_HEIGHT * 3
  )
  lowestHealthThisSessionLabel:SetText('This Session:')
  AddStatisticTooltip(lowestHealthThisSessionLabel, 'thisSession')

  local lowestHealthThisSessionText =
    lowestHealthContent:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  lowestHealthThisSessionText:SetPoint(
    'TOPRIGHT',
    lowestHealthContent,
    'TOPRIGHT',
    -LAYOUT.ROW_INDENT,
    -LAYOUT.CONTENT_PADDING - LAYOUT.ROW_HEIGHT * 3
  )
  lowestHealthThisSessionText:SetText(string.format('%.1f%%', CharacterStats:GetStat('lowestHealthThisSession') or 100))

  -- Create radio button for showing session health in main screen statistics
  local showStatsSessionHealthRadio =
    CreateFrame('CheckButton', nil, lowestHealthContent, 'UIRadioButtonTemplate')
  showStatsSessionHealthRadio:SetPoint('LEFT', lowestHealthThisSessionLabel, 'LEFT', -20, 0)
  showStatsSessionHealthRadio:SetChecked(false) -- Initialize as unchecked, will be updated by updateRadioButtons()
  radioButtons.showMainStatisticsPanelSessionHealth = showStatsSessionHealthRadio
  showStatsSessionHealthRadio:SetScript('OnClick', function(self)
    tempSettings.showMainStatisticsPanelSessionHealth = self:GetChecked()
    GLOBAL_SETTINGS.showMainStatisticsPanelSessionHealth = self:GetChecked()
    -- Trigger immediate update of main screen statistics
    if UltraHardcoreStatsFrame and UltraHardcoreStatsFrame.UpdateRowVisibility then
      UltraHardcoreStatsFrame.UpdateRowVisibility()
    end
  end)

  -- Add pet death rows to the same content frame
  -- Create the pet deaths text display
  local petDeathsLabel = lowestHealthContent:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  petDeathsLabel:SetPoint(
    'TOPLEFT',
    lowestHealthContent,
    'TOPLEFT',
    LAYOUT.ROW_INDENT,
    -LAYOUT.CONTENT_PADDING - LAYOUT.ROW_HEIGHT * 4
  )
  petDeathsLabel:SetText('Pet Deaths:')
  AddStatisticTooltip(petDeathsLabel, 'petDeaths')

  petDeathsText = lowestHealthContent:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  petDeathsText:SetPoint(
    'TOPRIGHT',
    lowestHealthContent,
    'TOPRIGHT',
    -LAYOUT.ROW_INDENT,
    -LAYOUT.CONTENT_PADDING - LAYOUT.ROW_HEIGHT * 4
  )
  petDeathsText:SetText(formatNumberWithCommas(CharacterStats:GetStat('petDeaths')))

  -- Create radio button for showing pet deaths in main screen statistics
  local showStatsPetDeathsRadio =
    CreateFrame('CheckButton', nil, lowestHealthContent, 'UIRadioButtonTemplate')
  showStatsPetDeathsRadio:SetPoint('LEFT', petDeathsLabel, 'LEFT', -20, 0)
  showStatsPetDeathsRadio:SetChecked(false) -- Initialize as unchecked, will be updated by updateRadioButtons()
  radioButtons.showMainStatisticsPanelPetDeaths = showStatsPetDeathsRadio
  showStatsPetDeathsRadio:SetScript('OnClick', function(self)
    tempSettings.showMainStatisticsPanelPetDeaths = self:GetChecked()
    GLOBAL_SETTINGS.showMainStatisticsPanelPetDeaths = self:GetChecked()
    -- Trigger immediate update of main screen statistics
    if UltraHardcoreStatsFrame and UltraHardcoreStatsFrame.UpdateRowVisibility then
      UltraHardcoreStatsFrame.UpdateRowVisibility()
    end
  end)

  -- Create modern WoW-style enemies slain section (no accordion functionality)
  local enemiesSlainHeader = CreateFrame('Frame', nil, statsScrollChild, 'BackdropTemplate')
  enemiesSlainHeader:SetSize(470, LAYOUT.SECTION_HEADER_HEIGHT)
  -- Anchor directly below the Lowest Health content to avoid overlap on different UI scales
  enemiesSlainHeader:SetPoint('TOPLEFT', lowestHealthContent, 'BOTTOMLEFT', -LAYOUT.CONTENT_INDENT, -LAYOUT.SECTION_SPACING)

  -- Modern WoW row styling with rounded corners and greyish background
  enemiesSlainHeader:SetBackdrop({
    bgFile = 'Interface\\DialogFrame\\UI-DialogBox-Background',
    edgeFile = 'Interface\\DialogFrame\\UI-DialogBox-Border',
    tile = true,
    tileSize = 32,
    edgeSize = 16,
    insets = {
      left = 4,
      right = 4,
      top = 4,
      bottom = 4,
    },
  })
  enemiesSlainHeader:SetBackdropColor(0.2, 0.2, 0.2, 0.9) -- Dark greyish background
  enemiesSlainHeader:SetBackdropBorderColor(0.6, 0.6, 0.6, 1) -- Light grey border
  -- Create header text
  local enemiesSlainLabel = enemiesSlainHeader:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  enemiesSlainLabel:SetPoint('LEFT', enemiesSlainHeader, 'LEFT', 12, 0)
  enemiesSlainLabel:SetText('Enemies Slain')

  -- Create content frame for Enemies Slain breakdown
  local enemiesSlainContent = CreateFrame('Frame', nil, statsScrollChild, 'BackdropTemplate')
  enemiesSlainContent:SetSize(450, 8 * LAYOUT.ROW_HEIGHT + LAYOUT.CONTENT_PADDING * 2) -- 8 rows + padding (added rare elites, world bosses, and highest heal crit)
  -- Position content directly under its header with consistent padding
  enemiesSlainContent:SetPoint('TOPLEFT', enemiesSlainHeader, 'BOTTOMLEFT', LAYOUT.CONTENT_INDENT, -LAYOUT.CONTENT_PADDING)
  enemiesSlainContent:Show() -- Show by default
  -- Modern content frame styling
  enemiesSlainContent:SetBackdrop({
    bgFile = 'Interface\\Buttons\\UI-Listbox-Empty',
    edgeFile = 'Interface\\Buttons\\UI-Listbox-Empty',
    tile = true,
    tileSize = 16,
    edgeSize = 8,
    insets = {
      left = 4,
      right = 4,
      top = 4,
      bottom = 4,
    },
  })

  -- Create the total text display (indented)
  local enemiesSlainTotalLabel =
    enemiesSlainContent:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  enemiesSlainTotalLabel:SetPoint(
    'TOPLEFT',
    enemiesSlainContent,
    'TOPLEFT',
    LAYOUT.ROW_INDENT,
    -LAYOUT.CONTENT_PADDING
  )
  enemiesSlainTotalLabel:SetText('Total:')
  AddStatisticTooltip(enemiesSlainTotalLabel, 'enemiesSlainTotal')

  local enemiesSlainText = enemiesSlainContent:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  enemiesSlainText:SetPoint(
    'TOPRIGHT',
    enemiesSlainContent,
    'TOPRIGHT',
    -LAYOUT.ROW_INDENT,
    -LAYOUT.CONTENT_PADDING
  )
  enemiesSlainText:SetText(formatNumberWithCommas(CharacterStats:GetStat('enemiesSlain')))

  -- Create radio button for showing enemies slain in main screen statistics
  local showStatsEnemiesSlainRadio =
    CreateFrame('CheckButton', nil, enemiesSlainContent, 'UIRadioButtonTemplate')
  showStatsEnemiesSlainRadio:SetPoint('LEFT', enemiesSlainTotalLabel, 'LEFT', -20, 0)
  showStatsEnemiesSlainRadio:SetChecked(false) -- Initialize as unchecked, will be updated by updateRadioButtons()
  radioButtons.showMainStatisticsPanelEnemiesSlain = showStatsEnemiesSlainRadio
  showStatsEnemiesSlainRadio:SetScript('OnClick', function(self)
    tempSettings.showMainStatisticsPanelEnemiesSlain = self:GetChecked()
    GLOBAL_SETTINGS.showMainStatisticsPanelEnemiesSlain = self:GetChecked()
    -- Trigger immediate update of main screen statistics
    if UltraHardcoreStatsFrame and UltraHardcoreStatsFrame.UpdateRowVisibility then
      UltraHardcoreStatsFrame.UpdateRowVisibility()
    end
  end)

  -- Create the elites slain text display (indented)
  local elitesSlainLabel = enemiesSlainContent:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  elitesSlainLabel:SetPoint(
    'TOPLEFT',
    enemiesSlainContent,
    'TOPLEFT',
    LAYOUT.ROW_INDENT,
    -LAYOUT.CONTENT_PADDING - LAYOUT.ROW_HEIGHT
  )
  elitesSlainLabel:SetText('Elites Slain:')
  AddStatisticTooltip(elitesSlainLabel, 'elitesSlain')

  local elitesSlainText = enemiesSlainContent:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  elitesSlainText:SetPoint(
    'TOPRIGHT',
    enemiesSlainContent,
    'TOPRIGHT',
    -LAYOUT.ROW_INDENT,
    -LAYOUT.CONTENT_PADDING - LAYOUT.ROW_HEIGHT
  )
  elitesSlainText:SetText(formatNumberWithCommas(CharacterStats:GetStat('elitesSlain')))

  -- Create radio button for showing elites slain in main screen statistics
  local showStatsElitesSlainRadio =
    CreateFrame('CheckButton', nil, enemiesSlainContent, 'UIRadioButtonTemplate')
  showStatsElitesSlainRadio:SetPoint('LEFT', elitesSlainLabel, 'LEFT', -20, 0)
  showStatsElitesSlainRadio:SetChecked(false) -- Initialize as unchecked, will be updated by updateRadioButtons()
  radioButtons.showMainStatisticsPanelElitesSlain = showStatsElitesSlainRadio
  showStatsElitesSlainRadio:SetScript('OnClick', function(self)
    tempSettings.showMainStatisticsPanelElitesSlain = self:GetChecked()
    GLOBAL_SETTINGS.showMainStatisticsPanelElitesSlain = self:GetChecked()
    -- Trigger immediate update of main screen statistics
    if UltraHardcoreStatsFrame and UltraHardcoreStatsFrame.UpdateRowVisibility then
      UltraHardcoreStatsFrame.UpdateRowVisibility()
    end
  end)

  -- Create the rare elites slain text display (indented)
  local rareElitesSlainLabel =
    enemiesSlainContent:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  rareElitesSlainLabel:SetPoint(
    'TOPLEFT',
    enemiesSlainContent,
    'TOPLEFT',
    LAYOUT.ROW_INDENT,
    -LAYOUT.CONTENT_PADDING - LAYOUT.ROW_HEIGHT * 2
  )
  rareElitesSlainLabel:SetText('Rare Elites Slain:')
  AddStatisticTooltip(rareElitesSlainLabel, 'rareElitesSlain')

  local rareElitesSlainText =
    enemiesSlainContent:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  rareElitesSlainText:SetPoint(
    'TOPRIGHT',
    enemiesSlainContent,
    'TOPRIGHT',
    -LAYOUT.ROW_INDENT,
    -LAYOUT.CONTENT_PADDING - LAYOUT.ROW_HEIGHT * 2
  )
  rareElitesSlainText:SetText(formatNumberWithCommas(CharacterStats:GetStat('rareElitesSlain')))

  -- Create radio button for showing rare elites slain in main screen statistics
  local showStatsRareElitesSlainRadio =
    CreateFrame('CheckButton', nil, enemiesSlainContent, 'UIRadioButtonTemplate')
  showStatsRareElitesSlainRadio:SetPoint('LEFT', rareElitesSlainLabel, 'LEFT', -20, 0)
  showStatsRareElitesSlainRadio:SetChecked(false) -- Initialize as unchecked, will be updated by updateRadioButtons()
  radioButtons.showMainStatisticsPanelRareElitesSlain = showStatsRareElitesSlainRadio
  showStatsRareElitesSlainRadio:SetScript('OnClick', function(self)
    tempSettings.showMainStatisticsPanelRareElitesSlain = self:GetChecked()
    GLOBAL_SETTINGS.showMainStatisticsPanelRareElitesSlain = self:GetChecked()
    -- Trigger immediate update of main screen statistics
    if UltraHardcoreStatsFrame and UltraHardcoreStatsFrame.UpdateRowVisibility then
      UltraHardcoreStatsFrame.UpdateRowVisibility()
    end
  end)

  -- Create the world bosses slain text display (indented)
  local worldBossesSlainLabel =
    enemiesSlainContent:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  worldBossesSlainLabel:SetPoint(
    'TOPLEFT',
    enemiesSlainContent,
    'TOPLEFT',
    LAYOUT.ROW_INDENT,
    -LAYOUT.CONTENT_PADDING - LAYOUT.ROW_HEIGHT * 3
  )
  worldBossesSlainLabel:SetText('World Bosses Slain:')
  AddStatisticTooltip(worldBossesSlainLabel, 'worldBossesSlain')

  local worldBossesSlainText =
    enemiesSlainContent:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  worldBossesSlainText:SetPoint(
    'TOPRIGHT',
    enemiesSlainContent,
    'TOPRIGHT',
    -LAYOUT.ROW_INDENT,
    -LAYOUT.CONTENT_PADDING - LAYOUT.ROW_HEIGHT * 3
  )
  worldBossesSlainText:SetText(formatNumberWithCommas(CharacterStats:GetStat('worldBossesSlain')))

  -- Create radio button for showing world bosses slain in main screen statistics
  local showStatsWorldBossesSlainRadio =
    CreateFrame('CheckButton', nil, enemiesSlainContent, 'UIRadioButtonTemplate')
  showStatsWorldBossesSlainRadio:SetPoint('LEFT', worldBossesSlainLabel, 'LEFT', -20, 0)
  showStatsWorldBossesSlainRadio:SetChecked(false) -- Initialize as unchecked, will be updated by updateRadioButtons()
  radioButtons.showMainStatisticsPanelWorldBossesSlain = showStatsWorldBossesSlainRadio
  showStatsWorldBossesSlainRadio:SetScript('OnClick', function(self)
    tempSettings.showMainStatisticsPanelWorldBossesSlain = self:GetChecked()
    GLOBAL_SETTINGS.showMainStatisticsPanelWorldBossesSlain = self:GetChecked()
    -- Trigger immediate update of main screen statistics
    if UltraHardcoreStatsFrame and UltraHardcoreStatsFrame.UpdateRowVisibility then
      UltraHardcoreStatsFrame.UpdateRowVisibility()
    end
  end)

  -- Create the dungeon bosses slain text display (indented)
  local dungeonBossesLabel =
    enemiesSlainContent:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  dungeonBossesLabel:SetPoint(
    'TOPLEFT',
    enemiesSlainContent,
    'TOPLEFT',
    LAYOUT.ROW_INDENT,
    -LAYOUT.CONTENT_PADDING - LAYOUT.ROW_HEIGHT * 4
  )
  dungeonBossesLabel:SetText('Dungeon Bosses Slain:')
  AddStatisticTooltip(dungeonBossesLabel, 'dungeonBossesSlain')

  local dungeonBossesText =
    enemiesSlainContent:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  dungeonBossesText:SetPoint(
    'TOPRIGHT',
    enemiesSlainContent,
    'TOPRIGHT',
    -LAYOUT.ROW_INDENT,
    -LAYOUT.CONTENT_PADDING - LAYOUT.ROW_HEIGHT * 4
  )
  dungeonBossesText:SetText(formatNumberWithCommas(CharacterStats:GetStat('dungeonBossesKilled')))

  -- Create radio button for showing dungeon bosses slain in main screen statistics
  local showStatsDungeonBossesRadio =
    CreateFrame('CheckButton', nil, enemiesSlainContent, 'UIRadioButtonTemplate')
  showStatsDungeonBossesRadio:SetPoint('LEFT', dungeonBossesLabel, 'LEFT', -20, 0)
  showStatsDungeonBossesRadio:SetChecked(false) -- Initialize as unchecked, will be updated by updateRadioButtons()
  radioButtons.showMainStatisticsPanelDungeonBosses = showStatsDungeonBossesRadio
  showStatsDungeonBossesRadio:SetScript('OnClick', function(self)
    tempSettings.showMainStatisticsPanelDungeonBosses = self:GetChecked()
    GLOBAL_SETTINGS.showMainStatisticsPanelDungeonBosses = self:GetChecked()
    -- Trigger immediate update of main screen statistics
    if UltraHardcoreStatsFrame and UltraHardcoreStatsFrame.UpdateRowVisibility then
      UltraHardcoreStatsFrame.UpdateRowVisibility()
    end
  end)

  -- Create the dungeons completed text display (indented)
  local dungeonsCompletedLabel =
    enemiesSlainContent:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  dungeonsCompletedLabel:SetPoint(
    'TOPLEFT',
    enemiesSlainContent,
    'TOPLEFT',
    LAYOUT.ROW_INDENT,
    -LAYOUT.CONTENT_PADDING - LAYOUT.ROW_HEIGHT * 5
  )
  dungeonsCompletedLabel:SetText('Dungeons Completed:')
  AddStatisticTooltip(dungeonsCompletedLabel, 'dungeonsCompleted')

  local dungeonsCompletedText =
    enemiesSlainContent:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  dungeonsCompletedText:SetPoint(
    'TOPRIGHT',
    enemiesSlainContent,
    'TOPRIGHT',
    -LAYOUT.ROW_INDENT,
    -LAYOUT.CONTENT_PADDING - LAYOUT.ROW_HEIGHT * 5
  )
  dungeonsCompletedText:SetText(formatNumberWithCommas(CharacterStats:GetStat('dungeonsCompleted')))

  -- Create radio button for showing dungeons completed in main screen statistics
  local showStatsDungeonsCompletedRadio =
    CreateFrame('CheckButton', nil, enemiesSlainContent, 'UIRadioButtonTemplate')
  showStatsDungeonsCompletedRadio:SetPoint('LEFT', dungeonsCompletedLabel, 'LEFT', -20, 0)
  showStatsDungeonsCompletedRadio:SetChecked(false) -- Initialize as unchecked, will be updated by updateRadioButtons()
  radioButtons.showMainStatisticsPanelDungeonsCompleted = showStatsDungeonsCompletedRadio
  showStatsDungeonsCompletedRadio:SetScript('OnClick', function(self)
    tempSettings.showMainStatisticsPanelDungeonsCompleted = self:GetChecked()
    GLOBAL_SETTINGS.showMainStatisticsPanelDungeonsCompleted = self:GetChecked()
    -- Trigger immediate update of main screen statistics
    if UltraHardcoreStatsFrame and UltraHardcoreStatsFrame.UpdateRowVisibility then
      UltraHardcoreStatsFrame.UpdateRowVisibility()
    end
  end)

  -- Create the highest crit value text display (indented)
  local highestCritLabel = enemiesSlainContent:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  highestCritLabel:SetPoint(
    'TOPLEFT',
    enemiesSlainContent,
    'TOPLEFT',
    LAYOUT.ROW_INDENT,
    -LAYOUT.CONTENT_PADDING - LAYOUT.ROW_HEIGHT * 6
  )
  highestCritLabel:SetText('Highest Crit Value:')
  AddStatisticTooltip(highestCritLabel, 'highestCritValue')

  local highestCritText = enemiesSlainContent:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  highestCritText:SetPoint(
    'TOPRIGHT',
    enemiesSlainContent,
    'TOPRIGHT',
    -LAYOUT.ROW_INDENT,
    -LAYOUT.CONTENT_PADDING - LAYOUT.ROW_HEIGHT * 6
  )
  highestCritText:SetText(formatNumberWithCommas(CharacterStats:GetStat('highestCritValue')))

  -- Create radio button for showing highest crit value in main screen statistics
  local showStatsHighestCritRadio =
    CreateFrame('CheckButton', nil, enemiesSlainContent, 'UIRadioButtonTemplate')
  showStatsHighestCritRadio:SetPoint('LEFT', highestCritLabel, 'LEFT', -20, 0)
  showStatsHighestCritRadio:SetChecked(false) -- Initialize as unchecked, will be updated by updateRadioButtons()
  radioButtons.showMainStatisticsPanelHighestCritValue = showStatsHighestCritRadio
  showStatsHighestCritRadio:SetScript('OnClick', function(self)
    tempSettings.showMainStatisticsPanelHighestCritValue = self:GetChecked()
    GLOBAL_SETTINGS.showMainStatisticsPanelHighestCritValue = self:GetChecked()
    -- Trigger immediate update of main screen statistics
    if UltraHardcoreStatsFrame and UltraHardcoreStatsFrame.UpdateRowVisibility then
      UltraHardcoreStatsFrame.UpdateRowVisibility()
    end
  end)

  -- Create the highest heal crit value text display (indented)
  local highestHealCritLabel =
    enemiesSlainContent:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  highestHealCritLabel:SetPoint(
    'TOPLEFT',
    enemiesSlainContent,
    'TOPLEFT',
    LAYOUT.ROW_INDENT,
    -LAYOUT.CONTENT_PADDING - LAYOUT.ROW_HEIGHT * 7
  )
  highestHealCritLabel:SetText('Highest Heal Crit Value:')
  AddStatisticTooltip(highestHealCritLabel, 'highestHealCritValue')

  local highestHealCritText =
    enemiesSlainContent:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  highestHealCritText:SetPoint(
    'TOPRIGHT',
    enemiesSlainContent,
    'TOPRIGHT',
    -LAYOUT.ROW_INDENT,
    -LAYOUT.CONTENT_PADDING - LAYOUT.ROW_HEIGHT * 7
  )
  highestHealCritText:SetText(formatNumberWithCommas(CharacterStats:GetStat('highestHealCritValue')))

  -- Create radio button for showing highest heal crit value in main screen statistics
  local showStatsHighestHealCritRadio =
    CreateFrame('CheckButton', nil, enemiesSlainContent, 'UIRadioButtonTemplate')
  showStatsHighestHealCritRadio:SetPoint('LEFT', highestHealCritLabel, 'LEFT', -20, 0)
  showStatsHighestHealCritRadio:SetChecked(false) -- Initialize as unchecked, will be updated by updateRadioButtons()
  radioButtons.showMainStatisticsPanelHighestHealCritValue = showStatsHighestHealCritRadio
  showStatsHighestHealCritRadio:SetScript('OnClick', function(self)
    tempSettings.showMainStatisticsPanelHighestHealCritValue = self:GetChecked()
    GLOBAL_SETTINGS.showMainStatisticsPanelHighestHealCritValue = self:GetChecked()
    -- Trigger immediate update of main screen statistics
    if UltraHardcoreStatsFrame and UltraHardcoreStatsFrame.UpdateRowVisibility then
      UltraHardcoreStatsFrame.UpdateRowVisibility()
    end
  end)

  -- Create modern WoW-style Survival section (no accordion functionality)
  local survivalHeader = CreateFrame('Frame', nil, statsScrollChild, 'BackdropTemplate')
  survivalHeader:SetSize(470, LAYOUT.SECTION_HEADER_HEIGHT)
  -- Anchor directly below the Enemies Slain content to avoid overlap on different UI scales
  survivalHeader:SetPoint('TOPLEFT', enemiesSlainContent, 'BOTTOMLEFT', -LAYOUT.CONTENT_INDENT, -LAYOUT.SECTION_SPACING)
  -- Modern WoW row styling with rounded corners and greyish background
  survivalHeader:SetBackdrop({
    bgFile = 'Interface\\DialogFrame\\UI-DialogBox-Background',
    edgeFile = 'Interface\\DialogFrame\\UI-DialogBox-Border',
    tile = true,
    tileSize = 32,
    edgeSize = 16,
    insets = {
      left = 4,
      right = 4,
      top = 4,
      bottom = 4,
    },
  })
  survivalHeader:SetBackdropColor(0.2, 0.2, 0.2, 0.9) -- Dark greyish background
  survivalHeader:SetBackdropBorderColor(0.6, 0.6, 0.6, 1) -- Light grey border
  -- Create header text
  local survivalLabel = survivalHeader:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  survivalLabel:SetPoint('LEFT', survivalHeader, 'LEFT', 12, 0)
  survivalLabel:SetText('Survival')

  -- Create content frame for Survival breakdown (always visible)
  local survivalContent = CreateFrame('Frame', nil, statsScrollChild, 'BackdropTemplate')
  survivalContent:SetSize(450, 5 * LAYOUT.ROW_HEIGHT + LAYOUT.CONTENT_PADDING * 2) -- Initial height, will be corrected below
  -- Position content directly under its header with consistent padding
  survivalContent:SetPoint('TOPLEFT', survivalHeader, 'BOTTOMLEFT', LAYOUT.CONTENT_INDENT, -LAYOUT.CONTENT_PADDING)
  survivalContent:Show() -- Always show
  -- Modern content frame styling
  survivalContent:SetBackdrop({
    bgFile = 'Interface\\Buttons\\UI-Listbox-Empty',
    edgeFile = 'Interface\\Buttons\\UI-Listbox-Empty',
    tile = true,
    tileSize = 16,
    edgeSize = 8,
    insets = {
      left = 4,
      right = 4,
      top = 4,
      bottom = 4,
    },
  })

  -- Create survival statistics display inside the content frame
  local survivalTexts = {}

  -- Create survival statistics entries
  local survivalStats = { {
    key = 'healthPotionsUsed',
    label = 'Health Potions Used:',
    tooltipKey = 'healthPotionsUsed',
  }, {
    key = 'manaPotionsUsed',
    label = 'Mana Potions Used:',
    tooltipKey = 'manaPotionsUsed',
  }, {
    key = 'bandagesUsed',
    label = 'Bandages Applied:',
    tooltipKey = 'bandagesApplied',
  }, {
    key = 'targetDummiesUsed',
    label = 'Target Dummies Used (Beta):',
    tooltipKey = 'targetDummiesUsed',
  }, {
    key = 'grenadesUsed',
    label = 'Grenades Used (Beta):',
    tooltipKey = 'grenadesUsed',
  }, {
    key = 'partyMemberDeaths',
    label = 'Party Deaths Witnessed:',
    tooltipKey = 'partyDeathsWitnessed',
  }, {
    key = 'closeEscapes',
    label = 'Close Escapes:',
    tooltipKey = 'closeEscapes',
  }, {
    key = 'duelsTotal',
    label = 'Duels Total:',
    tooltipKey = 'duelsTotal',
  }, {
    key = 'duelsWon',
    label = 'Duels Won:',
    tooltipKey = 'duelsWon',
  }, {
    key = 'duelsLost',
    label = 'Duels Lost:',
    tooltipKey = 'duelsLost',
  }, {
    key = 'duelsWinPercent',
    label = 'Duel Win Percent:',
    tooltipKey = 'duelsWinPercent',
  }, {
    key = 'playerJumps',
    label = 'Jumps Performed:',
    tooltipKey = 'playerJumps',
  }, {
    key = 'xpGWA',
    label = 'XP With Addon:',
    tooltipKey = 'xpGWA',
  }, {
    key = 'xpGWOA',
    label = 'XP Without Addon:',
    tooltipKey = 'xpGWOA',
  }, {
    key = 'mapKeyPressesWhileMapBlocked',
    label = 'Blocked Map Opens (Route Planner):',
    tooltipKey = 'mapKeyPressesWhileMapBlocked',
  } }

  local yOffset = -LAYOUT.CONTENT_PADDING
  for _, stat in ipairs(survivalStats) do
    local label = survivalContent:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
    label:SetPoint('TOPLEFT', survivalContent, 'TOPLEFT', LAYOUT.ROW_INDENT, yOffset)
    label:SetText(stat.label)
    AddStatisticTooltip(label, stat.tooltipKey)

    local text = survivalContent:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
    text:SetPoint('TOPRIGHT', survivalContent, 'TOPRIGHT', -LAYOUT.ROW_INDENT, yOffset)
    if stat.key == "duelsWinPercent" then
      -- format percentage stats differently
      local duelWinPercent = CharacterStats:GetStat(stat.key)
      if duelWinPercent % 1 == 0 then
        text:SetText(string.format('%d%%', duelWinPercent))
      else
        text:SetText(string.format('%.1f%%', duelWinPercent))
      end
    else
      text:SetText(formatNumberWithCommas(CharacterStats:GetStat(stat.key)))
    end

    -- Create radio button for this survival statistic
    local radio = CreateFrame('CheckButton', nil, survivalContent, 'UIRadioButtonTemplate')
    radio:SetPoint('LEFT', label, 'LEFT', -20, 0)
    local settingName = 'showMainStatisticsPanel' .. string.gsub(stat.key, '^%l', string.upper)
    radio:SetChecked(false) -- Initialize as unchecked, will be updated by updateRadioButtons()
    radioButtons[settingName] = radio
    radio:SetScript('OnClick', function(self)
      tempSettings[settingName] = self:GetChecked()
      GLOBAL_SETTINGS[settingName] = self:GetChecked()
      -- Trigger immediate update of main screen statistics
      if UltraHardcoreStatsFrame and UltraHardcoreStatsFrame.UpdateRowVisibility then
        UltraHardcoreStatsFrame.UpdateRowVisibility()
      end
    end)

    survivalTexts[stat.key] = text

    yOffset = yOffset - LAYOUT.ROW_HEIGHT
  end

  -- Correct survival content height now that we know the total rows
  local survivalRows = #survivalStats
  survivalContent:SetSize(450, survivalRows * LAYOUT.ROW_HEIGHT + LAYOUT.CONTENT_PADDING * 2)

  -- Create modern WoW-style XP gained section (no accordion functionality)
  local xpGainedHeader = CreateFrame('Frame', nil, statsScrollChild, 'BackdropTemplate')
  xpGainedHeader:SetSize(470, LAYOUT.SECTION_HEADER_HEIGHT)
  -- Anchor directly below Survival content to avoid overlap
  xpGainedHeader:SetPoint('TOPLEFT', survivalContent, 'BOTTOMLEFT', -LAYOUT.CONTENT_INDENT, -LAYOUT.SECTION_SPACING)
  -- Modern WoW row styling with rounded corners and greyish background
  xpGainedHeader:SetBackdrop({
    bgFile = 'Interface\\DialogFrame\\UI-DialogBox-Background',
    edgeFile = 'Interface\\DialogFrame\\UI-DialogBox-Border',
    tile = true,
    tileSize = 32,
    edgeSize = 16,
    insets = {
      left = 4,
      right = 4,
      top = 4,
      bottom = 4,
    },
  })
  xpGainedHeader:SetBackdropColor(0.2, 0.2, 0.2, 0.9) -- Dark greyish background
  xpGainedHeader:SetBackdropBorderColor(0.6, 0.6, 0.6, 1) -- Light grey border
  -- Create header text
  local xpGainedLabel = xpGainedHeader:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  xpGainedLabel:SetPoint('LEFT', xpGainedHeader, 'LEFT', 12, 0)
  xpGainedLabel:SetText('XP Gained Without Option Breakdown')

  -- Create collapsible content frame for XP breakdown
  local xpGainedContent = CreateFrame('Frame', nil, statsScrollChild, 'BackdropTemplate')
  xpGainedContent:SetSize(450, 15 * LAYOUT.ROW_HEIGHT + LAYOUT.CONTENT_PADDING * 2 + 40) -- Added 40px extra gap at bottom
  -- Position content directly under its header with consistent padding
  xpGainedContent:SetPoint('TOPLEFT', xpGainedHeader, 'BOTTOMLEFT', LAYOUT.CONTENT_INDENT, -LAYOUT.CONTENT_PADDING)
  xpGainedContent:Show() -- Show by default
  -- Modern content frame styling
  xpGainedContent:SetBackdrop({
    bgFile = 'Interface\\Buttons\\UI-Listbox-Empty',
    edgeFile = 'Interface\\Buttons\\UI-Listbox-Empty',
    tile = true,
    tileSize = 16,
    edgeSize = 8,
    insets = {
      left = 4,
      right = 4,
      top = 4,
      bottom = 4,
    },
  })

  -- Create XP breakdown display inside the content frame
  local xpBreakdownLabels = {}
  local xpBreakdownTexts = {}
  local xpSectionHeaders = {}

  -- Mapping of setting names to display names (ordered by preset sections)
  local settingDisplayNames = {
    -- Lite section
    hidePlayerFrame = 'Hide Player Frame',
    showTunnelVision = 'Tunnel Vision',
    -- Recommended section
    hideTargetFrame = 'Hide Target Frame',
    hideTargetTooltip = 'Hide Target Tooltips',
    disableNameplateHealth = 'Disable Nameplates',
    showDazedEffect = 'Show Dazed Effect',
    hideGroupHealth = 'Use UHC Party Frames',
    hideMinimap = 'Hide Minimap',
    -- Extreme section
    petsDiePermanently = 'Pets Die Permanently',
    hideActionBars = 'Hide Action Bars',
    tunnelVisionMaxStrata = 'Tunnel Vision Covers Everything',
    routePlanner = 'Route Planner',
    -- Experimental section
    hideBreathIndicator = 'Use UHC Breath Indicator',
    showCritScreenMoveEffect = 'Use UHC Incoming Crit Effect',
    showFullHealthIndicator = 'Use UHC Full Health Indicator',
    hideCustomResourceBar = 'Hide Custom Resource Bar',
    showIncomingDamageEffect = 'Use UHC Incoming Damage Effect',
    showHealingIndicator = 'Use UHC Incoming Healing Effect',
  }

  -- Define preset sections with their settings (limit to up to Extreme)
  local allSectionsSimple = GetPresetSections('simple', false) -- Exclude Misc section
  local presetSections = {}
  for i, section in ipairs(allSectionsSimple) do
    if i <= 3 then
      table.insert(presetSections, section)
    else
      break
    end
  end
  -- Create XP breakdown entries with section headers
  local yOffset = -LAYOUT.CONTENT_PADDING
  for sectionIndex, section in ipairs(presetSections) do
    -- Create section header
    local sectionHeader = xpGainedContent:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
    sectionHeader:SetPoint('TOPLEFT', xpGainedContent, 'TOPLEFT', LAYOUT.ROW_INDENT, yOffset)
    sectionHeader:SetText(section.title)
    sectionHeader:SetTextColor(1, 1, 0.5) -- Light yellow color for headers
    xpSectionHeaders[sectionIndex] = sectionHeader
    yOffset = yOffset - LAYOUT.ROW_HEIGHT

    -- Create settings for this section
    for _, settingName in ipairs(section.settings) do
      local displayName = settingDisplayNames[settingName]
      if displayName then
        local label = xpGainedContent:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
        label:SetPoint('TOPLEFT', xpGainedContent, 'TOPLEFT', LAYOUT.ROW_INDENT + 12, yOffset) -- Indented more for settings
        label:SetText(displayName .. ':')

        local text = xpGainedContent:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
        text:SetPoint('TOPRIGHT', xpGainedContent, 'TOPRIGHT', -LAYOUT.ROW_INDENT, yOffset)
        -- this is fragile, but similar logic is used below
        local xpVariable = 'xpGainedWithoutOption' .. string.gsub(settingName, '^%l', string.upper)
        text:SetText(formatNumberWithCommas(CharacterStats:GetStat(xpVariable)))

        xpBreakdownLabels[settingName] = label
        xpBreakdownTexts[settingName] = text

        yOffset = yOffset - LAYOUT.ROW_HEIGHT
      end
    end

    -- Add extra space between sections
    yOffset = yOffset - LAYOUT.SECTION_SPACING
  end

  -- Set initial positioning after all statistics are created
  -- All sections are always visible

  -- Function to update XP breakdown display
  local function UpdateXPBreakdown()
    -- Define preset sections with their settings (limit to up to Extreme, same order as TrackXPPerSetting.lua)
    local allSectionsExtended = GetPresetSections('extended', false) -- Exclude Misc section, use extended titles
    local presetSections = {}
    for i, section in ipairs(allSectionsExtended) do
      if i <= 3 then
        table.insert(presetSections, section)
      else
        break
      end
    end
    -- Update display organized by preset sections
    local yOffset = -LAYOUT.CONTENT_PADDING
    for sectionIndex, section in ipairs(presetSections) do
      -- Position section header
      local sectionHeader = xpSectionHeaders[sectionIndex]
      if sectionHeader then
        sectionHeader:SetPoint('TOPLEFT', xpGainedContent, 'TOPLEFT', LAYOUT.ROW_INDENT, yOffset)
        yOffset = yOffset - LAYOUT.ROW_HEIGHT
      end

      -- Position settings for this section
      for _, settingName in ipairs(section.settings) do
        local textElement = xpBreakdownTexts[settingName]
        local labelElement = xpBreakdownLabels[settingName]

        if textElement and labelElement then
          -- Convert setting name to proper variable name format
          local xpVariable =
            'xpGainedWithoutOption' .. string.gsub(settingName, '^%l', string.upper)
          -- Handle camelCase conversion for multi-word settings
          xpVariable = string.gsub(xpVariable, '(%u)(%l)', '%1%2')

          local xpGained = CharacterStats:GetStat(xpVariable) or 0

          -- Position both label and text (indented for settings)
          labelElement:SetPoint(
            'TOPLEFT',
            xpGainedContent,
            'TOPLEFT',
            LAYOUT.ROW_INDENT + 12,
            yOffset
          )
          textElement:SetPoint('TOPRIGHT', xpGainedContent, 'TOPRIGHT', -LAYOUT.ROW_INDENT, yOffset)
          textElement:SetText(formatNumberWithCommas(xpGained))
          yOffset = yOffset - LAYOUT.ROW_HEIGHT
        end
      end

      -- Add extra space between sections
      yOffset = yOffset - LAYOUT.SECTION_SPACING
    end
  end

  -- Update the lowest health display
  local function UpdateLowestHealthDisplay()
    if not UltraHardcoreDB then
      LoadDBData()
    end
    -- Refresh current preset status in case settings changed
    UpdateCurrentPresetDisplay()

    -- Update level display
    if levelText then
      local playerLevel = UnitLevel('player') or 1
      levelText:SetText(formatNumberWithCommas(playerLevel))
    end

    if lowestHealthText then
      local currentLowestHealth = CharacterStats:GetStat('lowestHealth') or 100
      lowestHealthText:SetText(string.format('%.1f', currentLowestHealth) .. '%')
    end

    if lowestHealthThisLevelText then
      local currentLowestHealthThisLevel = CharacterStats:GetStat('lowestHealthThisLevel') or 100
      lowestHealthThisLevelText:SetText(string.format('%.1f', currentLowestHealthThisLevel) .. '%')
    end

    if lowestHealthThisSessionText then
      local currentLowestHealthThisSession =
        CharacterStats:GetStat('lowestHealthThisSession') or 100
      lowestHealthThisSessionText:SetText(
        string.format('%.1f', currentLowestHealthThisSession) .. '%'
      )
    end

    -- Update pet death display
    if petDeathsText then
      local currentPetDeaths = CharacterStats:GetStat('petDeaths') or 0
      petDeathsText:SetText(formatNumberWithCommas(currentPetDeaths))
    end

    if elitesSlainText then
      local elites = CharacterStats:GetStat('elitesSlain') or 0
      elitesSlainText:SetText(formatNumberWithCommas(elites))
    end

    if rareElitesSlainText then
      local rareElites = CharacterStats:GetStat('rareElitesSlain') or 0
      rareElitesSlainText:SetText(formatNumberWithCommas(rareElites))
    end

    if worldBossesSlainText then
      local worldBosses = CharacterStats:GetStat('worldBossesSlain') or 0
      worldBossesSlainText:SetText(formatNumberWithCommas(worldBosses))
    end

    if enemiesSlainText then
      local enemies = CharacterStats:GetStat('enemiesSlain') or 0
      enemiesSlainText:SetText(formatNumberWithCommas(enemies))
    end

    if dungeonBossesText then
      local dungeonBosses = CharacterStats:GetStat('dungeonBossesKilled') or 0
      dungeonBossesText:SetText(formatNumberWithCommas(dungeonBosses))
    end

    if dungeonsCompletedText then
      local dungeonsCompleted = CharacterStats:GetStat('dungeonsCompleted') or 0
      dungeonsCompletedText:SetText(formatNumberWithCommas(dungeonsCompleted))
    end

    -- Update highest crit value
    if highestCritText then
      local highestCrit = CharacterStats:GetStat('highestCritValue') or 0
      highestCritText:SetText(formatNumberWithCommas(highestCrit))
    end

    -- Update highest heal crit value
    if highestHealCritText then
      local highestHealCrit = CharacterStats:GetStat('highestHealCritValue') or 0
      highestHealCritText:SetText(formatNumberWithCommas(highestHealCrit))
    end

    -- Update XP breakdown (always visible now)
    UpdateXPBreakdown()

    -- Update survival statistics
    if survivalTexts then
      for _, stat in ipairs(survivalStats) do
        local value = CharacterStats:GetStat(stat.key) or 0
        if survivalTexts[stat.key] then
          if stat.key == 'duelsWinPercent' then
            if value % 1 == 0 then
              survivalTexts[stat.key]:SetText(string.format('%d%%', value))
            else
              survivalTexts[stat.key]:SetText(string.format('%.1f%%', value))
            end
          else
            survivalTexts[stat.key]:SetText(formatNumberWithCommas(value))
          end
        end
      end
    end
  end

  -- Share button for Statistics tab
  local shareButton = CreateFrame('Button', nil, tabContents[1], 'UIPanelButtonTemplate')
  shareButton:SetSize(80, 30)
  shareButton:SetPoint('BOTTOM', tabContents[1], 'BOTTOM', 0, -40)
  shareButton:SetText('Share')

  -- Add tooltip
  shareButton:SetScript('OnEnter', function()
    GameTooltip:SetOwner(shareButton, 'ANCHOR_RIGHT')
    GameTooltip:SetText('Share UHC Stats to Chat')
    GameTooltip:Show()
  end)
  shareButton:SetScript('OnLeave', function()
    GameTooltip:Hide()
  end)

  shareButton:SetScript('OnClick', function()
    if CharacterStats and CharacterStats.LogStatsToChat then
      CharacterStats:LogStatsToChat()
    else
      print('UHC - CharacterStats not available. Please reload UI.')
    end
  end)

  -- Export functions for use by Settings.lua
  _G.UpdateLowestHealthDisplay = UpdateLowestHealthDisplay
  _G.UpdateXPBreakdown = UpdateXPBreakdown
end
