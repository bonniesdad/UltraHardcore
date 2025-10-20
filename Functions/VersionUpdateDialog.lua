function CreateVersionUpdateFrame(previousVersion, currentVersion)
  local frame = CreateFrame('Frame', 'UltraHardcoreVersionUpdateFrame', UIParent, 'BackdropTemplate')
  frame:SetSize(450, 300)
  frame:SetPoint('CENTER')
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

  -- Title
  local title = frame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  title:SetPoint('TOP', frame, 'TOP', 0, -25)
  title:SetWidth(410) -- Constrain width to prevent overflowing
  title:SetJustifyH('CENTER')
  local font, _, flags = title:GetFont()
  title:SetFont(font, 20, flags)
  title:SetTextColor(1, 1, 0)
  title:SetText('Ultra Hardcore Updated!')

  -- Version info
  local versionText = frame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  versionText:SetPoint('TOP', frame, 'TOP', 0, -55)
  versionText:SetWidth(410)
  versionText:SetJustifyH('CENTER')
  local font, _, flags = versionText:GetFont()
  versionText:SetFont(font, 16, flags)
  versionText:SetTextColor(0.8, 0.8, 1)
  
  if previousVersion then
    versionText:SetText('Updated from version ' .. previousVersion .. ' to ' .. currentVersion)
  else
    versionText:SetText('Welcome to version ' .. currentVersion)
  end

  -- Main message
  local message = frame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  message:SetPoint('TOP', frame, 'TOP', 0, -85)
  message:SetWidth(410)
  message:SetJustifyH('LEFT')
  local font, _, flags = message:GetFont()
  message:SetFont(font, 14, flags)
  message:SetText(
    "The addon has been updated - make sure you have the correct settings selected before continuing your journey.\n\n" ..
    "You can access the settings through the main menu button or by typing '/uhc' in chat.\n\n" ..
    "Take a moment to review your current settings and adjust them as needed for the best experience."
  )

  -- Close Button
  local closeButton = CreateFrame('Button', nil, frame, 'UIPanelButtonTemplate')
  closeButton:SetSize(200, 25)
  closeButton:SetPoint('BOTTOM', frame, 'BOTTOM', 0, 20)
  closeButton:SetText('Continue')
  closeButton:SetScript('OnClick', function()
    -- Mark this version as seen
    SaveDBData('lastSeenVersion', currentVersion)
    frame:Hide()
  end)

  return frame
end

local versionUpdateOpen = false
function ShowVersionUpdateDialog()
  -- Get current version from TOC
  local currentVersion = GetAddOnMetadata(addonName, "Version")
  
  -- Get last seen version from database
  local lastSeenVersion = UltraHardcoreDB.lastSeenVersion
  
  -- Only show dialog if version has changed and dialog isn't already open
  if currentVersion ~= lastSeenVersion and not versionUpdateOpen then
    versionUpdateOpen = true
    local versionFrame = CreateVersionUpdateFrame(lastSeenVersion, currentVersion)
    versionFrame:Show()
  end
end

