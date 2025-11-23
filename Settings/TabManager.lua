-- TabManager.lua
-- Handles tab creation, management, and switching for the UltraHardcore settings window

local TabManager = {}

local NUM_TABS = 6
local TAB_WIDTH = 92
local TAB_HEIGHT = 32
local TAB_SPACING = 2

local BASE_TEXT_COLOR = {
  r = 0.922,
  g = 0.871,
  b = 0.761,
}
local ACTIVE_CLASS_FADE = 0.75

local function getPlayerClassColor()
  local _, playerClass = UnitClass('player')
  if not playerClass then
    return BASE_TEXT_COLOR.r, BASE_TEXT_COLOR.g, BASE_TEXT_COLOR.b
  end
  local r, g, b = GetClassColor(playerClass)
  if not r then
    return BASE_TEXT_COLOR.r, BASE_TEXT_COLOR.g, BASE_TEXT_COLOR.b
  end
  return r, g, b
end

-- Tab-related variables
local tabButtons = {}
local tabContents = {}
local activeTab = 1

-- Create proper folder tabs with angled edges
local function createTabButton(text, index, parentFrame)
  local button = CreateFrame('Button', nil, parentFrame, 'BackdropTemplate')
  button:SetSize(TAB_WIDTH, TAB_HEIGHT)
  local centerIndex = (NUM_TABS + 1) / 2
  local horizontalOffset = (index - centerIndex) * (TAB_WIDTH + TAB_SPACING)
  button:SetPoint('TOP', parentFrame, 'TOP', horizontalOffset, -57) -- Position below title bar with spacing
  -- Create the main tab background with the custom texture
  local background = button:CreateTexture(nil, 'BACKGROUND')
  background:SetAllPoints()
  background:SetTexture('Interface\\AddOns\\UltraHardcore\\Textures\\tab_texture.png')
  button.backgroundTexture = background
  button:SetBackdrop({
    bgFile = nil,
    edgeFile = 'Interface\\Buttons\\WHITE8x8',
    tile = false,
    edgeSize = 1,
    insets = {
      left = 0,
      right = 0,
      top = 0,
      bottom = 0,
    },
  })
  button:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.6)

  -- Set the text
  local buttonText = button:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
  buttonText:SetPoint('CENTER', button, 'CENTER', 0, -2)
  buttonText:SetText(text)
  buttonText:SetTextColor(BASE_TEXT_COLOR.r, BASE_TEXT_COLOR.g, BASE_TEXT_COLOR.b)
  button.text = buttonText

  -- Set up click handler
  button:SetScript('OnClick', function()
    TabManager.switchToTab(index)
  end)

  -- Set initial appearance
  button.backgroundTexture:SetVertexColor(0.6, 0.6, 0.6, 1)
  button:SetAlpha(0.9)

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
  tabButtons[4] = createTabButton('X Found', 4, settingsFrame)
  tabButtons[5] = createTabButton('Info', 5, settingsFrame)
  tabButtons[6] = createTabButton('Commands', 6, settingsFrame)

  -- Create tab content frames
  tabContents[1] = createTabContent(1, settingsFrame) -- Statistics tab
  tabContents[2] = createTabContent(2, settingsFrame) -- Settings tab
  tabContents[3] = createTabContent(3, settingsFrame) -- Achievements tab
  tabContents[4] = createTabContent(4, settingsFrame) -- Self Found tab
  tabContents[5] = createTabContent(5, settingsFrame) -- Info tab
  tabContents[6] = createTabContent(6, settingsFrame) -- Commands tab
  -- Make tabContents globally accessible immediately
  _G.tabContents = tabContents
end

