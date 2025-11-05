-- 🟢 X Found Mode - Intro Page
-- Shows Guild Found, Duo Found, and Group Found banners for level 1 players

local function CreateIntroPage(parentFrame)
  local introPage = CreateFrame('Frame', nil, parentFrame)
  introPage:SetAllPoints(parentFrame)
  introPage:Hide()

  -- Title
  local titleText = introPage:CreateFontString(nil, 'OVERLAY', 'GameFontNormalHuge')
  titleText:SetPoint('TOP', introPage, 'TOP', 0, -60)
  titleText:SetText('Choose Your X Found Mode')
  titleText:SetTextColor(1, 1, 0.5) -- Light yellow

  -- Description
  local descriptionText = introPage:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  descriptionText:SetPoint('TOP', titleText, 'BOTTOM', 0, -20)
  descriptionText:SetWidth(450)
  descriptionText:SetText('Select your preferred X Found mode. This choice will determine your trading restrictions and gameplay experience.')
  descriptionText:SetJustifyH('CENTER')
  descriptionText:SetNonSpaceWrap(true)

  -- Guild Found Card
  local guildFoundCard = CreateFrame('Frame', nil, introPage, 'BackdropTemplate')
  guildFoundCard:SetSize(200, 160)
  guildFoundCard:SetPoint('CENTER', introPage, 'CENTER', -110, 60)
  guildFoundCard:SetBackdrop({
    bgFile = 'Interface\\DialogFrame\\UI-DialogBox-Background',
    edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border',
    tile = true,
    tileSize = 16,
    edgeSize = 8,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
  })
  guildFoundCard:SetBackdropColor(0.1, 0.1, 0.1, 0.8)
  guildFoundCard:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)

  -- Guild Found Banner Button
  local guildFoundButton = CreateFrame('Button', nil, guildFoundCard)
  guildFoundButton:SetSize(170, 70)
  guildFoundButton:SetPoint('TOP', guildFoundCard, 'TOP', 0, -15)

  -- Guild Found Banner Background
  local guildBannerTexture = guildFoundButton:CreateTexture(nil, 'BACKGROUND')
  guildBannerTexture:SetAllPoints()
  guildBannerTexture:SetTexture('Interface\\AddOns\\UltraHardcore\\Textures\\guild-found-banner.png')

  -- Guild Found Text
  local guildFoundText = guildFoundButton:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
  guildFoundText:SetPoint('CENTER', guildFoundButton, 'CENTER', 0, 0)
  guildFoundText:SetText('Guild Found')
  guildFoundText:SetTextColor(1, 1, 1)

  -- Guild Found Description
  local guildFoundDesc = guildFoundCard:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  guildFoundDesc:SetPoint('TOP', guildFoundButton, 'BOTTOM', 0, -10)
  guildFoundDesc:SetWidth(180)
  guildFoundDesc:SetText('Trade only with guild members. More restrictive but allows guild cooperation.')
  guildFoundDesc:SetJustifyH('CENTER')
  guildFoundDesc:SetNonSpaceWrap(true)
  guildFoundDesc:SetTextColor(0.8, 0.8, 0.8)

  -- Duo Found Card
  local duoFoundCard = CreateFrame('Frame', nil, introPage, 'BackdropTemplate')
  duoFoundCard:SetSize(200, 160)
  duoFoundCard:SetPoint('CENTER', introPage, 'CENTER', 0, -120)
  duoFoundCard:SetBackdrop({
    bgFile = 'Interface\\DialogFrame\\UI-DialogBox-Background',
    edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border',
    tile = true,
    tileSize = 16,
    edgeSize = 8,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
  })
  duoFoundCard:SetBackdropColor(0.1, 0.1, 0.1, 0.8)
  duoFoundCard:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)

  -- Duo Found Banner Button
  local duoFoundButton = CreateFrame('Button', nil, duoFoundCard)
  duoFoundButton:SetSize(170, 70)
  duoFoundButton:SetPoint('TOP', duoFoundCard, 'TOP', 0, -15)

  -- Duo Found Banner Background
  local duoBannerTexture = duoFoundButton:CreateTexture(nil, 'BACKGROUND')
  duoBannerTexture:SetAllPoints()
  duoBannerTexture:SetTexture('Interface\\AddOns\\UltraHardcore\\Textures\\duo-found-banner.png')

  -- Duo Found Text
  local duoFoundText = duoFoundButton:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
  duoFoundText:SetPoint('CENTER', duoFoundButton, 'CENTER', 0, 0)
  duoFoundText:SetText('Duo Found')
  duoFoundText:SetTextColor(1, 1, 1)

  -- Duo Found Description
  local duoFoundDesc = duoFoundCard:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  duoFoundDesc:SetPoint('TOP', duoFoundButton, 'BOTTOM', 0, -10)
  duoFoundDesc:SetWidth(180)
  duoFoundDesc:SetText('Trade only with one designated partner. Perfect for duo adventures.')
  duoFoundDesc:SetJustifyH('CENTER')
  duoFoundDesc:SetNonSpaceWrap(true)
  duoFoundDesc:SetTextColor(0.8, 0.8, 0.8)

  -- Group Found Card
  local groupFoundCard = CreateFrame('Frame', nil, introPage, 'BackdropTemplate')
  groupFoundCard:SetSize(200, 160)
  groupFoundCard:SetPoint('CENTER', introPage, 'CENTER', 110, 60)
  groupFoundCard:SetBackdrop({
    bgFile = 'Interface\\DialogFrame\\UI-DialogBox-Background',
    edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border',
    tile = true,
    tileSize = 16,
    edgeSize = 8,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
  })
  groupFoundCard:SetBackdropColor(0.1, 0.1, 0.1, 0.8)
  groupFoundCard:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)

  -- Group Found Banner Button
  local groupFoundButton = CreateFrame('Button', nil, groupFoundCard)
  groupFoundButton:SetSize(170, 70)
  groupFoundButton:SetPoint('TOP', groupFoundCard, 'TOP', 0, -15)

  -- Group Found Banner Background
  local groupBannerTexture = groupFoundButton:CreateTexture(nil, 'BACKGROUND')
  groupBannerTexture:SetAllPoints()
  groupBannerTexture:SetTexture('Interface\\AddOns\\UltraHardcore\\Textures\\group-found-banner.png')

  -- Group Found Text
  local groupFoundText = groupFoundButton:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
  groupFoundText:SetPoint('CENTER', groupFoundButton, 'CENTER', 0, 0)
  groupFoundText:SetText('Group Found')
  groupFoundText:SetTextColor(1, 1, 1)

  -- Group Found Description
  local groupFoundDesc = groupFoundCard:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  groupFoundDesc:SetPoint('TOP', groupFoundButton, 'BOTTOM', 0, -10)
  groupFoundDesc:SetWidth(180)
  groupFoundDesc:SetText('Trade only with manually selected players. Create your own trusted trading list.')
  groupFoundDesc:SetJustifyH('CENTER')
  groupFoundDesc:SetNonSpaceWrap(true)
  groupFoundDesc:SetTextColor(0.8, 0.8, 0.8)

  -- Hover effects for cards
  guildFoundButton:SetScript('OnEnter', function(self)
    guildFoundCard:SetBackdropBorderColor(1, 1, 0, 1) -- Yellow border on hover
    GameTooltip:SetOwner(self, 'ANCHOR_TOP')
    GameTooltip:SetText('Guild Found Mode')
    GameTooltip:AddLine('Click to select Guild Found mode', 1, 1, 1, true)
    GameTooltip:Show()
  end)

  guildFoundButton:SetScript('OnLeave', function(self)
    guildFoundCard:SetBackdropBorderColor(0.5, 0.5, 0.5, 1) -- Reset border
    GameTooltip:Hide()
  end)

  duoFoundButton:SetScript('OnEnter', function(self)
    duoFoundCard:SetBackdropBorderColor(1, 1, 0, 1) -- Yellow border on hover
    GameTooltip:SetOwner(self, 'ANCHOR_TOP')
    GameTooltip:SetText('Duo Found Mode')
    GameTooltip:AddLine('Click to select Duo Found mode', 1, 1, 1, true)
    GameTooltip:AddLine('Trade only with one specific partner', 0.8, 0.8, 0.8, true)
    GameTooltip:Show()
  end)

  duoFoundButton:SetScript('OnLeave', function(self)
    duoFoundCard:SetBackdropBorderColor(0.5, 0.5, 0.5, 1) -- Reset border
    GameTooltip:Hide()
  end)

  groupFoundButton:SetScript('OnEnter', function(self)
    groupFoundCard:SetBackdropBorderColor(1, 1, 0, 1) -- Yellow border on hover
    GameTooltip:SetOwner(self, 'ANCHOR_TOP')
    GameTooltip:SetText('Group Found Mode')
    GameTooltip:AddLine('Click to select Group Found mode', 1, 1, 1, true)
    GameTooltip:AddLine('Manually curate your trusted trading partners', 0.8, 0.8, 0.8, true)
    GameTooltip:Show()
  end)

  groupFoundButton:SetScript('OnLeave', function(self)
    groupFoundCard:SetBackdropBorderColor(0.5, 0.5, 0.5, 1) -- Reset border
    GameTooltip:Hide()
  end)

  -- Click handlers
  guildFoundButton:SetScript('OnClick', function()
    if XFoundModeManager and XFoundModeManager.ShowGuildConfirmPage then
      XFoundModeManager:ShowGuildConfirmPage()
    end
  end)

  duoFoundButton:SetScript('OnClick', function()
    if XFoundModeManager and XFoundModeManager.ShowDuoConfirmPage then
      XFoundModeManager:ShowDuoConfirmPage()
    end
  end)

  groupFoundButton:SetScript('OnClick', function()
    if XFoundModeManager and XFoundModeManager.ShowGroupConfirmPage then
      XFoundModeManager:ShowGroupConfirmPage()
    end
  end)

  return introPage
end

-- Export the function
if not XFoundModePages then
  XFoundModePages = {}
end
XFoundModePages.CreateIntroPage = CreateIntroPage