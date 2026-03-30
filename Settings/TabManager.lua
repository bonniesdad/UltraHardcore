-- TabManager.lua
-- Handles tab creation, management, and switching for the UltraHardcore settings window

local TabManager = {}

local TAB_WIDTH = 128 -- Default width
local TAB_HEIGHT = 32
local TAB_SPACING = 3

-- Tab-specific widths
local TAB_WIDTHS = {
  [1] = TAB_WIDTH, -- Verify
  [2] = TAB_WIDTH, -- Settings
  [3] = TAB_WIDTH, -- Info
  [4] = TAB_WIDTH, -- Commands
  [5] = TAB_WIDTH, -- Credits
}

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

-- Calculate cumulative horizontal offset for variable-width tabs
local function calculateTabOffset(index)
  -- Calculate total width of all tabs
  local totalWidth = 0
  for i = 1, 5 do
    local width = TAB_WIDTHS[i] or TAB_WIDTH
    if i < 5 then
      totalWidth = totalWidth + width + TAB_SPACING
    else
      totalWidth = totalWidth + width
    end
  end

  -- Calculate the left edge of the first tab (centered)
  local leftEdge = -totalWidth / 2

  -- Calculate cumulative width up to this tab
  local cumulativeWidth = 0
  for i = 1, index - 1 do
    local width = TAB_WIDTHS[i] or TAB_WIDTH
    cumulativeWidth = cumulativeWidth + width + TAB_SPACING
  end

  -- Position this tab's center
  local tabWidth = TAB_WIDTHS[index] or TAB_WIDTH
  local tabCenter = leftEdge + cumulativeWidth + (tabWidth / 2)

  return tabCenter
end

-- Create proper folder tabs with angled edges
local function createTabButton(text, index, parentFrame)
  local button = CreateFrame('Button', nil, parentFrame, 'BackdropTemplate')
  local tabWidth = TAB_WIDTHS[index] or TAB_WIDTH
  button:SetSize(tabWidth, TAB_HEIGHT)
  local horizontalOffset = calculateTabOffset(index)
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
    TabManagerSwitchToTab(index)
  end)

  -- Set initial appearance
  button.backgroundTexture:SetVertexColor(0.6, 0.6, 0.6, 1)
  button:SetAlpha(0.9)

  return button
end

-- Create tab content frames
local function createTabContent(index, parentFrame)
  local content = CreateFrame('Frame', nil, parentFrame)
  content:SetSize(620, 650) -- Use space down to settings frame bottom (~50px was unused at 600)
  content:SetPoint('TOP', parentFrame, 'TOP', 0, -50) -- Positioned below tabs
  content:Hide()
  return content
end

-- Initialize tabs for the settings frame
function TabManagerInitializeTabs(settingsFrame)
  -- Store the settings frame reference
  TabManager.settingsFrame = settingsFrame

  -- Check if tabs are already initialized to prevent duplicates
  if tabButtons[1] then return end

  -- Create tab buttons
  tabButtons[1] = createTabButton('Verification', 1, settingsFrame)
  tabButtons[2] = createTabButton('Settings', 2, settingsFrame)
  tabButtons[3] = createTabButton('Info', 3, settingsFrame)
  tabButtons[4] = createTabButton('Commands', 4, settingsFrame)
  tabButtons[5] = createTabButton('Need Help?', 5, settingsFrame)

  -- Create tab content frames
  tabContents[1] = createTabContent(1, settingsFrame) -- XP Verification tab
  tabContents[2] = createTabContent(2, settingsFrame) -- Settings tab
  tabContents[3] = createTabContent(3, settingsFrame) -- Info tab
  tabContents[4] = createTabContent(4, settingsFrame) -- Commands tab
  tabContents[5] = createTabContent(5, settingsFrame) -- Credits tab
end

-- Switch to a specific tab
function TabManagerSwitchToTab(index)
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
    if UHC_SaveCharacterSettings then
      UHC_SaveCharacterSettings(GLOBAL_SETTINGS)
    end
  end

  -- Initialize Verification tab if it's being shown
  if index == 1 and InitializeVerificationTab then
    InitializeVerificationTab(tabContents)
    if updateRadioButtons then
      updateRadioButtons()
    end
    if RefreshVerificationTab then
      if C_Timer and C_Timer.After then
        C_Timer.After(0, function()
          if TabManagerGetActiveTab and TabManagerGetActiveTab() == 1 and RefreshVerificationTab then
            RefreshVerificationTab()
          end
        end)
      else
        RefreshVerificationTab()
      end
    end
  end

  -- Initialize Settings Options tab if it's being shown
  if index == 2 and InitializeSettingsOptionsTab then
    InitializeSettingsOptionsTab(tabContents)
  end
  -- Initialize Info tab if it's being shown
  if index == 3 and InitializeInfoTab then
    InitializeInfoTab(tabContents)
  end

  -- Initialize Commands tab if it's being shown
  if index == 4 and InitializeCommandsTab then
    InitializeCommandsTab(tabContents)
  end

  -- Initialize Credits tab if it's being shown
  if index == 5 and InitializeCreditsTab then
    InitializeCreditsTab(tabContents)
  end
end

-- Set the default tab (Verification tab)
function TabManagerSetDefaultTab()
  local defaultIndex = 1
  if GLOBAL_SETTINGS and GLOBAL_SETTINGS.lastOpenedSettingsTab then
    local saved = GLOBAL_SETTINGS.lastOpenedSettingsTab
    if type(saved) == 'number' and tabContents[saved] then
      defaultIndex = saved
    end
  end
  TabManagerSwitchToTab(defaultIndex)
end

-- Get the currently active tab
function TabManagerGetActiveTab()
  return activeTab
end

-- Get tab content frame by index
function TabManagerGetTabContent(index)
  return tabContents[index]
end

-- Get tab button by index
function TabManagerGetTabButton(index)
  return tabButtons[index]
end

-- Hide all tabs
function TabManagerHideAllTabs()
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
function TabManagerResetTabState()
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
