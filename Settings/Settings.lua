-- Global variables for radio button management (global so StatisticsTab.lua can access them)
radioButtons = {}

-- Helper function to format numbers with comma separators (global so StatisticsTab.lua can access it)
function formatNumberWithCommas(number)
  if type(number) ~= 'number' then
    number = tonumber(number) or 0
  end

  -- Handle negative numbers
  local isNegative = number < 0
  if isNegative then
    number = -number
  end

  -- Convert to string and add commas
  local formatted = tostring(math.floor(number))
  local k
  while true do
    formatted, k = string.gsub(formatted, '^(-?%d+)(%d%d%d)', '%1,%2')
    if k == 0 then
      break
    end
  end

  -- Add back negative sign if needed
  if isNegative then
    formatted = '-' .. formatted
  end

  return formatted
end

-- Layout constants for consistent spacing (global so StatisticsTab.lua can access it)
LAYOUT = {
  SECTION_HEADER_HEIGHT = 28,
  ROW_HEIGHT = 25,
  HEADER_TO_CONTENT_GAP = 5,
  SECTION_SPACING = 10,
  CONTENT_INDENT = 20,
  ROW_INDENT = 12,
  CONTENT_PADDING = 8,
}

-- Helper function to calculate consistent positioning (global so StatisticsTab.lua can access it)
function calculatePosition(sectionIndex, rowIndex)
  -- Calculate cumulative height of previous sections
  local previousSectionsHeight = 0
  for i = 1, sectionIndex - 1 do
    previousSectionsHeight =
      previousSectionsHeight + LAYOUT.SECTION_HEADER_HEIGHT + LAYOUT.HEADER_TO_CONTENT_GAP
    if i == 1 then
      previousSectionsHeight =
        previousSectionsHeight + (5 * LAYOUT.ROW_HEIGHT + LAYOUT.CONTENT_PADDING * 2) -- Lowest Health
    elseif i == 2 then
      previousSectionsHeight =
        previousSectionsHeight + (4 * LAYOUT.ROW_HEIGHT + LAYOUT.CONTENT_PADDING * 2) -- Enemies Slain
    elseif i == 3 then
      previousSectionsHeight =
        previousSectionsHeight + (5 * LAYOUT.ROW_HEIGHT + LAYOUT.CONTENT_PADDING * 2) -- Survival
    end
    previousSectionsHeight = previousSectionsHeight + LAYOUT.SECTION_SPACING
  end

  local headerY = -5 - previousSectionsHeight
  local contentY = headerY - LAYOUT.SECTION_HEADER_HEIGHT - LAYOUT.HEADER_TO_CONTENT_GAP
  local rowY = contentY - LAYOUT.CONTENT_PADDING - (rowIndex - 1) * LAYOUT.ROW_HEIGHT
  return headerY, contentY, rowY
end

-- Helper function to determine if a radio button should be checked
local function shouldRadioBeChecked(settingName, settings)
  if settings[settingName] ~= nil then
    -- Use the actual setting value
    return settings[settingName]
  else
    -- Apply default behavior based on the setting
    -- These default to true (show unless explicitly false)
    if settingName == 'showMainStatisticsPanelLevel' or settingName == 'showMainStatisticsPanelLowestHealth' or settingName == 'showMainStatisticsPanelEnemiesSlain' or settingName == 'showMainStatisticsPanelDungeonsCompleted' or settingName == 'showMainStatisticsPanelHighestCritValue' or settingName == 'showMainStatisticsPanelMaxTunnelVisionOverlayShown' then
      return true
    else
      -- These default to false (hide unless explicitly true)
      return false
    end
  end
end

