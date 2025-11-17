-- Commands Tab Content
-- Builds a readable, scrollable list of all available slash commands

function InitializeCommandsTab()
  -- Ensure tab content exists
  if not tabContents or not tabContents[6] then return end
  -- Prevent duplicate builds
  if tabContents[6].initialized then return end
  tabContents[6].initialized = true

  local parent = tabContents[6]

  -- Title
  local title = parent:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
  title:SetPoint('TOP', parent, 'TOP', 0, -58)
  title:SetText('Commands')
  title:SetTextColor(0.922, 0.871, 0.761)

  -- Short explainer
  local explainer = parent:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  explainer:SetPoint('TOP', title, 'BOTTOM', 0, -6)
  explainer:SetWidth(500)
  explainer:SetJustifyH('CENTER')
  explainer:SetNonSpaceWrap(true)
  explainer:SetText('Use these slash commands in chat.')

  -- Scroll frame container
  local scrollFrame = CreateFrame('ScrollFrame', nil, parent, 'UIPanelScrollFrameTemplate')
  scrollFrame:SetPoint('TOPLEFT', parent, 'TOPLEFT', 12, -136)
  scrollFrame:SetPoint('BOTTOMRIGHT', parent, 'BOTTOMRIGHT', -28, 12)

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
    r = 0.922,
    g = 0.871,
    b = 0.761,
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
    fs:SetTextColor(SECTION_TITLE_COLOR.r, SECTION_TITLE_COLOR.g, SECTION_TITLE_COLOR.b)
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
      { '/uhc', 'Open the Ultra Hardcore settings window.' },
      {
        '/uhcversion, /uhcv',
        'Post your UltraHardcore version to your current chat (auto-detects context).',
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
        'Set your tracked “lowest health” value to a specific percentage.',
      },
      {
        '/uhcstatsreset, /uhcsr',
        'Move the on-screen statistics panel to its saved position (or default if none).',
      },
    },
  }, {
    header = 'XP Tracking',
    items = {
      { '/uhcxpreport', 'Print a verification report of your XP (verified vs unverified).' },
    },
  }, {
    header = 'UI & Minimap',
    items = {
      { '/resetclockposition, /rcp', 'Reset the minimap clock to the default position.' },
      { '/resetmailposition, /rmp', 'Reset the minimap mail icon to the default position.' },
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
