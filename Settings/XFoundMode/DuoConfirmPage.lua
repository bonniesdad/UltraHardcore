-- 🟢 X Found Mode - Duo Found Confirmation Page
-- Confirmation page for selecting Duo Found mode

local function CreateDuoConfirmPage(parentFrame)
  local confirmPage = CreateFrame('Frame', nil, parentFrame)
  confirmPage:SetAllPoints(parentFrame)
  confirmPage:Hide()

  -- Duo Found Banner (behind title)
  local duoBanner = confirmPage:CreateTexture(nil, 'BACKGROUND')
  duoBanner:SetSize(450, 200) -- Match confirmation dialog width
  duoBanner:SetPoint('TOP', confirmPage, 'TOP', 0, -60) -- Behind the title
  duoBanner:SetTexture('Interface\\AddOns\\UltraHardcore\\Textures\\duo-found-banner.png')

  -- Duo Found Banner Border
  local duoBannerBorder = CreateFrame('Frame', nil, confirmPage, 'BackdropTemplate')
  duoBannerBorder:SetSize(450, 200)
  duoBannerBorder:SetPoint('TOP', confirmPage, 'TOP', 0, -60)
  duoBannerBorder:SetBackdrop({
    edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border',
    edgeSize = 8,
  })
  duoBannerBorder:SetBackdropBorderColor(0.8, 0.8, 0.8, 1) -- Light grey border

  -- Title (overlaying the banner)
  local titleText = confirmPage:CreateFontString(nil, 'OVERLAY', 'GameFontNormalHuge')
  titleText:SetPoint('TOP', confirmPage, 'TOP', 0, -80) -- Moved down by 20 pixels
  titleText:SetText('Confirm Duo Found Mode')
  titleText:SetTextColor(1, 1, 1) -- White color
  titleText:SetShadowColor(0, 0, 0, 1) -- Black shadow for border effect
  titleText:SetShadowOffset(2, -2) -- Shadow offset for depth

  -- Confirmation Frame
  local confirmFrame = CreateFrame('Frame', nil, confirmPage, 'BackdropTemplate')
  confirmFrame:SetSize(450, 250)
  confirmFrame:SetPoint('TOP', duoBanner, 'BOTTOM', 0, -20) -- Position below banner

  confirmFrame:SetBackdrop({
    bgFile = 'Interface\\DialogFrame\\UI-DialogBox-Background',
    edgeFile = 'Interface\\DialogFrame\\UI-DialogBox-Border',
    tile = true,
    tileSize = 64,
    edgeSize = 16,
    insets = {
      left = 4,
      right = 4,
      top = 4,
      bottom = 4,
    },
  })
  confirmFrame:SetBackdropColor(0.1, 0.1, 0.1, 0.9)
  confirmFrame:SetBackdropBorderColor(0.6, 0.6, 0.6, 1)

  -- Warning Header
  local warningHeader = confirmFrame:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
  warningHeader:SetPoint('TOP', confirmFrame, 'TOP', 0, -20)
  warningHeader:SetText('WARNING: This choice is PERMANENT!')
  warningHeader:SetTextColor(1, 0.5, 0.5) -- Red

  -- Description
  local descriptionText = confirmFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  descriptionText:SetPoint('TOP', warningHeader, 'BOTTOM', 0, -20)
  descriptionText:SetWidth(400)
  descriptionText:SetText('Duo Found mode will restrict all trading and mail usage to only you and ONE other player. You will need to set your duo partner after confirmation. This cannot be changed once confirmed.')
  descriptionText:SetJustifyH('CENTER')
  descriptionText:SetNonSpaceWrap(true)
  descriptionText:SetTextColor(1, 1, 1)

  -- Restrictions List
  local restrictionsLabel = confirmFrame:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
  restrictionsLabel:SetPoint('TOP', descriptionText, 'BOTTOM', 0, -20)
  restrictionsLabel:SetText('Restrictions include:')
  restrictionsLabel:SetTextColor(1, 1, 0.5)

  local restrictionsList = confirmFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  restrictionsList:SetPoint('TOP', restrictionsLabel, 'BOTTOM', 0, -10)
  restrictionsList:SetWidth(400)
  restrictionsList:SetText('• Trading with anyone except your duo partner\n• Sending mail to anyone except your duo partner\n• Using Auction House\n• Receiving items from anyone except your duo partner')
  restrictionsList:SetJustifyH('CENTER')
  restrictionsList:SetNonSpaceWrap(true)
  restrictionsList:SetTextColor(0.8, 0.8, 0.8)

  -- Button Frame
  local buttonFrame = CreateFrame('Frame', nil, confirmPage)
  buttonFrame:SetSize(300, 50)
  buttonFrame:SetPoint('TOP', confirmFrame, 'BOTTOM', 0, 0)

  -- Confirm Button
  local confirmButton = CreateFrame('Button', nil, buttonFrame, 'UIPanelButtonTemplate')
  confirmButton:SetSize(120, 30)
  confirmButton:SetPoint('LEFT', buttonFrame, 'LEFT', 0, 0)
  confirmButton:SetText('CONFIRM')
  confirmButton.Text:SetTextColor(1, 0.2, 0.2) -- Red text

  -- Cancel Button
  local cancelButton = CreateFrame('Button', nil, buttonFrame, 'UIPanelButtonTemplate')
  cancelButton:SetSize(120, 30)
  cancelButton:SetPoint('RIGHT', buttonFrame, 'RIGHT', 0, 0)
  cancelButton:SetText('Cancel')

  -- Button click handlers
  confirmButton:SetScript('OnClick', function()
    -- Enable Duo Found mode and disable all other modes
    if GLOBAL_SETTINGS then
      GLOBAL_SETTINGS.duoSelfFound = true
      GLOBAL_SETTINGS.duoPartner = nil -- Partner will be set later in status page
      GLOBAL_SETTINGS.groupSelfFound = false
      GLOBAL_SETTINGS.guildSelfFound = false
      -- Clear group names if they exist
      if GLOBAL_SETTINGS.groupFoundNames then
        GLOBAL_SETTINGS.groupFoundNames = {}
      end
      if GLOBAL_SETTINGS.trustedPlayers then
        GLOBAL_SETTINGS.trustedPlayers = {}
      end
    end

    -- Save settings
    if SaveCharacterSettings then
      SaveCharacterSettings(GLOBAL_SETTINGS)
    end

    -- Show success message
    print('|cff00ff00Duo Found mode activated!|r You can now set your duo partner in the status page.')

    -- Return to status page
    if XFoundModeManager and XFoundModeManager.ShowStatusPage then
      XFoundModeManager:ShowStatusPage()
    end
  end)

  cancelButton:SetScript('OnClick', function()
    -- Return to intro page
    if XFoundModeManager and XFoundModeManager.ShowIntroPage then
      XFoundModeManager:ShowIntroPage()
    end
  end)

  -- Hover effects
  confirmButton:SetScript('OnEnter', function(self)
    GameTooltip:SetOwner(self, 'ANCHOR_TOP')
    GameTooltip:SetText('Confirm Duo Found Mode')
    GameTooltip:AddLine('This action cannot be undone!', 1, 0.5, 0.5, true)
    GameTooltip:Show()
  end)

  confirmButton:SetScript('OnLeave', function(self)
    GameTooltip:Hide()
  end)

  cancelButton:SetScript('OnEnter', function(self)
    GameTooltip:SetOwner(self, 'ANCHOR_TOP')
    GameTooltip:SetText('Cancel Selection')
    GameTooltip:AddLine('Return to mode selection', 1, 1, 1, true)
    GameTooltip:Show()
  end)

  cancelButton:SetScript('OnLeave', function(self)
    GameTooltip:Hide()
  end)

  return confirmPage
end

-- Export the function
if not XFoundModePages then
  XFoundModePages = {}
end
XFoundModePages.CreateDuoConfirmPage = CreateDuoConfirmPage