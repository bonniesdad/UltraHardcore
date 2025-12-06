-- Info Tab Content
-- Initialize Info Tab when called
function InitializeInfoTab()
  -- Check if tabContents[5] exists
  if not tabContents or not tabContents[6] then return end

  -- Check if already initialized to prevent duplicates
  if tabContents[6].initialized then return end

  -- Mark as initialized
  tabContents[6].initialized = true

  -- Philosophy text (at top, moved down by 30)
  local philosophyText = tabContents[6]:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
  philosophyText:SetPoint('TOP', tabContents[6], 'TOP', 0, -50)
  philosophyText:SetWidth(500)
  philosophyText:SetText(
    'UltraHardcore Addon\nVersion: ' .. GetAddOnMetadata('UltraHardcore', 'Version')
  )
  philosophyText:SetJustifyH('CENTER')
  philosophyText:SetNonSpaceWrap(true)

  -- Bug report text
  local bugReportText = tabContents[6]:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
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
      tabContents[6],
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
  local patchNotesTitle = tabContents[6]:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
  patchNotesTitle:SetPoint('TOP', discordButton, 'BOTTOM', 0, -30)
  patchNotesTitle:SetText('Patch Notes')
  patchNotesTitle:SetJustifyH('CENTER')
  patchNotesTitle:SetTextColor(1, 1, 0.5)

  -- Create patch notes display at bottom (larger to fill space left by removing Twitch button)
  local patchNotesFrame = CreateFrame('Frame', nil, tabContents[6], 'BackdropTemplate')
  patchNotesFrame:SetSize(600, 420)
  patchNotesFrame:SetPoint('TOP', patchNotesTitle, 'BOTTOM', 0, -5)
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
end
