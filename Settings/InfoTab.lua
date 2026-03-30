-- Info Tab Content
-- Initialize Info Tab when called
function InitializeInfoTab(tabContents)
  if not tabContents or not tabContents[3] then return end

  -- Check if already initialized to prevent duplicates
  if tabContents[3].initialized then return end

  -- Mark as initialized
  tabContents[3].initialized = true

  -- Philosophy text (at top, moved down by 30)
  local philosophyText = tabContents[3]:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
  philosophyText:SetPoint('TOP', tabContents[3], 'TOP', 0, -70)
  philosophyText:SetWidth(500)
  philosophyText:SetText(
    'UltraHardcore Addon\nVersion: ' .. C_AddOns.GetAddOnMetadata('UltraHardcore', 'Version')
  )
  philosophyText:SetJustifyH('CENTER')
  philosophyText:SetNonSpaceWrap(true)

  -- Bug report text
  local bugReportText = tabContents[3]:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  bugReportText:SetPoint('TOP', philosophyText, 'BOTTOM', 0, -10)
  bugReportText:SetText(
    'Found a bug or have suggestions?\n\nJoin the developers discord community to have your say on the future of this addon!'
  )
  bugReportText:SetJustifyH('CENTER')
  bugReportText:SetTextColor(0.95, 0.95, 0.9)
  bugReportText:SetWidth(500)
  bugReportText:SetNonSpaceWrap(true)

  -- Discord invite button (re-usable helper)
  local discordButton =
    UHC_CreateDiscordInviteButton(
      tabContents[3],
      'TOP',
      bugReportText,
      'BOTTOM',
      0,
      -10,
      220,
      24,
      'Discord Invite Link'
    )

  -- Patch Notes Section (at bottom, bigger to fill space)
  local patchNotesTitle = tabContents[3]:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
  patchNotesTitle:SetPoint('TOP', discordButton, 'BOTTOM', 0, -30)
  patchNotesTitle:SetText('Patch Notes')
  patchNotesTitle:SetJustifyH('CENTER')
  patchNotesTitle:SetTextColor(1, 1, 0.5)

  -- Create patch notes display at bottom (larger to fill space left by removing Twitch button)
  local patchNotesFrame = CreateFrame('Frame', nil, tabContents[3], 'BackdropTemplate')
  patchNotesFrame:SetPoint('TOP', patchNotesTitle, 'BOTTOM', 0, -17)
  patchNotesFrame:SetPoint('LEFT', tabContents[3], 'LEFT', 10, 0)
  patchNotesFrame:SetPoint('RIGHT', tabContents[3], 'RIGHT', -10, 0)
  patchNotesFrame:SetHeight(380)
  patchNotesFrame:SetBackdrop({
    bgFile = 'Interface\\DialogFrame\\UI-DialogBox-Background',
    edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border',
    tile = true,
    tileSize = 64,
    edgeSize = 16,
    insets = {
      left = 3,
      right = 3,
      top = 3,
      bottom = 3,
    },
  })
  patchNotesFrame:SetBackdropColor(0.1, 0.1, 0.1, 0.95)
  patchNotesFrame:SetBackdropBorderColor(0.4, 0.4, 0.4, 0.8)

  -- Create patch notes display using reusable component (larger to fill new space)
  UHC_CreatePatchNotesDisplay(patchNotesFrame, 560, 360, 10, -10)
end
