-- Credits Tab Content
-- Initialize Credits Tab when called
function InitializeCreditsTab(tabContents)
  -- Check if tabContents[5] exists
  if not tabContents or not tabContents[5] then return end

  -- Check if already initialized to prevent duplicates
  if tabContents[5].initialized then return end

  -- Mark as initialized
  tabContents[5].initialized = true

  -- Background frame with border for all content
  local contentBackground = CreateFrame('Frame', nil, tabContents[5], 'BackdropTemplate')
  contentBackground:SetPoint('TOP', tabContents[5], 'TOP', 0, -60)
  contentBackground:SetPoint('LEFT', tabContents[5], 'LEFT', 10, 0)
  contentBackground:SetPoint('RIGHT', tabContents[5], 'RIGHT', -10, 0)
  contentBackground:SetPoint('BOTTOM', tabContents[5], 'BOTTOM', 0, -30)
  contentBackground:SetBackdrop({
    bgFile = 'Interface\\DialogFrame\\UI-DialogBox-Background',
    edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border',
    tile = true,
    tileSize = 64,
    edgeSize = 16,
    insets = {
      left = 3,
      right = 3,
      top = 3,
      bottom = 3,
    },
  })
  contentBackground:SetBackdropColor(0.1, 0.1, 0.1, 0.95)
  contentBackground:SetBackdropBorderColor(0.4, 0.4, 0.4, 0.8)

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
  discordButton:SetPoint('CENTER', tabContents[5], 'CENTER', 0, 0)

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
  twitchButton:SetPoint('CENTER', tabContents[5], 'CENTER', 0, 0)
end
