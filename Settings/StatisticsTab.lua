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
  -- Survival section
  healthPotionsUsed = 'Number of health potions you have consumed',
  bandagesApplied = 'Number of bandages you have used to heal',
  targetDummiesUsed = 'Number of target dummies you have used',
  grenadesUsed = 'Number of grenades you have thrown',
  partyDeathsWitnessed = 'Number of party member deaths you have witnessed',
  closeEscapes = "Number of times you've seen the final tunnel vision phase (<20% health)",
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
  statsScrollFrame:SetSize(340, 460)
  statsScrollFrame:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', 10, -10)
  statsScrollFrame:SetPoint('BOTTOMRIGHT', statsFrame, 'BOTTOMRIGHT', -2, 10)

  -- Create scroll child frame
  local statsScrollChild = CreateFrame('Frame', nil, statsScrollFrame)
  statsScrollChild:SetSize(500, 1100) -- Increased height to accommodate proper bottom spacing for XP section
  statsScrollFrame:SetScrollChild(statsScrollChild)

  -- Create modern WoW-style lowest health section (no accordion functionality)
  local lowestHealthHeader = CreateFrame('Frame', nil, statsScrollChild, 'BackdropTemplate')
  lowestHealthHeader:SetSize(470, LAYOUT.SECTION_HEADER_HEIGHT)
  lowestHealthHeader:SetPoint('TOPLEFT', statsScrollChild, 'TOPLEFT', 0, -5)

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
  lowestHealthContent:SetPoint('TOPLEFT', statsScrollChild, 'TOPLEFT', LAYOUT.CONTENT_INDENT, -38)
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
  levelText:SetText(formatNumberWithCommas(1))

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
  lowestHealthText:SetText(string.format('%.1f', lowestHealthScore or 100) .. '%')

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
  lowestHealthThisLevelLabel:SetText('This Level (Beta):')
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
  lowestHealthThisLevelText:SetText('100.0%')

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
  lowestHealthThisSessionLabel:SetText('This Session (Beta):')
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
  lowestHealthThisSessionText:SetText('100.0%')

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
  petDeathsText:SetText(formatNumberWithCommas(0))

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
  enemiesSlainHeader:SetPoint('TOPLEFT', statsScrollChild, 'TOPLEFT', 0, -179)

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
  enemiesSlainContent:SetSize(450, 7 * LAYOUT.ROW_HEIGHT + LAYOUT.CONTENT_PADDING * 2) -- 7 rows + padding (added rare elites and world bosses)
  enemiesSlainContent:SetPoint('TOPLEFT', statsScrollChild, 'TOPLEFT', LAYOUT.CONTENT_INDENT, -212)
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
  enemiesSlainText:SetText(formatNumberWithCommas(0))

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
  elitesSlainText:SetText(formatNumberWithCommas(0))

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
  rareElitesSlainText:SetText(formatNumberWithCommas(0))

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
  worldBossesSlainText:SetText(formatNumberWithCommas(0))

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
  dungeonBossesText:SetText(formatNumberWithCommas(0))

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
  dungeonsCompletedText:SetText(formatNumberWithCommas(0))

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
  highestCritText:SetText(formatNumberWithCommas(0))

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

  -- Create modern WoW-style Survival section (no accordion functionality)
  local survivalHeader = CreateFrame('Frame', nil, statsScrollChild, 'BackdropTemplate')
  survivalHeader:SetSize(470, LAYOUT.SECTION_HEADER_HEIGHT)
  survivalHeader:SetPoint('TOPLEFT', statsScrollChild, 'TOPLEFT', 0, -399) -- Moved down by 50px for new rows
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
  survivalContent:SetSize(450, 5 * LAYOUT.ROW_HEIGHT + LAYOUT.CONTENT_PADDING * 2) -- Height for 5 items
  survivalContent:SetPoint('TOPLEFT', statsScrollChild, 'TOPLEFT', LAYOUT.CONTENT_INDENT, -432) -- Moved down by 50px for new rows
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
    key = 'maxTunnelVisionOverlayShown',
    label = 'Close Escapes:',
    tooltipKey = 'closeEscapes',
  } }

  local yOffset = -LAYOUT.CONTENT_PADDING
  for _, stat in ipairs(survivalStats) do
    local label = survivalContent:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
    label:SetPoint('TOPLEFT', survivalContent, 'TOPLEFT', LAYOUT.ROW_INDENT, yOffset)
    label:SetText(stat.label)
    AddStatisticTooltip(label, stat.tooltipKey)

    local text = survivalContent:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
    text:SetPoint('TOPRIGHT', survivalContent, 'TOPRIGHT', -LAYOUT.ROW_INDENT, yOffset)
    text:SetText(formatNumberWithCommas(0))

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

  -- Create modern WoW-style XP gained section (no accordion functionality)
  local xpGainedHeader = CreateFrame('Frame', nil, statsScrollChild, 'BackdropTemplate')
  xpGainedHeader:SetSize(470, LAYOUT.SECTION_HEADER_HEIGHT)
  xpGainedHeader:SetPoint('TOPLEFT', statsScrollChild, 'TOPLEFT', 0, -593) -- Added 20px gap after Close Escapes
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
  xpGainedContent:SetSize(450, 20 * LAYOUT.ROW_HEIGHT + LAYOUT.CONTENT_PADDING * 2 + 40) -- Added 40px extra gap at bottom
  xpGainedContent:SetPoint('TOPLEFT', statsScrollChild, 'TOPLEFT', LAYOUT.CONTENT_INDENT, -626) -- Adjusted to maintain proper gap from header
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
    -- Ultra section
    petsDiePermanently = 'Pets Die Permanently',
    hideActionBars = 'Hide Action Bars',
    tunnelVisionMaxStrata = 'Tunnel Vision Covers Everything',
    -- Experimental section
    hideBreathIndicator = 'Use UHC Breath Indicator',
    showCritScreenMoveEffect = 'Use UHC Incoming Crit Effect',
    showFullHealthIndicator = 'Use UHC Full Health Indicator',
    showIncomingDamageEffect = 'Use UHC Incoming Damage Effect',
    showHealingIndicator = 'Use UHC Incoming Healing Effect',
  }

  -- Define preset sections with their settings
  local presetSections = GetPresetSections('simple', false) -- Exclude Misc section
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
        text:SetText(formatNumberWithCommas(0))

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
    -- Define preset sections with their settings (same order as TrackXPPerSetting.lua)
    local presetSections = GetPresetSections('extended', false) -- Exclude Misc section, use extended titles
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

    -- Update XP breakdown (always visible now)
    UpdateXPBreakdown()

    -- Update survival statistics
    if survivalTexts then
      for _, stat in ipairs(survivalStats) do
        local value = CharacterStats:GetStat(stat.key) or 0
        if survivalTexts[stat.key] then
          survivalTexts[stat.key]:SetText(formatNumberWithCommas(value))
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