-- Switch to a specific tab
function TabManager.switchToTab(index)
  -- Hide TBC overlay if it's showing
  if _G.tbcContentFrame then
    _G.tbcContentFrame:Hide()
  end

  -- Hide all tab contents
  for i, content in ipairs(tabContents) do
    content:Hide()
  end

  -- Reset all tab button appearances
  for i, tabButton in ipairs(tabButtons) do
    if tabButton.backgroundTexture then
      tabButton.backgroundTexture:SetVertexColor(0.6, 0.6, 0.6, 1)
    end
    tabButton:SetAlpha(0.9)
    tabButton:SetHeight(TAB_HEIGHT)
    if tabButton.text then
      tabButton.text:SetTextColor(BASE_TEXT_COLOR.r, BASE_TEXT_COLOR.g, BASE_TEXT_COLOR.b)
    end
    tabButton:SetBackdrop({
      bgFile = nil,
      edgeFile = 'Interface\\Buttons\\WHITE8x8',
      tile = false,
      edgeSize = 1,
      insets = {
        left = 0,
        right = 0,
        top = 0,
        bottom = 0,
      },
    })
    tabButton:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.6)
  end

  -- Show selected tab content and highlight button
  tabContents[index]:Show()
  if tabButtons[index].backgroundTexture then
    tabButtons[index].backgroundTexture:SetVertexColor(1, 1, 1, 1)
  end
  tabButtons[index]:SetAlpha(1.0)
  tabButtons[index]:SetHeight(TAB_HEIGHT + 6)
  local classR, classG, classB = getPlayerClassColor()
  local fadedR = (classR * ACTIVE_CLASS_FADE) + (BASE_TEXT_COLOR.r * (1 - ACTIVE_CLASS_FADE))
  local fadedG = (classG * ACTIVE_CLASS_FADE) + (BASE_TEXT_COLOR.g * (1 - ACTIVE_CLASS_FADE))
  local fadedB = (classB * ACTIVE_CLASS_FADE) + (BASE_TEXT_COLOR.b * (1 - ACTIVE_CLASS_FADE))
  if tabButtons[index].text then
    tabButtons[index].text:SetTextColor(fadedR, fadedG, fadedB)
  end
  tabButtons[index]:SetBackdrop({
    bgFile = nil,
    edgeFile = 'Interface\\Buttons\\WHITE8x8',
    tile = false,
    edgeSize = 1,
    insets = {
      left = 0,
      right = 0,
      top = 0,
      bottom = 0,
    },
  })
  tabButtons[index]:SetBackdropBorderColor(fadedR, fadedG, fadedB, 1)
  activeTab = index

  -- Persist last opened settings tab per character
  if GLOBAL_SETTINGS then
    GLOBAL_SETTINGS.lastOpenedSettingsTab = index
    if SaveCharacterSettings then
      SaveCharacterSettings(GLOBAL_SETTINGS)
    end
  end

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

  -- Initialize Commands tab if it's being shown
  if index == 6 and InitializeCommandsTab then
    InitializeCommandsTab()
  end
end

-- Set the default tab (Statistics tab)
function TabManager.setDefaultTab()
  local defaultIndex = 1
  if GLOBAL_SETTINGS and GLOBAL_SETTINGS.lastOpenedSettingsTab then
    local saved = GLOBAL_SETTINGS.lastOpenedSettingsTab
    if type(saved) == 'number' and tabContents[saved] then
      defaultIndex = saved
    end
  end
  TabManager.switchToTab(defaultIndex)
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
    if tabButton.backgroundTexture then
      tabButton.backgroundTexture:SetVertexColor(0.6, 0.6, 0.6, 1)
    end
    tabButton:SetAlpha(0.9)
    tabButton:SetHeight(TAB_HEIGHT)
    if tabButton.text then
      tabButton.text:SetTextColor(BASE_TEXT_COLOR.r, BASE_TEXT_COLOR.g, BASE_TEXT_COLOR.b)
    end
    tabButton:SetBackdrop({
      bgFile = nil,
      edgeFile = 'Interface\\Buttons\\WHITE8x8',
      tile = false,
      edgeSize = 1,
      insets = {
        left = 0,
        right = 0,
        top = 0,
        bottom = 0,
      },
    })
    tabButton:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.6)
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
      if tabButton.backgroundTexture then
        tabButton.backgroundTexture:SetVertexColor(0.6, 0.6, 0.6, 1)
      end
      tabButton:SetAlpha(0.9)
      -- Ensure the button is fully opaque and visible
      tabButton:Show()
      tabButton:SetHeight(TAB_HEIGHT)
      if tabButton.text then
        tabButton.text:SetTextColor(BASE_TEXT_COLOR.r, BASE_TEXT_COLOR.g, BASE_TEXT_COLOR.b)
      end
      tabButton:SetBackdrop(nil)
    end
  end
end

-- Make TabManager globally accessible
_G.TabManager = TabManager
