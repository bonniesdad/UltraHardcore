local settingsCheckboxOptions = { {
  -- Lite Preset Settings
  name = 'UHC Player Frame',
  dbSettingsValueName = 'hidePlayerFrame',
  tooltip = 'Minimalistic player frame to hide own health',
}, {
  name = 'On Screen Statistics',
  dbSettingsValueName = 'showOnScreenStatistics',
  tooltip = 'Show important UHC statistics on the screen at all times',
}, {
  name = 'Tunnel Vision',
  dbSettingsValueName = 'showTunnelVision',
  tooltip = 'The screen gets darker as you get closer to death',
}, {
  name = 'Announce Level Up to Guild',
  dbSettingsValueName = 'announceLevelUpToGuild',
  tooltip = 'Announces level ups to guild chat every 10th level',
},
-- Recommended Preset Settings
 {
  name = 'Tunnel Vision Covers Everything',
  dbSettingsValueName = 'tunnelVisionMaxStrata',
  tooltip = 'Tunnel Vision covers all UI elements',
}, {
  name = 'Hide Target Frame',
  dbSettingsValueName = 'hideTargetFrame',
  tooltip = 'Target frame is not visible, so you can\'t see the target\'s health or level',
}, {
  name = 'Hide Target Tooltips',
  dbSettingsValueName = 'hideTargetTooltip',
  tooltip = 'Target tooltips are not visible, so you can\'t see the target\'s health or level',
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
  name = 'UHC Incoming Crit Effect',
  dbSettingsValueName = 'showCritScreenMoveEffect',
  tooltip = 'A red screen rotation effect appears when you take a critical hit',
}, {
  name = 'Hide Action Bars when not resting',
  dbSettingsValueName = 'hideActionBars',
  tooltip = 'Hide action bars when not resting or near a campfire',
}, {
  name = 'Pets Die Permanently',
  dbSettingsValueName = 'petsDiePermanently',
  tooltip = 'Pets can\'t be resurrected when they are killed',
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
  name = 'Hide UI Error Messages',
  dbSettingsValueName = 'hideUIErrors',
  tooltip = 'Hide error messages that appear on screen (like "Target is too far away")',
}, {
  name = 'First Person Camera',
  dbSettingsValueName = 'setFirstPersonCamera',
  tooltip = 'Play in first person mode, allows to look around for briew records of time',
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
  showOnScreenStatistics = true,
}, {
  -- Preset 2: Recommended
  hidePlayerFrame = true,
  hideMinimap = true,
  hideTargetFrame = true,
  hideTargetTooltip = true,
  showTunnelVision = true,
  tunnelVisionMaxStrata = true,
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
  showOnScreenStatistics = true,
}, {
  -- Preset 3: Ultra
  hidePlayerFrame = true,
  hideMinimap = true,
  hideTargetFrame = true,
  hideTargetTooltip = true,
  showTunnelVision = true,
  tunnelVisionMaxStrata = true,
  showFullHealthIndicator = true,
  disableNameplateHealth = true,
  showIncomingDamageEffect = true,
  showHealingIndicator = true,
  showDazedEffect = true,
  showCritScreenMoveEffect = true,
  hideActionBars = true,
  hideGroupHealth = true,
  petsDiePermanently = true,
  hideBreathIndicator = true,
  showOnScreenStatistics = true,
  hideUIErrors = false,
  setFirstPersonCamera = false,
} }

-- Temporary settings storage and initialization function
local tempSettings = {}

local function initializeTempSettings()
  -- Copy current GLOBAL_SETTINGS to temporary storage
  for key, value in pairs(GLOBAL_SETTINGS) do
    tempSettings[key] = value
  end
end

local settingsFrame = CreateFrame('Frame', nil, UIParent, 'BackdropTemplate')
settingsFrame:SetSize(560, 640)
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

-- Statistics Tab Content - Full size scrollable frame
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
statsScrollChild:SetSize(500, 720) -- Increased height to accommodate expanded lowest health section and larger XP content frame
statsScrollFrame:SetScrollChild(statsScrollChild)

