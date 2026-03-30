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
  hideMinimap = false,
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

-- Preset names and descriptions
local presetData = { {
  name = 'Lite',
  description = 'Your own health bar is hidden and your screen gets darker as your health drops.',
}, {
  name = 'Recommended',
  description = 'The above and - Enemy health bars and levels are hidden. Party members health is replaced with an estimation indicator.',
}, {
  name = 'Extreme',
  description = 'All of the above and - Action bars and the map post level 6 are hidden when not in a rested zone.',
} }

-- Helper function to clear all checkbox settings (set all booleans to false)
function UHC_CreateIntroPanel()
  -- Create a nice custom panel frame
  local frame = CreateFrame('Frame', 'UltraHardcoreIntroPanel', UIParent, 'BackdropTemplate')

  -- Consistent content width for alignment - all sections use this exact width
  local CONTENT_WIDTH = 480
  local FRAME_PADDING = 20
  local FRAME_WIDTH = CONTENT_WIDTH + (FRAME_PADDING * 2)

  -- Frame height will be calculated dynamically based on content
  frame:SetSize(FRAME_WIDTH, 500) -- Initial height, will expand as needed
  frame:SetPoint('CENTER', UIParent, 'CENTER', 0, 40)
  frame:SetClipsChildren(true)

  -- Class-specific background texture (same as settings panel)
  local CLASS_BACKGROUND_MAP = {
    WARRIOR = 'Interface\\AddOns\\UltraHardcore\\Textures\\bg_warrior.png',
    PALADIN = 'Interface\\AddOns\\UltraHardcore\\Textures\\bg_pally.png',
    HUNTER = 'Interface\\AddOns\\UltraHardcore\\Textures\\bg_hunter.png',
    ROGUE = 'Interface\\AddOns\\UltraHardcore\\Textures\\bg_rogue.png',
    PRIEST = 'Interface\\AddOns\\UltraHardcore\\Textures\\bg_priest.png',
    MAGE = 'Interface\\AddOns\\UltraHardcore\\Textures\\bg_mage.png',
    WARLOCK = 'Interface\\AddOns\\UltraHardcore\\Textures\\bg_warlock.png',
    DRUID = 'Interface\\AddOns\\UltraHardcore\\Textures\\bg_druid.png',
    SHAMAN = 'Interface\\AddOns\\UltraHardcore\\Textures\\bg_shaman.png',
  }
  local CLASS_BACKGROUND_ASPECT_RATIO = 1200 / 700

  local function getClassBackgroundTexture()
    local _, classFileName = UnitClass('player')
    if classFileName and CLASS_BACKGROUND_MAP[classFileName] then
      return CLASS_BACKGROUND_MAP[classFileName]
    end
    return 'Interface\\AddOns\\UltraHardcore\\Textures\\bg_warrior.png' -- Default fallback
  end

  local frameBackground = frame:CreateTexture(nil, 'BACKGROUND')
  frameBackground:SetPoint('CENTER', frame, 'CENTER')
  frameBackground:SetTexCoord(0, 1, 0, 1)

  local function updateFrameBackdrop()
    frameBackground:SetTexture(getClassBackgroundTexture())
    local frameHeight = frame:GetHeight()
    frameBackground:SetSize(frameHeight * CLASS_BACKGROUND_ASPECT_RATIO, frameHeight)

    frame:SetBackdrop({
      edgeFile = 'Interface\\Buttons\\WHITE8x8',
      tile = false,
      edgeSize = 2,
      insets = {
        left = 0,
        right = 0,
        top = 0,
        bottom = 0,
      },
    })
    frame:SetBackdropBorderColor(0, 0, 0, 1)
  end
  updateFrameBackdrop()

  -- Add close button
  local closeButton = CreateFrame('Button', nil, frame, 'UIPanelCloseButton')
  closeButton:SetPoint('TOPRIGHT', frame, 'TOPRIGHT', -5, -5)
  closeButton:SetScript('OnClick', function()
    -- Mark intro as seen for this character (without applying preset)
    local characterGUID = UnitGUID('player')
    if not UltraHardcoreDB.introSeen then
      UltraHardcoreDB.introSeen = {}
    end
    UltraHardcoreDB.introSeen[characterGUID] = true
    if UHC_SaveDBData then
      UHC_SaveDBData('introSeen', UltraHardcoreDB.introSeen)
    end
    frame:Hide()
    introPanelOpen = false
  end)

  tinsert(UISpecialFrames, 'UltraHardcoreIntroPanel')
  frame:SetMovable(true)
  frame:EnableMouse(true)
  frame:RegisterForDrag('LeftButton')
  frame:SetScript('OnDragStart', frame.StartMoving)
  frame:SetScript('OnDragStop', frame.StopMovingOrSizing)
  frame:SetFrameStrata('DIALOG')
  frame:SetFrameLevel(20)

  -- Handle keyboard input (Enter to continue if preset selected)
  -- Only capture Enter if chat edit box is not active
  frame:SetScript('OnKeyDown', function(self, key)
    if (key == 'ENTER' or key == 'NUMPADENTER') then
      -- Check if chat edit box is active - if so, don't capture Enter
      local chatFrame = _G.ChatFrame1EditBox
      if chatFrame and chatFrame:IsVisible() and chatFrame:HasFocus() then
        -- Let chat handle Enter, don't capture it
        return
      end

      -- If a preset is selected and continue button is enabled, trigger it
      if selectedPresetIndex and frame.continueButton and frame.continueButton:IsEnabled() then
        frame.continueButton:Click()
      end
    end
  end)
  -- Only enable keyboard after a short delay to avoid capturing Enter from chat command
  if C_Timer and C_Timer.After then
    C_Timer.After(0.1, function()
      frame:EnableKeyboard(true)
    end)
  else
    frame:EnableKeyboard(true)
  end

  -- Title with nice styling (centered)
  local title = frame:CreateFontString(nil, 'OVERLAY', 'GameFontNormalHuge')
  title:SetPoint('TOP', frame, 'TOP', 0, -25)
  title:SetWidth(CONTENT_WIDTH)
  title:SetJustifyH('CENTER')
  title:SetText('Welcome to ULTRA!')
  title:SetTextColor(1, 0.82, 0)
  title:SetShadowOffset(2, -2)
  title:SetShadowColor(0, 0, 0, 1)

  -- Subtitle (centered)
  local subtitle = frame:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
  subtitle:SetPoint('TOP', title, 'BOTTOM', 0, -12)
  subtitle:SetWidth(CONTENT_WIDTH)
  subtitle:SetJustifyH('CENTER')
  subtitle:SetText('Choose your playstyle')
  subtitle:SetTextColor(0.95, 0.95, 0.95)
  subtitle:SetShadowOffset(1, -1)
  subtitle:SetShadowColor(0, 0, 0, 0.9)

  -- Create container for preset entries (centered, exact width)
  local presetContainer = CreateFrame('Frame', nil, frame)
  presetContainer:SetPoint('TOP', subtitle, 'BOTTOM', 0, -20)
  presetContainer:SetPoint('LEFT', frame, 'LEFT', FRAME_PADDING, 0)
  presetContainer:SetPoint('RIGHT', frame, 'RIGHT', -FRAME_PADDING, 0)
  presetContainer:SetHeight(1) -- Will be resized to fit its 3 buttons
  -- Preset icons
  local presetIcons =
    {
      'Interface\\AddOns\\UltraHardcore\\Textures\\skull1_100.png',
      'Interface\\AddOns\\UltraHardcore\\Textures\\skull2_100.png',
      'Interface\\AddOns\\UltraHardcore\\Textures\\skull3_100.png',
    }

  local presetButtons = {}
  local currentYOffset = -5

  -- Create preset entry buttons with nice styling (exact width match)
  for i = 1, 3 do
    -- Create preset entry button with backdrop (full width of container)
    local presetButton = CreateFrame('Button', nil, presetContainer, 'BackdropTemplate')
    presetButton:SetWidth(CONTENT_WIDTH) -- Exact same width as all sections
    presetButton:SetHeight(75) -- Better height for two lines
    presetButton:SetPoint('TOP', presetContainer, 'TOP', 0, currentYOffset)

    -- Improved button backdrop with cleaner look
    presetButton:SetBackdrop({
      bgFile = 'Interface\\DialogFrame\\UI-DialogBox-Background',
      edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border',
      tile = true,
      tileSize = 16,
      edgeSize = 16,
      insets = {
        left = 0,
        right = 0,
        top = 0,
        bottom = 0,
      },
    })
    presetButton:SetBackdropColor(0.18, 0.18, 0.18, 0.9)
    presetButton:SetBackdropBorderColor(0.45, 0.45, 0.45, 0.8)

    -- Hover highlight (fills entire button)
    local highlight = presetButton:CreateTexture(nil, 'HIGHLIGHT')
    highlight:SetAllPoints(presetButton)
    highlight:SetTexture('Interface\\Buttons\\UI-Listbox-Highlight')
    highlight:SetBlendMode('ADD')
    highlight:SetAlpha(0.3)

    -- Selected background (fills entire button)
    local selectedBg = presetButton:CreateTexture(nil, 'BACKGROUND')
    selectedBg:SetAllPoints(presetButton)
    selectedBg:SetTexture('Interface\\Buttons\\UI-Listbox-Highlight')
    selectedBg:SetBlendMode('ADD')
    selectedBg:SetAlpha(0.5)
    selectedBg:Hide()
    presetButton.selectedBg = selectedBg

    -- Selected border highlight (fills entire button)
    local selectedBorder = presetButton:CreateTexture(nil, 'OVERLAY')
    selectedBorder:SetAllPoints(presetButton)
    selectedBorder:SetTexture('Interface\\Buttons\\UI-Listbox-Highlight')
    selectedBorder:SetBlendMode('ADD')
    selectedBorder:SetAlpha(0.6)
    selectedBorder:Hide()
    presetButton.selectedBorder = selectedBorder

    -- Preset icon (skull icon) with better padding (only if icon exists)
    local presetIcon = nil
    if presetIcons[i] then
      presetIcon = presetButton:CreateTexture(nil, 'ARTWORK')
      presetIcon:SetSize(48, 48)
      presetIcon:SetPoint('LEFT', presetButton, 'LEFT', 18, 0)
      presetIcon:SetTexture(presetIcons[i])
    end

    -- Content area for text (aligned properly)
    local textContainer = CreateFrame('Frame', nil, presetButton)
    if presetIcon then
      textContainer:SetPoint('LEFT', presetIcon, 'RIGHT', 18, 0)
      textContainer:SetPoint('RIGHT', presetButton, 'RIGHT', -18, 0)
    else
      textContainer:SetPoint('LEFT', presetButton, 'LEFT', 18, 0)
      textContainer:SetPoint('RIGHT', presetButton, 'RIGHT', -18, 0)
    end
    textContainer:SetPoint('TOP', presetButton, 'TOP', 0, 0)
    textContainer:SetPoint('BOTTOM', presetButton, 'BOTTOM', 0, 0)

    -- Preset title text with improved styling (larger font)
    local presetTitle = textContainer:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
    -- Left align for preset buttons
    presetTitle:SetPoint('TOPLEFT', textContainer, 'TOPLEFT', 0, -12)
    presetTitle:SetPoint('RIGHT', textContainer, 'RIGHT', 0, 0)
    presetTitle:SetJustifyH('LEFT')
    presetTitle:SetText(presetData[i].name)
    presetTitle:SetTextColor(0.95, 0.85, 0.5) -- Softer, more muted gold color
    presetTitle:SetShadowOffset(1, -1)
    presetTitle:SetShadowColor(0, 0, 0, 0.8)

    -- Preset description text with better styling (larger font)
    local presetDesc = textContainer:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
    -- Left align for preset buttons
    presetDesc:SetPoint('TOPLEFT', presetTitle, 'BOTTOMLEFT', 0, -6)
    presetDesc:SetPoint('RIGHT', textContainer, 'RIGHT', 0, 0)
    presetDesc:SetJustifyH('LEFT')
    presetDesc:SetText(presetData[i].description)
    presetDesc:SetTextColor(0.75, 0.75, 0.75) -- Muted gray for description
    presetDesc:SetNonSpaceWrap(true)
    presetDesc:SetSpacing(1)

    -- Ensure button height accommodates two lines of content with proper padding
    local titleHeight = presetTitle:GetStringHeight()
    local descHeight = presetDesc:GetStringHeight()
    presetButton:SetHeight(
      math.max(75, titleHeight + descHeight + 32) -- Ensure space for two lines with padding
    )

    -- Click handler
    presetButton:SetScript('OnClick', function()
      -- Reset all buttons
      for j = 1, 3 do
        if presetButtons[j] then
          if presetButtons[j].selectedBg then
            presetButtons[j].selectedBg:Hide()
          end
          if presetButtons[j].selectedBorder then
            presetButtons[j].selectedBorder:Hide()
          end
          -- Reset button backdrop color
          presetButtons[j]:SetBackdropBorderColor(0.45, 0.45, 0.45, 0.8)
        end
      end
      -- Highlight selected button
      selectedBg:Show()
      selectedBorder:Show()
      presetButton:SetBackdropBorderColor(1, 0.85, 0.3, 1) -- Gold border when selected
      selectedPresetIndex = i

      -- Enable continue button
      if frame.continueButton then
        frame.continueButton:Enable()
      end
    end)

    -- Hover effects
    presetButton:SetScript('OnEnter', function()
      if selectedPresetIndex ~= i then
        highlight:Show()
        presetButton:SetBackdropBorderColor(0.65, 0.65, 0.65, 1)
        presetButton:SetBackdropColor(0.22, 0.22, 0.22, 0.95)
      end
    end)

    presetButton:SetScript('OnLeave', function()
      highlight:Hide()
      if selectedPresetIndex ~= i then
        presetButton:SetBackdropBorderColor(0.45, 0.45, 0.45, 0.8)
        presetButton:SetBackdropColor(0.18, 0.18, 0.18, 0.9)
      end
    end)

    presetButtons[i] = presetButton
    currentYOffset = currentYOffset - presetButton:GetHeight() - 14 -- Better spacing between buttons
  end

  -- Resize the container to tightly fit the buttons (removes extra blank space)
  do
    local lastButton = presetButtons[3]
    if lastButton and presetContainer.GetTop and lastButton.GetBottom then
      local containerTop = presetContainer:GetTop()
      local lastBottom = lastButton:GetBottom()
      if containerTop and lastBottom then
        presetContainer:SetHeight(containerTop - lastBottom + 6)
      end
    end
  end

  -- Informational note (replaces removed "Choose Later" option)
  local chooseLaterText = frame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
  chooseLaterText:SetPoint('TOP', presetContainer, 'BOTTOM', 0, -20)
  chooseLaterText:SetWidth(CONTENT_WIDTH)
  chooseLaterText:SetJustifyH('CENTER')
  chooseLaterText:SetTextColor(0.82, 0.82, 0.82)
  chooseLaterText:SetText('Every option is toggleable and can be updated at any time.')

  -- Continue Button with nice styling (centered, positioned below preset buttons)
  local continueButton = CreateFrame('Button', nil, frame, 'UIPanelButtonTemplate')
  continueButton:SetSize(200, 32)
  continueButton:SetPoint('TOP', chooseLaterText, 'BOTTOM', 0, -10)

  -- Calculate total frame height needed and adjust frame size
  local continueButtonBottom = continueButton:GetBottom()
  local frameTop = frame:GetTop()
  local totalHeight = frameTop - continueButtonBottom + 15 -- Reduced bottom padding
  frame:SetHeight(totalHeight)

  -- Update background texture size after frame height is set
  updateFrameBackdrop()
  continueButton:SetText('Continue')
  continueButton:Disable() -- Disabled by default
  -- Style the button text
  local buttonText = continueButton:GetFontString()
  if buttonText then
    buttonText:SetFontObject('GameFontNormalLarge')
  end
  -- Store reference to continue button for use in click handlers
  frame.continueButton = continueButton

  continueButton:SetScript('OnClick', function()
    -- Apply selected preset if one was chosen (Lite, Recommended, or Extreme)
    if selectedPresetIndex and selectedPresetIndex <= 3 and presets[selectedPresetIndex] then
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
      if UHC_SaveCharacterSettings then
        UHC_SaveCharacterSettings(GLOBAL_SETTINGS)
      end
    end

    -- Mark intro as seen for this character
    local characterGUID = UnitGUID('player')
    if not UltraHardcoreDB.introSeen then
      UltraHardcoreDB.introSeen = {}
    end
    UltraHardcoreDB.introSeen[characterGUID] = true
    if UHC_SaveDBData then
      UHC_SaveDBData('introSeen', UltraHardcoreDB.introSeen)
    end

    -- Hide the intro panel
    frame:Hide()
    introPanelOpen = false

    -- If a preset (Lite, Recommended, Extreme) was selected, reload UI to apply settings
    if selectedPresetIndex and selectedPresetIndex <= 3 then
      ReloadUI()
    else
      -- Choose Later or no preset: open settings to tab 2 (Settings Options tab)
      if OpenSettingsToTab then
        OpenSettingsToTab(2)
      end
    end
  end)

  return frame
