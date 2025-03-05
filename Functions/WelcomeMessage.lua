function CreateWelcomeFrame()
  local frame = CreateFrame('Frame', 'MyAddonWelcomeFrame', UIParent, 'BackdropTemplate')
  frame:SetSize(400, 355)
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

  -- Text
  local title = frame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  title:SetPoint('TOP', frame, 'TOP', 0, -30)
  title:SetWidth(360) -- Constrain width to prevent overflowing
  title:SetJustifyH('LEFT')
  local font, _, flags = title:GetFont()
  title:SetFont(font, 22, flags)
  title:SetTextColor(1, 1, 0)
  title:SetText('Welcome to Ultra Hardcore!')
  local text = frame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  text:SetPoint('TOP', frame, 'TOP', 0, -70)
  text:SetWidth(360) -- Constrain width to prevent overflowing
  text:SetJustifyH('LEFT')
  local font, _, flags = text:GetFont()
  text:SetFont(font, 15, flags)
  text:SetText(
    "For the best experience, we recommend disabling all other addons and using a new character if you're playing for the first time.\n\nThe goal of this addon is to fully immerse you in the game world.\n\nIt’s ideal for solo play or for grouping with others who are also using the addon.\n\nFeel free to adjust the settings to customize your experience and make it as enjoyable as possible.\n\nYou can connect with other players using the addon on our dedicated Discord server."
  )

  -- Close Button
  local closeButton = CreateFrame('Button', nil, frame, 'UIPanelButtonTemplate')
  closeButton:SetSize(200, 25)
  closeButton:SetPoint('BOTTOM', frame, 'BOTTOM', 0, 20)
  closeButton:SetText('Continue')
  closeButton:SetScript('OnClick', function()
    SaveDBData('WELCOME_MESSAGE_CLOSED', true)
    ToggleSettings()
    frame:Hide()
  end)

  return frame
end

local isOpen = false
function ShowWelcomeMessage()
  if not WELCOME_MESSAGE_CLOSED and not isOpen then
    isOpen = true
    local welcomeFrame = CreateWelcomeFrame()
    welcomeFrame:Show()
  end
end
