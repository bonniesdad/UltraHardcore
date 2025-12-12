-- Statistics Tab Content - Full size scrollable frame

-- Centralized tooltip map for all statistics
local STATISTIC_TOOLTIPS = {
  -- Lowest Health section
  level = 'Your current character level',
  total = "The lowest health percentage you've ever reached across all levels",
  thisLevel = "The lowest health percentage you've reached at your current level",
  thisSession = "The lowest health percentage you've reached in your current play session",
  petDeaths = 'Total number of times your pet has died permanently',
  -- Enemies Slain section
  enemiesSlainTotal = 'Total number of enemies you have killed',
  elitesSlain = 'Number of elite enemies you have killed',
  rareElitesSlain = 'Number of rare elite enemies you have killed',
  worldBossesSlain = 'Number of world bosses you have killed',
  dungeonBossesSlain = 'Number of dungeon bosses you have killed',
  dungeonsCompleted = 'Number of dungeons you have fully completed',
  highestCritValue = 'The highest critical hit damage you have dealt',
  highestHealCritValue = 'The highest critical heal you have done',
  -- Survival section
  healthPotionsUsed = 'Number of health potions you have consumed',
  manaPotionsUsed = 'Number of mana potions you have consumed',
  bandagesApplied = 'Number of bandages you have used to heal',
  targetDummiesUsed = 'Number of target dummies you have used',
  grenadesUsed = 'Number of grenades you have thrown',
  partyDeathsWitnessed = 'Number of party member deaths you have witnessed',
  closeEscapes = 'Number of times your health has dropped below ' .. closeEscapeHealthPercent .. '%',
  duelsTotal = 'Total number of duels you have done',
  duelsWon = 'Number of duels you have won',
  duelsLost = 'Number of duels you have lost',
  duelsWinPercent = 'Percentage of duels you have won',
  playerJumps = 'Number of jumps you have performed.  Work that jump key!',
  mapKeyPressesWhileMapBlocked = 'Times you pressed M while Route Planner blocked the map',
  totalHP = 'Your maximum possible health with current gear and buffs',
  totalMana = 'Your maximum possible mana with current gear and buffs',
}

-- Helper function to attach tooltip to a statistic label
local function AddStatisticTooltip(label, tooltipKey)
  if not label or not tooltipKey then return end

  local tooltipText = STATISTIC_TOOLTIPS[tooltipKey]
  if not tooltipText then return end

  label:SetScript('OnEnter', function()
    GameTooltip:SetOwner(label, 'ANCHOR_RIGHT')
    GameTooltip:SetText(tooltipText, nil, nil, nil, nil, true)
    GameTooltip:Show()
  end)

  label:SetScript('OnLeave', function()
    GameTooltip:Hide()
  end)
end

-- Shared configuration for the new stat bar visuals
local STAT_BAR_HEIGHT = 25
local STAT_BAR_INSET = 2 -- widen bars by reducing side inset by 20px per side
local STAT_FILL_INSET = 3
local ROW_Y_ADJUST = -(LAYOUT.ROW_HEIGHT - STAT_BAR_HEIGHT) / 2
local BAR_VERTICAL_SHIFT = 28 -- pull bars up slightly now that min labels are hidden
local TIER_LEFT_PADDING = 16 -- extra gap from bar start
-- Fill colors progress from calm/neutral to impressive across tiers
local TIER_COLORS = {
  { 0.25, 0.65, 0.9, 0.95 }, -- tier 1: neutral blue
  { 0.3, 0.75, 0.55, 0.95 }, -- tier 2: teal
  { 0.9, 0.75, 0.25, 0.95 }, -- tier 3: gold
  { 0.9, 0.45, 0.25, 0.95 }, -- tier 4: orange
  { 0.9, 0.25, 0.25, 0.95 }, -- tier 5+: red
}

-- Level bar color steps (blue -> red as you near cap)
local LEVEL_COLOR_STEPS = {
  { 0.25, 0.65, 0.9, 0.95 }, -- blue
  { 0.3, 0.75, 0.75, 0.95 }, -- teal
  { 0.35, 0.8, 0.55, 0.95 }, -- green-teal
  { 0.8, 0.75, 0.35, 0.95 }, -- yellow-gold
  { 0.9, 0.55, 0.25, 0.95 }, -- orange
  { 0.9, 0.25, 0.25, 0.95 }, -- red
}

local STAT_BAR_CONFIG = {
  default = {
    base = 100,
    multiplier = 2,
    color = { 0.25, 0.65, 0.9, 0.95 },
    bgColor = { 0.05, 0.05, 0.07, 0.75 },
  },
  percent = {
    type = 'percent',
    max = 100,
    color = { 0.85, 0.35, 0.3, 0.95 },
    bgColor = { 0.07, 0.07, 0.09, 0.75 },
  },
  lowestHealth = {
    type = 'percent',
    max = 100,
    color = { 0.85, 0.25, 0.25, 0.95 },
  },
  lowestHealthThisLevel = {
    type = 'percent',
    max = 100,
    color = { 0.85, 0.25, 0.25, 0.95 },
  },
  lowestHealthThisSession = {
    type = 'percent',
    max = 100,
    color = { 0.85, 0.25, 0.25, 0.95 },
  },
  duelsWinPercent = {
    type = 'percent',
    max = 100,
    color = { 0.9, 0.7, 0.25, 0.95 },
  },
  -- Numeric stats with individualized tier settings (all inherit default base/multiplier unless overridden)
  level = {
    type = 'percent',
    max = 60, -- classic cap
  },
  closeEscapes = {
    base = 10,
    multiplier = 2,
  },
  petDeaths = { valueOnly = true },
  enemiesSlain = {
    base = 1000,
    multiplier = 3,
  },
  elitesSlain = {
    base = 200,
    multiplier = 3,
  },
  rareElitesSlain = {
    base = 25,
    multiplier = 2,
  },
  worldBossesSlain = {
    base = 10,
    multiplier = 2,
  },
  dungeonBossesKilled = {
    base = 25,
    multiplier = 2,
  },
  dungeonsCompleted = {
    base = 25,
    multiplier = 2,
  },
  highestCritValue = {
    base = 500,
    multiplier = 2,
    valueOnly = true,
  },
  highestHealCritValue = {
    base = 500,
    multiplier = 2,
    valueOnly = true,
  },
  healthPotionsUsed = {
    base = 25,
    multiplier = 2,
  },
  manaPotionsUsed = {
    base = 25,
    multiplier = 2,
  },
  bandagesUsed = {
    base = 50,
    multiplier = 2,
  },
  targetDummiesUsed = {
    base = 20,
    multiplier = 2,
  },
  grenadesUsed = {
    base = 25,
    multiplier = 2,
  },
  partyMemberDeaths = {
    base = 25,
    multiplier = 2,
    valueOnly = true,
  },
  duelsTotal = {
    base = 25,
    multiplier = 2,
  },
  duelsWon = {
    base = 25,
    multiplier = 2,
  },
  duelsLost = {
    base = 25,
    multiplier = 2,
    valueOnly = true,
  },
  playerJumps = {
    base = 10000,
    multiplier = 3,
  },
  mapKeyPressesWhileMapBlocked = {
    base = 50,
    multiplier = 2,
    valueOnly = true,
  },
}

local statBars = {}

local function CreateStatBar(parent)
  local barFrame = CreateFrame('Frame', nil, parent, 'BackdropTemplate')
  barFrame:SetHeight(STAT_BAR_HEIGHT)
  barFrame:SetBackdrop({
    bgFile = 'Interface\\Buttons\\WHITE8X8',
    edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border',
    tile = true,
    tileSize = 8,
    edgeSize = 8,
    insets = {
      left = 2,
      right = 2,
      top = 2,
      bottom = 2,
    },
  })
  barFrame:SetBackdropColor(0.12, 0.16, 0.24, 0.85)
  barFrame:SetBackdropBorderColor(0.18, 0.35, 0.55, 0.9)

  local bg = barFrame:CreateTexture(nil, 'BACKGROUND')
  bg:SetPoint('TOPLEFT', barFrame, 'TOPLEFT', 2, -2)
  bg:SetPoint('BOTTOMRIGHT', barFrame, 'BOTTOMRIGHT', -2, 2)
  bg:SetColorTexture(0.08, 0.12, 0.2, 0.85)

  local fill = barFrame:CreateTexture(nil, 'ARTWORK')
  fill:SetPoint('TOPLEFT', bg, 'TOPLEFT', STAT_FILL_INSET, -STAT_FILL_INSET)
  fill:SetPoint('BOTTOMLEFT', bg, 'BOTTOMLEFT', STAT_FILL_INSET, STAT_FILL_INSET)
  fill:SetWidth(0)
  fill:SetColorTexture(0.25, 0.65, 0.9, 0.95)

  local text = barFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
  text:SetPoint('CENTER', barFrame, 'CENTER', 0, 0)

  -- Dedicated container to force highest z-order for tier text/background
  local tierContainer = CreateFrame('Frame', nil, barFrame)
  tierContainer:SetFrameLevel(barFrame:GetFrameLevel() + 20)

  local tierText = tierContainer:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
  tierText:SetPoint('TOPRIGHT', barFrame, 'TOPRIGHT', 0, 9)
  tierText:SetDrawLayer('OVERLAY', 50) -- keep above any pill/bg/fill
  tierText:SetTextColor(1, 1, 1, 1) -- bright white for readability
  -- Pill-style backdrop behind tier text
  local tierBg = CreateFrame('Frame', nil, tierContainer, 'BackdropTemplate')
  tierBg:SetFrameLevel(tierContainer:GetFrameLevel() - 1)
  tierBg:SetBackdrop({
    bgFile = 'Interface\\Buttons\\WHITE8X8',
    edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border',
    tile = true,
    tileSize = 8,
    edgeSize = 10,
    insets = {
      left = 3,
      right = 3,
      top = 2,
      bottom = 2,
    },
  })
  tierBg:SetBackdropColor(0, 0, 0, 0.35)
  tierBg:SetBackdropBorderColor(0, 0, 0, 0.5)
  tierBg:Hide()

  return {
    frame = barFrame,
    fill = fill,
    text = text,
    tier = tierText,
    tierBg = tierBg,
    tierContainer = tierContainer,
    bg = bg,
  }
end

local function PositionStatBar(bar, parent, yOffset)
  if not bar or not bar.frame then return end
  bar.frame:ClearAllPoints()
  bar.frame:SetPoint(
    'TOPLEFT',
    parent,
    'TOPLEFT',
    LAYOUT.ROW_INDENT + STAT_BAR_INSET,
    yOffset - LAYOUT.ROW_HEIGHT - (LAYOUT.ROW_HEIGHT - STAT_BAR_HEIGHT) / 2 + BAR_VERTICAL_SHIFT
  )
  bar.frame:SetPoint(
    'TOPRIGHT',
    parent,
    'TOPRIGHT',
    -LAYOUT.ROW_INDENT - STAT_BAR_INSET,
    yOffset - LAYOUT.ROW_HEIGHT - (LAYOUT.ROW_HEIGHT - STAT_BAR_HEIGHT) / 2 + BAR_VERTICAL_SHIFT
  )
