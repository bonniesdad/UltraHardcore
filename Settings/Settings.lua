radioButtons = {}

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

-- Helper function to determine if a radio button should be checked
local function shouldRadioBeChecked(settingName, settings)
  if settings[settingName] ~= nil then
    return settings[settingName]
  else
    if settingName == 'showMainStatisticsPanelLevel' or settingName == 'showMainStatisticsPanelLowestHealth' or settingName == 'showMainStatisticsPanelEnemiesSlain' or settingName == 'showMainStatisticsPanelDungeonsCompleted' or settingName == 'showMainStatisticsPanelHighestCritValue' or settingName == 'showMainStatisticsPanelCloseEscapes' then
      return true
    else
      return false
    end
  end
end

-- Temporary settings storage and initialization function (global so StatisticsTab.lua can access it)
tempSettings = {}

local function initializeTempSettings()
  for key, value in pairs(GLOBAL_SETTINGS) do
    tempSettings[key] = value
  end

  for settingName, _ in pairs(radioButtons) do
    if tempSettings[settingName] == nil then
      tempSettings[settingName] = shouldRadioBeChecked(settingName, GLOBAL_SETTINGS)
    end
  end

  -- Initialize checkbox defaults for settings that don't exist
  if tempSettings.showExpBar == nil then
    tempSettings.showExpBar = false -- Default to off
  end
  if tempSettings.showXpBarToolTip == nil then
    tempSettings.showXpBarToolTip = false -- Default to off (hide tooltip)
  end
  if tempSettings.hideDefaultExpBar == nil then
    tempSettings.hideDefaultExpBar = false -- Default to off (show default XP bar)
  end
  if tempSettings.xpBarHeight == nil then
    tempSettings.xpBarHeight = 3 -- Default height
  end
end

local CLASS_BACKGROUND_MAP = {
  WARRIOR = 'Interface\\AddOns\\UltraHardcore\\Textures\\bg_warrior.png',
  PALADIN = 'Interface\\AddOns\\UltraHardcore\\Textures\\bg_pally.png',
  HUNTER = 'Interface\\AddOns\\UltraHardcore\\Textures\\bg_hunter.png',
  ROGUE = 'Interface\\AddOns\\UltraHardcore\\Textures\\bg_rogue.png',
  PRIEST = 'Interface\\AddOns\\UltraHardcore\\Textures\\bg_priest.png',
  MAGE = 'Interface\\AddOns\\UltraHardcore\\Textures\\bg_mage.png',
  WARLOCK = 'Interface\\AddOns\\UltraHardcore\\Textures\\bg_warlock.png',
  DRUID = 'Interface\\AddOns\\UltraHardcore\\Textures\\bg_druid.png',
}

local CLASS_BACKGROUND_ASPECT_RATIO = 1200 / 700

local function getClassBackgroundTexture()
  local _, classFileName = UnitClass('player')
  if classFileName and CLASS_BACKGROUND_MAP[classFileName] then
    return CLASS_BACKGROUND_MAP[classFileName]
  end
  return 'Interface\\DialogFrame\\UI-DialogBox-Background'
end

local settingsFrame =
  CreateFrame('Frame', 'UltraHardcoreSettingsFrame', UIParent, 'BackdropTemplate')
tinsert(UISpecialFrames, 'UltraHardcoreSettingsFrame')
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
settingsFrame:SetPoint('CENTER', UIParent, 'CENTER', 0, 30)
settingsFrame:Hide()
settingsFrame:SetFrameStrata('DIALOG')
settingsFrame:SetFrameLevel(15)
settingsFrame:SetClipsChildren(true)

local settingsFrameBackground = settingsFrame:CreateTexture(nil, 'BACKGROUND')
settingsFrameBackground:SetPoint('CENTER', settingsFrame, 'CENTER')
settingsFrameBackground:SetTexCoord(0, 1, 0, 1)

local function updateSettingsFrameBackdrop()
  settingsFrameBackground:SetTexture(getClassBackgroundTexture())
  local frameHeight = settingsFrame:GetHeight()
  settingsFrameBackground:SetSize(frameHeight * CLASS_BACKGROUND_ASPECT_RATIO, frameHeight)

  settingsFrame:SetBackdrop({
    edgeFile = 'Interface\\Buttons\\WHITE8x8',
    tile = false,
    edgeSize = 2,
    insets = { left = 0, right = 0, top = 0, bottom = 0 },
  })
  settingsFrame:SetBackdropBorderColor(0, 0, 0, 1)
end
updateSettingsFrameBackdrop()
local titleBar = CreateFrame('Frame', nil, settingsFrame, 'BackdropTemplate')
titleBar:SetSize(560, 60)
titleBar:SetPoint('TOP', settingsFrame, 'TOP')
titleBar:SetFrameStrata('DIALOG')
titleBar:SetFrameLevel(20)

