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

-- Temporary settings storage and initialization function (global so StatisticsTab.lua can access it)
tempSettings = {}

function initializeTempSettings()
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
-- Initialize tabs using TabManager (will be called after TabManager is loaded)
local function initializeTabs()
  if TabManager then
    TabManager.initializeTabs(settingsFrame)
  end
end
-- Statistics Tab Content is now in StatisticsTab.lua

-- Set initial positioning after all statistics are created
-- All sections are always visible

local closeButton = CreateFrame('Button', nil, titleBar, 'UIPanelCloseButton')
closeButton:SetPoint('RIGHT', titleBar, 'RIGHT', -4, 0)
closeButton:SetSize(32, 32)
closeButton:SetScript('OnClick', function()
  -- Reset tab state when closing
  if TabManager then
    TabManager.resetTabState()
  end
  -- Discard temporary changes by reinitializing temp settings
  initializeTempSettings()
  settingsFrame:Hide()
end)

-- Settings Options Tab Content is now in SettingsOptionsTab.lua

-- X Found Mode Tab Content is now in XFoundMode.lua

-- Info Tab Content is now in InfoTab.lua

-- Achievement Tab Content is now in AchievementTab.lua

-- Save button for Settings tab is now in SettingsOptionsTab.lua

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

-- Settings Options Tab delegation functions
local function updateCheckboxes()
  -- This function is now in SettingsOptionsTab.lua
  if _G.updateCheckboxes then
    _G.updateCheckboxes()
  end
end

local function updateRadioButtons()
  -- This function is now in SettingsOptionsTab.lua
  if _G.updateRadioButtons then
    _G.updateRadioButtons()
  end
end

local function applyPreset(presetIndex)
  -- This function is now in SettingsOptionsTab.lua
  if _G.applyPreset then
    _G.applyPreset(presetIndex)
  end
end

local function createCheckboxes()
  -- This function is now in SettingsOptionsTab.lua
  if _G.createCheckboxes then
    _G.createCheckboxes()
  end
end

function ToggleSettings()
  if settingsFrame:IsShown() then
    -- Reset tab state when closing
    if TabManager then
      TabManager.resetTabState()
    end
    settingsFrame:Hide()
  else
    -- Initialize tabs if not already done
    initializeTabs()

    -- Initialize temporary settings when opening
    initializeTempSettings()

    -- Reset preset button highlighting
    if _G.selectedPreset then
      _G.selectedPreset:SetBackdropBorderColor(0.5, 0.5, 0.5) -- Reset previous
      _G.selectedPreset = nil
    end

    -- Set Statistics tab as default (tab 1)
    if TabManager then
      TabManager.hideAllTabs()
      TabManager.setDefaultTab()
    end

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
  -- Initialize tabs if not already done
  initializeTabs()

  -- Initialize temporary settings when opening
  initializeTempSettings()

  -- Reset preset button highlighting
  if _G.selectedPreset then
    _G.selectedPreset:SetBackdropBorderColor(0.5, 0.5, 0.5) -- Reset previous
    _G.selectedPreset = nil
  end

  -- Hide all tab contents and reset appearances
  if TabManager then
    TabManager.hideAllTabs()
    -- Show specified tab content and highlight button
    TabManager.switchToTab(tabIndex)
  end

  -- Show the settings frame
  settingsFrame:Show()
  updateCheckboxes()
  updateRadioButtons()
  UpdateLowestHealthDisplay()
end

-- Initialize temporary settings
initializeTempSettings()

-- Create LibDataBroker object for minimap button
local addonLDB = LibStub('LibDataBroker-1.1'):NewDataObject('UltraHardcore', {
  type = 'data source',
  text = 'Ultra Hardcore',
  icon = 'Interface\\AddOns\\UltraHardcore\\Textures\\skull3_100_halloween.png',
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
