-- 🟢 X Found Mode - Intro Page
-- Shows Guild Found and Group Found banners for level 1 players

local function CreateIntroPage(parentFrame)
  local introPage = CreateFrame('Frame', nil, parentFrame)
  introPage:SetAllPoints(parentFrame)
  introPage:Hide()

  -- Title
  local titleText = introPage:CreateFontString(nil, 'OVERLAY', 'GameFontNormalHuge')
  titleText:SetPoint('TOP', introPage, 'TOP', 0, -60)
  titleText:SetText('Choose Your X Found Mode (BETA)')
  titleText:SetTextColor(1, 1, 0.5) -- Light yellow
  -- Description
  local descriptionText = introPage:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  descriptionText:SetPoint('TOP', titleText, 'BOTTOM', 0, -20)
  descriptionText:SetWidth(450)
  descriptionText:SetText(
    'Select your preferred X Found mode. This choice will determine your trading restrictions and gameplay experience.'
  )
  descriptionText:SetJustifyH('CENTER')
  descriptionText:SetNonSpaceWrap(true)

  -- Guild Found Banner Button
  local guildFoundButton = CreateFrame('Button', nil, introPage, 'BackdropTemplate')
  guildFoundButton:SetSize(200, 100)
  guildFoundButton:SetPoint('CENTER', introPage, 'CENTER', -120, -20)

  -- Guild Found Banner Background
  local guildBannerTexture = guildFoundButton:CreateTexture(nil, 'BACKGROUND')
  guildBannerTexture:SetAllPoints()
  guildBannerTexture:SetTexture(
    'Interface\\AddOns\\UltraHardcore\\Textures\\guild-found-banner.png'
  )

  -- Guild Found Button Styling
  guildFoundButton:SetBackdrop({
    edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border',
    edgeSize = 8,
  })
  guildFoundButton:SetBackdropBorderColor(0.5, 0.5, 0.5)

  -- Guild Found Text
  local guildFoundText = guildFoundButton:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
  guildFoundText:SetPoint('CENTER', guildFoundButton, 'CENTER', 0, 0)
  guildFoundText:SetText('Guild Found')
  guildFoundText:SetTextColor(1, 1, 1)

  -- Guild Found Description
  local guildFoundDesc = introPage:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  guildFoundDesc:SetPoint('TOP', guildFoundButton, 'BOTTOM', 0, -10)
  guildFoundDesc:SetWidth(180)
  guildFoundDesc:SetText(
    'Trade only with guild members. More restrictive but allows guild cooperation.'
  )
  guildFoundDesc:SetJustifyH('CENTER')
  guildFoundDesc:SetNonSpaceWrap(true)
  guildFoundDesc:SetTextColor(0.8, 0.8, 0.8)

  -- Phase 2 placeholder (shown when Guild Found UI is disabled)
  local phase2Text = introPage:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
  phase2Text:SetPoint('CENTER', guildFoundButton, 'CENTER', 0, 0)
  phase2Text:SetText('Coming in phase 2')
  phase2Text:SetTextColor(1, 0.95, 0.5)
  phase2Text:Hide()

  -- Group Found Banner Button
  local groupFoundButton = CreateFrame('Button', nil, introPage, 'BackdropTemplate')
  groupFoundButton:SetSize(200, 100)
  groupFoundButton:SetPoint('CENTER', introPage, 'CENTER', 120, -20)

  -- Group Found Banner Background
  local groupBannerTexture = groupFoundButton:CreateTexture(nil, 'BACKGROUND')
  groupBannerTexture:SetAllPoints()
  groupBannerTexture:SetTexture(
    'Interface\\AddOns\\UltraHardcore\\Textures\\group-found-banner.png'
  )

  -- Group Found Button Styling
  groupFoundButton:SetBackdrop({
    edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border',
    edgeSize = 8,
  })
  groupFoundButton:SetBackdropBorderColor(0.5, 0.5, 0.5)

  -- Group Found Text
  local groupFoundText = groupFoundButton:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
  groupFoundText:SetPoint('CENTER', groupFoundButton, 'CENTER', 0, 0)
  groupFoundText:SetText('Group Found')
  groupFoundText:SetTextColor(1, 1, 1)

  -- Group Found Description
  local groupFoundDesc = introPage:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  groupFoundDesc:SetPoint('TOP', groupFoundButton, 'BOTTOM', 0, -10)
  groupFoundDesc:SetWidth(180)
  groupFoundDesc:SetText(
    'Trade only with manually selected players. Create your own trusted trading list.'
  )
  groupFoundDesc:SetJustifyH('CENTER')
  groupFoundDesc:SetNonSpaceWrap(true)
  groupFoundDesc:SetTextColor(0.8, 0.8, 0.8)

  -- Hover effects
  guildFoundButton:SetScript('OnEnter', function(self)
    if _G.UHC_ENABLE_GUILD_FOUND_UI == false then
      self:SetBackdropBorderColor(0.5, 0.5, 0.5)
      return
    end
    self:SetBackdropBorderColor(1, 1, 0) -- Yellow border on hover
    GameTooltip:SetOwner(self, 'ANCHOR_TOP')
    GameTooltip:SetText('Guild Found Mode')
    GameTooltip:AddLine('Click to select Guild Found mode', 1, 1, 1, true)
    GameTooltip:Show()
  end)

  guildFoundButton:SetScript('OnLeave', function(self)
    self:SetBackdropBorderColor(0.5, 0.5, 0.5) -- Reset border
    GameTooltip:Hide()
  end)

  groupFoundButton:SetScript('OnEnter', function(self)
    self:SetBackdropBorderColor(1, 1, 0) -- Yellow border on hover
    GameTooltip:SetOwner(self, 'ANCHOR_TOP')
    GameTooltip:SetText('Group Found Mode')
    GameTooltip:AddLine('Click to select Group Found mode', 1, 1, 1, true)
    GameTooltip:AddLine('Manually curate your trusted trading partners', 0.8, 0.8, 0.8, true)
    GameTooltip:Show()
  end)

  groupFoundButton:SetScript('OnLeave', function(self)
    self:SetBackdropBorderColor(0.5, 0.5, 0.5) -- Reset border
    GameTooltip:Hide()
  end)

  -- Click handlers
  guildFoundButton:SetScript('OnClick', function()
    if _G.UHC_ENABLE_GUILD_FOUND_UI == false then
      -- Do nothing; Guild Found UI is hidden for phase 2
      return
    end
    if XFoundModeManager and XFoundModeManager.ShowGuildConfirmPage then
      XFoundModeManager:ShowGuildConfirmPage()
    end
  end)

  groupFoundButton:SetScript('OnClick', function()
    if XFoundModeManager and XFoundModeManager.ShowGroupConfirmPage then
      XFoundModeManager:ShowGroupConfirmPage()
    end
  end)

  -- Toggle Guild Found elements based on feature flag
  if _G.UHC_ENABLE_GUILD_FOUND_UI == false then
    guildFoundButton:Disable()
    guildBannerTexture:Hide()
    guildFoundText:Hide()
    guildFoundDesc:Hide()
    phase2Text:Show()
  end

  return introPage
end

-- Export the function
if not XFoundModePages then
  XFoundModePages = {}
end
XFoundModePages.CreateIntroPage = CreateIntroPage