end

local function CreateBarRow(parent, statKey, yOffset, isLast)
  local bar = CreateStatBar(parent)
  bar.minText = parent:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
  bar.maxText = parent:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')

  bar.tier:ClearAllPoints()
  bar.tier:SetPoint('TOPRIGHT', parent, 'TOPRIGHT', -LAYOUT.ROW_INDENT, yOffset + ROW_Y_ADJUST)

  bar.minText:SetPoint('BOTTOMLEFT', bar.frame, 'TOPLEFT', 0, 4)
  -- Show the max value inside the bar on the right
  bar.maxText:ClearAllPoints()
  bar.maxText:SetPoint('RIGHT', bar.frame, 'RIGHT', -6, 0)
  bar.maxText:SetJustifyH('RIGHT')
  bar.maxText:SetDrawLayer('OVERLAY', 10) -- ensure it sits above fills/frames
  -- Match styling to the centered current value
  local r, g, b, a = bar.text:GetTextColor()
  local sr, sg, sb, sa = bar.text:GetShadowColor()
  local sx, sy = bar.text:GetShadowOffset()
  local font, fontSize, fontFlags = bar.text:GetFont()
  if font then
    bar.maxText:SetFont(font, fontSize, fontFlags)
  end
  local fontObj = bar.text:GetFontObject()
  if fontObj then
    bar.maxText:SetFontObject(fontObj)
  end
  bar.maxText:SetTextColor(r, g, b, a)
  if sr and sg and sb and sa then
    bar.maxText:SetShadowColor(sr, sg, sb, sa)
  end
  if sx and sy then
    bar.maxText:SetShadowOffset(sx, sy)
  end

  if not isLast then
    local divider = parent:CreateTexture(nil, 'ARTWORK')
    divider:SetColorTexture(0.25, 0.25, 0.3, 0.65)
    divider:SetHeight(1) -- fill more space below (reduce post-divider gap by ~30px)
    divider:SetPoint('TOP', bar.frame, 'BOTTOM', 0, -14) -- add 10px more gap above divider
    divider:SetPoint('LEFT', parent, 'LEFT', LAYOUT.ROW_INDENT + 5, 0)
    divider:SetPoint('RIGHT', parent, 'RIGHT', -LAYOUT.ROW_INDENT - 5, 0)
    bar.divider = divider
  end

  statBars[statKey] = bar
  PositionStatBar(bar, parent, yOffset)
  return bar
end

local function CalculateTierProgress(value, base, multiplier)
  local currentValue = math.max(0, value or 0)
  local tier = 1
  local tierMax = base

  while currentValue > tierMax do
    tier = tier + 1
    tierMax = tierMax * multiplier
  end

  local tierMin = tier == 1 and 0 or (tierMax / multiplier)
  local range = tierMax - tierMin
  local progress = range > 0 and (currentValue - tierMin) / range or 0

  return tier, tierMin, tierMax, math.min(math.max(progress, 0), 1)
end

