-- Statistics Tab Content - Redirect message (statistics moved to Ultra Statistics addon)

local ultraStatsCurseforgeDialog
local ultraStatsCurseforgeEditBox
local ultraStatsCurseforgeUrl = 'https://www.curseforge.com/wow/addons/ultra-statistics'

local function ShowUltraStatsCurseforgeDialog()
  if ultraStatsCurseforgeDialog and ultraStatsCurseforgeDialog:IsShown() then
    ultraStatsCurseforgeDialog:Raise()
    if ultraStatsCurseforgeEditBox then
      ultraStatsCurseforgeEditBox:SetFocus()
      ultraStatsCurseforgeEditBox:HighlightText()
      ultraStatsCurseforgeEditBox:SetCursorPosition(0)
    end
    return
  end

  if not ultraStatsCurseforgeDialog then
    ultraStatsCurseforgeDialog =
      CreateFrame('Frame', 'UltraHardcoreUltraStatsCurseforgeDialog', UIParent, 'BackdropTemplate')
    ultraStatsCurseforgeDialog:SetFrameStrata('FULLSCREEN_DIALOG')
    ultraStatsCurseforgeDialog:SetToplevel(true)
    ultraStatsCurseforgeDialog:SetSize(420, 145)
    ultraStatsCurseforgeDialog:SetPoint('CENTER')

    local bgTexture = ultraStatsCurseforgeDialog:CreateTexture(nil, 'BACKGROUND')
    bgTexture:SetAllPoints()
    bgTexture:SetColorTexture(0, 0, 0, 1)

    ultraStatsCurseforgeDialog:SetBackdrop({
      edgeFile = 'Interface\\DialogFrame\\UI-DialogBox-Border',
      tile = false,
      edgeSize = 16,
      insets = {
        left = 4,
        right = 4,
        top = 4,
        bottom = 4,
      },
    })
    ultraStatsCurseforgeDialog:SetBackdropBorderColor(0.6, 0.6, 0.6, 1)

    local title = ultraStatsCurseforgeDialog:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
    title:SetPoint('TOP', ultraStatsCurseforgeDialog, 'TOP', 0, -16)
    title:SetText('Ultra Statistics (CurseForge)')
    title:SetJustifyH('CENTER')

    local message = ultraStatsCurseforgeDialog:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
    message:SetPoint('TOP', title, 'BOTTOM', 0, -8)
    message:SetWidth(380)
    message:SetJustifyH('CENTER')
    message:SetNonSpaceWrap(true)
    message:SetText('Copy the CurseForge link below and paste it into your web browser:')

    ultraStatsCurseforgeEditBox =
      CreateFrame('EditBox', nil, ultraStatsCurseforgeDialog, 'InputBoxTemplate')
    ultraStatsCurseforgeEditBox:SetSize(360, 30)
    ultraStatsCurseforgeEditBox:SetPoint('TOP', message, 'BOTTOM', 0, -10)
    ultraStatsCurseforgeEditBox:SetAutoFocus(false)
    ultraStatsCurseforgeEditBox:SetText(ultraStatsCurseforgeUrl)
    ultraStatsCurseforgeEditBox:SetScript('OnEscapePressed', function(self)
      self:ClearFocus()
    end)
    ultraStatsCurseforgeEditBox:SetScript('OnEditFocusGained', function(self)
      self:HighlightText()
    end)

    local closeButton =
      CreateFrame('Button', nil, ultraStatsCurseforgeDialog, 'UIPanelButtonTemplate')
    closeButton:SetSize(100, 22)
    closeButton:SetText('Close')
    closeButton:SetPoint('TOP', ultraStatsCurseforgeEditBox, 'BOTTOM', 0, -8)
    closeButton:SetScript('OnClick', function()
      ultraStatsCurseforgeDialog:Hide()
    end)

    ultraStatsCurseforgeDialog:SetScript('OnShow', function()
      if ultraStatsCurseforgeEditBox then
        ultraStatsCurseforgeEditBox:SetText(ultraStatsCurseforgeUrl)
        ultraStatsCurseforgeEditBox:SetFocus()
        ultraStatsCurseforgeEditBox:HighlightText()
        ultraStatsCurseforgeEditBox:SetCursorPosition(0)
        ultraStatsCurseforgeDialog:Raise()
      end
    end)
  end

  ultraStatsCurseforgeDialog:Show()
  ultraStatsCurseforgeDialog:Raise()
end

function InitializeStatisticsTab(tabContents)
  if not tabContents or not tabContents[1] then return end
  if tabContents[1].initialized then return end

  tabContents[1].initialized = true

  local container = CreateFrame('Frame', nil, tabContents[1])
  container:SetPoint('TOP', tabContents[1], 'TOP', 0, -55)
  container:SetPoint('LEFT', tabContents[1], 'LEFT', 10, 0)
  container:SetPoint('RIGHT', tabContents[1], 'RIGHT', -10, 0)
  container:SetHeight(200)

  local title = container:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
  title:SetPoint('TOP', container, 'TOP', 0, -20)
  title:SetText('Statistics have moved!')
  title:SetTextColor(0.9, 0.85, 0.75, 1)
  title:SetShadowOffset(1, -1)
  title:SetShadowColor(0, 0, 0, 0.8)

  local subtitle = container:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  subtitle:SetPoint('TOP', title, 'BOTTOM', 0, -12)
  subtitle:SetText('We have created a stand alone addon for all things statistics')
  subtitle:SetTextColor(0.8, 0.78, 0.72, 1)
  subtitle:SetShadowOffset(1, -1)
  subtitle:SetShadowColor(0, 0, 0, 0.6)

  local curseforgeButton = CreateFrame('Button', nil, container, 'UIPanelButtonTemplate')
  curseforgeButton:SetSize(260, 26)
  curseforgeButton:SetPoint('TOP', subtitle, 'BOTTOM', 0, -18)
  curseforgeButton:SetText('Open Statistics Menu')
  curseforgeButton:SetScript('OnClick', function()
    if _G.ToggleUltraStatistics then
      _G.ToggleUltraStatistics()
      if _G.UltraHardcoreSettingsFrame then
        _G.UltraHardcoreSettingsFrame:Hide()
      end
    else
      ShowUltraStatsCurseforgeDialog()
    end
  end)

  -- No-op stubs so callers (TabManager, Settings) do not error
  _G.UpdateLowestHealthDisplay = function() end
  _G.UpdateXPBreakdown = function() end
end
