-- Patch notes are now loaded from PatchNotes.lua

function CreateVersionUpdateFrame(previousVersion, currentVersion)
  local frame =
    CreateFrame('Frame', 'UltraHardcoreVersionUpdateFrame', UIParent, 'BackdropTemplate')
  frame:SetSize(500, 600) -- Increased height to accommodate important info and button spacing
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
  title:SetPoint('TOP', frame, 'TOP', 0, -20)
  title:SetWidth(460) -- Constrain width to prevent overflowing
  title:SetJustifyH('CENTER')
  local font, _, flags = title:GetFont()
  title:SetFont(font, 18, flags)
  title:SetTextColor(1, 1, 0)
  title:SetText('ULTRA Updated!')

  -- Version info
  local versionText = frame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  versionText:SetPoint('TOP', frame, 'TOP', 0, -45)
  versionText:SetWidth(460)
  versionText:SetJustifyH('CENTER')
  local font, _, flags = versionText:GetFont()
  versionText:SetFont(font, 14, flags)
  versionText:SetTextColor(0.8, 0.8, 1)

  if previousVersion then
    versionText:SetText('Updated from version ' .. previousVersion .. ' to ' .. currentVersion)
  else
    versionText:SetText('Welcome to version ' .. currentVersion)
  end

  -- Patch Notes Section
  local patchNotesLabel = frame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  patchNotesLabel:SetPoint('TOP', frame, 'TOP', 0, -70)
  patchNotesLabel:SetWidth(460)
  patchNotesLabel:SetJustifyH('LEFT')
  local font, _, flags = patchNotesLabel:GetFont()
  patchNotesLabel:SetFont(font, 16, flags)
  patchNotesLabel:SetTextColor(1, 1, 0)
  patchNotesLabel:SetText('Patch Notes:')

  -- Create patch notes display using reusable component
  local patchNotesScrollFrame = CreatePatchNotesDisplay(frame, 430, 320, 35, -100)

  -- Divider line after patch notes
  local divider = frame:CreateTexture(nil, 'OVERLAY')
  divider:SetSize(450, 2)
  divider:SetPoint('TOP', frame, 'TOP', 0, -440)
  divider:SetColorTexture(0.6, 0.6, 0.6, 0.8)
  divider:SetDrawLayer('OVERLAY', 1)

  -- Details Section
  local detailsLabel = frame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  detailsLabel:SetPoint('TOP', frame, 'TOP', 0, -460)
  detailsLabel:SetWidth(460)
  detailsLabel:SetJustifyH('LEFT')
  local font, _, flags = detailsLabel:GetFont()
  detailsLabel:SetFont(font, 14, flags)
  detailsLabel:SetTextColor(1, 1, 0.5)
  detailsLabel:SetText('Important Information:')

  -- Main message
  local message = frame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  message:SetPoint('TOP', frame, 'TOP', 0, -480)
  message:SetWidth(460)
  message:SetJustifyH('LEFT')
  local font, _, flags = message:GetFont()
  message:SetFont(font, 12, flags)
  message:SetText(
    "IMPORTANT: After updating, please review your settings to ensure they're configured correctly for your playstyle.\n\n" .. 'Take a moment to verify your current settings before continuing your hardcore journey.'
  )

  -- Close Button
  local closeButton = CreateFrame('Button', nil, frame, 'UIPanelButtonTemplate')
  closeButton:SetSize(200, 25)
  closeButton:SetPoint('BOTTOM', frame, 'BOTTOM', 0, 25)
  closeButton:SetText('Continue')
  closeButton:SetScript('OnClick', function()
    -- Mark this version as seen
    SaveDBData('lastSeenVersion', currentVersion)
    frame:Hide()

    -- Open UHC settings and navigate to Settings tab (index 2)
    if OpenSettingsToTab then
      OpenSettingsToTab(2)
    end
  end)

  return frame
end

local versionUpdateOpen = false
function ShowVersionUpdateDialog()
  -- Get current version from TOC
  local currentVersion = (UltraGetAddOnMetadata and UltraGetAddOnMetadata(addonName, 'Version')) or 'unknown'

  -- Get last seen version from database
  local lastSeenVersion = UltraDB.lastSeenVersion

  -- Only show dialog if version has changed and dialog isn't already open
  if currentVersion ~= lastSeenVersion and not versionUpdateOpen then
    versionUpdateOpen = true
    local versionFrame = CreateVersionUpdateFrame(lastSeenVersion, currentVersion)
    versionFrame:Show()
  end
end
