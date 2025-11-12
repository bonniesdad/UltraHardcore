local explainerOpen = false

local function CreateResourceTrackingExplainerFrame()
  local frame = CreateFrame('Frame', 'UltraHardcoreResourceTrackingExplainer', UIParent, 'BackdropTemplate')
  frame:SetSize(360, 170)
  frame:SetPoint('CENTER')
  frame:SetFrameStrata('DIALOG')
  frame:SetBackdrop({
    bgFile = 'Interface\\DialogFrame\\UI-DialogBox-Background',
    edgeFile = 'Interface\\DialogFrame\\UI-DialogBox-Border',
    tile = true,
    tileSize = 32,
    edgeSize = 16,
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
  frame:Hide()

  local title = frame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  title:SetPoint('TOP', frame, 'TOP', 0, -16)
  title:SetWidth(320)
  title:SetJustifyH('CENTER')
  local font, _, flags = title:GetFont()
  title:SetFont(font, 16, flags)
  title:SetTextColor(1, 1, 0)
  title:SetText('Resource Tracking')

  local icon = frame:CreateTexture(nil, 'ARTWORK')
  icon:SetSize(24, 24)
  icon:SetPoint('TOP', frame, 'TOP', 0, -42)
  icon:SetTexture('Interface\\MINIMAP\\TRACKING\\FindHerbs')

  local message = frame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  message:SetPoint('TOP', frame, 'TOP', 0, -74)
  message:SetWidth(300)
  message:SetJustifyH('CENTER')
  local mfont, _, mflags = message:GetFont()
  message:SetFont(mfont, 12, mflags)
  message:SetText("Quick tip: When your minimap is hidden, casting a tracking spell will briefly highlight nearby resources on your screen (about 5 seconds).")

  local closeButton = CreateFrame('Button', nil, frame, 'UIPanelButtonTemplate')
  closeButton:SetSize(120, 24)
  closeButton:SetPoint('BOTTOM', frame, 'BOTTOM', 0, 20)
  closeButton:SetText('Got it')
  closeButton:SetScript('OnClick', function()
    SaveDBData('shownResourceTrackingExplainer', true)
    explainerOpen = false
    frame:Hide()
  end)

  return frame
end

function ShowResourceTrackingExplainer()
  if explainerOpen then return end
  if UltraHardcoreDB and UltraHardcoreDB.shownResourceTrackingExplainer then return end
  if not GLOBAL_SETTINGS or not GLOBAL_SETTINGS.hideMinimap then return end

  explainerOpen = true
  local frame = _G.UltraHardcoreResourceTrackingExplainer or CreateResourceTrackingExplainerFrame()
  frame:Show()
end