local settingsCheckboxOptions = { {
  -- Lite Preset Settings
  name = 'UHC Player Frame',
  dbSettingsValueName = 'hidePlayerFrame',
  tooltip = 'Minimalistic player frame to hide own health',
}, {
  name = 'Tunnel Vision',
  dbSettingsValueName = 'showTunnelVision',
  tooltip = 'The screen gets darker as you get closer to death',
}, {
  -- Recommended Preset Settings
  name = 'Hide Target Frame',
  dbSettingsValueName = 'hideTargetFrame',
  tooltip = "Target frame is not visible, so you can't see the target's health or level",
}, {
  name = 'Hide Target Tooltips',
  dbSettingsValueName = 'hideTargetTooltip',
  tooltip = "Target tooltips are not visible, so you can't see the target's health or level",
}, {
  name = 'Disable Nameplates',
  dbSettingsValueName = 'disableNameplateHealth',
  tooltip = 'Turns off nameplates, hiding healthbars above units',
}, {
  name = 'Show Dazed effect',
  dbSettingsValueName = 'showDazedEffect',
  tooltip = 'A blue blur effect appears around your character when dazed',
}, {
  name = 'UHC Party Frames',
  dbSettingsValueName = 'hideGroupHealth',
  tooltip = 'Party healthbars are hidden and replaced with a custom health indicator',
}, {
  name = 'Hide Minimap',
  dbSettingsValueName = 'hideMinimap',
  tooltip = 'Makes gathering resources a lot more challenging by hiding the minimap',
}, {
  name = 'UHC Breath Indicator',
  dbSettingsValueName = 'hideBreathIndicator',
  tooltip = 'Replace the breath bar with a increasingly red screen overlay when underwater',
}, {
  -- Ultra Preset Settings
  name = 'Pets Die Permanently',
  dbSettingsValueName = 'petsDiePermanently',
  tooltip = "Pets can't be resurrected when they are killed",
}, {
  name = 'Hide Action Bars when not resting',
  dbSettingsValueName = 'hideActionBars',
  tooltip = 'Hide action bars when not resting or near a campfire',
}, {
  name = 'Tunnel Vision Covers Everything',
  dbSettingsValueName = 'tunnelVisionMaxStrata',
  tooltip = 'Tunnel Vision covers all UI elements',
}, {
  -- Experimental Preset Settings
  name = 'UHC Incoming Crit Effect',
  dbSettingsValueName = 'showCritScreenMoveEffect',
  tooltip = 'A red screen rotation effect appears when you take a critical hit',
}, {
  name = 'UHC Full Health Indicator',
  dbSettingsValueName = 'showFullHealthIndicator',
  tooltip = 'The edges of the screen glow when you are at full health',
}, {
  name = 'UHC Incoming Damage Effect',
  dbSettingsValueName = 'showIncomingDamageEffect',
  tooltip = 'Various screen effects on incoming damage',
}, {
  name = 'UHC Incoming Healing Effect',
  dbSettingsValueName = 'showHealingIndicator',
  tooltip = 'Gold glow on the edges of the screen when you are healed',
}, {
  name = 'First Person Camera',
  dbSettingsValueName = 'setFirstPersonCamera',
  tooltip = 'Play in first person mode, allows to look around for briew records of time',
}, {
  -- Misc Settings (no preset button)
  name = 'On Screen Statistics',
  dbSettingsValueName = 'showOnScreenStatistics',
  tooltip = 'Show important UHC statistics on the screen at all times',
}, {
  name = 'Announce Level Up to Guild',
  dbSettingsValueName = 'announceLevelUpToGuild',
  tooltip = 'Announces level ups to guild chat every 10th level',
}, {
  name = 'Hide UI Error Messages',
  dbSettingsValueName = 'hideUIErrors',
  tooltip = 'Hide error messages that appear on screen (like "Target is too far away")',
}, {
  name = 'Show Clock Even When Map is Hidden',
  dbSettingsValueName = 'showClockEvenWhenMapHidden',
  tooltip = 'If Hide Minimap is enabled, keep the clock on display instead of hiding it',
}, {
  name = 'Announce Party Deaths on Group Join',
  dbSettingsValueName = 'announcePartyDeathsOnGroupJoin',
  tooltip = 'Automatically announce party death statistics when joining a group',
}, {
  name = 'Announce Dungeons Completed on Group Join',
  dbSettingsValueName = 'announceDungeonsCompletedOnGroupJoin',
  tooltip = 'Automatically announce dungeons completed statistics when joining a group',
}, {
  name = 'Buff Bar on Resource Bar',
  dbSettingsValueName = 'buffBarOnResourceBar',
  tooltip = 'Position player buff bar on top of the custom resource bar',
}, {
  name = 'Highest Crit Appreciation Soundbite',
  dbSettingsValueName = 'newHighCritAppreciationSoundbite',
  tooltip = 'Play a soundbite when you achieve a new highest crit value',
}, {
  name = 'Party Death Soundbite',
  dbSettingsValueName = 'playPartyDeathSoundbite',
  tooltip = 'Play a soundbite when a party member dies',
}, {
  name = 'Player Death Soundbite',
  dbSettingsValueName = 'playPlayerDeathSoundbite',
  tooltip = 'Play a soundbite when you die',
}, {
  name = 'Spooky Tunnel Vision',
  dbSettingsValueName = 'spookyTunnelVision',
  tooltip = 'Use Halloween-themed tunnel vision overlay for ultra spooky experience',
}, {
  name = 'Roach Hearthstone In Party Combat',
  dbSettingsValueName = 'roachHearthstoneInPartyCombat',
  tooltip = 'Show a roach overlay on screen when using hearthstone whilst a party member is in combat',
} }

