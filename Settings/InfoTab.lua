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

  -- Discord Link Text (clickable)
  local discordLinkText = tabContents[5]:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  discordLinkText:SetPoint('CENTER', tabContents[5], 'CENTER', 0, 60)
  discordLinkText:SetText('Discord Server: https://discord.gg/zuSPDNhYEN')
  discordLinkText:SetJustifyH('CENTER')
  discordLinkText:SetTextColor(0.4, 0.8, 1)

  -- Discord instructions text
  local discordInstructions = tabContents[5]:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  discordInstructions:SetPoint('CENTER', tabContents[5], 'CENTER', 0, 40)
  discordInstructions:SetText('Click the link above to copy it to your chatbox')
  discordInstructions:SetJustifyH('CENTER')
  discordInstructions:SetTextColor(0.8, 0.8, 0.8)
  discordInstructions:SetWidth(500)
  discordInstructions:SetNonSpaceWrap(true)

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

  -- Make the text clickable
  local discordLinkFrame = CreateFrame('Button', nil, tabContents[5])
  discordLinkFrame:SetPoint('CENTER', discordLinkText, 'CENTER', 0, 0)
  discordLinkFrame:SetSize(400, 20)
  discordLinkFrame:SetScript('OnClick', function()
    -- Insert the Discord link into the chat input box
    local discordLink = 'https://discord.gg/zuSPDNhYEN'

    -- Get the chat input frame
    local chatFrame = DEFAULT_CHAT_FRAME
    if chatFrame and chatFrame.editBox then
      chatFrame.editBox:SetText(discordLink)
      chatFrame.editBox:HighlightText() -- Select all text for easy copying
      chatFrame.editBox:SetFocus() -- Focus the input box
    end

    -- Also print to console as backup
    print('Discord link copied to chat input box!')
    print('You can now copy it from the chat input field.')
  end)

  -- Add tooltip for the link
  discordLinkFrame:SetScript('OnEnter', function()
    GameTooltip:SetOwner(discordLinkFrame, 'ANCHOR_TOP')
    GameTooltip:SetText('Click to copy Discord link to chat input')
    GameTooltip:AddLine(
      'The link will appear in your chat box where you can easily copy it!',
      1,
      1,
      1,
      true
    )
    GameTooltip:Show()
  end)

  discordLinkFrame:SetScript('OnLeave', function()
    GameTooltip:Hide()
  end)
end