titleBar:SetBackdropBorderColor(0, 0, 0, 1)
titleBar:SetBackdropColor(0, 0, 0, 0.95)
local titleBarBackground = titleBar:CreateTexture(nil, 'BACKGROUND')
titleBarBackground:SetAllPoints()
titleBarBackground:SetTexture('Interface\\AddOns\\UltraHardcore\\Textures\\header.png')
titleBarBackground:SetTexCoord(0, 1, 0, 1)
local settingsTitleLabel = titleBar:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightHuge')
settingsTitleLabel:SetPoint('CENTER', titleBar, 'CENTER', 0, 4)
settingsTitleLabel:SetText('Ultra Hardcore')
settingsTitleLabel:SetTextColor(0.922, 0.871, 0.761)
local dividerFrame = CreateFrame('Frame', nil, settingsFrame)
dividerFrame:SetSize(570, 24)
dividerFrame:SetPoint('BOTTOM', titleBar, 'BOTTOM', 0, -10)
dividerFrame:SetFrameStrata('DIALOG')
dividerFrame:SetFrameLevel(20)
local dividerTexture = dividerFrame:CreateTexture(nil, 'ARTWORK')
dividerTexture:SetAllPoints()
dividerTexture:SetTexture('Interface\\AddOns\\UltraHardcore\\Textures\\divider.png')
dividerTexture:SetTexCoord(0, 1, 0, 1)
local function initializeTabs()
  if TabManager then
    TabManager.initializeTabs(settingsFrame)
  end
end
local closeButton = CreateFrame('Button', nil, titleBar, 'UIPanelCloseButton')
closeButton:SetPoint('RIGHT', titleBar, 'RIGHT', -15, 4)
closeButton:SetSize(12, 12)
closeButton:SetScript('OnClick', function()
  if TabManager then
    TabManager.resetTabState()
  end
  initializeTempSettings()
  settingsFrame:Hide()
end)
closeButton:SetNormalTexture('Interface\\AddOns\\UltraHardcore\\Textures\\header-x.png')
closeButton:SetPushedTexture('Interface\\AddOns\\UltraHardcore\\Textures\\header-x.png')
closeButton:SetHighlightTexture('Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight', 'ADD')
local closeButtonTex = closeButton:GetNormalTexture()
if closeButtonTex then
  closeButtonTex:SetTexCoord(0, 1, 0, 1)
end
local closeButtonPushed = closeButton:GetPushedTexture()
if closeButtonPushed then
  closeButtonPushed:SetTexCoord(0, 1, 0, 1)
end

function ToggleSettings()
  if settingsFrame:IsShown() then
    if TabManager then
      TabManager.resetTabState()
    end
    settingsFrame:Hide()
  else
    updateSettingsFrameBackdrop()
    initializeTabs()

    initializeTempSettings()

    if _G.selectedPreset then
      _G.selectedPreset:SetBackdropBorderColor(0.5, 0.5, 0.5)
      _G.selectedPreset = nil
    end

    if TabManager then
      TabManager.hideAllTabs()
      TabManager.setDefaultTab()
    end

    settingsFrame:Show()
    if _G.updateCheckboxes then
      _G.updateCheckboxes()
    end
    if _G.updateSliders then
      _G.updateSliders()
    end
    if _G.updateRadioButtons then
      _G.updateRadioButtons()
    end
    if _G.UpdateLowestHealthDisplay then
      _G.UpdateLowestHealthDisplay()
    end
  end
end

SLASH_TOGGLESETTINGS1 = '/uhc'
SlashCmdList['TOGGLESETTINGS'] = ToggleSettings

-- Function to open settings and switch to a specific tab
function OpenSettingsToTab(tabIndex)
  updateSettingsFrameBackdrop()
  initializeTabs()

  initializeTempSettings()

  if _G.selectedPreset then
    _G.selectedPreset:SetBackdropBorderColor(0.5, 0.5, 0.5)
    _G.selectedPreset = nil
  end

  if TabManager then
    TabManager.hideAllTabs()
    TabManager.switchToTab(tabIndex)
  end

  settingsFrame:Show()
  if _G.updateCheckboxes then
    _G.updateCheckboxes()
  end
  if _G.updateRadioButtons then
    _G.updateRadioButtons()
  end
  if _G.UpdateLowestHealthDisplay then
    _G.UpdateLowestHealthDisplay()
  end
end

-- Initialize temporary settings
initializeTempSettings()

-- Create LibDataBroker object for minimap button
local addonLDB = LibStub('LibDataBroker-1.1'):NewDataObject('UltraHardcore', {
  type = 'data source',
  text = 'Ultra Hardcore',
  icon = 'Interface\\AddOns\\UltraHardcore\\Textures\\skull3_100.png',
  OnClick = function(self, btn)
    if btn == 'LeftButton' then
      ToggleSettings()
    end
  end,
  OnTooltipShow = function(tooltip)
    if not tooltip or not tooltip.AddLine then return end
    tooltip:AddLine('|cffffffffUltra Hardcore|r\n\nLeft-click to open settings', nil, nil, nil, nil)
  end,
})

-- Initialize minimap button settings
local minimapSettings = { hide = false }
if UltraHardcoreDB and UltraHardcoreDB.minimapButton then
  for key, value in pairs(UltraHardcoreDB.minimapButton) do
    minimapSettings[key] = value
  end
end

-- Register the minimap button with LibDBIcon
local addonIcon = LibStub('LibDBIcon-1.0')
addonIcon:Register('UltraHardcore', addonLDB, minimapSettings)