-- Create modern WoW-style lowest health section (no accordion functionality)
local lowestHealthHeader = CreateFrame('Frame', nil, statsScrollChild, 'BackdropTemplate')
lowestHealthHeader:SetSize(470, 28)
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
lowestHealthContent:SetSize(450, 150) -- Increased height for 6 rows (3 player + 3 pet)
lowestHealthContent:SetPoint('TOPLEFT', statsScrollChild, 'TOPLEFT', 20, -33) -- Indented more than header
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

-- Create the total text display (indented)
local lowestHealthTotalLabel = lowestHealthContent:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
lowestHealthTotalLabel:SetPoint('TOPLEFT', lowestHealthContent, 'TOPLEFT', 12, -8)
lowestHealthTotalLabel:SetText('Total:')

lowestHealthText = lowestHealthContent:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
lowestHealthText:SetPoint('TOPRIGHT', lowestHealthContent, 'TOPRIGHT', -12, -8)
lowestHealthText:SetText(string.format("%.1f", lowestHealthScore or 100) .. '%')

-- Create the This Level text display
local lowestHealthThisLevelLabel = lowestHealthContent:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
lowestHealthThisLevelLabel:SetPoint('TOPLEFT', lowestHealthContent, 'TOPLEFT', 12, -33)
lowestHealthThisLevelLabel:SetText('This Level (Beta):')

local lowestHealthThisLevelText = lowestHealthContent:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
lowestHealthThisLevelText:SetPoint('TOPRIGHT', lowestHealthContent, 'TOPRIGHT', -12, -33)
lowestHealthThisLevelText:SetText('100.0%')

-- Create the This Session text display
local lowestHealthThisSessionLabel = lowestHealthContent:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
lowestHealthThisSessionLabel:SetPoint('TOPLEFT', lowestHealthContent, 'TOPLEFT', 12, -58)
lowestHealthThisSessionLabel:SetText('This Session (Beta):')

local lowestHealthThisSessionText = lowestHealthContent:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
lowestHealthThisSessionText:SetPoint('TOPRIGHT', lowestHealthContent, 'TOPRIGHT', -12, -58)
lowestHealthThisSessionText:SetText('100.0%')

-- Add pet death rows to the same content frame
-- Create the pet deaths text display
local petDeathsLabel = lowestHealthContent:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
petDeathsLabel:SetPoint('TOPLEFT', lowestHealthContent, 'TOPLEFT', 12, -83)
petDeathsLabel:SetText('Pet Deaths:')

petDeathsText = lowestHealthContent:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
petDeathsText:SetPoint('TOPRIGHT', lowestHealthContent, 'TOPRIGHT', -12, -83)
petDeathsText:SetText('0')


-- Create modern WoW-style enemies slain section (no accordion functionality)
local enemiesSlainHeader = CreateFrame('Frame', nil, statsScrollChild, 'BackdropTemplate')
enemiesSlainHeader:SetSize(470, 28)
enemiesSlainHeader:SetPoint('TOPLEFT', statsScrollChild, 'TOPLEFT', 0, -145)

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
local enemiesSlainTotalContent = CreateFrame('Frame', nil, statsScrollChild, 'BackdropTemplate')
enemiesSlainTotalContent:SetSize(450, 30)
enemiesSlainTotalContent:SetPoint('TOPLEFT', statsScrollChild, 'TOPLEFT', 20, -175) -- Indented more than header
enemiesSlainTotalContent:Show() -- Show by default