end

function ShowIntroPanel(forceShow)
  if not UltraHardcoreDB then return end

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
        ShowIntroPanel(forceShow)
      end)
    end
    return
  end

  -- Check if this character has already seen the intro (unless forced)
  if not forceShow and UltraHardcoreDB.introSeen[characterGUID] then return end

  -- Check if character has played before by checking stats (jumps or kills)
  -- Only show intro panel if stats are empty (new character) - unless forced
  if not forceShow then
    -- Try to check stats if CharacterStats is available
    local hasPlayed = false
    if _G.UltraStatisticsCharacterStats and _G.UltraStatisticsCharacterStats.GetStat then
      local success, jumps, kills = pcall(function()
        return _G.UltraStatisticsCharacterStats:GetStat(
          'playerJumps'
        ) or 0, _G.UltraStatisticsCharacterStats:GetStat('enemiesSlain') or 0
      end)

      if success then
        -- If player has jumps or kills, they've played before
        if (jumps and jumps > 0) or (kills and kills > 0) then
          hasPlayed = true
        end
      end
    else
      -- If CharacterStats is not available, check database directly
      if UltraStatisticsCharacterStats and UltraStatisticsCharacterStats.characterStats and characterGUID then
        local stats = UltraStatisticsCharacterStats.characterStats[characterGUID]
        if stats then
          local jumps = stats.playerJumps or 0
          local kills = stats.enemiesSlain or 0
          if jumps > 0 or kills > 0 then
            hasPlayed = true
          end
        end
      end
    -- If we can't check stats at all, assume new character and show panel
    end

    -- If player has played before, don't show intro
    if hasPlayed then
      -- Mark as seen so we don't check again
      UltraHardcoreDB.introSeen[characterGUID] = true
      if UHC_SaveDBData then
        UHC_SaveDBData('introSeen', UltraHardcoreDB.introSeen)
      end
      return
    end
  end

  -- Only show if not already open
  if not introPanelOpen then
    introPanelOpen = true
    selectedPresetIndex = nil -- Reset selection
    local introFrame = UHC_CreateIntroPanel()
    if introFrame then
      -- Set lastSeenVersion so we don't show the patch notes modal for this first-time character
      local addonVersion
      if C_AddOns and C_AddOns.GetAddOnMetadata then
        addonVersion = C_AddOns.GetAddOnMetadata('UltraHardcore', 'Version')
      end
      if addonVersion then
        UltraHardcoreDB.lastSeenVersion = addonVersion
        if UHC_SaveDBData then
          UHC_SaveDBData('lastSeenVersion', addonVersion)
        end
      end
      introFrame:Show()
    else
      -- If frame creation failed, reset the flag
      introPanelOpen = false
    end
  end
end

-- Function to check if intro panel is currently showing
function UHC_IsIntroPanelShowing()
  return introPanelOpen
end

-- Debug command to manually show intro panel (for testing)
SLASH_SHOWINTRO1 = '/showintro'
SlashCmdList['SHOWINTRO'] = function()
  -- Force show the intro panel (bypass all checks)
  introPanelOpen = false
  ShowIntroPanel(true) -- Pass true to force show
end
