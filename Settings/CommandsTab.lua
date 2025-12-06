-- Commands Tab Content
-- Builds a readable, scrollable list of all available slash commands

function InitializeCommandsTab()
  -- Ensure tab content exists
  if not tabContents or not tabContents[7] then return end
  -- Prevent duplicate builds
  if tabContents[7].initialized then return end
  tabContents[7].initialized = true

  local parent = tabContents[7]

  -- Title
  local title = parent:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
  title:SetPoint('TOP', parent, 'TOP', 0, -58)
  title:SetText('Commands')
  title:SetTextColor(0.9, 0.85, 0.75, 1) -- Warmer, more readable color
  title:SetShadowOffset(1, -1)
  title:SetShadowColor(0, 0, 0, 0.8)

  -- Short explainer
  local explainer = parent:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  explainer:SetPoint('TOP', title, 'BOTTOM', 0, -6)
  explainer:SetWidth(500)
  explainer:SetJustifyH('CENTER')
  explainer:SetNonSpaceWrap(true)
  explainer:SetText('Use these slash commands in chat.')

  -- Create main container frame with background (similar to StatisticsTab and SettingsOptionsTab)
  local commandsFrame = CreateFrame('Frame', nil, parent, 'BackdropTemplate')
  commandsFrame:SetPoint('TOPLEFT', explainer, 'BOTTOMLEFT', -12, -10)
  commandsFrame:SetPoint('BOTTOMRIGHT', parent, 'BOTTOMRIGHT', -28, 12)
  commandsFrame:SetBackdrop({
    bgFile = 'Interface\\DialogFrame\\UI-DialogBox-Background',
    edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border',
    tile = true,
    tileSize = 64,
    edgeSize = 16,
    insets = {
      left = 5,
      right = 5,
      top = 5,
      bottom = 5,
    },
  })
  commandsFrame:SetBackdropColor(0.1, 0.1, 0.1, 0.95) -- Darker, more solid background
  commandsFrame:SetBackdropBorderColor(0.4, 0.4, 0.4, 0.8) -- Softer border
  -- Scroll frame container
  local scrollFrame = CreateFrame('ScrollFrame', nil, commandsFrame, 'UIPanelScrollFrameTemplate')
  scrollFrame:SetPoint('TOPLEFT', commandsFrame, 'TOPLEFT', 10, -10)
  scrollFrame:SetPoint('BOTTOMRIGHT', commandsFrame, 'BOTTOMRIGHT', -30, 10) -- Leave room for scrollbar on right
  -- Scroll child
  local scrollChild = CreateFrame('Frame', nil, scrollFrame)
  scrollChild:SetSize(1, 1) -- width will be updated on size change
  scrollFrame:SetScrollChild(scrollChild)
  local function updateScrollChildWidth()
    local gutter = 2
    local w = scrollFrame:GetWidth() - gutter
    if w and w > 0 then
      scrollChild:SetWidth(w)
    end
  end
  scrollFrame:SetScript('OnSizeChanged', function()
    updateScrollChildWidth()
  end)
  updateScrollChildWidth()

  -- Styling helpers
  local SECTION_TITLE_COLOR = {
    r = 0.9,
    g = 0.85,
    b = 0.75,
  }
  local COMMAND_COLOR = {
    r = 1,
    g = 0.82,
    b = 0,
  } -- gold-ish
  local DESC_COLOR = {
    r = 0.9,
    g = 0.9,
    b = 0.9,
  }

  local currentYOffset = -6
  local leftPadding = 6
  local rowGap = 8
  local sectionGap = 14

  local function createSectionHeader(parentFrame, text)
    local fs = parentFrame:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
    fs:SetPoint('TOPLEFT', parentFrame, 'TOPLEFT', leftPadding, currentYOffset)
    fs:SetText(text)
    fs:SetTextColor(SECTION_TITLE_COLOR.r, SECTION_TITLE_COLOR.g, SECTION_TITLE_COLOR.b, 1)
    fs:SetShadowOffset(1, -1)
    fs:SetShadowColor(0, 0, 0, 0.8)
    currentYOffset = currentYOffset - 22
  end

  local function createCommandRow(parentFrame, commandsText, descriptionText)
    -- Command line (left)
    local cmd = parentFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
    cmd:SetPoint('TOPLEFT', parentFrame, 'TOPLEFT', leftPadding, currentYOffset)
    cmd:SetText(commandsText)
    cmd:SetTextColor(COMMAND_COLOR.r, COMMAND_COLOR.g, COMMAND_COLOR.b)

    -- Description (right/next line with wrap)
    local desc = parentFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
    desc:SetPoint('TOPLEFT', cmd, 'BOTTOMLEFT', 0, -2)
    desc:SetPoint('RIGHT', parentFrame, 'RIGHT', -8, 0)
    desc:SetWidth(scrollChild:GetWidth() - (leftPadding + 8))
    desc:SetJustifyH('LEFT')
    desc:SetNonSpaceWrap(true)
    desc:SetWordWrap(true)
    desc:SetText(descriptionText)
    desc:SetTextColor(DESC_COLOR.r, DESC_COLOR.g, DESC_COLOR.b)

    -- Advance Y offset by the two lines + gap
    local lineHeight = 28
    currentYOffset = currentYOffset - lineHeight - rowGap
  end

  -- Command definitions (grouped for readability)
  local commandGroups = { {
    header = 'General',
    items = {
      { '/uhc', 'Open the ULTRA settings window.' },
      {
        '/uhcversion, /uhcv',
        'Post your ULTRA version to your current chat (auto-detects context).',
      },
    },
  }, {
    header = 'Posting & Statistics',
    items = {
      { '/uhcstats, /logstats', 'Open a dialog to post your stats to SAY, PARTY, or GUILD.' },
      { '/logstatss', 'Immediately post a condensed stats line to /say.' },
      { '/logstatsp', 'Immediately post a condensed stats line to party chat.' },
      { '/logstatsg', 'Immediately post a condensed stats line to guild chat.' },
      {
        '/setlowesthealth <0-100>',
        'Increase your tracked lowest health value to a specific percentage (only if higher than the current value).',
      },
      {
        '/uhcstatsreset, /uhcsr',
        'Move the on-screen statistics panel to its saved position (or default if none).',
      },
    },
  }, {
    header = 'UI & Minimap',
    items = {
      { '/resetclockposition, /rcp', 'Reset the minimap clock to the default position.' },
      { '/resetmailposition, /rmp', 'Reset the minimap mail icon to the default position.' },
      {
        '/resettrackingposition, /rtp',
        'Reset the minimap tracking button to the default position.',
      },
      { '/resetresourcebar, /rrb', 'Reset the custom resource bar to its default position.' },
    },
  } }

  -- Build content
  for _, group in ipairs(commandGroups) do
    createSectionHeader(scrollChild, group.header)
    for _, item in ipairs(group.items) do
      createCommandRow(scrollChild, item[1], item[2])
    end
    currentYOffset = currentYOffset - sectionGap
  end

  -- Finalize scroll height
  local contentHeight = math.abs(currentYOffset) + 10
  scrollChild:SetHeight(contentHeight)
end