local presets = { {
  -- Preset 1: Lite
  hidePlayerFrame = true,
  hideMinimap = false,
  hideTargetFrame = false,
  hideTargetTooltip = false,
  showTunnelVision = true,
  tunnelVisionMaxStrata = false,
  showDazedEffect = false,
  showCritScreenMoveEffect = false,
  hideActionBars = false,
  hideGroupHealth = false,
  petsDiePermanently = false,
  showFullHealthIndicator = false,
  disableNameplateHealth = false,
  showIncomingDamageEffect = false,
  showHealingIndicator = false,
  hideBreathIndicator = false,
  setFirstPersonCamera = false,
}, {
  -- Preset 2: Recommended
  hidePlayerFrame = true,
  hideMinimap = true,
  hideTargetFrame = true,
  hideTargetTooltip = true,
  showTunnelVision = true,
  tunnelVisionMaxStrata = false,
  showDazedEffect = true,
  hideGroupHealth = true,
  showCritScreenMoveEffect = false,
  hideActionBars = false,
  petsDiePermanently = false,
  showFullHealthIndicator = false,
  disableNameplateHealth = true,
  showIncomingDamageEffect = false,
  showHealingIndicator = false,
  hideBreathIndicator = true,
  setFirstPersonCamera = false,
}, {
  -- Preset 3: Ultra
  hidePlayerFrame = true,
  hideMinimap = true,
  hideTargetFrame = true,
  hideTargetTooltip = true,
  showTunnelVision = true,
  tunnelVisionMaxStrata = true,
  showDazedEffect = true,
  hideGroupHealth = true,
  hideBreathIndicator = true,
  petsDiePermanently = true,
  showCritScreenMoveEffect = false,
  hideActionBars = true,
  showFullHealthIndicator = false,
  disableNameplateHealth = true,
  showIncomingDamageEffect = false,
  showHealingIndicator = false,
  setFirstPersonCamera = false,
  newHighCritAppreciationSoundbite = true,
} }

-- Temporary settings storage and initialization function (global so StatisticsTab.lua can access it)
tempSettings = {}

local function initializeTempSettings()
  -- Copy current GLOBAL_SETTINGS to temporary storage
  for key, value in pairs(GLOBAL_SETTINGS) do
    tempSettings[key] = value
  end

  -- Ensure all radio button settings are initialized with their correct values
  for settingName, _ in pairs(radioButtons) do
    if tempSettings[settingName] == nil then
      tempSettings[settingName] = shouldRadioBeChecked(settingName, GLOBAL_SETTINGS)
    end
  end
end

