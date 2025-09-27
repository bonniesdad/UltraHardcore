local settingsCheckboxOptions = { {
  -- Lite Preset Settings
  name = 'Hide Own Player Frame',
  dbSettingsValueName = 'hidePlayerFrame',
}, {
  name = 'On Screen Statistics',
  dbSettingsValueName = 'showOnScreenStatistics',
}, {
  name = 'Tunnel Vision',
  dbSettingsValueName = 'showTunnelVision',
},
-- Recommended Preset Settings
 {
  name = 'Tunnel Vision Covers Everything',
  dbSettingsValueName = 'tunnelVisionMaxStrata',
}, {
  name = 'Hide Target Frame',
  dbSettingsValueName = 'hideTargetFrame',
}, {
  name = 'Hide Target Tooltips',
  dbSettingsValueName = 'hideTargetTooltip',
}, {
  name = 'Disable Nameplate Information',
  dbSettingsValueName = 'disableNameplateHealth',
}, {
  name = 'Show Dazed effect',
  dbSettingsValueName = 'showDazedEffect',
}, {
  name = 'Use UHC Party Frames',
  dbSettingsValueName = 'hideGroupHealth',
}, {
  name = 'Hide Minimap',
  dbSettingsValueName = 'hideMinimap',
}, {
  name = 'Hide Quest UI',
  dbSettingsValueName = 'hideQuestFrame',
}, {
  name = 'Use UHC Buff Frame',
  dbSettingsValueName = 'hideBuffFrame',
}, {
  name = 'Use UHC Breath Indicator',
  dbSettingsValueName = 'hideBreathIndicator',
}, {
  name = 'Use UHC Incoming Crit Effect',
  dbSettingsValueName = 'showCritScreenMoveEffect',
}, {
  name = 'Hide Action Bars when not resting',
  dbSettingsValueName = 'hideActionBars',
}, {
  name = 'Pets Die Permanently',
  dbSettingsValueName = 'petsDiePermanently',
}, {
  name = 'Use UHC Full Health Indicator',
  dbSettingsValueName = 'showFullHealthIndicator',
}, {
  name = 'Use UHC Incoming Damage Effect',
  dbSettingsValueName = 'showIncomingDamageEffect',
} }

local presets = { {
  -- Preset 1: Lite
  hidePlayerFrame = true,
  hideMinimap = false,
  hideBuffFrame = false,
  hideTargetFrame = false,
  hideTargetTooltip = false,
  showTunnelVision = true,
  tunnelVisionMaxStrata = false,
  hideQuestFrame = false,
  showDazedEffect = false,
  showCritScreenMoveEffect = false,
  hideActionBars = false,
  hideGroupHealth = false,
  petsDiePermanently = false,
  showFullHealthIndicator = false,
  disableNameplateHealth = false,
  showIncomingDamageEffect = false,
  hideBreathIndicator = false,
  showOnScreenStatistics = true,
}, {
  -- Preset 2: Recommended
  hidePlayerFrame = true,
  hideMinimap = true,
  hideBuffFrame = true,
  hideTargetFrame = true,
  hideTargetTooltip = true,
  showTunnelVision = true,
  tunnelVisionMaxStrata = true,
  hideQuestFrame = true,
  showDazedEffect = true,
  hideGroupHealth = true,
  showCritScreenMoveEffect = false,
  hideActionBars = false,
  petsDiePermanently = false,
  showFullHealthIndicator = false,
  disableNameplateHealth = true,
  showIncomingDamageEffect = false,
  hideBreathIndicator = true,
  showOnScreenStatistics = true,
}, {
  -- Preset 3: Ultra
  hidePlayerFrame = true,
  hideMinimap = true,
  hideBuffFrame = true,
  hideTargetFrame = true,
  hideTargetTooltip = true,
  showTunnelVision = true,
  tunnelVisionMaxStrata = true,
  showFullHealthIndicator = true,
  disableNameplateHealth = true,
  showIncomingDamageEffect = true,
  hideQuestFrame = true,
  showDazedEffect = true,
  showCritScreenMoveEffect = true,
  hideActionBars = true,
  hideGroupHealth = true,
  petsDiePermanently = true,
  hideBreathIndicator = true,
  showOnScreenStatistics = true,
} }

