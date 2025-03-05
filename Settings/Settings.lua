local settingsCheckboxOptions = { {
  name = 'Hide Player Frame',
  dbSettingsValueName = 'hidePlayerFrame',
}, {
  name = 'Hide Minimap',
  dbSettingsValueName = 'hideMinimap',
}, {
  name = 'Use Custom Buff Frame',
  dbSettingsValueName = 'hideBuffFrame',
}, {
  name = 'Hide Target Frame',
  dbSettingsValueName = 'hideTargetFrame',
}, {
  name = 'Hide Nameplates',
  dbSettingsValueName = 'hideEnemyNameplates',
}, {
  name = 'Hide Target Tooltips',
  dbSettingsValueName = 'hideTargetTooltip',
}, {
  name = 'Hide Quest UI',
  dbSettingsValueName = 'hideQuestFrame',
}, {
  name = 'Group Found (Guild Only Self Found)',
  dbSettingsValueName = 'guildSelfFound',
}, {
  name = 'Death Indicator (Tunnel Vision)',
  dbSettingsValueName = 'showTunnelVision',
}, {
  name = 'Show Dazed effect',
  dbSettingsValueName = 'showDazedEffect',
}, {
  name = 'Show Crit Screen Shift Effect',
  dbSettingsValueName = 'showCritScreenMoveEffect',
} }

local presets = { {
  -- Preset 1: Lite
  hidePlayerFrame = false,
  hideMinimap = false,
  hideBuffFrame = false,
  hideTargetFrame = true,
  hideTargetTooltip = true,
  hideEnemyNameplates = true,
  guildSelfFound = false,
  showTunnelVision = false,
  hideQuestFrame = false,
  showDazedEffect = false,
  showCritScreenMoveEffect = false,
}, {
  -- Preset 2: Recommended
  hidePlayerFrame = true,
  hideMinimap = true,
  hideBuffFrame = true,
  hideTargetFrame = true,
  hideTargetTooltip = true,
  hideEnemyNameplates = true,
  guildSelfFound = false,
  showTunnelVision = true,
  hideQuestFrame = true,
  showDazedEffect = true,
  showCritScreenMoveEffect = false,
}, {
  -- Preset 3: Ultra
  hidePlayerFrame = true,
  hideMinimap = true,
  hideBuffFrame = true,
  hideTargetFrame = true,
  hideTargetTooltip = true,
  hideEnemyNameplates = true,
  guildSelfFound = true,
  showTunnelVision = true,
  hideQuestFrame = true,
  showDazedEffect = true,
  showCritScreenMoveEffect = true,
} }

local settingsFrame = CreateFrame('Frame', nil, UIParent, 'BackdropTemplate')
settingsFrame:SetSize(400, 500)
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
titleBar:SetSize(400, 40)
titleBar:SetPoint('TOP', settingsFrame, 'TOP')

local settingsTitle = titleBar:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
settingsTitle:SetPoint('LEFT', titleBar, 'LEFT', 12, -3)
settingsTitle:SetText('Ultra Hardcore Settings')
settingsTitle:SetFontObject('GameFontHighlightLarge')

local closeButton = CreateFrame('Button', nil, titleBar, 'UIPanelCloseButton')
closeButton:SetPoint('RIGHT', titleBar, 'RIGHT', -4, -3)
closeButton:SetSize(32, 32)
closeButton:SetScript('OnClick', function()
  settingsFrame:Hide()
end)

-- Frame for selectable preset buttons
local presetButtonsFrame = CreateFrame('Frame', nil, settingsFrame)
presetButtonsFrame:SetSize(360, 50)
presetButtonsFrame:SetPoint('TOP', settingsFrame, 'TOP', 0, -45)

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
    'Interface\\AddOns\\UltraHardcore\\textures\\bonnie' .. 0 .. '.png',
    'Interface\\AddOns\\UltraHardcore\\textures\\bonnie' .. 4 .. '.png',
    'Interface\\AddOns\\UltraHardcore\\textures\\bonnie' .. 5 .. '.png',
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
scrollFrame:SetPoint('TOPLEFT', settingsFrame, 'TOPLEFT', 10, -160) -- Adjusted below images
scrollFrame:SetPoint('BOTTOMRIGHT', settingsFrame, 'BOTTOMRIGHT', -30, 40)

-- ScrollChild contains all checkboxes
local scrollChild = CreateFrame('Frame')
scrollFrame:SetScrollChild(scrollChild)
scrollChild:SetSize(360, #settingsCheckboxOptions * 30 + 20)

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

function ToggleSettings()
  if settingsFrame:IsShown() then
    settingsFrame:Hide()
  else
    settingsFrame:Show()
    updateCheckboxes()
  end
end

SLASH_TOGGLESETTINGS1 = '/uhc'
SlashCmdList['TOGGLESETTINGS'] = ToggleSettings

createCheckboxes()