-- Modern content frame styling
enemiesSlainTotalContent:SetBackdrop({
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
local enemiesSlainTotalLabel = enemiesSlainTotalContent:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
enemiesSlainTotalLabel:SetPoint('TOPLEFT', enemiesSlainTotalContent, 'TOPLEFT', 12, -8)
enemiesSlainTotalLabel:SetText('Total:')

local enemiesSlainText = enemiesSlainTotalContent:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
enemiesSlainText:SetPoint('TOPRIGHT', enemiesSlainTotalContent, 'TOPRIGHT', -12, -8)
enemiesSlainText:SetText('0')


-- Create collapsible content frame for elites slain
local enemiesSlainContent = CreateFrame('Frame', nil, statsScrollChild, 'BackdropTemplate')
enemiesSlainContent:SetSize(450, 30)
enemiesSlainContent:SetPoint('TOPLEFT', statsScrollChild, 'TOPLEFT', 20, -205) -- Indented more than header
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

-- Create the elites slain text display (indented)
local elitesSlainLabel = enemiesSlainContent:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
elitesSlainLabel:SetPoint('TOPLEFT', enemiesSlainContent, 'TOPLEFT', 12, -8)
elitesSlainLabel:SetText('Elites Slain:')

local elitesSlainText = enemiesSlainContent:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
elitesSlainText:SetPoint('TOPRIGHT', enemiesSlainContent, 'TOPRIGHT', -12, -8)
elitesSlainText:SetText('0')

-- Create modern WoW-style Survival section (no accordion functionality)
local survivalHeader = CreateFrame('Frame', nil, statsScrollChild, 'BackdropTemplate')
survivalHeader:SetSize(470, 28)
survivalHeader:SetPoint('TOPLEFT', statsScrollChild, 'TOPLEFT', 0, -245)

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
survivalContent:SetSize(450, 120) -- Height for 4 items
survivalContent:SetPoint('TOPLEFT', statsScrollChild, 'TOPLEFT', 20, -273) -- Indented more than header
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
local survivalLabels = {}
local survivalTexts = {}

-- Create survival statistics entries
local survivalStats = {
  {key = 'healthPotionsUsed', label = 'Health Potions Used:'},
  {key = 'bandagesUsed', label = 'Bandages Applied:'},
  {key = 'targetDummiesUsed', label = 'Target Dummies Used (Beta):'},
  {key = 'grenadesUsed', label = 'Grenades Used (Beta):'}
}

local yOffset = -8
for _, stat in ipairs(survivalStats) do
  local label = survivalContent:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  label:SetPoint('TOPLEFT', survivalContent, 'TOPLEFT', 12, yOffset)
  label:SetText(stat.label)
  
  local text = survivalContent:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  text:SetPoint('TOPRIGHT', survivalContent, 'TOPRIGHT', -12, yOffset)
  text:SetText('0')
  
  survivalLabels[stat.key] = label
  survivalTexts[stat.key] = text
  
  yOffset = yOffset - 25
end

-- Create modern WoW-style XP gained section (no accordion functionality)
local xpGainedHeader = CreateFrame('Frame', nil, statsScrollChild, 'BackdropTemplate')
xpGainedHeader:SetSize(470, 28)
xpGainedHeader:SetPoint('TOPLEFT', statsScrollChild, 'TOPLEFT', 0, -385) -- Moved down to make room for Survival section

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
xpGainedContent:SetSize(450, 480) -- Increased height to show all breakdown lines
xpGainedContent:SetPoint('TOPLEFT', statsScrollChild, 'TOPLEFT', 20, -413) -- Moved down to make room for Survival section
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

-- Mapping of setting names to display names
local settingDisplayNames = {
  hidePlayerFrame = 'Hide Player Frame',
  showOnScreenStatistics = 'On Screen Statistics',
  showTunnelVision = 'Tunnel Vision',
  announceLevelUpToGuild = 'Announce Level Up to Guild',
  tunnelVisionMaxStrata = 'Tunnel Vision Covers Everything',
  hideTargetFrame = 'Hide Target Frame',
  hideTargetTooltip = 'Hide Target Tooltips',
  disableNameplateHealth = 'Disable Nameplates',
  showDazedEffect = 'Show Dazed Effect',
  hideGroupHealth = 'Use UHC Party Frames',
  hideMinimap = 'Hide Minimap',
  hideBreathIndicator = 'Use UHC Breath Indicator',
  showCritScreenMoveEffect = 'Use UHC Incoming Crit Effect',
  hideActionBars = 'Hide Action Bars',
  petsDiePermanently = 'Pets Die Permanently',
  showFullHealthIndicator = 'Use UHC Full Health Indicator',
  showIncomingDamageEffect = 'Use UHC Incoming Damage Effect',
  showHealingIndicator = 'Use UHC Incoming Healing Effect',
}

-- Define preset sections with their settings
local presetSections = {
  {
    title = "Lite:",
    settings = {
      "hidePlayerFrame",
      "showOnScreenStatistics", 
      "showTunnelVision",
      "announceLevelUpToGuild"
    }
  },
  {
    title = "Recommended:",
    settings = {
      "tunnelVisionMaxStrata",
      "hideTargetFrame",
      "hideTargetTooltip",
      "disableNameplateHealth",
      "showDazedEffect",
      "hideGroupHealth",
      "hideMinimap",
      "hideBreathIndicator"
    }
  },
  {
    title = "Experimental:",
    settings = {
      "showCritScreenMoveEffect",
      "hideActionBars",
      "petsDiePermanently",
      "showFullHealthIndicator",
      "showIncomingDamageEffect",
      "showHealingIndicator"
    }
  }
}

-- Create XP breakdown entries with section headers
local yOffset = -8
for sectionIndex, section in ipairs(presetSections) do
  -- Create section header
  local sectionHeader = xpGainedContent:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
  sectionHeader:SetPoint('TOPLEFT', xpGainedContent, 'TOPLEFT', 8, yOffset)
  sectionHeader:SetText(section.title)
  sectionHeader:SetTextColor(1, 1, 0.5) -- Light yellow color for headers
  xpSectionHeaders[sectionIndex] = sectionHeader
  yOffset = yOffset - 25
  
  -- Create settings for this section
  for _, settingName in ipairs(section.settings) do
    local displayName = settingDisplayNames[settingName]
    if displayName then
      local label = xpGainedContent:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
      label:SetPoint('TOPLEFT', xpGainedContent, 'TOPLEFT', 20, yOffset) -- Indented more for settings
      label:SetText(displayName .. ':')
      
      local text = xpGainedContent:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
      text:SetPoint('TOPRIGHT', xpGainedContent, 'TOPRIGHT', -12, yOffset)
      text:SetText('0')
      
      xpBreakdownLabels[settingName] = label
      xpBreakdownTexts[settingName] = text
      
      yOffset = yOffset - 20
    end
  end
  
  -- Add extra space between sections
  yOffset = yOffset - 10
end

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

local function applyPreset(presetIndex)
  if not presets[presetIndex] then return end

  -- Copy preset to temporary settings
  for key, value in pairs(presets[presetIndex]) do
    tempSettings[key] = value
  end

  -- Apply Interface Status Text rule: always set to None when hidePlayerFrame is true
  if tempSettings.hidePlayerFrame then
    SetCVar("statusText", "0")
  end

  -- Update checkboxes
  updateCheckboxes()

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
    'Interface\\AddOns\\UltraHardcore\\textures\\skull1_100.png',
    'Interface\\AddOns\\UltraHardcore\\textures\\skull2_100.png',
    'Interface\\AddOns\\UltraHardcore\\textures\\skull3_100.png',
  }

local buttonSize = 100 -- Increased size for better visibility
local spacing = 10 -- Spacing between the buttons
local totalWidth = 360 -- Total width of the frame for preset buttons
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
    presetText:SetText('Experimental')
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
-- Calculate height: 3 section headers + all checkboxes + spacing
local totalHeight = (3 * 25) + (#settingsCheckboxOptions * 30) + (3 * 10) + 40 -- Headers + checkboxes + section spacing + padding
scrollChild:SetSize(420, totalHeight)

local function createCheckboxes()
  local yOffset = -10
  
  -- Define preset sections with their settings (same as statistics section)
  local presetSections = {
    {
      title = "Lite:",
      settings = {
        "hidePlayerFrame",
        "showOnScreenStatistics", 
        "showTunnelVision",
        "announceLevelUpToGuild"
      }
    },
    {
      title = "Recommended:",
      settings = {
        "tunnelVisionMaxStrata",
        "hideTargetFrame",
        "hideTargetTooltip",
        "disableNameplateHealth",
        "showDazedEffect",
        "hideGroupHealth",
        "hideMinimap",
        "hideBreathIndicator"
      }
    },
    {
      title = "Experimental:",
      settings = {
        "showCritScreenMoveEffect",
        "hideActionBars",
        "petsDiePermanently",
        "showFullHealthIndicator",
        "showIncomingDamageEffect",
        "showHealingIndicator",
        "hideUIErrors",
        "setFirstPersonCamera"
      }
    }
  }
  
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
        local checkbox = CreateFrame('CheckButton', nil, scrollChild, 'ChatConfigCheckButtonTemplate')
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
              SetCVar("statusText", "0")
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
-- Addon name and version at the top (moved up)
local addonTitle = tabContents[5]:CreateFontString(nil, 'OVERLAY', 'GameFontNormalHuge')
addonTitle:SetPoint('CENTER', tabContents[5], 'CENTER', 0, 120)
addonTitle:SetText('UltraHardcore Addon\nVersion: ' .. GetAddOnMetadata('UltraHardcore', 'Version'))
addonTitle:SetJustifyH('CENTER')

-- Philosophy text (moved up with more spacing from title)
local philosophyText = tabContents[5]:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
philosophyText:SetPoint('CENTER', tabContents[5], 'CENTER', 0, -10)
philosophyText:SetWidth(400)
philosophyText:SetText('Welcome to UltraHardcore!\nEvery feature can be customized to create your perfect hardcore experience. Toggle options on or off to find what works best for you.')
philosophyText:SetJustifyH('CENTER')
philosophyText:SetNonSpaceWrap(true)

-- Compatibility warning (moved down with more spacing)
local compatibilityText = tabContents[5]:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
compatibilityText:SetPoint('CENTER', tabContents[5], 'CENTER', 0, -80)
compatibilityText:SetWidth(400)
compatibilityText:SetText('Please note: UltraHardcore hasn\'t been tested with other addons. For the best experience, we recommend using UltraHardcore alone on your hardcore characters.')
compatibilityText:SetJustifyH('CENTER')
compatibilityText:SetNonSpaceWrap(true)
compatibilityText:SetTextColor(0.9, 0.9, 0.9) -- Slightly dimmed for italic effect

-- Bug report text (adjusted for new spacing)
local bugReportText = tabContents[5]:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
bugReportText:SetPoint('CENTER', tabContents[5], 'CENTER', 0, -140)
bugReportText:SetText('Found a bug or have suggestions? We\'d love to hear from you! Join our Discord community to report issues and share feedback.')
bugReportText:SetJustifyH('CENTER')
bugReportText:SetTextColor(0.8, 0.8, 0.8) -- Dimmed color for instructions
bugReportText:SetWidth(400)
bugReportText:SetNonSpaceWrap(true)

-- Discord Link Text (clickable, adjusted for new spacing)
local discordLinkText = tabContents[5]:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
discordLinkText:SetPoint('CENTER', tabContents[5], 'CENTER', 0, -170)
discordLinkText:SetText('Discord Server: https://discord.gg/zuSPDNhYEN')
discordLinkText:SetJustifyH('CENTER')
discordLinkText:SetTextColor(0.4, 0.8, 1) -- Light blue color to indicate it's a link

-- Discord instructions text (adjusted for new spacing)
local discordInstructions = tabContents[5]:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
discordInstructions:SetPoint('CENTER', tabContents[5], 'CENTER', 0, -190)
discordInstructions:SetText('Open your chatbox and press this link, then copy the text provided into your browser')
discordInstructions:SetJustifyH('CENTER')
discordInstructions:SetTextColor(0.8, 0.8, 0.8) -- Slightly dimmed color for instructions
discordInstructions:SetWidth(400)
discordInstructions:SetNonSpaceWrap(true)

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
  GameTooltip:AddLine('The link will appear in your chat box where you can easily copy it!', 1, 1, 1, true)
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
saveButton:SetText('Save')
saveButton:SetScript('OnClick', function()
  -- Copy temporary settings to GLOBAL_SETTINGS
  for key, value in pairs(tempSettings) do
    GLOBAL_SETTINGS[key] = value
  end
  
  -- Apply Interface Status Text rule: always set to None when hidePlayerFrame is true
  if GLOBAL_SETTINGS.hidePlayerFrame then
    SetCVar("statusText", "0")
  end
  
  UltraHardcoreDB.GLOBAL_SETTINGS = GLOBAL_SETTINGS
  SaveDBData('GLOBAL_SETTINGS', GLOBAL_SETTINGS)
  ReloadUI()
end)

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
    print("UHC - CharacterStats not available. Please reload UI.")
  end
end)

-- Function to update XP breakdown display
local function UpdateXPBreakdown()
  -- Define preset sections with their settings (same order as TrackXPPerSetting.lua)
  local presetSections = {
    {
      title = "Lite Preset Settings:",
      settings = {
        "hidePlayerFrame",
        "showOnScreenStatistics", 
        "showTunnelVision",
        "announceLevelUpToGuild"
      }
    },
    {
      title = "Recommended Preset Settings:",
      settings = {
        "tunnelVisionMaxStrata",
        "hideTargetFrame",
        "hideTargetTooltip",
        "disableNameplateHealth",
        "showDazedEffect",
        "hideGroupHealth",
        "hideMinimap",
        "hideBreathIndicator"
      }
    },
    {
      title = "Experimental Preset Settings:",
      settings = {
        "showCritScreenMoveEffect",
        "hideActionBars",
        "petsDiePermanently",
        "showFullHealthIndicator",
        "showIncomingDamageEffect",
        "showHealingIndicator"
      }
    }
  }
  
  -- Update display organized by preset sections
  local yOffset = -8
  for sectionIndex, section in ipairs(presetSections) do
    -- Position section header
    local sectionHeader = xpSectionHeaders[sectionIndex]
    if sectionHeader then
      sectionHeader:SetPoint('TOPLEFT', xpGainedContent, 'TOPLEFT', 8, yOffset)
      yOffset = yOffset - 25
    end
    
    -- Position settings for this section
    for _, settingName in ipairs(section.settings) do
      local textElement = xpBreakdownTexts[settingName]
      local labelElement = xpBreakdownLabels[settingName]
      
      if textElement and labelElement then
        -- Convert setting name to proper variable name format
        local xpVariable = 'xpGainedWithoutOption' .. string.gsub(settingName, '^%l', string.upper)
        -- Handle camelCase conversion for multi-word settings
        xpVariable = string.gsub(xpVariable, '(%u)(%l)', '%1%2')
        
        local xpGained = CharacterStats:GetStat(xpVariable) or 0
        
        -- Position both label and text (indented for settings)
        labelElement:SetPoint('TOPLEFT', xpGainedContent, 'TOPLEFT', 20, yOffset)
        textElement:SetPoint('TOPRIGHT', xpGainedContent, 'TOPRIGHT', -12, yOffset)
        textElement:SetText(tostring(xpGained))
        yOffset = yOffset - 20
      end
    end
    
    -- Add extra space between sections
    yOffset = yOffset - 10
  end
end

-- Update the lowest health display
local function UpdateLowestHealthDisplay()
  if not UltraHardcoreDB then
    LoadDBData()
  end
  
  if lowestHealthText then
    local currentLowestHealth = CharacterStats:GetStat('lowestHealth') or 100
    lowestHealthText:SetText(string.format("%.1f", currentLowestHealth) .. '%')
  end
  
  if lowestHealthThisLevelText then
    local currentLowestHealthThisLevel = CharacterStats:GetStat('lowestHealthThisLevel') or 100
    lowestHealthThisLevelText:SetText(string.format("%.1f", currentLowestHealthThisLevel) .. '%')
  end
  
  if lowestHealthThisSessionText then
    local currentLowestHealthThisSession = CharacterStats:GetStat('lowestHealthThisSession') or 100
    lowestHealthThisSessionText:SetText(string.format("%.1f", currentLowestHealthThisSession) .. '%')
  end
  
  -- Update pet death display
  if petDeathsText then
    local currentPetDeaths = CharacterStats:GetStat('petDeaths') or 0
    petDeathsText:SetText(currentPetDeaths)
  end
  
  
  if elitesSlainText then
    local elites = CharacterStats:GetStat('elitesSlain') or 0
    elitesSlainText:SetText(elites)
  end
  
  if enemiesSlainText then
    local enemies = CharacterStats:GetStat('enemiesSlain') or 0
    enemiesSlainText:SetText(enemies)
  end
  
  -- Update XP breakdown (always visible now)
  UpdateXPBreakdown()
  
  -- Update survival statistics
  if survivalTexts then
    for _, stat in ipairs(survivalStats) do
      local value = CharacterStats:GetStat(stat.key) or 0
      if survivalTexts[stat.key] then
        survivalTexts[stat.key]:SetText(tostring(value))
      end
    end
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
    UpdateLowestHealthDisplay()
  end
end

SLASH_TOGGLESETTINGS1 = '/uhc'
SlashCmdList['TOGGLESETTINGS'] = ToggleSettings

-- Initialize temporary settings and create checkboxes
initializeTempSettings()
createCheckboxes()


