-- Intro Panel for First Time Characters
-- Shows a welcome panel with playstyle selection on first login

local introPanelOpen = false
local selectedPresetIndex = nil

-- Presets matching SettingsOptionsTab.lua
local presets = { {
  -- Preset 1: Lite
  hidePlayerFrame = true,
  showTunnelVision = true,
  hideMinimap = false,
  hideTargetFrame = false,
  hideTargetTooltip = false,
  disableNameplateHealth = false,
  showDazedEffect = false,
  hideGroupHealth = false,
  petsDiePermanently = false,
  hideActionBars = false,
  tunnelVisionMaxStrata = false,
}, {
  -- Preset 2: Recommended
  hidePlayerFrame = true,
  showTunnelVision = true,
  hideMinimap = true,
  hideTargetFrame = true,
  hideTargetTooltip = true,
  disableNameplateHealth = true,
  showDazedEffect = true,
  hideGroupHealth = true,
  petsDiePermanently = false,
  hideActionBars = false,
  tunnelVisionMaxStrata = false,
  routePlanner = false,
}, {
  -- Preset 3: Extreme
  hidePlayerFrame = true,
  showTunnelVision = true,
  hideMinimap = true,
  hideTargetFrame = true,
  hideTargetTooltip = true,
  disableNameplateHealth = true,
  showDazedEffect = true,
  hideGroupHealth = true,
  petsDiePermanently = true,
  hideActionBars = true,
  tunnelVisionMaxStrata = true,
  routePlanner = true,
} }