local settingsFrame = CreateFrame('Frame', nil, UIParent, 'BackdropTemplate')
settingsFrame:SetSize(400, 650)
settingsFrame:SetPoint('CENTER', UIParent, 'CENTER')
settingsFrame:Hide()

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
titleBar:SetSize(400, 50) -- Increased height for header
titleBar:SetPoint('TOP', settingsFrame, 'TOP')
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

local settingsTitle = titleBar:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
settingsTitle:SetPoint('CENTER', titleBar, 'CENTER', 0, 0)
settingsTitle:SetText('Ultra Hardcore')
settingsTitle:SetFont('Fonts\\FRIZQT__.TTF', 24, 'OUTLINE')

-- Add Statistics title
local statsTitle = settingsFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
statsTitle:SetPoint('TOPLEFT', settingsFrame, 'TOPLEFT', 20, -60)
statsTitle:SetText('Statistics')
statsTitle:SetFontObject('GameFontNormalLarge')

-- Create Statistics section
local statsFrame = CreateFrame('Frame', nil, settingsFrame, 'BackdropTemplate')
statsFrame:SetSize(360, 100) -- Increased height to accommodate XP tracking
statsFrame:SetPoint('TOP', settingsFrame, 'TOP', 0, -85)
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

-- Create the lowest health text display in the stats section
local lowestHealthLabel = statsFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
lowestHealthLabel:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', 20, -15)
lowestHealthLabel:SetText('Lowest Health Reached:')

lowestHealthText = statsFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
lowestHealthText:SetPoint('TOPRIGHT', statsFrame, 'TOPRIGHT', -20, -15)
lowestHealthText:SetText(string.format("%.1f", lowestHealthScore or 100) .. '%')

-- Create the elites slain text display
local elitesSlainLabel = statsFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
elitesSlainLabel:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', 20, -35)
elitesSlainLabel:SetText('Elites Slain:')

local elitesSlainText = statsFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
elitesSlainText:SetPoint('TOPRIGHT', statsFrame, 'TOPRIGHT', -20, -35)
elitesSlainText:SetText('0')

-- Create the enemies slain text display
local enemiesSlainLabel = statsFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
enemiesSlainLabel:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', 20, -55)
enemiesSlainLabel:SetText('Enemies Slain:')

local enemiesSlainText = statsFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
enemiesSlainText:SetPoint('TOPRIGHT', statsFrame, 'TOPRIGHT', -20, -55)
enemiesSlainText:SetText('0')

-- Create the XP gained without addon text display
local xpLabel = statsFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
xpLabel:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', 20, -75)
xpLabel:SetText('XP Gained Without Addon:')

local xpText = statsFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
xpText:SetPoint('TOPRIGHT', statsFrame, 'TOPRIGHT', -20, -75)
xpText:SetText('0')

local closeButton = CreateFrame('Button', nil, titleBar, 'UIPanelCloseButton')
closeButton:SetPoint('RIGHT', titleBar, 'RIGHT', -4, 0)
closeButton:SetSize(32, 32)
closeButton:SetScript('OnClick', function()
  settingsFrame:Hide()
end)

-- Frame for selectable preset buttons
local presetButtonsFrame = CreateFrame('Frame', nil, settingsFrame)
presetButtonsFrame:SetSize(360, 50)
presetButtonsFrame:SetPoint('TOP', settingsFrame, 'TOP', 0, -225)

-- Add Settings title above the preset buttons
local settingsSectionTitle = settingsFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
settingsSectionTitle:SetPoint('TOPLEFT', settingsFrame, 'TOPLEFT', 20, -200)
settingsSectionTitle:SetText('Settings')
settingsSectionTitle:SetFontObject('GameFontNormalLarge')

local checkboxes = {}
local presetButtons = {}
local selectedPreset = nil

