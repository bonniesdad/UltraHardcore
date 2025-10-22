-- TabManager.lua
-- Handles tab creation, management, and switching for the UltraHardcore settings window

local TabManager = {}

-- Tab-related variables
local tabButtons = {}
local tabContents = {}
local activeTab = 1

-- Create proper folder tabs with angled edges
local function createTabButton(text, index, parentFrame)
  local button = CreateFrame('Button', nil, parentFrame, 'BackdropTemplate')
  button:SetSize(110, 35)
  button:SetPoint('TOP', parentFrame, 'TOP', (index - 3) * 110, -45) -- Position below title bar
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
    TabManager.switchToTab(index)
  end)

  -- Set initial appearance
  button:SetBackdropBorderColor(0.5, 0.5, 0.5)
  button:SetAlpha(0.8)

  return button
end

-- Create tab content frames
local function createTabContent(index, parentFrame)
  local content = CreateFrame('Frame', nil, parentFrame)
  content:SetSize(520, 540)
  content:SetPoint('TOP', parentFrame, 'TOP', 0, -50) -- Positioned below tabs
  content:Hide()
  return content
end

-- Initialize tabs for the settings frame
function TabManager.initializeTabs(settingsFrame)
  -- Store the settings frame reference
  TabManager.settingsFrame = settingsFrame

  -- Check if tabs are already initialized to prevent duplicates
  if tabButtons[1] then return end

  -- Create tab buttons
  tabButtons[1] = createTabButton('Statistics', 1, settingsFrame)
  tabButtons[2] = createTabButton('Settings', 2, settingsFrame)
  tabButtons[3] = createTabButton('Achievements', 3, settingsFrame)
  tabButtons[4] = createTabButton('X Found Mode', 4, settingsFrame)
  tabButtons[5] = createTabButton('Info', 5, settingsFrame)

  -- Create tab content frames
  tabContents[1] = createTabContent(1, settingsFrame) -- Statistics tab
  tabContents[2] = createTabContent(2, settingsFrame) -- Settings tab
  tabContents[3] = createTabContent(3, settingsFrame) -- Achievements tab
  tabContents[4] = createTabContent(4, settingsFrame) -- Self Found tab
  tabContents[5] = createTabContent(5, settingsFrame) -- Info tab
  -- Make tabContents globally accessible immediately
  _G.tabContents = tabContents
end

-- Switch to a specific tab
function TabManager.switchToTab(index)
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
  tabButtons[index]:SetBackdropBorderColor(1, 1, 0)
  tabButtons[index]:SetAlpha(1.0)
  activeTab = index

  -- Initialize tabs only if not already initialized
  -- Initialize X Found Mode tab if it's being shown
  if index == 4 and InitializeXFoundModeTab then
    InitializeXFoundModeTab()
  end

  -- Initialize Achievement tab if it's being shown
  if index == 3 and InitializeAchievementTab then
    InitializeAchievementTab()
  end

  -- Initialize Info tab if it's being shown
  if index == 5 and InitializeInfoTab then
    InitializeInfoTab()
  end

  -- Initialize Statistics tab if it's being shown
  if index == 1 and InitializeStatisticsTab then
    InitializeStatisticsTab()
    -- Update radio buttons after Statistics tab is initialized
    if updateRadioButtons then
      updateRadioButtons()
    end
  end

  -- Initialize Settings Options tab if it's being shown
  if index == 2 and InitializeSettingsOptionsTab then
    InitializeSettingsOptionsTab()
  end
end

-- Set the default tab (Statistics tab)
function TabManager.setDefaultTab()
  TabManager.switchToTab(1)
end

-- Get the currently active tab
function TabManager.getActiveTab()
  return activeTab
end

-- Get tab content frame by index
function TabManager.getTabContent(index)
  return tabContents[index]
end

-- Get tab button by index
function TabManager.getTabButton(index)
  return tabButtons[index]
end

-- Hide all tabs
function TabManager.hideAllTabs()
  for i, content in ipairs(tabContents) do
    content:Hide()
  end
  for i, tabButton in ipairs(tabButtons) do
    tabButton:SetBackdropBorderColor(0.5, 0.5, 0.5)
    tabButton:SetAlpha(0.8)
  end
end

-- Reset tab state (called when settings window is closed)
function TabManager.resetTabState()
  -- Reset active tab to default
  activeTab = 1

  -- Hide all tabs and reset all button appearances to initial state
  for i, content in ipairs(tabContents) do
    content:Hide()
  end
  for i, tabButton in ipairs(tabButtons) do
    if tabButton then
      tabButton:SetBackdropBorderColor(0.5, 0.5, 0.5)
      tabButton:SetAlpha(0.8)
      -- Ensure the button is fully opaque and visible
      tabButton:Show()
    end
  end
end

-- Make TabManager globally accessible
_G.TabManager = TabManager
