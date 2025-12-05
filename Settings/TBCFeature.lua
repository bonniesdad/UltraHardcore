-- ============================================================================
-- TBC Feature - Easy to remove: Comment out or delete this entire file
-- To disable: Remove this file from UltraHardcore.toc or comment out the
-- InitializeTBCFeature() call in Settings.lua
-- ============================================================================

function InitializeTBCFeature(
titleBar,
  settingsFrame,
  updateSettingsFrameBackdrop,
  initializeTabs,
  initializeTempSettings
)
  -- TBC Button (top left of title bar)
  local tbcButton = CreateFrame('Button', nil, titleBar, 'BackdropTemplate')
  tbcButton:SetSize(140, 28)
  tbcButton:SetPoint('LEFT', titleBar, 'LEFT', 15, 3)
  tbcButton:SetBackdrop({
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
  tbcButton:SetBackdropBorderColor(0.1, 0.6, 0.3, 1) -- Green border color
  -- TBC button background texture
  local tbcButtonBackground = tbcButton:CreateTexture(nil, 'BACKGROUND')
  tbcButtonBackground:SetAllPoints()
  tbcButtonBackground:SetTexture('Interface\\AddOns\\UltraHardcore\\Textures\\tbc.png')
  tbcButtonBackground:SetTexCoord(0, 1, 0, 1)
  tbcButtonBackground:SetVertexColor(0.3, 0.3, 0.3, 1) -- Much darker
  local tbcButtonText = tbcButton:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
  tbcButtonText:SetPoint('CENTER', tbcButton, 'CENTER', 0, 0)
  tbcButtonText:SetText('The Burning Crusade')
  tbcButtonText:SetTextColor(1, 0.85, 0.3) -- Gold text color
  -- TBC Content Frame (separate overlay, not a tab)
  local tbcContentFrame = CreateFrame('Frame', nil, settingsFrame, 'BackdropTemplate')
  tbcContentFrame:SetSize(660, 640) -- Full width and height below header (700 - 60 header = 640)
  tbcContentFrame:SetPoint('TOP', settingsFrame, 'TOP', 0, -60) -- Below header
  tbcContentFrame:Hide()
  tbcContentFrame:SetFrameStrata('DIALOG')
  tbcContentFrame:SetFrameLevel(25) -- Higher than tab content
  _G.tbcContentFrame = tbcContentFrame -- Make globally accessible
  -- Add darkening edges effect (backdrop border like other tabs)
  tbcContentFrame:SetBackdrop({
    bgFile = nil,
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
  tbcContentFrame:SetBackdropBorderColor(0.1, 0.6, 0.3, 1) -- Green border color
  -- TBC content frame background texture (maintains aspect ratio, no stretching)
  local tbcContentBackground = tbcContentFrame:CreateTexture(nil, 'BACKGROUND')
  tbcContentBackground:SetTexture('Interface\\AddOns\\UltraHardcore\\Textures\\tbc.png')
  tbcContentBackground:SetTexCoord(0, 1, 0, 1)

  -- Maintain aspect ratio: fit to frame width, height will scale proportionally
  -- If image is wider than frame aspect ratio, it may extend beyond frame height (centered)
  local frameWidth = 660
  local frameHeight = 640
  local imageAspectRatio = 1.714 -- Approximate 16:9 aspect ratio (adjust if needed)
  -- Fit to width, calculate proportional height
  local textureWidth = frameWidth
  local textureHeight = frameWidth / imageAspectRatio

  -- If calculated height is less than frame height, fit to height instead (for tall images)
  if textureHeight < frameHeight then
    textureHeight = frameHeight
    textureWidth = frameHeight * imageAspectRatio
  end

  tbcContentBackground:SetSize(textureWidth, textureHeight)
  tbcContentBackground:SetPoint('CENTER', tbcContentFrame, 'CENTER', 0, 0)

  -- Add semi-transparent overlay to reduce vibrancy
  local tbcContentOverlay = tbcContentFrame:CreateTexture(nil, 'ARTWORK')
  tbcContentOverlay:SetAllPoints()
  tbcContentOverlay:SetColorTexture(0, 0, 0, 0.4) -- Dark overlay to reduce vibrancy
  -- Track previous tab when showing TBC
  local previousTabIndex = 1

  -- Initialize TBC content
  local function initializeTBCContent()
    if tbcContentFrame.initialized then return end
    tbcContentFrame.initialized = true

    -- Semi-transparent background panel for text and buttons (for readability)
    local textBackgroundPanel = CreateFrame('Frame', nil, tbcContentFrame, 'BackdropTemplate')
    -- Height will be set after content is created to fit content
    textBackgroundPanel:SetWidth(580)
    textBackgroundPanel:SetPoint('CENTER', tbcContentFrame, 'CENTER', 0, 50)

    -- Solid black background texture (fully opaque)
    local bgTexture = textBackgroundPanel:CreateTexture(nil, 'BACKGROUND')
    bgTexture:SetAllPoints()
    bgTexture:SetColorTexture(0, 0, 0, 0.8) -- Fully opaque black
    -- Gold border using backdrop
    textBackgroundPanel:SetBackdrop({
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
    textBackgroundPanel:SetBackdropBorderColor(0.1, 0.6, 0.3, 1) -- Green border color
    -- Main question text (bigger title)
    local questionText =
      textBackgroundPanel:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightHuge')
    questionText:SetPoint('TOP', textBackgroundPanel, 'TOP', 0, -20)
    questionText:SetWidth(540) -- Reduced width for padding
    questionText:SetText('Would you like to see Ultra in The Burning Crusade?')
    questionText:SetJustifyH('CENTER')
    questionText:SetNonSpaceWrap(true)
    questionText:SetTextColor(0.922, 0.871, 0.761)

    -- Twitch message text (subtitle - bigger and Legion green)
    local twitchMessageText =
      textBackgroundPanel:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
    twitchMessageText:SetPoint('TOP', questionText, 'BOTTOM', 0, -12)
    twitchMessageText:SetWidth(540) -- Reduced width for padding
    twitchMessageText:SetText(
      'Join the developers discord community and twitch channel to have your say on the future of this addon!'
    )
    twitchMessageText:SetJustifyH('CENTER')
    twitchMessageText:SetNonSpaceWrap(true)
    twitchMessageText:SetTextColor(0.1, 0.6, 0.3) -- Darker green color
    local questionnaireText =
      textBackgroundPanel:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightLarge')
    questionnaireText:SetPoint('TOP', twitchMessageText, 'BOTTOM', 0, -12)
    questionnaireText:SetWidth(540)
    questionnaireText:SetText(
      'Please fill out this short questionnaire to help the developers decide the path for TBC.'
    )
    questionnaireText:SetJustifyH('CENTER')
    questionnaireText:SetNonSpaceWrap(true)
    questionnaireText:SetTextColor(0.922, 0.871, 0.761)
    local questionnaireButton =
      UHC_CreateTBCQuestionnaireButton(
        textBackgroundPanel,
        'TOP',
        questionnaireText,
        'BOTTOM',
        0,
        -15,
        220,
        28,
        'TBC Questionnaire'
      )
    -- Discord invite button
    local discordButton =
      UHC_CreateDiscordInviteButton(
        textBackgroundPanel,
        'TOP',
        questionnaireButton,
        'BOTTOM',
        0,
        -10,
        220,
        24,
        'Discord Invite Link'
      )

    -- Twitch invite button (same width as Discord button)
    local twitchButton =
      UHC_CreateTwitchInviteButton(
        textBackgroundPanel,
        'TOP',
        discordButton,
        'BOTTOM',
        0,
        0,
        220,
        28,
        'Twitch Channel'
      )

    -- Calculate and set background panel height to fit content
    local topPadding = 20
    local bottomPadding = 20
    local panelHeight =
      topPadding + (questionText:GetHeight() or 0) + 12 + (twitchMessageText:GetHeight() or 0) + 12 + (questionnaireText:GetHeight() or 0) + 15 + (questionnaireButton:GetHeight() or 0) + 0 + (discordButton:GetHeight() or 0) + 0 + (twitchButton:GetHeight() or 0) + bottomPadding
    textBackgroundPanel:SetHeight(panelHeight)

    -- Back button
    local backButton = CreateFrame('Button', nil, tbcContentFrame, 'UIPanelButtonTemplate')
    backButton:SetSize(100, 24)
    backButton:SetPoint('BOTTOMLEFT', tbcContentFrame, 'BOTTOMLEFT', 10, 10)
    backButton:SetText('Back')
    backButton:SetScript('OnClick', function()
      tbcContentFrame:Hide()
      if TabManager then
        TabManager.switchToTab(previousTabIndex)
      end
    end)
  end

  tbcButton:SetScript('OnClick', function()
    -- Store current tab before showing TBC
    if TabManager then
      previousTabIndex = TabManager.getActiveTab() or 1
    end

    -- Hide all tab contents
    if TabManager then
      TabManager.hideAllTabs()
    end

    -- Initialize and show TBC content
    initializeTBCContent()
    tbcContentFrame:Show()

    -- Make sure settings frame is open
    if not settingsFrame:IsShown() then
      updateSettingsFrameBackdrop()
      initializeTabs()
      initializeTempSettings()
      settingsFrame:Show()
    end
  end)

  tbcButton:SetScript('OnEnter', function(self)
    tbcButtonBackground:SetVertexColor(0.5, 0.5, 0.5, 1) -- Slightly brighter on hover (but still dark)
    tbcButtonText:SetTextColor(1, 0.95, 0.4) -- Brighter gold on hover
  end)

  tbcButton:SetScript('OnLeave', function(self)
    tbcButtonBackground:SetVertexColor(0.3, 0.3, 0.3, 1) -- Reset to dark
    tbcButtonText:SetTextColor(1, 0.85, 0.3) -- Reset to original gold
  end)
end