local function updateCheckboxes()
  for _, checkboxItem in ipairs(settingsCheckboxOptions) do
    local checkbox = checkboxes[checkboxItem.dbSettingsValueName]
    if checkbox then
      checkbox:SetChecked(GLOBAL_SETTINGS[checkboxItem.dbSettingsValueName])
    end
  end
end

local function applyPreset(presetIndex)
  GLOBAL_SETTINGS = presets[presetIndex]

  if not presets[presetIndex] then return end

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
    'Interface\\AddOns\\UltraHardcore\\textures\\skull' .. 1 .. '.png',
    'Interface\\AddOns\\UltraHardcore\\textures\\skull' .. 2 .. '.png',
    'Interface\\AddOns\\UltraHardcore\\textures\\skull' .. 3 .. '.png',
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

-- ScrollFrame to enable scrolling
local scrollFrame = CreateFrame('ScrollFrame', nil, settingsFrame, 'UIPanelScrollFrameTemplate')
scrollFrame:SetPoint('TOPLEFT', settingsFrame, 'TOPLEFT', 10, -345)
scrollFrame:SetPoint('BOTTOMRIGHT', settingsFrame, 'BOTTOMRIGHT', -30, 60)

-- ScrollChild contains all checkboxes
local scrollChild = CreateFrame('Frame')
scrollFrame:SetScrollChild(scrollChild)
scrollChild:SetSize(360, #settingsCheckboxOptions * 30 + 40) -- Increased padding in scroll content

local function createCheckboxes()
  local yOffset = -10
  for _, checkboxItem in ipairs(settingsCheckboxOptions) do
    local checkbox = CreateFrame('CheckButton', nil, scrollChild, 'ChatConfigCheckButtonTemplate')
    checkbox:SetPoint('TOPLEFT', 10, yOffset)
    checkbox.Text:SetText(checkboxItem.name)
    checkbox:SetChecked(GLOBAL_SETTINGS[checkboxItem.dbSettingsValueName])

    checkboxes[checkboxItem.dbSettingsValueName] = checkbox

    checkbox:SetScript('OnClick', function(self)
      GLOBAL_SETTINGS[checkboxItem.dbSettingsValueName] = self:GetChecked()
    end)

    yOffset = yOffset - 30
  end
end

local saveButton = CreateFrame('Button', nil, settingsFrame, 'UIPanelButtonTemplate')
saveButton:SetSize(120, 30)
saveButton:SetPoint('BOTTOM', settingsFrame, 'BOTTOM', 0, 10)
saveButton:SetText('Save')
saveButton:SetScript('OnClick', function()
  UltraHardcoreDB.GLOBAL_SETTINGS = GLOBAL_SETTINGS
  SaveDBData('GLOBAL_SETTINGS', GLOBAL_SETTINGS)
  ReloadUI()
end)

-- Update the lowest health display
local function UpdateLowestHealthDisplay()
  if not UltraHardcoreDB then
    LoadDBData()
  end
  
  if lowestHealthText then
    local currentLowestHealth = CharacterStats:GetStat('lowestHealth') or 100
    lowestHealthText:SetText(string.format("%.1f", currentLowestHealth) .. '%')
  end
  
  if elitesSlainText then
    local elites = CharacterStats:GetStat('elitesSlain') or 0
    elitesSlainText:SetText(elites)
  end
  
  if enemiesSlainText then
    local enemies = CharacterStats:GetStat('enemiesSlain') or 0
    enemiesSlainText:SetText(enemies)
  end
  
  if xpText then
    local xp = CharacterStats:GetStat('xpGainedWithoutAddon') or 0
    xpText:SetText(xp)
  end
end

function ToggleSettings()
  if settingsFrame:IsShown() then
    settingsFrame:Hide()
  else
    settingsFrame:Show()
    updateCheckboxes()
    UpdateLowestHealthDisplay()
  end
end

SLASH_TOGGLESETTINGS1 = '/uhc'
SlashCmdList['TOGGLESETTINGS'] = ToggleSettings

createCheckboxes()