local function UpdateStatBar(statKey, value)
  local bar = statBars[statKey]
  if not bar then return end

  local cfg = STAT_BAR_CONFIG[statKey] or STAT_BAR_CONFIG.default
  local valueOnly = cfg.valueOnly
  local fillColor = cfg.color or STAT_BAR_CONFIG.default.color
  local bgColor = cfg.bgColor or STAT_BAR_CONFIG.default.bgColor
  local effectiveFillColor = fillColor

  if valueOnly then
    -- Hide bar visuals, show only the value text with a subtle badge-style background
    if bar.bg then
      bar.bg:Hide()
    end
    if bar.fill then
      bar.fill:Hide()
    end
    local displayText
    local badgeColor = fillColor or { 0.8, 0.8, 0.8, 0.95 }
    local textColor = badgeColor
    if cfg.type == 'percent' then
      local pctMax = cfg.max or 100
      local percent = math.max(0, math.min(value or 0, pctMax))
      displayText = string.format('%.1f%%', percent)
    else
      displayText = formatNumberWithCommas(value or 0)
    end
    if bar.minText then
      bar.minText:Hide()
    end
    if bar.maxText then
      bar.maxText:Hide()
    end
    if bar.tier then
      bar.tier:SetText('')
      bar.tier:Hide()
    end
    if bar.tierBg then
      bar.tierBg:Hide()
    end
    bar.frame:SetBackdrop({
      bgFile = 'Interface\\Buttons\\WHITE8X8',
      edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border',
      tile = true,
      tileSize = 8,
      edgeSize = 8,
      insets = {
        left = 2,
        right = 2,
        top = 2,
        bottom = 2,
      },
    })
    bar.frame:SetBackdropColor(badgeColor[1], badgeColor[2], badgeColor[3], 0.18)
    bar.frame:SetBackdropBorderColor(badgeColor[1], badgeColor[2], badgeColor[3], 0.35)
    bar.text:ClearAllPoints()
    bar.text:SetPoint('CENTER', bar.frame, 'CENTER', 0, 0)
    bar.text:SetText(displayText or '')
    bar.text:SetTextColor(textColor[1] or 1, textColor[2] or 1, textColor[3] or 1, 1)
    if bar.tier then
      bar.tier:Hide()
    end
    if bar.tierBg then
      bar.tierBg:Hide()
    end
    -- Keep bar height consistent
    bar.frame:SetHeight(STAT_BAR_HEIGHT)
    return
  end

  -- Ensure visuals are shown for normal bar mode
  if bar.bg then
    bar.bg:Show()
  end
  if bar.fill then
    bar.fill:Show()
  end
  if bar.tier then
    bar.tier:Show()
  end
  if bar.minText then
    bar.minText:Hide()
    bar.minText:SetText('')
  end
  if bar.maxText then
    bar.maxText:Show()
  end

  if cfg.type == 'percent' then
    local pctMax = cfg.max or 100
    local percent = math.max(0, math.min(value or 0, pctMax))
    local progress = pctMax > 0 and percent / pctMax or 0
    if statKey == 'level' and #LEVEL_COLOR_STEPS > 0 then
      local idx =
        math.min(#LEVEL_COLOR_STEPS, math.max(1, math.floor(progress * #LEVEL_COLOR_STEPS) + 1))
      effectiveFillColor = LEVEL_COLOR_STEPS[idx] or effectiveFillColor
    end
    local availableWidth =
      (bar.bg and (bar.bg:GetWidth() - STAT_FILL_INSET * 2)) or bar.frame:GetWidth()
    bar.fill:SetWidth(availableWidth * progress)
    if statKey == 'level' then
      bar.text:SetText(string.format('%d', value or 0))
    else
      bar.text:SetText(string.format('%.1f%%', percent))
    end
    bar.tier:SetText('')
    if bar.minText then
      bar.minText:SetText('0')
    end
    if bar.maxText then
      bar.maxText:SetText(string.format('%d', pctMax))
    end
  else
    local base = cfg.base or STAT_BAR_CONFIG.default.base
    local multiplier = cfg.multiplier or STAT_BAR_CONFIG.default.multiplier
    if multiplier <= 1 then
      multiplier = STAT_BAR_CONFIG.default.multiplier
    end

    local tier, tierMin, tierMax, progress = CalculateTierProgress(value or 0, base, multiplier)
    if not cfg.color and #TIER_COLORS > 0 then
      local tierColorIndex = math.min(tier, #TIER_COLORS)
      effectiveFillColor = TIER_COLORS[tierColorIndex] or effectiveFillColor
    end
    local availableWidth =
      (bar.bg and (bar.bg:GetWidth() - STAT_FILL_INSET * 2)) or bar.frame:GetWidth()
    bar.fill:SetWidth(availableWidth * progress)
    bar.text:SetText(formatNumberWithCommas(value or 0))
    bar.tier:SetText('Tier ' .. tier)
    if bar.minText then
      bar.minText:SetText(formatNumberWithCommas(tierMin))
    end
    if bar.maxText then
      bar.maxText:SetText(formatNumberWithCommas(tierMax))
    end
  end

  -- Style end value to exactly match the centered value and sit above fills
  if bar.maxText then
    bar.maxText:Show()
    bar.maxText:ClearAllPoints()
    bar.maxText:SetPoint('RIGHT', bar.frame, 'RIGHT', -6, 0)
    bar.maxText:SetJustifyH('RIGHT')
    local font, fontSize, fontFlags = bar.text:GetFont()
    if font then
      bar.maxText:SetFont(font, fontSize, fontFlags)
    end
    local fontObj = bar.text:GetFontObject()
    if fontObj then
      bar.maxText:SetFontObject(fontObj)
    end
    local r, g, b, a = bar.text:GetTextColor()
    bar.maxText:SetTextColor(r or 1, g or 1, b or 1, a or 1)
    local sr, sg, sb, sa = bar.text:GetShadowColor()
    if sr and sg and sb and sa then
      bar.maxText:SetShadowColor(sr, sg, sb, sa)
    end
    local sx, sy = bar.text:GetShadowOffset()
    if sx and sy then
      bar.maxText:SetShadowOffset(sx, sy)
    end
    -- Force max text to the topmost layer
    bar.maxText:SetDrawLayer('OVERLAY', 50)
  end

  -- Layout: tier on the left, value on the right
  if bar.tier then
    if cfg.type == 'percent' then
      bar.tier:Hide()
      if bar.tierBg then
        bar.tierBg:Hide()
      end
    else
      bar.tier:Show()
      bar.tier:ClearAllPoints()
      bar.tier:SetPoint('LEFT', bar.frame, 'LEFT', TIER_LEFT_PADDING, 0)
      if bar.tierBg then
        bar.tierBg:ClearAllPoints()
        bar.tierBg:SetPoint('TOPLEFT', bar.tier, 'TOPLEFT', -8, 2)
        bar.tierBg:SetPoint('BOTTOMRIGHT', bar.tier, 'BOTTOMRIGHT', 8, -2)
        bar.tierBg:Show()
      end
    end
  end
  bar.text:ClearAllPoints()
  bar.text:SetPoint('CENTER', bar.frame, 'CENTER', 0, 0)

  if effectiveFillColor then
    bar.fill:SetColorTexture(unpack(effectiveFillColor))
  end
  if bgColor then
    bar.bg:SetColorTexture(unpack(bgColor))
  end
  if effectiveFillColor then
    bar.fill:SetColorTexture(unpack(effectiveFillColor))
  end
  if bgColor then
    bar.bg:SetColorTexture(unpack(bgColor))
  end
end

-- Initialize Statistics Tab when called
function InitializeStatisticsTab()
  -- Check if tabContents[1] exists
  if not tabContents or not tabContents[1] then return end

  -- Check if already initialized to prevent duplicates
  if tabContents[1].initialized then return end

  -- Mark as initialized
  tabContents[1].initialized = true

  local statsFrame = CreateFrame('Frame', nil, tabContents[1], 'BackdropTemplate')
  statsFrame:SetSize(600, 540) -- Increased width and height to match new layout
  statsFrame:SetPoint('TOP', tabContents[1], 'TOP', 0, -55) -- Moved up 10px
  statsFrame:SetBackdrop({
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
  statsFrame:SetBackdropColor(0.1, 0.1, 0.1, 0.95) -- Darker, more solid background
  statsFrame:SetBackdropBorderColor(0.4, 0.4, 0.4, 0.8) -- Softer border
  -- Create scroll frame for statistics content
  local statsScrollFrame = CreateFrame('ScrollFrame', nil, statsFrame, 'UIPanelScrollFrameTemplate')
  statsScrollFrame:SetPoint('TOPLEFT', statsFrame, 'TOPLEFT', 10, -10)
  statsScrollFrame:SetPoint('BOTTOMRIGHT', statsFrame, 'BOTTOMRIGHT', -30, 10) -- Leave room for scrollbar on right
  -- Create scroll child frame
  local statsScrollChild = CreateFrame('Frame', nil, statsScrollFrame)
  statsScrollChild:SetSize(560, 300) -- Width matches section header width
  statsScrollFrame:SetScrollChild(statsScrollChild)
  local resourceEventFrame

  -- Track all sections for dynamic positioning
  local sections = {}
  local function addSection(header, content, name)
    local section = {
      header = header,
      content = content,
      name = name,
      collapsed = GLOBAL_SETTINGS.collapsedStatsSections and GLOBAL_SETTINGS.collapsedStatsSections[name] or false,
    }
    table.insert(sections, section)
    return section
  end

  -- Function to update section positions based on collapsed state
  local function updateSectionPositions()
    for i, section in ipairs(sections) do
      -- Position header
      section.header:ClearAllPoints()
      if i == 1 then
        section.header:SetPoint('TOPLEFT', statsScrollChild, 'TOPLEFT', 0, -5)
      else
        -- Anchor to the previous section's header if collapsed, otherwise to its content
        local previousSection = sections[i - 1]
        local anchorFrame =
          previousSection.collapsed and previousSection.header or previousSection.content
        section.header:SetPoint(
          'TOPLEFT',
          anchorFrame,
          'BOTTOMLEFT',
          previousSection.collapsed and 0 or -LAYOUT.CONTENT_INDENT,
          -LAYOUT.SECTION_SPACING
        )
      end

      -- Show/hide content based on collapsed state
      if section.collapsed then
        section.content:Hide()
      else
        section.content:Show()
        section.content:ClearAllPoints()
        section.content:SetPoint(
          'TOPLEFT',
          section.header,
          'BOTTOMLEFT',
          LAYOUT.CONTENT_INDENT,
          -LAYOUT.CONTENT_PADDING
        )
      end
    end
  end

  -- Helper function to create a collapsible header
  local function makeHeaderClickable(header, content, sectionName, section)
    -- Add collapse icon
    local collapseIcon = header:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
    collapseIcon:SetPoint('LEFT', header, 'LEFT', 10, 0)
    collapseIcon:SetTextColor(0.9, 0.85, 0.75, 1)
    collapseIcon:SetShadowOffset(1, -1)
    collapseIcon:SetShadowColor(0, 0, 0, 0.8)

    -- Function to update icon
    local function updateIcon(collapsed)
      collapseIcon:SetText(collapsed and '+' or '-')
    end

    -- Enable mouse interaction
    header:EnableMouse(true)
    header:SetScript('OnMouseDown', function(self, button)
      if button == 'LeftButton' and section then
        section.collapsed = not section.collapsed
        -- Save state
        if not GLOBAL_SETTINGS.collapsedStatsSections then
          GLOBAL_SETTINGS.collapsedStatsSections = {}
        end
        GLOBAL_SETTINGS.collapsedStatsSections[sectionName] = section.collapsed
        -- Update icon
        updateIcon(section.collapsed)
        -- Update all positions
        updateSectionPositions()
      end
    end)

    -- Add hover effect
    header:SetScript('OnEnter', function(self)
      self:SetBackdropColor(0.2, 0.2, 0.28, 0.95)
      self:SetBackdropBorderColor(0.6, 0.6, 0.75, 1)
    end)
    header:SetScript('OnLeave', function(self)
      self:SetBackdropColor(0.15, 0.15, 0.2, 0.85)
      self:SetBackdropBorderColor(0.5, 0.5, 0.6, 0.9)
    end)

    -- Set initial icon state
    if section then
      updateIcon(section.collapsed)
    end
  end

  -- Create modern WoW-style Character Info section (collapsible)
  local characterInfoHeader = CreateFrame('Frame', nil, statsScrollChild, 'BackdropTemplate')
  characterInfoHeader:SetSize(560, LAYOUT.SECTION_HEADER_HEIGHT)

  -- Modern WoW row styling with rounded corners and greyish background
  characterInfoHeader:SetBackdrop({
    bgFile = 'Interface\\Buttons\\WHITE8X8',
    edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border',
    tile = true,
    tileSize = 8,
    edgeSize = 12,
    insets = {
      left = 3,
      right = 3,
      top = 3,
      bottom = 3,
    },
  })
  characterInfoHeader:SetBackdropColor(0.15, 0.15, 0.2, 0.85) -- Darker blue-tinted background
  characterInfoHeader:SetBackdropBorderColor(0.5, 0.5, 0.6, 0.9) -- Softer blue-tinted border
  -- Create header text (offset to make room for collapse icon)
  local characterInfoLabel =
    characterInfoHeader:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
  characterInfoLabel:SetPoint('LEFT', characterInfoHeader, 'LEFT', 24, 0)
  characterInfoLabel:SetText('Character Info')
  characterInfoLabel:SetTextColor(0.9, 0.85, 0.75, 1) -- Warmer, more readable color
  characterInfoLabel:SetShadowOffset(1, -1)
  characterInfoLabel:SetShadowColor(0, 0, 0, 0.8)

  -- Create content frame for Character Info breakdown
  local characterInfoContent = CreateFrame('Frame', nil, statsScrollChild, 'BackdropTemplate')
  characterInfoContent:SetSize(540, LAYOUT.ROW_HEIGHT * 2 + LAYOUT.CONTENT_PADDING * 2 - 12) -- Level only
  -- Position will be set by updateSectionPositions
  characterInfoContent:Show() -- Show by default
  -- Register section and make header clickable
  local characterInfoSection =
    addSection(characterInfoHeader, characterInfoContent, 'characterInfo')
  makeHeaderClickable(
    characterInfoHeader,
    characterInfoContent,
    'characterInfo',
    characterInfoSection
  )
  -- Modern content frame styling
  characterInfoContent:SetBackdrop({
    bgFile = 'Interface\\Buttons\\WHITE8X8',
    edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border',
    tile = true,
    tileSize = 8,
    edgeSize = 10,
    insets = {
      left = 3,
      right = 3,
      top = 3,
      bottom = 3,
    },
  })
  characterInfoContent:SetBackdropColor(0.08, 0.08, 0.1, 0.6) -- Very subtle dark background
  characterInfoContent:SetBackdropBorderColor(0.3, 0.3, 0.35, 0.5) -- Subtle border
  -- Create the level text display
  local levelLabel = characterInfoContent:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  levelLabel:SetPoint(
    'TOPLEFT',
    characterInfoContent,
    'TOPLEFT',
    LAYOUT.ROW_INDENT + 12,
    -LAYOUT.CONTENT_PADDING + ROW_Y_ADJUST
  )
  levelLabel:SetText('Level:')
  AddStatisticTooltip(levelLabel, 'level')

  local levelBar = CreateBarRow(characterInfoContent, 'level', -LAYOUT.CONTENT_PADDING, false)
  UpdateStatBar('level', UnitLevel('player'))

  -- Create checkbox for showing level in main screen statistics
  local showStatsLevelRadio =
    CreateFrame('CheckButton', nil, characterInfoContent, 'UICheckButtonTemplate')
  showStatsLevelRadio:SetPoint('RIGHT', levelLabel, 'LEFT', -4, 0)
  showStatsLevelRadio:SetScale(0.5)
  showStatsLevelRadio:SetChecked(false) -- Initialize as unchecked, will be updated by updateRadioButtons()
  radioButtons.showMainStatisticsPanelLevel = showStatsLevelRadio
  showStatsLevelRadio:SetScript('OnClick', function(self)
    tempSettings.showMainStatisticsPanelLevel = self:GetChecked()
    GLOBAL_SETTINGS.showMainStatisticsPanelLevel = self:GetChecked()
    -- Trigger immediate update of main screen statistics
    if UltraHardcoreStatsFrame and UltraHardcoreStatsFrame.UpdateRowVisibility then
      UltraHardcoreStatsFrame.UpdateRowVisibility()
    end
  end)

  -- Create Health Tracking section
  local healthTrackingHeader = CreateFrame('Frame', nil, statsScrollChild, 'BackdropTemplate')
  healthTrackingHeader:SetSize(560, LAYOUT.SECTION_HEADER_HEIGHT)

  healthTrackingHeader:SetBackdrop({
    bgFile = 'Interface\\Buttons\\WHITE8X8',
    edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border',
    tile = true,
    tileSize = 8,
    edgeSize = 12,
    insets = {
      left = 3,
      right = 3,
      top = 3,
      bottom = 3,
    },
  })
  healthTrackingHeader:SetBackdropColor(0.15, 0.15, 0.2, 0.85)
  healthTrackingHeader:SetBackdropBorderColor(0.5, 0.5, 0.6, 0.9)
  local healthTrackingLabel =
    healthTrackingHeader:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
  healthTrackingLabel:SetPoint('LEFT', healthTrackingHeader, 'LEFT', 24, 0)
  healthTrackingLabel:SetText('Health Tracking')
  healthTrackingLabel:SetTextColor(0.9, 0.85, 0.75, 1)
  healthTrackingLabel:SetShadowOffset(1, -1)
  healthTrackingLabel:SetShadowColor(0, 0, 0, 0.8)

  local healthTrackingContent = CreateFrame('Frame', nil, statsScrollChild, 'BackdropTemplate')
  healthTrackingContent:SetSize(540, 5 * LAYOUT.ROW_HEIGHT * 2 + LAYOUT.CONTENT_PADDING * 2 - 12) -- 5 stats, two rows each
  healthTrackingContent:Show()
  local healthTrackingSection =
    addSection(healthTrackingHeader, healthTrackingContent, 'healthTracking')
  makeHeaderClickable(
    healthTrackingHeader,
    healthTrackingContent,
    'healthTracking',
    healthTrackingSection
  )
  healthTrackingContent:SetBackdrop({
    bgFile = 'Interface\\Buttons\\WHITE8X8',
    edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border',
    tile = true,
    tileSize = 8,
    edgeSize = 10,
    insets = {
      left = 3,
      right = 3,
      top = 3,
      bottom = 3,
    },
  })
  healthTrackingContent:SetBackdropColor(0.08, 0.08, 0.1, 0.6)
  healthTrackingContent:SetBackdropBorderColor(0.3, 0.3, 0.35, 0.5)

  -- Create the total text display (indented)
  local lowestHealthTotalLabel =
    healthTrackingContent:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  lowestHealthTotalLabel:SetPoint(
    'TOPLEFT',
    healthTrackingContent,
    'TOPLEFT',
    LAYOUT.ROW_INDENT + 12,
    -LAYOUT.CONTENT_PADDING + ROW_Y_ADJUST
  )
  lowestHealthTotalLabel:SetText('Lowest Health (Total):')
  AddStatisticTooltip(lowestHealthTotalLabel, 'total')

  statBars.lowestHealth =
    CreateBarRow(healthTrackingContent, 'lowestHealth', -LAYOUT.CONTENT_PADDING, false)
  UpdateStatBar('lowestHealth', CharacterStats:GetStat('lowestHealth') or 100)

  -- Create checkbox for showing lowest health in main screen statistics
  local showStatsLowestHealthRadio =
    CreateFrame('CheckButton', nil, healthTrackingContent, 'UICheckButtonTemplate')
  showStatsLowestHealthRadio:SetPoint('RIGHT', lowestHealthTotalLabel, 'LEFT', -4, 0)
  showStatsLowestHealthRadio:SetScale(0.5)
  showStatsLowestHealthRadio:SetChecked(false) -- Initialize as unchecked, will be updated by updateRadioButtons()
  radioButtons.showMainStatisticsPanelLowestHealth = showStatsLowestHealthRadio
  showStatsLowestHealthRadio:SetScript('OnClick', function(self)
    tempSettings.showMainStatisticsPanelLowestHealth = self:GetChecked()
    GLOBAL_SETTINGS.showMainStatisticsPanelLowestHealth = self:GetChecked()
    -- Trigger immediate update of main screen statistics
    if UltraHardcoreStatsFrame and UltraHardcoreStatsFrame.UpdateRowVisibility then
      UltraHardcoreStatsFrame.UpdateRowVisibility()
    end
  end)

  -- Create the This Level text display
  local lowestHealthThisLevelLabel =
    healthTrackingContent:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  lowestHealthThisLevelLabel:SetPoint(
    'TOPLEFT',
    healthTrackingContent,
    'TOPLEFT',
    LAYOUT.ROW_INDENT + 12,
    -LAYOUT.CONTENT_PADDING - LAYOUT.ROW_HEIGHT * 2 + ROW_Y_ADJUST
  )
  lowestHealthThisLevelLabel:SetText('Lowest Health (This Level):')
  AddStatisticTooltip(lowestHealthThisLevelLabel, 'thisLevel')

  statBars.lowestHealthThisLevel =
    CreateBarRow(
      healthTrackingContent,
      'lowestHealthThisLevel',
      -LAYOUT.CONTENT_PADDING - LAYOUT.ROW_HEIGHT * 2,
      false
    )
  UpdateStatBar('lowestHealthThisLevel', CharacterStats:GetStat('lowestHealthThisLevel') or 100)

  -- Create checkbox for showing this level health in main screen statistics
  local showStatsThisLevelRadio =
    CreateFrame('CheckButton', nil, healthTrackingContent, 'UICheckButtonTemplate')
  showStatsThisLevelRadio:SetPoint('RIGHT', lowestHealthThisLevelLabel, 'LEFT', -4, 0)
  showStatsThisLevelRadio:SetScale(0.5)
  showStatsThisLevelRadio:SetChecked(false) -- Initialize as unchecked, will be updated by updateRadioButtons()
  radioButtons.showMainStatisticsPanelThisLevel = showStatsThisLevelRadio
  showStatsThisLevelRadio:SetScript('OnClick', function(self)
    tempSettings.showMainStatisticsPanelThisLevel = self:GetChecked()
    GLOBAL_SETTINGS.showMainStatisticsPanelThisLevel = self:GetChecked()
    -- Trigger immediate update of main screen statistics
    if UltraHardcoreStatsFrame and UltraHardcoreStatsFrame.UpdateRowVisibility then
      UltraHardcoreStatsFrame.UpdateRowVisibility()
    end
  end)

  -- Create the This Session text display
  local lowestHealthThisSessionLabel =
    healthTrackingContent:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  lowestHealthThisSessionLabel:SetPoint(
    'TOPLEFT',
    healthTrackingContent,
    'TOPLEFT',
    LAYOUT.ROW_INDENT + 12,
    -LAYOUT.CONTENT_PADDING - LAYOUT.ROW_HEIGHT * 4 + ROW_Y_ADJUST
  )
  lowestHealthThisSessionLabel:SetText('Lowest Health (This Session):')
  AddStatisticTooltip(lowestHealthThisSessionLabel, 'thisSession')

  statBars.lowestHealthThisSession =
    CreateBarRow(
      healthTrackingContent,
      'lowestHealthThisSession',
      -LAYOUT.CONTENT_PADDING - LAYOUT.ROW_HEIGHT * 4,
      false
    )
  UpdateStatBar('lowestHealthThisSession', CharacterStats:GetStat('lowestHealthThisSession') or 100)

  -- Create checkbox for showing session health in main screen statistics
  local showStatsSessionHealthRadio =
    CreateFrame('CheckButton', nil, healthTrackingContent, 'UICheckButtonTemplate')
  showStatsSessionHealthRadio:SetPoint('RIGHT', lowestHealthThisSessionLabel, 'LEFT', -4, 0)
  showStatsSessionHealthRadio:SetScale(0.5)
  showStatsSessionHealthRadio:SetChecked(false) -- Initialize as unchecked, will be updated by updateRadioButtons()
  radioButtons.showMainStatisticsPanelSessionHealth = showStatsSessionHealthRadio
  showStatsSessionHealthRadio:SetScript('OnClick', function(self)
    tempSettings.showMainStatisticsPanelSessionHealth = self:GetChecked()
    GLOBAL_SETTINGS.showMainStatisticsPanelSessionHealth = self:GetChecked()
    -- Trigger immediate update of main screen statistics
    if UltraHardcoreStatsFrame and UltraHardcoreStatsFrame.UpdateRowVisibility then
      UltraHardcoreStatsFrame.UpdateRowVisibility()
    end
  end)

  -- Create Close Escapes display
  local closeEscapesLabel =
    healthTrackingContent:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  closeEscapesLabel:SetPoint(
    'TOPLEFT',
    healthTrackingContent,
    'TOPLEFT',
    LAYOUT.ROW_INDENT + 12,
    -LAYOUT.CONTENT_PADDING - LAYOUT.ROW_HEIGHT * 6 + ROW_Y_ADJUST
  )
  closeEscapesLabel:SetText('Close Escapes:')
  AddStatisticTooltip(closeEscapesLabel, 'closeEscapes')

  statBars.closeEscapes =
    CreateBarRow(
      healthTrackingContent,
      'closeEscapes',
      -LAYOUT.CONTENT_PADDING - LAYOUT.ROW_HEIGHT * 6,
      false
    )
  UpdateStatBar('closeEscapes', CharacterStats:GetStat('closeEscapes') or 0)

  local showStatsCloseEscapesRadio =
    CreateFrame('CheckButton', nil, healthTrackingContent, 'UICheckButtonTemplate')
  showStatsCloseEscapesRadio:SetPoint('RIGHT', closeEscapesLabel, 'LEFT', -4, 0)
  showStatsCloseEscapesRadio:SetScale(0.5)
  showStatsCloseEscapesRadio:SetChecked(false)
  radioButtons.showMainStatisticsPanelCloseEscapes = showStatsCloseEscapesRadio
  showStatsCloseEscapesRadio:SetScript('OnClick', function(self)
    tempSettings.showMainStatisticsPanelCloseEscapes = self:GetChecked()
    GLOBAL_SETTINGS.showMainStatisticsPanelCloseEscapes = self:GetChecked()
    if UltraHardcoreStatsFrame and UltraHardcoreStatsFrame.UpdateRowVisibility then
      UltraHardcoreStatsFrame.UpdateRowVisibility()
    end
  end)

  -- Create the pet deaths text display
  local petDeathsLabel = healthTrackingContent:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  petDeathsLabel:SetPoint(
    'TOPLEFT',
    healthTrackingContent,
    'TOPLEFT',
    LAYOUT.ROW_INDENT + 12,
    -LAYOUT.CONTENT_PADDING - LAYOUT.ROW_HEIGHT * 8 + ROW_Y_ADJUST
  )
  petDeathsLabel:SetText('Pet Deaths:')
  AddStatisticTooltip(petDeathsLabel, 'petDeaths')

  petDeathsText =
    CreateBarRow(
      healthTrackingContent,
      'petDeaths',
      -LAYOUT.CONTENT_PADDING - LAYOUT.ROW_HEIGHT * 8,
      true
    )
  statBars.petDeaths = petDeathsText
  UpdateStatBar('petDeaths', CharacterStats:GetStat('petDeaths'))

  -- Create checkbox for showing pet deaths in main screen statistics
  local showStatsPetDeathsRadio =
    CreateFrame('CheckButton', nil, healthTrackingContent, 'UICheckButtonTemplate')
  showStatsPetDeathsRadio:SetPoint('RIGHT', petDeathsLabel, 'LEFT', -4, 0)
  showStatsPetDeathsRadio:SetScale(0.5)
  showStatsPetDeathsRadio:SetChecked(false) -- Initialize as unchecked, will be updated by updateRadioButtons()
  radioButtons.showMainStatisticsPanelPetDeaths = showStatsPetDeathsRadio
  showStatsPetDeathsRadio:SetScript('OnClick', function(self)
    tempSettings.showMainStatisticsPanelPetDeaths = self:GetChecked()
    GLOBAL_SETTINGS.showMainStatisticsPanelPetDeaths = self:GetChecked()
    -- Trigger immediate update of main screen statistics
    if UltraHardcoreStatsFrame and UltraHardcoreStatsFrame.UpdateRowVisibility then
      UltraHardcoreStatsFrame.UpdateRowVisibility()
    end
  end)

  -- Create modern WoW-style Combat section (collapsible)
  local combatHeader = CreateFrame('Frame', nil, statsScrollChild, 'BackdropTemplate')
  combatHeader:SetSize(560, LAYOUT.SECTION_HEADER_HEIGHT)
  -- Position will be set by updateSectionPositions

  -- Modern WoW row styling with rounded corners and greyish background
  combatHeader:SetBackdrop({
    bgFile = 'Interface\\Buttons\\WHITE8X8',
    edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border',
    tile = true,
    tileSize = 8,
    edgeSize = 12,
    insets = {
      left = 3,
      right = 3,
      top = 3,
      bottom = 3,
    },
  })
  combatHeader:SetBackdropColor(0.15, 0.15, 0.2, 0.85)
  combatHeader:SetBackdropBorderColor(0.5, 0.5, 0.6, 0.9)
  -- Create header text
  local combatLabel = combatHeader:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
  combatLabel:SetPoint('LEFT', combatHeader, 'LEFT', 24, 0)
  combatLabel:SetText('Combat')
  combatLabel:SetTextColor(0.9, 0.85, 0.75, 1)
  combatLabel:SetShadowOffset(1, -1)
  combatLabel:SetShadowColor(0, 0, 0, 0.8)

  -- Create content frame for Combat breakdown
  local combatContent = CreateFrame('Frame', nil, statsScrollChild, 'BackdropTemplate')
  combatContent:SetSize(540, 8 * LAYOUT.ROW_HEIGHT * 2 + LAYOUT.CONTENT_PADDING * 2 - 12) -- 8 stats, two rows each
  -- Position will be set by updateSectionPositions
  combatContent:Show() -- Show by default
  -- Register section and make header clickable
  local combatSection = addSection(combatHeader, combatContent, 'combat')
  makeHeaderClickable(combatHeader, combatContent, 'combat', combatSection)
  combatLabel:SetTextColor(0.9, 0.85, 0.75, 1)
  combatLabel:SetShadowOffset(1, -1)
  combatLabel:SetShadowColor(0, 0, 0, 0.8)
  -- Modern content frame styling
  combatContent:SetBackdrop({
    bgFile = 'Interface\\Buttons\\WHITE8X8',
    edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border',
    tile = true,
    tileSize = 8,
    edgeSize = 10,
    insets = {
      left = 3,
      right = 3,
      top = 3,
      bottom = 3,
    },
  })
  combatContent:SetBackdropColor(0.08, 0.08, 0.1, 0.6)
  combatContent:SetBackdropBorderColor(0.3, 0.3, 0.35, 0.5)

  -- Create the total text display (indented)
  local enemiesSlainTotalLabel = combatContent:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  enemiesSlainTotalLabel:SetPoint(
    'TOPLEFT',
    combatContent,
    'TOPLEFT',
    LAYOUT.ROW_INDENT + 12,
    -LAYOUT.CONTENT_PADDING + ROW_Y_ADJUST
  )
  enemiesSlainTotalLabel:SetText('Total:')
  AddStatisticTooltip(enemiesSlainTotalLabel, 'enemiesSlainTotal')

  local enemiesSlainText =
    CreateBarRow(combatContent, 'enemiesSlain', -LAYOUT.CONTENT_PADDING, false)
  UpdateStatBar('enemiesSlain', CharacterStats:GetStat('enemiesSlain'))

  -- Create checkbox for showing enemies slain in main screen statistics
  local showStatsEnemiesSlainRadio =
    CreateFrame('CheckButton', nil, combatContent, 'UICheckButtonTemplate')
  showStatsEnemiesSlainRadio:SetPoint('RIGHT', enemiesSlainTotalLabel, 'LEFT', -4, 0)
  showStatsEnemiesSlainRadio:SetScale(0.5)
  showStatsEnemiesSlainRadio:SetChecked(false) -- Initialize as unchecked, will be updated by updateRadioButtons()
  radioButtons.showMainStatisticsPanelEnemiesSlain = showStatsEnemiesSlainRadio
  showStatsEnemiesSlainRadio:SetScript('OnClick', function(self)
    tempSettings.showMainStatisticsPanelEnemiesSlain = self:GetChecked()
    GLOBAL_SETTINGS.showMainStatisticsPanelEnemiesSlain = self:GetChecked()
    -- Trigger immediate update of main screen statistics
    if UltraHardcoreStatsFrame and UltraHardcoreStatsFrame.UpdateRowVisibility then
      UltraHardcoreStatsFrame.UpdateRowVisibility()
    end
  end)

  -- Create the elites slain text display (indented)
  local elitesSlainLabel = combatContent:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  elitesSlainLabel:SetPoint(
    'TOPLEFT',
    combatContent,
    'TOPLEFT',
    LAYOUT.ROW_INDENT + 12,
    -LAYOUT.CONTENT_PADDING - LAYOUT.ROW_HEIGHT * 2 + ROW_Y_ADJUST
  )
  elitesSlainLabel:SetText('Elites Slain:')
  AddStatisticTooltip(elitesSlainLabel, 'elitesSlain')

  local elitesSlainText =
    CreateBarRow(
      combatContent,
      'elitesSlain',
      -LAYOUT.CONTENT_PADDING - LAYOUT.ROW_HEIGHT * 2,
      false
    )
  UpdateStatBar('elitesSlain', CharacterStats:GetStat('elitesSlain'))

  -- Create checkbox for showing elites slain in main screen statistics
  local showStatsElitesSlainRadio =
    CreateFrame('CheckButton', nil, combatContent, 'UICheckButtonTemplate')
  showStatsElitesSlainRadio:SetPoint('RIGHT', elitesSlainLabel, 'LEFT', -4, 0)
  showStatsElitesSlainRadio:SetScale(0.5)
  showStatsElitesSlainRadio:SetChecked(false) -- Initialize as unchecked, will be updated by updateRadioButtons()
  radioButtons.showMainStatisticsPanelElitesSlain = showStatsElitesSlainRadio
  showStatsElitesSlainRadio:SetScript('OnClick', function(self)
    tempSettings.showMainStatisticsPanelElitesSlain = self:GetChecked()
    GLOBAL_SETTINGS.showMainStatisticsPanelElitesSlain = self:GetChecked()
    -- Trigger immediate update of main screen statistics
    if UltraHardcoreStatsFrame and UltraHardcoreStatsFrame.UpdateRowVisibility then
      UltraHardcoreStatsFrame.UpdateRowVisibility()
    end
  end)

  -- Create the rare elites slain text display (indented)
  local rareElitesSlainLabel = combatContent:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  rareElitesSlainLabel:SetPoint(
    'TOPLEFT',
    combatContent,
    'TOPLEFT',
    LAYOUT.ROW_INDENT + 12,
    -LAYOUT.CONTENT_PADDING - LAYOUT.ROW_HEIGHT * 4 + ROW_Y_ADJUST
  )
  rareElitesSlainLabel:SetText('Rare Elites Slain:')
  AddStatisticTooltip(rareElitesSlainLabel, 'rareElitesSlain')

  local rareElitesSlainText =
    CreateBarRow(
      combatContent,
      'rareElitesSlain',
      -LAYOUT.CONTENT_PADDING - LAYOUT.ROW_HEIGHT * 4,
      false
    )
  UpdateStatBar('rareElitesSlain', CharacterStats:GetStat('rareElitesSlain'))

  -- Create checkbox for showing rare elites slain in main screen statistics
  local showStatsRareElitesSlainRadio =
    CreateFrame('CheckButton', nil, combatContent, 'UICheckButtonTemplate')
  showStatsRareElitesSlainRadio:SetPoint('RIGHT', rareElitesSlainLabel, 'LEFT', -4, 0)
  showStatsRareElitesSlainRadio:SetScale(0.5)
  showStatsRareElitesSlainRadio:SetChecked(false) -- Initialize as unchecked, will be updated by updateRadioButtons()
  radioButtons.showMainStatisticsPanelRareElitesSlain = showStatsRareElitesSlainRadio
  showStatsRareElitesSlainRadio:SetScript('OnClick', function(self)
    tempSettings.showMainStatisticsPanelRareElitesSlain = self:GetChecked()
    GLOBAL_SETTINGS.showMainStatisticsPanelRareElitesSlain = self:GetChecked()
    -- Trigger immediate update of main screen statistics
    if UltraHardcoreStatsFrame and UltraHardcoreStatsFrame.UpdateRowVisibility then
      UltraHardcoreStatsFrame.UpdateRowVisibility()
    end
  end)

  -- Create the world bosses slain text display (indented)
  local worldBossesSlainLabel = combatContent:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  worldBossesSlainLabel:SetPoint(
    'TOPLEFT',
    combatContent,
    'TOPLEFT',
    LAYOUT.ROW_INDENT + 12,
    -LAYOUT.CONTENT_PADDING - LAYOUT.ROW_HEIGHT * 6 + ROW_Y_ADJUST
  )
  worldBossesSlainLabel:SetText('World Bosses Slain:')
  AddStatisticTooltip(worldBossesSlainLabel, 'worldBossesSlain')

  local worldBossesSlainText =
    CreateBarRow(
      combatContent,
      'worldBossesSlain',
      -LAYOUT.CONTENT_PADDING - LAYOUT.ROW_HEIGHT * 6,
      false
    )
  UpdateStatBar('worldBossesSlain', CharacterStats:GetStat('worldBossesSlain'))

  -- Create checkbox for showing world bosses slain in main screen statistics
  local showStatsWorldBossesSlainRadio =
    CreateFrame('CheckButton', nil, combatContent, 'UICheckButtonTemplate')
  showStatsWorldBossesSlainRadio:SetPoint('RIGHT', worldBossesSlainLabel, 'LEFT', -4, 0)
  showStatsWorldBossesSlainRadio:SetScale(0.5)
  showStatsWorldBossesSlainRadio:SetChecked(false) -- Initialize as unchecked, will be updated by updateRadioButtons()
  radioButtons.showMainStatisticsPanelWorldBossesSlain = showStatsWorldBossesSlainRadio
  showStatsWorldBossesSlainRadio:SetScript('OnClick', function(self)
    tempSettings.showMainStatisticsPanelWorldBossesSlain = self:GetChecked()
    GLOBAL_SETTINGS.showMainStatisticsPanelWorldBossesSlain = self:GetChecked()
    -- Trigger immediate update of main screen statistics
    if UltraHardcoreStatsFrame and UltraHardcoreStatsFrame.UpdateRowVisibility then
      UltraHardcoreStatsFrame.UpdateRowVisibility()
    end
  end)

  -- Create the dungeon bosses slain text display (indented)
  local dungeonBossesLabel = combatContent:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  dungeonBossesLabel:SetPoint(
    'TOPLEFT',
    combatContent,
    'TOPLEFT',
    LAYOUT.ROW_INDENT + 12,
    -LAYOUT.CONTENT_PADDING - LAYOUT.ROW_HEIGHT * 8 + ROW_Y_ADJUST
  )
  dungeonBossesLabel:SetText('Dungeon Bosses Slain:')
  AddStatisticTooltip(dungeonBossesLabel, 'dungeonBossesSlain')

  local dungeonBossesText =
    CreateBarRow(
      combatContent,
      'dungeonBossesKilled',
      -LAYOUT.CONTENT_PADDING - LAYOUT.ROW_HEIGHT * 8,
      false
    )
  statBars.dungeonBossesKilled = dungeonBossesText
  UpdateStatBar('dungeonBossesKilled', CharacterStats:GetStat('dungeonBossesKilled'))

  -- Create checkbox for showing dungeon bosses slain in main screen statistics
  local showStatsDungeonBossesRadio =
    CreateFrame('CheckButton', nil, combatContent, 'UICheckButtonTemplate')
  showStatsDungeonBossesRadio:SetPoint('RIGHT', dungeonBossesLabel, 'LEFT', -4, 0)
  showStatsDungeonBossesRadio:SetScale(0.5)
  showStatsDungeonBossesRadio:SetChecked(false) -- Initialize as unchecked, will be updated by updateRadioButtons()
  radioButtons.showMainStatisticsPanelDungeonBosses = showStatsDungeonBossesRadio
  showStatsDungeonBossesRadio:SetScript('OnClick', function(self)
    tempSettings.showMainStatisticsPanelDungeonBosses = self:GetChecked()
    GLOBAL_SETTINGS.showMainStatisticsPanelDungeonBosses = self:GetChecked()
    -- Trigger immediate update of main screen statistics
    if UltraHardcoreStatsFrame and UltraHardcoreStatsFrame.UpdateRowVisibility then
      UltraHardcoreStatsFrame.UpdateRowVisibility()
    end
  end)

  -- Create the dungeons completed text display (indented)
  local dungeonsCompletedLabel = combatContent:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  dungeonsCompletedLabel:SetPoint(
    'TOPLEFT',
    combatContent,
    'TOPLEFT',
    LAYOUT.ROW_INDENT + 12,
    -LAYOUT.CONTENT_PADDING - LAYOUT.ROW_HEIGHT * 10 + ROW_Y_ADJUST
  )
  dungeonsCompletedLabel:SetText('Dungeons Completed:')
  AddStatisticTooltip(dungeonsCompletedLabel, 'dungeonsCompleted')

  local dungeonsCompletedText =
    CreateBarRow(
      combatContent,
      'dungeonsCompleted',
      -LAYOUT.CONTENT_PADDING - LAYOUT.ROW_HEIGHT * 10,
      false
    )
  statBars.dungeonsCompleted = dungeonsCompletedText
  UpdateStatBar('dungeonsCompleted', CharacterStats:GetStat('dungeonsCompleted'))

  -- Create checkbox for showing dungeons completed in main screen statistics
  local showStatsDungeonsCompletedRadio =
    CreateFrame('CheckButton', nil, combatContent, 'UICheckButtonTemplate')
  showStatsDungeonsCompletedRadio:SetPoint('RIGHT', dungeonsCompletedLabel, 'LEFT', -4, 0)
  showStatsDungeonsCompletedRadio:SetScale(0.5)
  showStatsDungeonsCompletedRadio:SetChecked(false) -- Initialize as unchecked, will be updated by updateRadioButtons()
  radioButtons.showMainStatisticsPanelDungeonsCompleted = showStatsDungeonsCompletedRadio
  showStatsDungeonsCompletedRadio:SetScript('OnClick', function(self)
    tempSettings.showMainStatisticsPanelDungeonsCompleted = self:GetChecked()
    GLOBAL_SETTINGS.showMainStatisticsPanelDungeonsCompleted = self:GetChecked()
    -- Trigger immediate update of main screen statistics
    if UltraHardcoreStatsFrame and UltraHardcoreStatsFrame.UpdateRowVisibility then
      UltraHardcoreStatsFrame.UpdateRowVisibility()
    end
  end)

  -- Create the highest crit value text display (indented)
  local highestCritLabel = combatContent:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  highestCritLabel:SetPoint(
    'TOPLEFT',
    combatContent,
    'TOPLEFT',
    LAYOUT.ROW_INDENT + 12,
    -LAYOUT.CONTENT_PADDING - LAYOUT.ROW_HEIGHT * 12 + ROW_Y_ADJUST
  )
  highestCritLabel:SetText('Highest Crit Value:')
  AddStatisticTooltip(highestCritLabel, 'highestCritValue')

  local highestCritText =
    CreateBarRow(
      combatContent,
      'highestCritValue',
      -LAYOUT.CONTENT_PADDING - LAYOUT.ROW_HEIGHT * 12,
      false
    )
  statBars.highestCritValue = highestCritText
  UpdateStatBar('highestCritValue', CharacterStats:GetStat('highestCritValue'))

  -- Create checkbox for showing highest crit value in main screen statistics
  local showStatsHighestCritRadio =
    CreateFrame('CheckButton', nil, combatContent, 'UICheckButtonTemplate')
  showStatsHighestCritRadio:SetPoint('RIGHT', highestCritLabel, 'LEFT', -4, 0)
  showStatsHighestCritRadio:SetScale(0.5)
  showStatsHighestCritRadio:SetChecked(false) -- Initialize as unchecked, will be updated by updateRadioButtons()
  radioButtons.showMainStatisticsPanelHighestCritValue = showStatsHighestCritRadio
  showStatsHighestCritRadio:SetScript('OnClick', function(self)
    tempSettings.showMainStatisticsPanelHighestCritValue = self:GetChecked()
    GLOBAL_SETTINGS.showMainStatisticsPanelHighestCritValue = self:GetChecked()
    -- Trigger immediate update of main screen statistics
    if UltraHardcoreStatsFrame and UltraHardcoreStatsFrame.UpdateRowVisibility then
      UltraHardcoreStatsFrame.UpdateRowVisibility()
    end
  end)

  -- Create the highest heal crit value text display (indented)
  local highestHealCritLabel = combatContent:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  highestHealCritLabel:SetPoint(
    'TOPLEFT',
    combatContent,
    'TOPLEFT',
    LAYOUT.ROW_INDENT + 12,
    -LAYOUT.CONTENT_PADDING - LAYOUT.ROW_HEIGHT * 14 + ROW_Y_ADJUST
  )
  highestHealCritLabel:SetText('Highest Heal Crit Value:')
  AddStatisticTooltip(highestHealCritLabel, 'highestHealCritValue')

  local highestHealCritText =
    CreateBarRow(
      combatContent,
      'highestHealCritValue',
      -LAYOUT.CONTENT_PADDING - LAYOUT.ROW_HEIGHT * 14,
      true
    )
  statBars.highestHealCritValue = highestHealCritText
  UpdateStatBar('highestHealCritValue', CharacterStats:GetStat('highestHealCritValue'))

  -- Create checkbox for showing highest heal crit value in main screen statistics
  local showStatsHighestHealCritRadio =
    CreateFrame('CheckButton', nil, combatContent, 'UICheckButtonTemplate')
  showStatsHighestHealCritRadio:SetPoint('RIGHT', highestHealCritLabel, 'LEFT', -4, 0)
  showStatsHighestHealCritRadio:SetScale(0.5)
  showStatsHighestHealCritRadio:SetChecked(false) -- Initialize as unchecked, will be updated by updateRadioButtons()
  radioButtons.showMainStatisticsPanelHighestHealCritValue = showStatsHighestHealCritRadio
  showStatsHighestHealCritRadio:SetScript('OnClick', function(self)
    tempSettings.showMainStatisticsPanelHighestHealCritValue = self:GetChecked()
    GLOBAL_SETTINGS.showMainStatisticsPanelHighestHealCritValue = self:GetChecked()
    -- Trigger immediate update of main screen statistics
    if UltraHardcoreStatsFrame and UltraHardcoreStatsFrame.UpdateRowVisibility then
      UltraHardcoreStatsFrame.UpdateRowVisibility()
    end
  end)

  -- Create modern WoW-style Survival section (collapsible)
  local survivalHeader = CreateFrame('Frame', nil, statsScrollChild, 'BackdropTemplate')
  survivalHeader:SetSize(560, LAYOUT.SECTION_HEADER_HEIGHT)
  -- Position will be set by updateSectionPositions
  -- Modern WoW row styling with rounded corners and greyish background
  survivalHeader:SetBackdrop({
    bgFile = 'Interface\\Buttons\\WHITE8X8',
    edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border',
    tile = true,
    tileSize = 8,
    edgeSize = 12,
    insets = {
      left = 3,
      right = 3,
      top = 3,
      bottom = 3,
    },
  })
  survivalHeader:SetBackdropColor(0.15, 0.15, 0.2, 0.85)
  survivalHeader:SetBackdropBorderColor(0.5, 0.5, 0.6, 0.9)
  -- Create header text
  local survivalLabel = survivalHeader:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
  survivalLabel:SetPoint('LEFT', survivalHeader, 'LEFT', 24, 0)
  survivalLabel:SetText('Survival')
  survivalLabel:SetTextColor(0.9, 0.85, 0.75, 1)
  survivalLabel:SetShadowOffset(1, -1)
  survivalLabel:SetShadowColor(0, 0, 0, 0.8)

  -- Create content frame for Survival breakdown
  local survivalContent = CreateFrame('Frame', nil, statsScrollChild, 'BackdropTemplate')
  survivalContent:SetSize(540, 5 * LAYOUT.ROW_HEIGHT * 2 + LAYOUT.CONTENT_PADDING * 2 - 12) -- Initial height, will be corrected below
  -- Position will be set by updateSectionPositions
  survivalContent:Show() -- Always show
  -- Register section and make header clickable
  local survivalSection = addSection(survivalHeader, survivalContent, 'survival')
  makeHeaderClickable(survivalHeader, survivalContent, 'survival', survivalSection)
  -- Modern content frame styling
  survivalContent:SetBackdrop({
    bgFile = 'Interface\\Buttons\\WHITE8X8',
    edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border',
    tile = true,
    tileSize = 8,
    edgeSize = 10,
    insets = {
      left = 3,
      right = 3,
      top = 3,
      bottom = 3,
    },
  })
  survivalContent:SetBackdropColor(0.08, 0.08, 0.1, 0.6)
  survivalContent:SetBackdropBorderColor(0.3, 0.3, 0.35, 0.5)

  -- Create survival statistics entries (items/consumables used)
  local survivalStats = { {
    key = 'healthPotionsUsed',
    label = 'Health Potions Used:',
    tooltipKey = 'healthPotionsUsed',
  }, {
    key = 'manaPotionsUsed',
    label = 'Mana Potions Used:',
    tooltipKey = 'manaPotionsUsed',
  }, {
    key = 'bandagesUsed',
    label = 'Bandages Applied:',
    tooltipKey = 'bandagesApplied',
  }, {
    key = 'targetDummiesUsed',
    label = 'Target Dummies Used (Beta):',
    tooltipKey = 'targetDummiesUsed',
  }, {
    key = 'grenadesUsed',
    label = 'Grenades Used (Beta):',
    tooltipKey = 'grenadesUsed',
  } }

  local yOffset = -LAYOUT.CONTENT_PADDING
  for index, stat in ipairs(survivalStats) do
    local label = survivalContent:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
    label:SetPoint(
      'TOPLEFT',
      survivalContent,
      'TOPLEFT',
      LAYOUT.ROW_INDENT + 12,
      yOffset + ROW_Y_ADJUST
    )
    label:SetText(stat.label)
    AddStatisticTooltip(label, stat.tooltipKey)

    local bar = CreateBarRow(survivalContent, stat.key, yOffset, index == #survivalStats)
    UpdateStatBar(stat.key, CharacterStats:GetStat(stat.key))

    -- Create checkbox for this survival statistic
    local radio = CreateFrame('CheckButton', nil, survivalContent, 'UICheckButtonTemplate')
    radio:SetPoint('RIGHT', label, 'LEFT', -4, 0)
    radio:SetScale(0.5)
    local settingName = 'showMainStatisticsPanel' .. string.gsub(stat.key, '^%l', string.upper)
    radio:SetChecked(false) -- Initialize as unchecked, will be updated by updateRadioButtons()
    radioButtons[settingName] = radio
    radio:SetScript('OnClick', function(self)
      tempSettings[settingName] = self:GetChecked()
      GLOBAL_SETTINGS[settingName] = self:GetChecked()
      -- Trigger immediate update of main screen statistics
      if UltraHardcoreStatsFrame and UltraHardcoreStatsFrame.UpdateRowVisibility then
        UltraHardcoreStatsFrame.UpdateRowVisibility()
      end
    end)

    yOffset = yOffset - LAYOUT.ROW_HEIGHT * 2
  end

  -- Correct survival content height now that we know the total rows
  local survivalRows = #survivalStats
  survivalContent:SetSize(
    540,
    survivalRows * LAYOUT.ROW_HEIGHT * 2 + LAYOUT.CONTENT_PADDING * 2 - 12
  )
  -- Create modern WoW-style Social section (collapsible)
  local socialHeader = CreateFrame('Frame', nil, statsScrollChild, 'BackdropTemplate')
  socialHeader:SetSize(560, LAYOUT.SECTION_HEADER_HEIGHT)
  socialHeader:SetBackdrop({
    bgFile = 'Interface\\Buttons\\WHITE8X8',
    edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border',
    tile = true,
    tileSize = 8,
    edgeSize = 12,
    insets = {
      left = 3,
      right = 3,
      top = 3,
      bottom = 3,
    },
  })
  socialHeader:SetBackdropColor(0.15, 0.15, 0.2, 0.85)
  socialHeader:SetBackdropBorderColor(0.5, 0.5, 0.6, 0.9)
  local socialLabel = socialHeader:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
  socialLabel:SetPoint('LEFT', socialHeader, 'LEFT', 24, 0)
  socialLabel:SetText('Social')
  socialLabel:SetTextColor(0.9, 0.85, 0.75, 1)
  socialLabel:SetShadowOffset(1, -1)
  socialLabel:SetShadowColor(0, 0, 0, 0.8)

  local socialContent = CreateFrame('Frame', nil, statsScrollChild, 'BackdropTemplate')
  socialContent:SetSize(540, 1 * LAYOUT.ROW_HEIGHT * 2 + LAYOUT.CONTENT_PADDING * 2 - 12)
  socialContent:Show()
  local socialSection = addSection(socialHeader, socialContent, 'social')
  makeHeaderClickable(socialHeader, socialContent, 'social', socialSection)
  socialContent:SetBackdrop({
    bgFile = 'Interface\\Buttons\\WHITE8X8',
    edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border',
    tile = true,
    tileSize = 8,
    edgeSize = 10,
    insets = {
      left = 3,
      right = 3,
      top = 3,
      bottom = 3,
    },
  })
  socialContent:SetBackdropColor(0.08, 0.08, 0.1, 0.6)
  socialContent:SetBackdropBorderColor(0.3, 0.3, 0.35, 0.5)

  local partyDeathsLabel = socialContent:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  partyDeathsLabel:SetPoint(
    'TOPLEFT',
    socialContent,
    'TOPLEFT',
    LAYOUT.ROW_INDENT + 12,
    -LAYOUT.CONTENT_PADDING + ROW_Y_ADJUST
  )
  partyDeathsLabel:SetText('Party Deaths Witnessed:')
  AddStatisticTooltip(partyDeathsLabel, 'partyDeathsWitnessed')

  statBars.partyMemberDeaths =
    CreateBarRow(socialContent, 'partyMemberDeaths', -LAYOUT.CONTENT_PADDING, true)
  UpdateStatBar('partyMemberDeaths', CharacterStats:GetStat('partyMemberDeaths') or 0)

  local showStatsPartyDeathsRadio =
    CreateFrame('CheckButton', nil, socialContent, 'UICheckButtonTemplate')
  showStatsPartyDeathsRadio:SetPoint('RIGHT', partyDeathsLabel, 'LEFT', -4, 0)
  showStatsPartyDeathsRadio:SetScale(0.5)
  showStatsPartyDeathsRadio:SetChecked(false)
  radioButtons.showMainStatisticsPanelPartyMemberDeaths = showStatsPartyDeathsRadio
  showStatsPartyDeathsRadio:SetScript('OnClick', function(self)
    tempSettings.showMainStatisticsPanelPartyMemberDeaths = self:GetChecked()
    GLOBAL_SETTINGS.showMainStatisticsPanelPartyMemberDeaths = self:GetChecked()
    if UltraHardcoreStatsFrame and UltraHardcoreStatsFrame.UpdateRowVisibility then
      UltraHardcoreStatsFrame.UpdateRowVisibility()
    end
  end)

  -- Create modern WoW-style Misc section (collapsible)
  local miscHeader = CreateFrame('Frame', nil, statsScrollChild, 'BackdropTemplate')
  miscHeader:SetSize(560, LAYOUT.SECTION_HEADER_HEIGHT)
  -- Position will be set by updateSectionPositions
  -- Modern WoW row styling with rounded corners and greyish background
  miscHeader:SetBackdrop({
    bgFile = 'Interface\\Buttons\\WHITE8X8',
    edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border',
    tile = true,
    tileSize = 8,
    edgeSize = 12,
    insets = {
      left = 3,
      right = 3,
      top = 3,
      bottom = 3,
    },
  })
  miscHeader:SetBackdropColor(0.15, 0.15, 0.2, 0.85)
  miscHeader:SetBackdropBorderColor(0.5, 0.5, 0.6, 0.9)
  -- Create header text
  local miscLabel = miscHeader:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
  miscLabel:SetPoint('LEFT', miscHeader, 'LEFT', 24, 0)
  miscLabel:SetText('Misc')
  miscLabel:SetTextColor(0.9, 0.85, 0.75, 1)
  miscLabel:SetShadowOffset(1, -1)
  miscLabel:SetShadowColor(0, 0, 0, 0.8)

  -- Create content frame for Misc breakdown
  local miscContent = CreateFrame('Frame', nil, statsScrollChild, 'BackdropTemplate')
  miscContent:SetSize(540, 6 * LAYOUT.ROW_HEIGHT * 2 + LAYOUT.CONTENT_PADDING * 2 - 12) -- Initial height, will be corrected below
  -- Position will be set by updateSectionPositions
  miscContent:Show()

  -- Register section and make header clickable
  local miscSection = addSection(miscHeader, miscContent, 'misc')
  makeHeaderClickable(miscHeader, miscContent, 'misc', miscSection)
  -- Modern content frame styling
  miscContent:SetBackdrop({
    bgFile = 'Interface\\Buttons\\WHITE8X8',
    edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border',
    tile = true,
    tileSize = 8,
    edgeSize = 10,
    insets = {
      left = 3,
      right = 3,
      top = 3,
      bottom = 3,
    },
  })
  miscContent:SetBackdropColor(0.08, 0.08, 0.1, 0.6)
  miscContent:SetBackdropBorderColor(0.3, 0.3, 0.35, 0.5)

  -- Create misc statistics display inside the content frame
  local miscStats = { {
    key = 'duelsTotal',
    label = 'Duels Total:',
    tooltipKey = 'duelsTotal',
  }, {
    key = 'duelsWon',
    label = 'Duels Won:',
    tooltipKey = 'duelsWon',
  }, {
    key = 'duelsLost',
    label = 'Duels Lost:',
    tooltipKey = 'duelsLost',
  }, {
    key = 'duelsWinPercent',
    label = 'Duel Win Percent:',
    tooltipKey = 'duelsWinPercent',
  }, {
    key = 'playerJumps',
    label = 'Jumps Performed:',
    tooltipKey = 'playerJumps',
  }, {
    key = 'mapKeyPressesWhileMapBlocked',
    label = 'Blocked Map Opens (Route Planner):',
    tooltipKey = 'mapKeyPressesWhileMapBlocked',
  } }

  local miscYOffset = -LAYOUT.CONTENT_PADDING
  for index, stat in ipairs(miscStats) do
    local label = miscContent:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
    label:SetPoint(
      'TOPLEFT',
      miscContent,
      'TOPLEFT',
      LAYOUT.ROW_INDENT + 12,
      miscYOffset + ROW_Y_ADJUST
    )
    label:SetText(stat.label)
    AddStatisticTooltip(label, stat.tooltipKey)

    local bar = CreateBarRow(miscContent, stat.key, miscYOffset, index == #miscStats)
    UpdateStatBar(stat.key, CharacterStats:GetStat(stat.key))

    -- Create checkbox for this misc statistic
    local radio = CreateFrame('CheckButton', nil, miscContent, 'UICheckButtonTemplate')
    radio:SetPoint('RIGHT', label, 'LEFT', -4, 0)
    radio:SetScale(0.5)
    local settingName = 'showMainStatisticsPanel' .. string.gsub(stat.key, '^%l', string.upper)
    radio:SetChecked(false)
    radioButtons[settingName] = radio
    radio:SetScript('OnClick', function(self)
      tempSettings[settingName] = self:GetChecked()
      GLOBAL_SETTINGS[settingName] = self:GetChecked()
      if UltraHardcoreStatsFrame and UltraHardcoreStatsFrame.UpdateRowVisibility then
        UltraHardcoreStatsFrame.UpdateRowVisibility()
      end
    end)

    miscYOffset = miscYOffset - LAYOUT.ROW_HEIGHT * 2
  end

  -- Correct misc content height now that we know the total rows
  local miscRows = #miscStats
  miscContent:SetSize(540, miscRows * LAYOUT.ROW_HEIGHT * 2 + LAYOUT.CONTENT_PADDING * 2 - 12)
  -- Create modern WoW-style XP gained section (collapsible)
  local xpGainedHeader = CreateFrame('Frame', nil, statsScrollChild, 'BackdropTemplate')
  xpGainedHeader:SetSize(560, LAYOUT.SECTION_HEADER_HEIGHT)
  -- Position will be set by updateSectionPositions
  -- Modern WoW row styling with rounded corners and greyish background
  xpGainedHeader:SetBackdrop({
    bgFile = 'Interface\\Buttons\\WHITE8X8',
    edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border',
    tile = true,
    tileSize = 8,
    edgeSize = 12,
    insets = {
      left = 3,
      right = 3,
      top = 3,
      bottom = 3,
    },
  })
  xpGainedHeader:SetBackdropColor(0.15, 0.15, 0.2, 0.85)
  xpGainedHeader:SetBackdropBorderColor(0.5, 0.5, 0.6, 0.9)
  -- Create header text
  local xpGainedLabel = xpGainedHeader:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
  xpGainedLabel:SetPoint('LEFT', xpGainedHeader, 'LEFT', 24, 0)
  xpGainedLabel:SetText('Settings XP Gain Verification')
  xpGainedLabel:SetTextColor(0.9, 0.85, 0.75, 1)
  xpGainedLabel:SetShadowOffset(1, -1)
  xpGainedLabel:SetShadowColor(0, 0, 0, 0.8)

  -- Create collapsible content frame for XP breakdown
  local xpGainedContent = CreateFrame('Frame', nil, statsScrollChild, 'BackdropTemplate')
  xpGainedContent:SetSize(540, 15 * LAYOUT.ROW_HEIGHT + LAYOUT.CONTENT_PADDING * 2 + 12) -- Adjusted for equal padding (reduced extra gap from 40px to 35px)
  -- Position will be set by updateSectionPositions
  xpGainedContent:Show() -- Show by default
  -- Register section and make header clickable
  local xpGainedSection = addSection(xpGainedHeader, xpGainedContent, 'xpGained')
  makeHeaderClickable(xpGainedHeader, xpGainedContent, 'xpGained', xpGainedSection)
  -- Modern content frame styling
  xpGainedContent:SetBackdrop({
    bgFile = 'Interface\\Buttons\\WHITE8X8',
    edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border',
    tile = true,
    tileSize = 8,
    edgeSize = 10,
    insets = {
      left = 3,
      right = 3,
      top = 3,
      bottom = 3,
    },
  })
  xpGainedContent:SetBackdropColor(0.08, 0.08, 0.1, 0.6)
  xpGainedContent:SetBackdropBorderColor(0.3, 0.3, 0.35, 0.5)

  -- Create XP breakdown display inside the content frame
  local xpBreakdownLabels = {}
  local xpBreakdownTexts = {}
  local xpSectionHeaders = {}

  -- Mapping of setting names to display names (ordered by preset sections)
  local settingDisplayNames = {
    -- Lite section
    hidePlayerFrame = 'Hide Player Frame',
    showTunnelVision = 'Tunnel Vision',
    -- Recommended section
    hideTargetFrame = 'Hide Target Frame',
    hideTargetTooltip = 'Hide Target Tooltips',
    disableNameplateHealth = 'Disable Nameplates',
    showDazedEffect = 'Show Dazed Effect',
    hideGroupHealth = 'Use ULTRA Party Frames',
    hideMinimap = 'Hide Minimap',
    -- Extreme section
    petsDiePermanently = 'Pets Die Permanently',
    hideActionBars = 'Hide Action Bars',
    tunnelVisionMaxStrata = 'Tunnel Vision Covers Everything',
    routePlanner = 'Route Planner',
    -- Experimental section
    showCritScreenMoveEffect = 'Use ULTRA Incoming Crit Effect',
    showFullHealthIndicator = 'Use ULTRA Full Health Indicator',
    hideCustomResourceBar = 'Hide Custom Resource Bar',
    showHealingIndicator = 'Use ULTRA Incoming Healing Effect',
  }

  -- Define preset sections with their settings (limit to up to Extreme)
  local allSectionsSimple = GetPresetSections('simple', false) -- Exclude Misc section
  local presetSections = {}
  for i, section in ipairs(allSectionsSimple) do
    if i <= 3 then
      table.insert(presetSections, section)
    else
      break
    end
  end
  -- Create XP breakdown entries with section headers
  local yOffset = -LAYOUT.CONTENT_PADDING
  for sectionIndex, section in ipairs(presetSections) do
    -- Create section header
    local sectionHeader = xpGainedContent:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
    sectionHeader:SetPoint('TOPLEFT', xpGainedContent, 'TOPLEFT', LAYOUT.ROW_INDENT + 12, yOffset)
    sectionHeader:SetText(section.title)
    sectionHeader:SetTextColor(1, 1, 0.5) -- Light yellow color for headers
    xpSectionHeaders[sectionIndex] = sectionHeader
    yOffset = yOffset - LAYOUT.ROW_HEIGHT

    -- Create settings for this section
    for _, settingName in ipairs(section.settings) do
      local displayName = settingDisplayNames[settingName]
      if displayName then
        local label = xpGainedContent:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
        label:SetPoint('TOPLEFT', xpGainedContent, 'TOPLEFT', LAYOUT.ROW_INDENT + 20, yOffset) -- Indented more for settings
        label:SetText(displayName .. ':')

        local text = xpGainedContent:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
        text:SetPoint('TOPRIGHT', xpGainedContent, 'TOPRIGHT', -LAYOUT.ROW_INDENT, yOffset)
        -- this is fragile, but similar logic is used below
        local xpVariable = 'xpGainedWithoutOption' .. string.gsub(settingName, '^%l', string.upper)
        text:SetText(formatNumberWithCommas(CharacterStats:GetStat(xpVariable)))

        xpBreakdownLabels[settingName] = label
        xpBreakdownTexts[settingName] = text

        yOffset = yOffset - LAYOUT.ROW_HEIGHT
      end
    end

    -- Add extra space between sections
    yOffset = yOffset - LAYOUT.SECTION_SPACING
  end

  -- Set initial positioning after all statistics are created
  -- Update all section positions now that all sections are registered
  updateSectionPositions()

  -- Function to update XP breakdown display
  local function UpdateXPBreakdown()
    -- Define preset sections with their settings (limit to up to Extreme, same order as TrackXPPerSetting.lua)
    local allSectionsExtended = GetPresetSections('extended', false) -- Exclude Misc section, use extended titles
    local presetSections = {}
    for i, section in ipairs(allSectionsExtended) do
      if i <= 3 then
        table.insert(presetSections, section)
      else
        break
      end
    end
    -- Update display organized by preset sections
    local yOffset = -LAYOUT.CONTENT_PADDING
    for sectionIndex, section in ipairs(presetSections) do
      -- Position section header
      local sectionHeader = xpSectionHeaders[sectionIndex]
      if sectionHeader then
        sectionHeader:SetPoint(
          'TOPLEFT',
          xpGainedContent,
          'TOPLEFT',
          LAYOUT.ROW_INDENT + 12,
          yOffset
        )
        yOffset = yOffset - LAYOUT.ROW_HEIGHT
      end

      -- Position settings for this section
      for _, settingName in ipairs(section.settings) do
        local textElement = xpBreakdownTexts[settingName]
        local labelElement = xpBreakdownLabels[settingName]

        if textElement and labelElement then
          -- Convert setting name to proper variable name format
          local xpVariable =
            'xpGainedWithoutOption' .. string.gsub(settingName, '^%l', string.upper)
          -- Handle camelCase conversion for multi-word settings
          xpVariable = string.gsub(xpVariable, '(%u)(%l)', '%1%2')

          local xpGained = CharacterStats:GetStat(xpVariable) or 0

          -- Position both label and text (indented for settings)
          labelElement:SetPoint(
            'TOPLEFT',
            xpGainedContent,
            'TOPLEFT',
            LAYOUT.ROW_INDENT + 20,
            yOffset
          )
          textElement:SetPoint('TOPRIGHT', xpGainedContent, 'TOPRIGHT', -LAYOUT.ROW_INDENT, yOffset)
          textElement:SetText(formatNumberWithCommas(xpGained))
          yOffset = yOffset - LAYOUT.ROW_HEIGHT
        end
      end

      -- Add extra space between sections
      yOffset = yOffset - LAYOUT.SECTION_SPACING
    end
  end

  -- Update the lowest health display
  local function UpdateLowestHealthDisplay()
    if not UltraHardcoreDB then
      LoadDBData()
    end

    UpdateStatBar('level', UnitLevel('player') or 1)

    UpdateStatBar('lowestHealth', CharacterStats:GetStat('lowestHealth') or 100)
    UpdateStatBar('lowestHealthThisLevel', CharacterStats:GetStat('lowestHealthThisLevel') or 100)
    UpdateStatBar(
      'lowestHealthThisSession',
      CharacterStats:GetStat('lowestHealthThisSession') or 100
    )

    UpdateStatBar('petDeaths', CharacterStats:GetStat('petDeaths') or 0)
    UpdateStatBar('closeEscapes', CharacterStats:GetStat('closeEscapes') or 0)
    UpdateStatBar('partyMemberDeaths', CharacterStats:GetStat('partyMemberDeaths') or 0)

    UpdateStatBar('elitesSlain', CharacterStats:GetStat('elitesSlain') or 0)
    UpdateStatBar('rareElitesSlain', CharacterStats:GetStat('rareElitesSlain') or 0)
    UpdateStatBar('worldBossesSlain', CharacterStats:GetStat('worldBossesSlain') or 0)
    UpdateStatBar('enemiesSlain', CharacterStats:GetStat('enemiesSlain') or 0)
    UpdateStatBar('dungeonBossesKilled', CharacterStats:GetStat('dungeonBossesKilled') or 0)
    UpdateStatBar('dungeonsCompleted', CharacterStats:GetStat('dungeonsCompleted') or 0)

    UpdateStatBar('highestCritValue', CharacterStats:GetStat('highestCritValue') or 0)
    UpdateStatBar('highestHealCritValue', CharacterStats:GetStat('highestHealCritValue') or 0)

    for _, stat in ipairs(survivalStats) do
      UpdateStatBar(stat.key, CharacterStats:GetStat(stat.key) or 0)
    end

    for _, stat in ipairs(miscStats) do
      UpdateStatBar(stat.key, CharacterStats:GetStat(stat.key) or 0)
    end

    -- Update XP breakdown (always visible now)
    UpdateXPBreakdown()
  end

  -- Keep Total HP/Mana values current when stats change outside the panel
  resourceEventFrame = CreateFrame('Frame')
  resourceEventFrame:RegisterEvent('PLAYER_LEVEL_UP')
  resourceEventFrame:RegisterEvent('PLAYER_EQUIPMENT_CHANGED')
  resourceEventFrame:RegisterEvent('UNIT_MAXHEALTH')
  resourceEventFrame:RegisterEvent('UNIT_MAXPOWER')
  resourceEventFrame:SetScript('OnEvent', function(_, event, unit)
    if (event == 'UNIT_MAXHEALTH' or event == 'UNIT_MAXPOWER') and unit ~= 'player' then return end
    if UpdateLowestHealthDisplay then
      UpdateLowestHealthDisplay()
    end
  end)

  -- Share button for Statistics tab
  local shareButton = CreateFrame('Button', nil, tabContents[1], 'UIPanelButtonTemplate')
  shareButton:SetSize(80, 30)
  shareButton:SetPoint('BOTTOM', tabContents[1], 'BOTTOM', 0, -40)
  shareButton:SetText('Share')

  -- Add tooltip
  shareButton:SetScript('OnEnter', function()
    GameTooltip:SetOwner(shareButton, 'ANCHOR_RIGHT')
    GameTooltip:SetText('Share ULTRA Stats to Chat')
    GameTooltip:Show()
  end)
  shareButton:SetScript('OnLeave', function()
    GameTooltip:Hide()
  end)

  shareButton:SetScript('OnClick', function()
    if CharacterStats and CharacterStats.LogStatsToChat then
      CharacterStats:LogStatsToChat()
    else
      print('ULTRA - CharacterStats not available. Please reload UI.')
    end
  end)

  -- Export functions for use by Settings.lua
  _G.UpdateLowestHealthDisplay = UpdateLowestHealthDisplay
  _G.UpdateXPBreakdown = UpdateXPBreakdown
end