local settingsFrame = CreateFrame('Frame', nil, UIParent, 'BackdropTemplate')
settingsFrame:SetSize(560, 640)
settingsFrame:SetMovable(true)
settingsFrame:EnableMouse(true)
settingsFrame:RegisterForDrag('LeftButton')
settingsFrame:SetScript('OnDragStart', function(self)
  self:StartMoving()
end)
settingsFrame:SetScript('OnDragStop', function(self)
  self:StopMovingOrSizing()
end)
settingsFrame:SetPoint('CENTER', UIParent, 'CENTER', 0, 30) -- Moved up by 30 pixels from center
settingsFrame:Hide()
settingsFrame:SetFrameStrata('DIALOG') -- Higher layer priority to appear above pet action bar
settingsFrame:SetFrameLevel(15) -- Higher level to ensure it's above pet action bar
settingsFrame:SetBackdrop({
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

local titleBar = CreateFrame('Frame', nil, settingsFrame, 'BackdropTemplate')
titleBar:SetSize(560, 50) -- Increased height for header
titleBar:SetPoint('TOP', settingsFrame, 'TOP')
titleBar:SetFrameStrata('DIALOG') -- Higher layer priority
titleBar:SetFrameLevel(20) -- Ensure it's above the main frame and tabs
titleBar:SetBackdrop({
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
titleBar:SetBackdropColor(0, 0, 0, 1) -- Pure black background, fully opaque
titleBar:SetBackdropBorderColor(0.6, 0.6, 0.6, 1) -- Light grey border
-- Create title image instead of text
local settingsTitleImage = titleBar:CreateTexture(nil, 'OVERLAY')
settingsTitleImage:SetSize(300, 40) -- Adjust size to fit nicely in title bar
settingsTitleImage:SetPoint('CENTER', titleBar, 'CENTER', 0, 0)
settingsTitleImage:SetTexture('Interface\\AddOns\\UltraHardcore\\Textures\\ultra-hc-title.png')
settingsTitleImage:SetTexCoord(0, 1, 0, 1) -- Use full texture
-- Create proper binder tabs that overlap the main frame
local tabButtons = {}
tabContents = {}
local activeTab = 1

-- Create proper folder tabs with angled edges
local function createTabButton(text, index)
  local button = CreateFrame('Button', nil, settingsFrame, 'BackdropTemplate')
  button:SetSize(110, 35)
  button:SetPoint('TOP', settingsFrame, 'TOP', (index - 3) * 110, -45) -- Position below title bar
  -- Create the main tab background with proper folder tab shape
  button:SetBackdrop({
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

  -- Set the text
  local buttonText = button:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
  buttonText:SetPoint('CENTER', button, 'CENTER', 0, -2)
  buttonText:SetText(text)

  -- Set up click handler
  button:SetScript('OnClick', function()
    -- Hide all tab contents
    for i, content in ipairs(tabContents) do
      content:Hide()
    end

    -- Reset all tab button appearances
    for i, tabButton in ipairs(tabButtons) do
      tabButton:SetBackdropBorderColor(0.5, 0.5, 0.5)
      tabButton:SetAlpha(0.8)
    end

    -- Show selected tab content and highlight button
    tabContents[index]:Show()
    button:SetBackdropBorderColor(1, 1, 0)
    button:SetAlpha(1.0)
    activeTab = index

    -- Initialize X Found Mode tab if it's being shown
    if index == 4 and InitializeXFoundModeTab then
      InitializeXFoundModeTab()
    end
  end)

  -- Set initial appearance
  button:SetBackdropBorderColor(0.5, 0.5, 0.5)
  button:SetAlpha(0.8)

  return button
end

-- Create tab buttons
tabButtons[1] = createTabButton('Statistics', 1)
tabButtons[2] = createTabButton('Settings', 2)
tabButtons[5] = createTabButton('Achievements', 3)
tabButtons[3] = createTabButton('X Found Mode', 4)
tabButtons[4] = createTabButton('Info', 5)

-- Create tab content frames
local function createTabContent(index)
  local content = CreateFrame('Frame', nil, settingsFrame)
  content:SetSize(520, 540)
  content:SetPoint('TOP', settingsFrame, 'TOP', 0, -50) -- Positioned below tabs
  content:Hide()
  return content
end

tabContents[1] = createTabContent(1) -- Statistics tab
tabContents[2] = createTabContent(2) -- Settings tab
tabContents[3] = createTabContent(3) -- Achievements tab
tabContents[4] = createTabContent(4) -- Self Found tab
tabContents[5] = createTabContent(5) -- Info tab
-- Statistics Tab Content is now in StatisticsTab.lua

-- Set initial positioning after all statistics are created
-- All sections are always visible

local closeButton = CreateFrame('Button', nil, titleBar, 'UIPanelCloseButton')
closeButton:SetPoint('RIGHT', titleBar, 'RIGHT', -4, 0)
closeButton:SetSize(32, 32)
closeButton:SetScript('OnClick', function()
  -- Discard temporary changes by reinitializing temp settings
  initializeTempSettings()
  settingsFrame:Hide()
end)

-- Settings Tab Content
-- Frame for selectable preset buttons
local presetButtonsFrame = CreateFrame('Frame', nil, tabContents[2])
presetButtonsFrame:SetSize(420, 150)
presetButtonsFrame:SetPoint('TOP', tabContents[2], 'TOP', 0, -10)

local checkboxes = {}
local presetButtons = {}
local selectedPreset = nil

local function updateCheckboxes()
  for _, checkboxItem in ipairs(settingsCheckboxOptions) do
    local checkbox = checkboxes[checkboxItem.dbSettingsValueName]
    if checkbox then
      checkbox:SetChecked(tempSettings[checkboxItem.dbSettingsValueName])
    end
  end
end

local function updateRadioButtons()
  -- Update all radio buttons using the stored references
  for settingName, radio in pairs(radioButtons) do
    if radio then
      local isChecked = tempSettings[settingName] or false
      radio:SetChecked(isChecked)
      -- Also update GLOBAL_SETTINGS for immediate effect
      GLOBAL_SETTINGS[settingName] = tempSettings[settingName]
    end
  end
end

local function applyPreset(presetIndex)
  if not presets[presetIndex] then return end

  -- Copy preset to temporary settings
  for key, value in pairs(presets[presetIndex]) do
    tempSettings[key] = value
  end

  -- Apply Interface Status Text rule: always set to None when hidePlayerFrame is true
  if tempSettings.hidePlayerFrame then
    SetCVar('statusText', '0')
  end

  -- Update checkboxes
  updateCheckboxes()
  updateRadioButtons()

  -- Highlight the selected preset button
  if selectedPreset then
    selectedPreset:SetBackdropBorderColor(0.5, 0.5, 0.5) -- Reset previous
  end
  selectedPreset = presetButtons[presetIndex]
  selectedPreset:SetBackdropBorderColor(1, 1, 0) -- Highlight new
end

-- Create preset buttons
local presetIcons =
  {
    'Interface\\AddOns\\UltraHardcore\\textures\\skull1_100_halloween.png',
    'Interface\\AddOns\\UltraHardcore\\textures\\skull2_100_halloween.png',
    'Interface\\AddOns\\UltraHardcore\\textures\\skull3_100_halloween.png',
  }

local buttonSize = 100 -- Increased size for better visibility
local spacing = 10 -- Spacing between the buttons
local totalWidth = 360 -- Total width of the frame for preset buttons
local textYOffset = -5 -- Distance between button and text
for i = 1, 3 do
  local button = CreateFrame('Button', nil, presetButtonsFrame, 'BackdropTemplate')
  button:SetSize(buttonSize, buttonSize)

  -- Position buttons evenly (left, center, right)
  if i == 1 then
    button:SetPoint('LEFT', presetButtonsFrame, 'LEFT', spacing, -20) -- Left
  elseif i == 2 then
    button:SetPoint('CENTER', presetButtonsFrame, 'CENTER', 0, -20) -- Centered
  elseif i == 3 then
    button:SetPoint('RIGHT', presetButtonsFrame, 'RIGHT', -spacing, -20) -- Right
  end

  button:SetBackdrop({
    edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border',
    edgeSize = 10,
  })
  button:SetBackdropBorderColor(0.5, 0.5, 0.5)

  local icon = button:CreateTexture(nil, 'ARTWORK')
  icon:SetAllPoints()
  icon:SetTexture(presetIcons[i])

  -- Add text below each button
  local presetText = button:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
  presetText:SetPoint('TOP', button, 'BOTTOM', 0, textYOffset) -- Adjust the distance as needed
  if i == 1 then
    presetText:SetText('Lite')
  elseif i == 2 then
    presetText:SetText('Recommended')
  elseif i == 3 then
    presetText:SetText('Ultra')
  end

  button:SetScript('OnClick', function()
    applyPreset(i)
  end)

  presetButtons[i] = button
end

-- ScrollFrame to enable scrolling for settings tab
local scrollFrame = CreateFrame('ScrollFrame', nil, tabContents[2], 'UIPanelScrollFrameTemplate')
scrollFrame:SetPoint('TOPLEFT', tabContents[2], 'TOPLEFT', 10, -190)
scrollFrame:SetPoint('BOTTOMRIGHT', tabContents[2], 'BOTTOMRIGHT', -30, 10)

-- ScrollChild contains all checkboxes
local scrollChild = CreateFrame('Frame')
scrollFrame:SetScrollChild(scrollChild)
-- Calculate height: 5 section headers + all checkboxes + spacing
local totalHeight = (5 * 25) + (#settingsCheckboxOptions * 30) + (5 * 10) + 40 -- Headers + checkboxes + section spacing + padding
scrollChild:SetSize(420, totalHeight)

local function createCheckboxes()
  local yOffset = -10

  -- Define preset sections with their settings (same as statistics section)
  local presetSections = { {
    title = 'Lite:',
    settings = { 'hidePlayerFrame', 'showTunnelVision' },
  }, {
    title = 'Recommended:',
    settings = {
      'hideTargetFrame',
      'hideTargetTooltip',
      'disableNameplateHealth',
      'showDazedEffect',
      'hideGroupHealth',
      'hideMinimap',
      'hideBreathIndicator',
    },
  }, {
    title = 'Ultra:',
    settings = { 'petsDiePermanently', 'hideActionBars', 'tunnelVisionMaxStrata' },
  }, {
    title = 'Experimental:',
    settings = {
      'showCritScreenMoveEffect',
      'showFullHealthIndicator',
      'showIncomingDamageEffect',
      'showHealingIndicator',
      'setFirstPersonCamera',
    },
  }, {
    title = 'Misc:',
    settings = {
      'showOnScreenStatistics',
      'announceLevelUpToGuild',
      'hideUIErrors',
      'showClockEvenWhenMapHidden',
      'announcePartyDeathsOnGroupJoin',
      'announceDungeonsCompletedOnGroupJoin',
      'buffBarOnResourceBar',
      'newHighCritAppreciationSoundbite',
      'playPartyDeathSoundbite',
      'playPlayerDeathSoundbite',
      'spookyTunnelVision',
      'roachHearthstoneInPartyCombat',
    },
  } }

  -- Create sections with headers and checkboxes
  for sectionIndex, section in ipairs(presetSections) do
    -- Create section header
    local sectionHeader = scrollChild:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
    sectionHeader:SetPoint('TOPLEFT', scrollChild, 'TOPLEFT', 10, yOffset)
    sectionHeader:SetText(section.title)
    sectionHeader:SetTextColor(1, 1, 0.5) -- Light yellow color for headers
    yOffset = yOffset - 25

    -- Create checkboxes for this section
    for _, settingName in ipairs(section.settings) do
      -- Find the checkbox item by dbSettingsValueName
      local checkboxItem = nil
      for _, item in ipairs(settingsCheckboxOptions) do
        if item.dbSettingsValueName == settingName then
          checkboxItem = item
          break
        end
      end

      if checkboxItem then
        local checkbox =
          CreateFrame('CheckButton', nil, scrollChild, 'ChatConfigCheckButtonTemplate')
        checkbox:SetPoint('TOPLEFT', scrollChild, 'TOPLEFT', 20, yOffset) -- Indented for settings
        checkbox.Text:SetText(checkboxItem.name)
        checkbox.Text:SetPoint('LEFT', checkbox, 'RIGHT', 5, 0) -- Add 5 pixel gap between checkbox and text
        checkbox:SetChecked(tempSettings[checkboxItem.dbSettingsValueName])

        checkboxes[checkboxItem.dbSettingsValueName] = checkbox

        checkbox:SetScript('OnClick', function(self)
          tempSettings[checkboxItem.dbSettingsValueName] = self:GetChecked()

          -- Apply Interface Status Text rule immediately when hidePlayerFrame is toggled
          if checkboxItem.dbSettingsValueName == 'hidePlayerFrame' then
            if self:GetChecked() then
              SetCVar('statusText', '0')
            end
          end

          -- Handle buff bar positioning when setting is toggled
          if checkboxItem.dbSettingsValueName == 'buffBarOnResourceBar' or checkboxItem.dbSettingsValueName == 'hidePlayerFrame' then
            if _G.UltraHardcoreHandleBuffBarSettingChange then
              _G.UltraHardcoreHandleBuffBarSettingChange()
            end
          end
        end)

        -- Add tooltip functionality
        checkbox:SetScript('OnEnter', function(self)
          GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
          GameTooltip:SetText(checkboxItem.tooltip)
          GameTooltip:Show()
        end)

        checkbox:SetScript('OnLeave', function(self)
          GameTooltip:Hide()
        end)

        yOffset = yOffset - 30 -- Reduced spacing between checkboxes
      end
    end

    -- Add extra space between sections
    yOffset = yOffset - 10
  end
end

-- X Found Mode Tab Content is now in XFoundMode.lua

-- Info Tab Content
-- Philosophy text (at top)
local philosophyText = tabContents[5]:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
philosophyText:SetPoint('CENTER', tabContents[5], 'CENTER', 0, 180)
philosophyText:SetWidth(500)
philosophyText:SetText(
  'UltraHardcore Addon\nVersion: ' .. GetAddOnMetadata('UltraHardcore', 'Version')
)
philosophyText:SetJustifyH('CENTER')
philosophyText:SetNonSpaceWrap(true)

-- Compatibility warning (below philosophy)
local compatibilityText = tabContents[5]:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
compatibilityText:SetPoint('CENTER', tabContents[5], 'CENTER', 0, 120)
compatibilityText:SetWidth(500)
compatibilityText:SetText(
  "Please note: UltraHardcore hasn't been tested with other addons. For the best experience, we recommend using UltraHardcore alone on your hardcore characters."
)
compatibilityText:SetJustifyH('CENTER')
compatibilityText:SetNonSpaceWrap(true)
compatibilityText:SetTextColor(0.9, 0.9, 0.9)

-- Bug report text
local bugReportText = tabContents[5]:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
bugReportText:SetPoint('CENTER', tabContents[5], 'CENTER', 0, 80)
bugReportText:SetText('Found a bug or have suggestions? Join our Discord community!')
bugReportText:SetJustifyH('CENTER')
bugReportText:SetTextColor(0.8, 0.8, 0.8)
bugReportText:SetWidth(500)
bugReportText:SetNonSpaceWrap(true)

-- Discord Link Text (clickable)
local discordLinkText = tabContents[5]:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
discordLinkText:SetPoint('CENTER', tabContents[5], 'CENTER', 0, 60)
discordLinkText:SetText('Discord Server: https://discord.gg/zuSPDNhYEN')
discordLinkText:SetJustifyH('CENTER')
discordLinkText:SetTextColor(0.4, 0.8, 1)

-- Discord instructions text
local discordInstructions = tabContents[5]:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
discordInstructions:SetPoint('CENTER', tabContents[5], 'CENTER', 0, 40)
discordInstructions:SetText('Click the link above to copy it to your chatbox')
discordInstructions:SetJustifyH('CENTER')
discordInstructions:SetTextColor(0.8, 0.8, 0.8)
discordInstructions:SetWidth(500)
discordInstructions:SetNonSpaceWrap(true)

-- Patch Notes Section (at bottom)
local patchNotesTitle = tabContents[5]:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
patchNotesTitle:SetPoint('CENTER', tabContents[5], 'CENTER', 0, 0)
patchNotesTitle:SetText('Patch Notes')
patchNotesTitle:SetJustifyH('CENTER')
patchNotesTitle:SetTextColor(1, 1, 0.5)

-- Create patch notes display at bottom
local patchNotesFrame = CreateFrame('Frame', nil, tabContents[5], 'BackdropTemplate')
patchNotesFrame:SetSize(520, 280)
patchNotesFrame:SetPoint('CENTER', tabContents[5], 'CENTER', 0, -160)
patchNotesFrame:SetBackdrop({
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
patchNotesFrame:SetBackdropColor(0.1, 0.1, 0.1, 0.8)
patchNotesFrame:SetBackdropBorderColor(0.6, 0.6, 0.6, 1)

-- Create patch notes display using reusable component
local patchNotesScrollFrame = CreatePatchNotesDisplay(patchNotesFrame, 480, 260, 10, -10)

-- Make the text clickable
local discordLinkFrame = CreateFrame('Button', nil, tabContents[5])
discordLinkFrame:SetPoint('CENTER', discordLinkText, 'CENTER', 0, 0)
discordLinkFrame:SetSize(400, 20)
discordLinkFrame:SetScript('OnClick', function()
  -- Insert the Discord link into the chat input box
  local discordLink = 'https://discord.gg/zuSPDNhYEN'

  -- Get the chat input frame
  local chatFrame = DEFAULT_CHAT_FRAME
  if chatFrame and chatFrame.editBox then
    chatFrame.editBox:SetText(discordLink)
    chatFrame.editBox:HighlightText() -- Select all text for easy copying
    chatFrame.editBox:SetFocus() -- Focus the input box
  end

  -- Also print to console as backup
  print('Discord link copied to chat input box!')
  print('You can now copy it from the chat input field.')
end)

-- Add tooltip for the link
discordLinkFrame:SetScript('OnEnter', function()
  GameTooltip:SetOwner(discordLinkFrame, 'ANCHOR_TOP')
  GameTooltip:SetText('Click to copy Discord link to chat input')
  GameTooltip:AddLine(
    'The link will appear in your chat box where you can easily copy it!',
    1,
    1,
    1,
    true
  )
  GameTooltip:Show()
end)

discordLinkFrame:SetScript('OnLeave', function()
  GameTooltip:Hide()
end)

-- Achievements Tab Content (empty for now)
local achievementsTitle = tabContents[3]:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
achievementsTitle:SetPoint('CENTER', tabContents[3], 'CENTER', 0, 0)
achievementsTitle:SetText('Achievements Coming In Phase 3!')
achievementsTitle:SetFontObject('GameFontNormalLarge')

-- Save button for Settings tab only
local saveButton = CreateFrame('Button', nil, tabContents[2], 'UIPanelButtonTemplate')
saveButton:SetSize(120, 30)
saveButton:SetPoint('BOTTOM', tabContents[2], 'BOTTOM', 0, -40)
saveButton:SetText('Save and Reload')
saveButton:SetScript('OnClick', function()
  -- Copy temporary settings to GLOBAL_SETTINGS
  for key, value in pairs(tempSettings) do
    GLOBAL_SETTINGS[key] = value
  end

  -- Apply Interface Status Text rule: always set to None when hidePlayerFrame is true
  if GLOBAL_SETTINGS.hidePlayerFrame then
    SetCVar('statusText', '0')
  end

  -- Save settings for current character
  SaveCharacterSettings(GLOBAL_SETTINGS)
  ReloadUI()
end)

-- Share button for Statistics tab is now in StatisticsTab.lua

-- Function to update XP breakdown display
local function UpdateXPBreakdown()
  -- This function is now in StatisticsTab.lua
  if _G.UpdateXPBreakdown then
    _G.UpdateXPBreakdown()
  end
end

-- Update the lowest health display
local function UpdateLowestHealthDisplay()
  -- This function is now in StatisticsTab.lua
  if _G.UpdateLowestHealthDisplay then
    _G.UpdateLowestHealthDisplay()
  end
end

function ToggleSettings()
  if settingsFrame:IsShown() then
    settingsFrame:Hide()
  else
    -- Initialize temporary settings when opening
    initializeTempSettings()

    -- Reset preset button highlighting
    if selectedPreset then
      selectedPreset:SetBackdropBorderColor(0.5, 0.5, 0.5) -- Reset previous
      selectedPreset = nil
    end

    -- Set Statistics tab as default (tab 1)
    for i, content in ipairs(tabContents) do
      content:Hide()
    end
    for i, tabButton in ipairs(tabButtons) do
      tabButton:SetBackdropBorderColor(0.5, 0.5, 0.5)
      tabButton:SetAlpha(0.8)
    end
    tabContents[1]:Show() -- Show Statistics tab
    tabButtons[1]:SetBackdropBorderColor(1, 1, 0) -- Highlight Statistics tab
    tabButtons[1]:SetAlpha(1.0) -- Highlight Statistics tab
    activeTab = 1

    settingsFrame:Show()
    updateCheckboxes()
    updateRadioButtons()
    UpdateLowestHealthDisplay()
  end
end

SLASH_TOGGLESETTINGS1 = '/uhc'
SlashCmdList['TOGGLESETTINGS'] = ToggleSettings

-- Function to open settings and switch to a specific tab
function OpenSettingsToTab(tabIndex)
  -- Initialize temporary settings when opening
  initializeTempSettings()

  -- Reset preset button highlighting
  if selectedPreset then
    selectedPreset:SetBackdropBorderColor(0.5, 0.5, 0.5) -- Reset previous
    selectedPreset = nil
  end

  -- Hide all tab contents
  for i, content in ipairs(tabContents) do
    content:Hide()
  end

  -- Reset all tab button appearances
  for i, tabButton in ipairs(tabButtons) do
    tabButton:SetBackdropBorderColor(0.5, 0.5, 0.5)
    tabButton:SetAlpha(0.8)
  end

  -- Show specified tab content and highlight button
  if tabContents[tabIndex] and tabButtons[tabIndex] then
    tabContents[tabIndex]:Show()
    tabButtons[tabIndex]:SetBackdropBorderColor(1, 1, 0)
    tabButtons[tabIndex]:SetAlpha(1.0)
    activeTab = tabIndex

    -- Initialize X Found Mode tab if it's being shown
    if tabIndex == 4 and InitializeXFoundModeTab then
      InitializeXFoundModeTab()
    end
  end

  -- Show the settings frame
  settingsFrame:Show()
  updateCheckboxes()
  updateRadioButtons()
  UpdateLowestHealthDisplay()
end

-- Initialize temporary settings and create checkboxes
initializeTempSettings()
createCheckboxes()