function CreateIntroPanel()
  local frame =
    CreateFrame('Frame', 'UltraHardcoreIntroPanel', UIParent, 'BackdropTemplate')
  tinsert(UISpecialFrames, 'UltraHardcoreIntroPanel')
  frame:SetSize(500, 600)
  frame:SetPoint('CENTER', UIParent, 'CENTER', 0, 40)
  frame:SetBackdrop({
    bgFile = 'Interface\\DialogFrame\\UI-DialogBox-Background',
    edgeFile = 'Interface\\DialogFrame\\UI-DialogBox-Border',
    tile = true,
    tileSize = 32,
    edgeSize = 32,
    insets = {
      left = 8,
      right = 8,
      top = 8,
      bottom = 8,
    },
  })
  frame:SetMovable(true)
  frame:EnableMouse(true)
  frame:RegisterForDrag('LeftButton')
  frame:SetScript('OnDragStart', frame.StartMoving)
  frame:SetScript('OnDragStop', frame.StopMovingOrSizing)
  frame:SetFrameStrata('DIALOG')
  frame:SetFrameLevel(20)

  -- Handle ESC key to close panel (mark as seen but don't apply preset)
  frame:SetScript('OnKeyDown', function(self, key)
    if key == 'ESCAPE' then
      -- Mark intro as seen for this character (without applying preset)
      local characterGUID = UnitGUID('player')
      if not UltraHardcoreDB.introSeen then
        UltraHardcoreDB.introSeen = {}
      end
      UltraHardcoreDB.introSeen[characterGUID] = true
      if SaveDBData then
        SaveDBData('introSeen', UltraHardcoreDB.introSeen)
      end

      -- Hide the intro panel
      frame:Hide()
      introPanelOpen = false
    end
  end)
  frame:EnableKeyboard(true)

  -- Icon in top left
  local icon = frame:CreateTexture(nil, 'OVERLAY')
  icon:SetSize(64, 64)
  icon:SetPoint('TOPLEFT', frame, 'TOPLEFT', 20, -20)
  icon:SetTexture('Interface\\AddOns\\UltraHardcore\\Textures\\skull3_100.png')

  -- Title
  local title = frame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  title:SetPoint('TOP', frame, 'TOP', 0, -20)
  title:SetWidth(460)
  title:SetJustifyH('CENTER')
  local font, _, flags = title:GetFont()
  title:SetFont(font, 18, flags)
  title:SetTextColor(1, 1, 0)
  title:SetText('Welcome to ULTRA!')

  -- "Choose your playstyle" text
  local playstyleText = frame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  playstyleText:SetPoint('TOP', title, 'BOTTOM', 0, -20)
  playstyleText:SetWidth(460)
  playstyleText:SetJustifyH('CENTER')
  local font, _, flags = playstyleText:GetFont()
  playstyleText:SetFont(font, 14, flags)
  playstyleText:SetTextColor(0.9, 0.9, 0.9)
  playstyleText:SetText('Choose your playstyle')

  -- Container for the three skull icons
  local iconsContainer = CreateFrame('Frame', nil, frame)
  iconsContainer:SetSize(400, 120)
  iconsContainer:SetPoint('TOP', playstyleText, 'BOTTOM', 0, -20)

  -- Preset icons
  local presetIcons = {
    'Interface\\AddOns\\UltraHardcore\\Textures\\skull1_100.png',
    'Interface\\AddOns\\UltraHardcore\\Textures\\skull2_100.png',
    'Interface\\AddOns\\UltraHardcore\\Textures\\skull3_100.png',
  }

  local buttonSize = 100
  local spacing = 20
  local presetButtons = {}

  -- Create three preset buttons
  for i = 1, 3 do
    local button = CreateFrame('Button', nil, iconsContainer, 'BackdropTemplate')
    button:SetSize(buttonSize, buttonSize)

    if i == 1 then
      button:SetPoint('LEFT', iconsContainer, 'CENTER', -buttonSize - spacing / 2, 0)
    elseif i == 2 then
      button:SetPoint('CENTER', iconsContainer, 'CENTER', 0, 0)
    elseif i == 3 then
      button:SetPoint('RIGHT', iconsContainer, 'CENTER', buttonSize + spacing / 2, 0)
    end

    button:SetBackdrop({
      edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border',
      edgeSize = 10,
    })
    button:SetBackdropBorderColor(0.5, 0.5, 0.5)

    local iconTexture = button:CreateTexture(nil, 'ARTWORK')
    iconTexture:SetAllPoints()
    iconTexture:SetTexture(presetIcons[i])

    -- Button click handler will be set after continueButton is created

    button:SetScript('OnEnter', function()
      if selectedPresetIndex ~= i then
        button:SetBackdropBorderColor(0.8, 0.8, 0.8) -- Light grey on hover
      end
    end)

    button:SetScript('OnLeave', function()
      if selectedPresetIndex ~= i then
        button:SetBackdropBorderColor(0.5, 0.5, 0.5) -- Reset to default
      end
    end)

    presetButtons[i] = button
  end

  -- Description text
  local desc1 = frame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  desc1:SetPoint('TOP', iconsContainer, 'BOTTOM', 0, -30)
  desc1:SetWidth(460)
  desc1:SetJustifyH('LEFT')
  local font, _, flags = desc1:GetFont()
  desc1:SetFont(font, 12, flags)
  desc1:SetTextColor(0.9, 0.9, 0.9)
  desc1:SetText(
    'The Ultra addon is designed to enhance the player experience by providing greater immersion and a more challenging way of playing.'
  )
  desc1:SetNonSpaceWrap(true)

  local desc2 = frame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  desc2:SetPoint('TOP', desc1, 'BOTTOM', 0, -15)
  desc2:SetWidth(460)
  desc2:SetJustifyH('LEFT')
  local font, _, flags = desc2:GetFont()
  desc2:SetFont(font, 12, flags)
  desc2:SetTextColor(0.9, 0.9, 0.9)
  desc2:SetText(
    'There is no one way to play. We encourage you to chose as many or as little options as you find most enjoyable.'
  )
  desc2:SetNonSpaceWrap(true)

  local desc3 = frame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  desc3:SetPoint('TOP', desc2, 'BOTTOM', 0, -15)
  desc3:SetWidth(460)
  desc3:SetJustifyH('LEFT')
  local font, _, flags = desc3:GetFont()
  desc3:SetFont(font, 12, flags)
  desc3:SetTextColor(0.9, 0.9, 0.9)
  desc3:SetText(
    'The addons works well with the one life hardcore system, though it is not essential.'
  )
  desc3:SetNonSpaceWrap(true)

  -- Continue Button
  local continueButton = CreateFrame('Button', nil, frame, 'UIPanelButtonTemplate')
  continueButton:SetSize(200, 25)
  continueButton:SetPoint('BOTTOM', frame, 'BOTTOM', 0, 25)
  continueButton:SetText('Continue')
  continueButton:Disable() -- Disabled by default

  -- Store reference to continue button for use in click handlers
  frame.continueButton = continueButton

  continueButton:SetScript('OnClick', function()
    -- Apply selected preset if one was chosen
    if selectedPresetIndex and presets[selectedPresetIndex] then
      local preset = presets[selectedPresetIndex]
      local difficultyNames = { 'lite', 'recommended', 'extreme' }
      local selectedDifficulty = difficultyNames[selectedPresetIndex]

      -- Apply preset to tempSettings (which will be shown in settings)
      if _G.tempSettings then
        for key, value in pairs(preset) do
          _G.tempSettings[key] = value
        end
        _G.tempSettings.selectedDifficulty = selectedDifficulty
      end

      -- Apply preset to GLOBAL_SETTINGS
      if GLOBAL_SETTINGS then
        for key, value in pairs(preset) do
          GLOBAL_SETTINGS[key] = value
        end
        GLOBAL_SETTINGS.selectedDifficulty = selectedDifficulty
      end

      -- Save the settings
      if SaveCharacterSettings then
        SaveCharacterSettings(GLOBAL_SETTINGS)
      end
    end

    -- Mark intro as seen for this character
    local characterGUID = UnitGUID('player')
    if not UltraHardcoreDB.introSeen then
      UltraHardcoreDB.introSeen = {}
    end
    UltraHardcoreDB.introSeen[characterGUID] = true
    if SaveDBData then
      SaveDBData('introSeen', UltraHardcoreDB.introSeen)
    end

    -- Hide the intro panel
    frame:Hide()
    introPanelOpen = false

    -- Open settings to tab 2 (Settings Options tab)
    if OpenSettingsToTab then
      OpenSettingsToTab(2)
    end
  end)

  -- Set button click handlers to use frame.continueButton
  for i = 1, 3 do
    local button = presetButtons[i]
    button:SetScript('OnClick', function()
      -- Reset all buttons
      for j = 1, 3 do
        presetButtons[j]:SetBackdropBorderColor(0.5, 0.5, 0.5)
      end
      -- Highlight selected button
      button:SetBackdropBorderColor(1, 1, 0) -- Yellow border
      selectedPresetIndex = i
      -- Enable continue button
      if frame.continueButton then
        frame.continueButton:Enable()
      end
    end)
  end

  return frame
end

function ShowIntroPanel()
  if not UltraHardcoreDB then
    return
  end

  -- Initialize introSeen if it doesn't exist
  if not UltraHardcoreDB.introSeen then
    UltraHardcoreDB.introSeen = {}
  end

  -- Get character GUID - may be nil if called too early
  local characterGUID = UnitGUID('player')
  
  -- If GUID is not available yet, delay the check
  if not characterGUID then
    -- Try again after a short delay
    if C_Timer and C_Timer.After then
      C_Timer.After(0.5, function()
        ShowIntroPanel()
      end)
    end
    return
  end

  -- Check if this character has already seen the intro
  if UltraHardcoreDB.introSeen[characterGUID] then
    return
  end

  -- Only show if not already open
  if not introPanelOpen then
    introPanelOpen = true
    selectedPresetIndex = nil -- Reset selection
    local introFrame = CreateIntroPanel()
    if introFrame then
      introFrame:Show()
    else
      -- If frame creation failed, reset the flag
      introPanelOpen = false
    end
  end
end

-- Function to check if intro panel is currently showing
function IsIntroPanelShowing()
  return introPanelOpen
end

-- Debug command to manually show intro panel (for testing)
SLASH_SHOWINTRO1 = '/showintro'
SlashCmdList['SHOWINTRO'] = function()
  -- Temporarily mark as not seen to allow showing
  local characterGUID = UnitGUID('player')
  if characterGUID and UltraHardcoreDB and UltraHardcoreDB.introSeen then
    UltraHardcoreDB.introSeen[characterGUID] = nil
  end
  introPanelOpen = false
  ShowIntroPanel()
end
