-- Info Tab Content
-- Initialize Info Tab when called
function InitializeInfoTab()
  -- Check if tabContents[5] exists
  if not tabContents or not tabContents[5] then return end

  -- Check if already initialized to prevent duplicates
  if tabContents[5].initialized then return end

  -- Mark as initialized
  tabContents[5].initialized = true

  -- Philosophy text (at top)
  local philosophyText = tabContents[5]:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
  philosophyText:SetPoint('CENTER', tabContents[5], 'CENTER', 0, 180)
  philosophyText:SetWidth(500)
  philosophyText:SetText(
    'UltraHardcore Addon\nVersion: ' .. GetAddOnMetadata('UltraHardcore', 'Version')
  )
  philosophyText:SetJustifyH('CENTER')
  philosophyText:SetNonSpaceWrap(true)

  -- Compatibility warning (below philosophy)
  local compatibilityText = tabContents[5]:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  compatibilityText:SetPoint('CENTER', tabContents[5], 'CENTER', 0, 120)
  compatibilityText:SetWidth(500)
  compatibilityText:SetText(
    "Please note: UltraHardcore hasn't been tested with other addons. For the best experience, we recommend using UltraHardcore alone on your hardcore characters."
  )
  compatibilityText:SetJustifyH('CENTER')
  compatibilityText:SetNonSpaceWrap(true)
  compatibilityText:SetTextColor(0.9, 0.9, 0.9)

  -- Bug report text
  local bugReportText = tabContents[5]:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  bugReportText:SetPoint('CENTER', tabContents[5], 'CENTER', 0, 80)
  bugReportText:SetText('Found a bug or have suggestions? Join our Discord community!')
  bugReportText:SetJustifyH('CENTER')
  bugReportText:SetTextColor(0.8, 0.8, 0.8)
  bugReportText:SetWidth(500)
  bugReportText:SetNonSpaceWrap(true)
 
  -- Discord invite button (opens dialog)
  local discordInviteUrl = 'https://discord.gg/zuSPDNhYEN'
  local discordButton = CreateFrame('Button', nil, tabContents[5], 'UIPanelButtonTemplate')
  discordButton:SetPoint('CENTER', tabContents[5], 'CENTER', 0, 40)
  discordButton:SetSize(220, 24)
  discordButton:SetText('Discord Invite Link')
 
  local function ShowDiscordDialog()
    -- Reuse existing dialog if created already
    if tabContents[5].discordDialog then
      local dialog = tabContents[5].discordDialog
      local editBox = tabContents[5].discordEditBox
      dialog:SetFrameStrata('FULLSCREEN_DIALOG')
      dialog:SetToplevel(true)
      dialog:Show()
      dialog:Raise()
      if C_Timer and C_Timer.After and editBox then
        C_Timer.After(0.05, function()
          editBox:SetFocus()
          editBox:HighlightText()
          editBox:SetCursorPosition(0)
          dialog:Raise()
        end)
      end
      return
    end
 
    local dialog = CreateFrame('Frame', 'UltraHardcoreDiscordDialog', UIParent, 'BackdropTemplate')
    dialog:SetFrameStrata('FULLSCREEN_DIALOG')
    dialog:SetToplevel(true)
    dialog:SetSize(420, 145)
    dialog:SetPoint('CENTER')
    dialog:SetBackdrop({
      bgFile = 'Interface\\DialogFrame\\UI-DialogBox-Background',
      edgeFile = 'Interface\\DialogFrame\\UI-DialogBox-Border',
      tile = true,
      tileSize = 32,
      edgeSize = 16,
      insets = {
        left = 4,
        right = 4,
        top = 4,
        bottom = 4,
      },
    })
    dialog:SetBackdropColor(0.1, 0.1, 0.1, 1)
    dialog:SetBackdropBorderColor(0.6, 0.6, 0.6, 1)
 
    local title = dialog:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
    title:SetPoint('TOP', dialog, 'TOP', 0, -16)
    title:SetText('Discord Invite')
    title:SetJustifyH('CENTER')
 
    local message = dialog:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
    message:SetPoint('TOP', title, 'BOTTOM', 0, -8)
    message:SetWidth(380)
    message:SetJustifyH('CENTER')
    message:SetNonSpaceWrap(true)
    message:SetText('Copy the invite link below and paste it into your web browser:')
 
    local editBox = CreateFrame('EditBox', nil, dialog, 'InputBoxTemplate')
    editBox:SetSize(360, 30)
    editBox:SetPoint('TOP', message, 'BOTTOM', 0, -10)
    editBox:SetAutoFocus(false)
    editBox:SetText(discordInviteUrl)
    editBox:SetScript('OnEscapePressed', function(self) self:ClearFocus() end)
    editBox:SetScript('OnEditFocusGained', function(self) self:HighlightText() end)
 
    -- Close button at bottom center
    local closeButton = CreateFrame('Button', nil, dialog, 'UIPanelButtonTemplate')
    closeButton:SetSize(100, 22)
    closeButton:SetText('Close')
    closeButton:SetPoint('TOP', editBox, 'BOTTOM', 0, -8)
    closeButton:SetScript('OnClick', function() dialog:Hide() end)
 
    -- Ensure the text is pre-highlighted each time the dialog is shown
    dialog:SetScript('OnShow', function()
      editBox:SetText(discordInviteUrl)
      -- Slight delay ensures focus/highlight after frame is fully shown
      if C_Timer and C_Timer.After then
        C_Timer.After(0.05, function()
          editBox:SetFocus()
          editBox:HighlightText()
          editBox:SetCursorPosition(0)
          dialog:Raise()
        end)
      else
        editBox:SetFocus()
        editBox:HighlightText()
        editBox:SetCursorPosition(0)
        dialog:Raise()
      end
    end)
 
    tabContents[5].discordDialog = dialog
    tabContents[5].discordEditBox = editBox
 
    dialog:Show()
    dialog:Raise()
  end
 
  discordButton:SetScript('OnClick', function()
    ShowDiscordDialog()
  end)

  -- Patch Notes Section (at bottom)
  local patchNotesTitle = tabContents[5]:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
  patchNotesTitle:SetPoint('CENTER', tabContents[5], 'CENTER', 0, 0)
  patchNotesTitle:SetText('Patch Notes')
  patchNotesTitle:SetJustifyH('CENTER')
  patchNotesTitle:SetTextColor(1, 1, 0.5)

  -- Create patch notes display at bottom
  local patchNotesFrame = CreateFrame('Frame', nil, tabContents[5], 'BackdropTemplate')
  patchNotesFrame:SetSize(520, 280)
  patchNotesFrame:SetPoint('CENTER', tabContents[5], 'CENTER', 0, -160)
  patchNotesFrame:SetBackdrop({
    bgFile = 'Interface\\DialogFrame\\UI-DialogBox-Background',
    edgeFile = 'Interface\\DialogFrame\\UI-DialogBox-Border',
    tile = true,
    tileSize = 32,
    edgeSize = 16,
    insets = {
      left = 4,
      right = 4,
      top = 4,
      bottom = 4,
    },
  })
  patchNotesFrame:SetBackdropColor(0.1, 0.1, 0.1, 0.8)
  patchNotesFrame:SetBackdropBorderColor(0.6, 0.6, 0.6, 1)

  -- Create patch notes display using reusable component
  local patchNotesScrollFrame = CreatePatchNotesDisplay(patchNotesFrame, 480, 260, 10, -10)

end
