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
  tbcButton:SetBackdropBorderColor(0.8, 0.6, 0.2, 1) -- TBC gold border
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
  tbcContentFrame:SetSize(560, 580) -- Full width and height below header (640 - 60 header = 580)
  tbcContentFrame:SetPoint('TOP', settingsFrame, 'TOP', 0, -60) -- Below header
  tbcContentFrame:Hide()
  tbcContentFrame:SetFrameStrata('DIALOG')
  tbcContentFrame:SetFrameLevel(25) -- Higher than tab content
  _G.tbcContentFrame = tbcContentFrame -- Make globally accessible
  -- TBC content frame background texture (maintains aspect ratio, no stretching)
  local tbcContentBackground = tbcContentFrame:CreateTexture(nil, 'BACKGROUND')
  tbcContentBackground:SetTexture('Interface\\AddOns\\UltraHardcore\\Textures\\tbc.png')
  tbcContentBackground:SetTexCoord(0, 1, 0, 1)

  -- Maintain aspect ratio: fit to frame width, height will scale proportionally
  -- If image is wider than frame aspect ratio, it may extend beyond frame height (centered)
  local frameWidth = 560
  local frameHeight = 580
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

  -- Track previous tab when showing TBC
  local previousTabIndex = 1

  -- Initialize TBC content
  local function initializeTBCContent()
    if tbcContentFrame.initialized then return end
    tbcContentFrame.initialized = true

    -- Semi-transparent background panel for text and buttons (for readability)
    local textBackgroundPanel = CreateFrame('Frame', nil, tbcContentFrame, 'BackdropTemplate')
    -- Height will be set after content is created to fit content
    textBackgroundPanel:SetWidth(480)
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
    textBackgroundPanel:SetBackdropBorderColor(0.8, 0.6, 0.2, 1) -- TBC gold border (fully opaque)
    -- Main question text
    local questionText = textBackgroundPanel:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
    questionText:SetPoint('TOP', textBackgroundPanel, 'TOP', 0, -20)
    questionText:SetWidth(440) -- Reduced width for padding
    questionText:SetText('Would you like to see Ultra in The Burning Crusade?')
    questionText:SetJustifyH('CENTER')
    questionText:SetNonSpaceWrap(true)
    questionText:SetTextColor(0.922, 0.871, 0.761)

    -- Twitch message text (subtitle - bigger and brighter)
    local twitchMessageText = textBackgroundPanel:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
    twitchMessageText:SetPoint('TOP', questionText, 'BOTTOM', 0, -12)
    twitchMessageText:SetWidth(440) -- Reduced width for padding
    twitchMessageText:SetText(
      'Join the developers twitch channel to have your say on the future of this addon'
    )
    twitchMessageText:SetJustifyH('CENTER')
    twitchMessageText:SetNonSpaceWrap(true)
    twitchMessageText:SetTextColor(0.95, 0.95, 0.9) -- Brighter color for better readability
    -- Twitch invite button (larger)
    local twitchButton =
      UHC_CreateTwitchInviteButton(
        textBackgroundPanel,
        'TOP',
        twitchMessageText,
        'BOTTOM',
        0,
        -15,
        260,
        28,
        'Twitch Channel'
      )

    -- About the Author section
    local aboutAuthorFrame = CreateFrame('Frame', nil, textBackgroundPanel)
    aboutAuthorFrame:SetSize(440, 140)
    aboutAuthorFrame:SetPoint('TOP', twitchButton, 'BOTTOM', 0, -70)

    -- About the Author title
    local aboutTitle = aboutAuthorFrame:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
    aboutTitle:SetPoint('TOPLEFT', aboutAuthorFrame, 'TOPLEFT', 0, 0)
    aboutTitle:SetText('About the Author')
    aboutTitle:SetTextColor(0.922, 0.871, 0.761)

    -- About the Author text (left side) - with line breaks for each sentence
    local aboutText = aboutAuthorFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
    aboutText:SetPoint('TOPLEFT', aboutTitle, 'BOTTOMLEFT', 0, -6)
    aboutText:SetWidth(280) -- Leave space for profile picture on right
    aboutText:SetText(
      "BonniesDadTV streams 10am - 5pm GMT every weekday.\n\nOur team works tirelessly to keep on top of feature requests and bug reports.\n\nWe're always working on new and exciting ways to play our favourite games.\n\nWe'd love to have you involved!"
    )
    aboutText:SetJustifyH('LEFT')
    aboutText:SetNonSpaceWrap(false) -- Allow line breaks
    aboutText:SetTextColor(0.8, 0.8, 0.8)

    -- Profile picture (right side) - image is already circular, centered vertically
    local profilePicture = aboutAuthorFrame:CreateTexture(nil, 'ARTWORK')
    profilePicture:SetSize(100, 100)
    profilePicture:SetPoint('RIGHT', aboutAuthorFrame, 'RIGHT', 0, 0) -- Centered vertically
    profilePicture:SetTexture('Interface\\AddOns\\UltraHardcore\\Textures\\profile-picture.png')
    profilePicture:SetTexCoord(0, 1, 0, 1)

    -- Calculate and set background panel height to fit content (including 70px gap)
    local bottomElement = aboutAuthorFrame
    local topPadding = 20
    local bottomPadding = 20
    local panelHeight =
      topPadding + (questionText:GetHeight() or 0) + 12 + (twitchMessageText:GetHeight() or 0) + 15 + 28 + 70 + (aboutAuthorFrame:GetHeight() or 140) + bottomPadding
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
