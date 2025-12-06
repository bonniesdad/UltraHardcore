-- Credits Tab Content
-- Initialize Credits Tab when called
function InitializeCreditsTab()
  -- Check if tabContents[7] exists
  if not tabContents or not tabContents[8] then return end

  -- Check if already initialized to prevent duplicates
  if tabContents[8].initialized then return end

  -- Mark as initialized
  tabContents[8].initialized = true

  -- Background frame with border for all content
  local contentBackground = CreateFrame('Frame', nil, tabContents[8], 'BackdropTemplate')
  contentBackground:SetPoint('TOP', tabContents[8], 'TOP', 0, -50)
  contentBackground:SetPoint('LEFT', tabContents[8], 'LEFT', 10, 0)
  contentBackground:SetPoint('RIGHT', tabContents[8], 'RIGHT', -10, 0)
  contentBackground:SetPoint('BOTTOM', tabContents[8], 'BOTTOM', 0, -20)
  contentBackground:SetBackdrop({
    bgFile = 'Interface\\DialogFrame\\UI-DialogBox-Background',
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
  contentBackground:SetBackdropColor(0.1, 0.1, 0.1, 0.8)
  contentBackground:SetBackdropBorderColor(0.6, 0.6, 0.6, 1)

  -- About the Author section (reusable component, wider)
  local aboutAuthorFrame =
    UHC_CreateAboutAuthorSection(contentBackground, 'TOP', contentBackground, 'TOP', 0, -20, 560)

  -- The Team section
  local teamTitle = contentBackground:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
  teamTitle:SetPoint('TOPLEFT', aboutAuthorFrame, 'BOTTOMLEFT', 0, 30)
  teamTitle:SetText('The Team')
  teamTitle:SetTextColor(0.922, 0.871, 0.761)

  -- Developers subsection
  local developersLabel = contentBackground:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  developersLabel:SetPoint('TOPLEFT', teamTitle, 'BOTTOMLEFT', 0, -10)
  developersLabel:SetText('Developers:')
  developersLabel:SetTextColor(0.922, 0.871, 0.761)

  local developersNames = contentBackground:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  developersNames:SetPoint('TOPLEFT', developersLabel, 'BOTTOMLEFT', 0, -4)
  developersNames:SetText('Chills, PtchBlvck, Booji, Wootenblatz')
  developersNames:SetTextColor(0.8, 0.8, 0.8)

  -- Design subsection
  local designLabel = contentBackground:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  designLabel:SetPoint('TOPLEFT', developersNames, 'BOTTOMLEFT', 0, -10)
  designLabel:SetText('Design:')
  designLabel:SetTextColor(0.922, 0.871, 0.761)

  local designName = contentBackground:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  designName:SetPoint('TOPLEFT', designLabel, 'BOTTOMLEFT', 0, -4)
  designName:SetText('Vivi')
  designName:SetTextColor(0.8, 0.8, 0.8)

  -- QA subsection
  local qaLabel = contentBackground:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  qaLabel:SetPoint('TOPLEFT', designName, 'BOTTOMLEFT', 0, -10)
  qaLabel:SetText('QA:')
  qaLabel:SetTextColor(0.922, 0.871, 0.761)

  local qaNames = contentBackground:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  qaNames:SetPoint('TOPLEFT', qaLabel, 'BOTTOMLEFT', 0, -4)
  qaNames:SetText('Tulhur, Moltera')
  qaNames:SetTextColor(0.8, 0.8, 0.8)

  -- Join the Developer text (wider, centered in tab)
  local joinDeveloperText = contentBackground:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  joinDeveloperText:SetPoint('TOP', qaNames, 'BOTTOM', 240, -20)
  joinDeveloperText:SetText(
    'Join the developers discord community and twitch channel to help \nsupport us and have your own say on the future of this addon!'
  )
  joinDeveloperText:SetJustifyH('CENTER')
  joinDeveloperText:SetTextColor(0.95, 0.95, 0.9)
  joinDeveloperText:SetWidth(560)
  joinDeveloperText:SetNonSpaceWrap(true)

  -- Discord invite button (centered in tab)
  local discordButton =
    UHC_CreateDiscordInviteButton(
      contentBackground,
      'TOP',
      joinDeveloperText,
      'BOTTOM',
      0,
      -10,
      220,
      24,
      'Discord Invite Link'
    )
  -- Center the button horizontally in the tab
  discordButton:ClearAllPoints()
  discordButton:SetPoint('TOP', joinDeveloperText, 'BOTTOM', 0, -10)
  discordButton:SetPoint('CENTER', tabContents[8], 'CENTER', 0, 0)

  -- Twitch invite button (centered in tab)
  local twitchButton =
    UHC_CreateTwitchInviteButton(
      contentBackground,
      'TOP',
      discordButton,
      'BOTTOM',
      0,
      0,
      220,
      28,
      'Twitch Channel'
    )
  -- Center the button horizontally in the tab
  twitchButton:ClearAllPoints()
  twitchButton:SetPoint('TOP', discordButton, 'BOTTOM', 0, 0)
  twitchButton:SetPoint('CENTER', tabContents[8], 'CENTER', 0, 0)

  -- Donate button (centered in tab)
  local donateButton =
    UHC_CreateKofiInviteButton(
      contentBackground,
      'TOP',
      twitchButton,
      'BOTTOM',
      0,
      0,
      220,
      28,
      'Donate'
    )
  -- Center the button horizontally in the tab
  donateButton:ClearAllPoints()
  donateButton:SetPoint('TOP', twitchButton, 'BOTTOM', 0, 0)
  donateButton:SetPoint('CENTER', tabContents[8], 'CENTER', 0, 0)
end
