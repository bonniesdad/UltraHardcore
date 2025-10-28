-- 🟢 X Found Mode - Group Found Confirmation Page
-- Confirmation page for selecting Group Found mode

local function CreateGroupConfirmPage(parentFrame)
  local confirmPage = CreateFrame('Frame', nil, parentFrame)
  confirmPage:SetAllPoints(parentFrame)
  confirmPage:Hide()
  
  -- Group Found Banner (behind title)
  local groupBanner = confirmPage:CreateTexture(nil, 'BACKGROUND')
  groupBanner:SetSize(450, 200) -- Match confirmation dialog width
  groupBanner:SetPoint('TOP', confirmPage, 'TOP', 0, -60) -- Behind the title
  groupBanner:SetTexture('Interface\\AddOns\\UltraHardcore\\Textures\\group-found-banner.png')
  
  -- Group Found Banner Border
  local groupBannerBorder = CreateFrame('Frame', nil, confirmPage, 'BackdropTemplate')
  groupBannerBorder:SetSize(450, 200)
  groupBannerBorder:SetPoint('TOP', confirmPage, 'TOP', 0, -60)
  groupBannerBorder:SetBackdrop({
    edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border',
    edgeSize = 8,
  })
  groupBannerBorder:SetBackdropBorderColor(0.8, 0.8, 0.8, 1) -- Light grey border
  
  -- Title (overlaying the banner)
  local titleText = confirmPage:CreateFontString(nil, 'OVERLAY', 'GameFontNormalHuge')
  titleText:SetPoint('TOP', confirmPage, 'TOP', 0, -80) -- Moved down by 20 pixels
  titleText:SetText('Confirm Group Found Mode')
  titleText:SetTextColor(1, 1, 1) -- White color
  titleText:SetShadowColor(0, 0, 0, 1) -- Black shadow for border effect
  titleText:SetShadowOffset(2, -2) -- Shadow offset for depth
  
  -- Confirmation Frame
  local confirmFrame = CreateFrame('Frame', nil, confirmPage, 'BackdropTemplate')
  confirmFrame:SetSize(450, 250)
  confirmFrame:SetPoint('TOP', groupBanner, 'BOTTOM', 0, -20) -- Position below banner
  
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
  descriptionText:SetText('Group Found mode will restrict all trading and mail usage to manually selected players only. You will need to add trusted players to your trading list. This cannot be changed once confirmed.')
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
  restrictionsList:SetText('• Trading with players not on your trusted list\n• Sending mail to players not on your trusted list\n• Receiving items from players not on your trusted list\n• Using Auction House')
  restrictionsList:SetJustifyH('LEFT')
  restrictionsList:SetNonSpaceWrap(true)
  restrictionsList:SetTextColor(0.8, 0.8, 0.8)
  
  -- Button Frame
  local buttonFrame = CreateFrame('Frame', nil, confirmPage)
  buttonFrame:SetSize(300, 50)
  buttonFrame:SetPoint('TOP', confirmFrame, 'BOTTOM', 0, 0) -- Moved up by 20 pixels
  
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
    -- Enable Group Found mode and disable Guild Found mode
    if GLOBAL_SETTINGS then
      GLOBAL_SETTINGS.groupSelfFound = true
      GLOBAL_SETTINGS.guildSelfFound = false -- Ensure only one mode is active
    end
    
    -- Save settings
    if SaveCharacterSettings then
      SaveCharacterSettings(GLOBAL_SETTINGS)
    end
    
    -- Show success message
    print('|cff00ff00Group Found mode activated!|r Trading is now restricted to party members only.')
    
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
    GameTooltip:SetText('Confirm Group Found Mode')
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
XFoundModePages.CreateGroupConfirmPage = CreateGroupConfirmPage
