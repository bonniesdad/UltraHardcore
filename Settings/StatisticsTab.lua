-- Statistics Tab Content - Full size scrollable frame

-- Helper function to check if player has Engineering profession
local function HasEngineering()
  local prof1, prof2 = GetProfessions()
  if not prof1 and not prof2 then
    return false
  end

  local professions = { prof1, prof2 }
  for _, profIndex in ipairs(professions) do
    if profIndex then
      local name, _, _, _, _, _, skillLine = GetProfessionInfo(profIndex)
      if skillLine == 202 then -- Engineering skill line ID
        return true
      end
    end
  end
  return false
end

-- Centralized tooltip map for all statistics
local STATISTIC_TOOLTIPS = {
  -- Character Info section
  level = 'Your current character level',
  -- Health Tracking section
  total = "The lowest health percentage you've ever reached across all levels",
  thisLevel = "The lowest health percentage you've reached at your current level",
  thisSession = "The lowest health percentage you've reached in your current play session",
  -- Combat section
  enemiesSlainTotal = 'Total number of enemies you have killed',
  elitesSlain = 'Number of elite enemies you have killed',
  rareElitesSlain = 'Number of rare elite enemies you have killed',
  worldBossesSlain = 'Number of world bosses you have killed',
  dungeonBossesSlain = 'Number of dungeon bosses you have killed',
  dungeonsCompleted = 'Number of dungeons you have fully completed',
  highestCritValue = 'The highest critical hit damage you have dealt',
  highestHealCritValue = 'The highest critical heal you have done',
  closeEscapes = 'Number of times your health has dropped below ' .. closeEscapeHealthPercent .. '%',
  petDeaths = 'Total number of times your pet has died permanently',
  -- Survival section
  healthPotionsUsed = 'Number of health potions you have consumed',
  manaPotionsUsed = 'Number of mana potions you have consumed',
  bandagesApplied = 'Number of bandages you have used to heal',
  targetDummiesUsed = 'Number of target dummies you have used',
  grenadesUsed = 'Number of grenades you have thrown',
  -- Social section
  partyDeathsWitnessed = 'Number of party member deaths you have witnessed',
  duelsTotal = 'Total number of duels you have done',
  duelsWon = 'Number of duels you have won',
  duelsLost = 'Number of duels you have lost',
  duelsWinPercent = 'Percentage of duels you have won',
  -- Misc section
  playerJumps = 'Number of jumps you have performed.  Work that jump key!',
  player360s = 'Number of times you did a full 360 spin during a jump',
  mapKeyPressesWhileMapBlocked = 'Times you pressed M while Route Planner blocked the map',
  -- Network section
  lagHome = 'Latency to your home server',
  lagWorld = 'Latency to the world server',
  -- Unused statistics
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
local BAR_ROW_HEIGHT_REDUCTION = 30 -- shrink bar rows vertically
local DEFAULT_BAR_ROW_HEIGHT =
  math.max(STAT_BAR_HEIGHT + 4, (LAYOUT.ROW_HEIGHT * 2) - BAR_ROW_HEIGHT_REDUCTION)
local SECTION_CONTENT_BOTTOM_PADDING = 12 -- gap between last row and frame edge
local SECTION_BOTTOM_PADDING = 30 -- add breathing room below each section
local STAT_TIER_ICON_SIZE = 14
local STAT_TIER_ICON_GAP = 12
-- Fill colors progress from calm/neutral to impressive across tiers
local TIER_COLORS = {
  { 0.78, 0.49, 0.20, 0.95 }, -- tier 1: bronze
  { 0.78, 0.78, 0.82, 0.95 }, -- tier 2: silver
  { 0.95, 0.80, 0.22, 0.95 }, -- tier 3: gold
  { 0.62, 0.36, 0.90, 0.95 }, -- tier 4: master (purple)
  { 0.90, 0.25, 0.25, 0.95 }, -- tier 5+: demon (red)
}

-- Tier name mapping
local TIER_NAMES = {
  [1] = 'Bronze',
  [2] = 'Silver',
  [3] = 'Gold',
  [4] = 'Master',
  [5] = 'Demon',
}

-- Expose tier names for other UI modules (e.g. StatisticsTrackingToast)
_G.ULTRA_TIER_NAMES = TIER_NAMES
-- Expose tier colors for other UI modules (e.g. StatisticsTrackingToast)
_G.ULTRA_TIER_COLORS = TIER_COLORS

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
    valueOnly = true,
  },
  percent = {
    type = 'percent',
    max = 100,
    color = { 0.85, 0.35, 0.3, 0.95 },
    bgColor = { 0.07, 0.07, 0.09, 0.75 },
    valueOnly = true,
  },
  lowestHealth = {
    type = 'percent',
    max = 100,
    color = { 0.85, 0.25, 0.25, 0.95 },
    valueOnly = true,
  },
  lowestHealthThisLevel = {
    type = 'percent',
    max = 100,
    color = { 0.85, 0.25, 0.25, 0.95 },
    valueOnly = true,
  },
  lowestHealthThisSession = {
    type = 'percent',
    max = 100,
    color = { 0.85, 0.25, 0.25, 0.95 },
    valueOnly = true,
  },
  duelsWinPercent = {
    type = 'percent',
    max = 100,
    color = { 0.9, 0.7, 0.25, 0.95 },
    valueOnly = true,
  },
  -- Numeric stats with individualized tier settings (all inherit default base/multiplier unless overridden)
  level = {
    max = 60, -- classic cap
    valueOnly = true,
    noTier = true,
  },
  closeEscapes = {
    base = 1,
    multiplier = 3,
    valueOnly = true,
  },
  petDeaths = {
    valueOnly = true,
    noTier = true,
  },
  enemiesSlain = {
    base = 1000,
    multiplier = 3,
    valueOnly = true,
  },
  elitesSlain = {
    base = 200,
    multiplier = 3,
    valueOnly = true,
  },
  rareElitesSlain = {
    base = 25,
    multiplier = 2,
    valueOnly = true,
  },
  worldBossesSlain = {
    base = 10,
    multiplier = 2,
    valueOnly = true,
  },
  dungeonBossesKilled = {
    base = 25,
    multiplier = 2,
    valueOnly = true,
  },
  dungeonsCompleted = {
    base = 25,
    multiplier = 2,
    valueOnly = true,
  },
  highestCritValue = {
    base = 500,
    multiplier = 2,
    valueOnly = true,
    noTier = true,
  },
  highestHealCritValue = {
    base = 500,
    multiplier = 2,
    valueOnly = true,
    noTier = true,
  },
  healthPotionsUsed = {
    base = 25,
    multiplier = 2,
    valueOnly = true,
  },
  manaPotionsUsed = {
    base = 25,
    multiplier = 2,
    valueOnly = true,
  },
  bandagesUsed = {
    base = 50,
    multiplier = 2,
    valueOnly = true,
  },
  targetDummiesUsed = {
    base = 20,
    multiplier = 2,
    valueOnly = true,
  },
  grenadesUsed = {
    base = 25,
    multiplier = 2,
    valueOnly = true,
  },
  partyMemberDeaths = {
    base = 25,
    multiplier = 2,
    valueOnly = true,
    noTier = true,
  },
  duelsTotal = {
    base = 25,
    multiplier = 2,
    valueOnly = true,
    noTier = true,
  },
  duelsWon = {
    base = 25,
    multiplier = 2,
    valueOnly = true,
    noTier = true,
  },
  duelsLost = {
    base = 25,
    multiplier = 2,
    valueOnly = true,
    noTier = true,
  },
  playerJumps = {
    base = 10000,
    multiplier = 3,
    valueOnly = true,
  },
  player360s = {
    base = 1000,
    multiplier = 3,
    valueOnly = true,
  },
  mapKeyPressesWhileMapBlocked = {
    base = 50,
    multiplier = 2,
    valueOnly = true,
    noTier = true,
  },
  lagHome = {
    valueOnly = true,
    suffix = ' ms',
    noTier = true,
  },
  lagWorld = {
    valueOnly = true,
    suffix = ' ms',
    noTier = true,
  },
}

-- Expose to other modules (e.g. StatisticsTrackingToast) without having to duplicate tier config.
-- NOTE: This file is loaded on addon load (per `.toc`), so this global is available during gameplay.
_G.ULTRA_STAT_BAR_CONFIG = STAT_BAR_CONFIG

local statBars = {}
local UpdateStatBar

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
  local tierIcon = tierContainer:CreateTexture(nil, 'OVERLAY')
  tierIcon:SetSize(STAT_TIER_ICON_SIZE, STAT_TIER_ICON_SIZE)
  tierIcon:SetPoint('LEFT', tierText, 'RIGHT', STAT_TIER_ICON_GAP, 0)
  tierIcon:Hide()

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

  -- Store tier range and name for tooltip directly on tierText
  tierText.tierMin = 0
  tierText.tierMax = 0
  tierText.tierCurrent = 0
  tierText.tierName = ''

  -- Add tooltip and click handler to tier text
  tierText:SetScript('OnEnter', function(self)
    local tooltipLines = {}

    -- Add tier info if available
    local currentValue = (self.tierCurrent ~= nil) and self.tierCurrent or self.tierMin
    if currentValue ~= nil and self.tierMax ~= nil and self.tierName ~= '' then
      table.insert(
        tooltipLines,
        string.format(
          '%s tier (%s/%s)',
          self.tierName,
          formatNumberWithCommas(currentValue),
          formatNumberWithCommas(self.tierMax)
        )
      )
    end

    -- Add toast toggle info if statKey is available
    if self.statKey then
      local toastEnabled =
        GLOBAL_SETTINGS.statisticsToastEnabled and GLOBAL_SETTINGS.statisticsToastEnabled[self.statKey] ~= false
      table.insert(tooltipLines, '')
      table.insert(
        tooltipLines,
        toastEnabled and 'Click to disable toast notifications' or 'Click to enable toast notifications'
      )
    end

    if #tooltipLines > 0 then
      GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
      for i, line in ipairs(tooltipLines) do
        if i == 1 then
          GameTooltip:SetText(line, nil, nil, nil, nil, true)
        else
          GameTooltip:AddLine(line, nil, nil, nil, true)
        end
      end
      GameTooltip:Show()
    end
  end)

  tierText:SetScript('OnLeave', function(self)
    GameTooltip:Hide()
  end)

  -- Make tier text clickable to toggle toast notifications
  tierText:EnableMouse(true)
  tierText:SetScript('OnMouseDown', function(self, button)
    if button == 'LeftButton' and self.statKey then
      if not GLOBAL_SETTINGS.statisticsToastEnabled then
        GLOBAL_SETTINGS.statisticsToastEnabled = {}
      end
      local current = GLOBAL_SETTINGS.statisticsToastEnabled[self.statKey]
      GLOBAL_SETTINGS.statisticsToastEnabled[self.statKey] = not (current ~= false)

      -- Update visual state immediately
      local enabled = GLOBAL_SETTINGS.statisticsToastEnabled[self.statKey] ~= false
      local r, g, b = self:GetTextColor()
      if enabled then
        -- Restore original tier color (will be set by UpdateStatBar)
        -- For now, just ensure it's not grey
        if r == 0.5 and g == 0.5 and b == 0.5 then
          self:SetTextColor(1, 1, 1, 1)
        end
      else
        -- Grey out when disabled
        self:SetTextColor(0.5, 0.5, 0.5, 1)
      end

      -- Refresh the stat bar to update colors properly
      if UpdateStatBar and self.statKey then
        local value = CharacterStats:GetStat(self.statKey) or 0
        UpdateStatBar(self.statKey, value)
      end
    end
  end)

  return {
    frame = barFrame,
    fill = fill,
    text = text,
    tier = tierText,
    tierIcon = tierIcon,
    tierBg = tierBg,
    tierContainer = tierContainer,
    bg = bg,
  }
end

local function PositionStatBar(bar, parent, yOffset, layoutOptions)
  if not bar or not bar.frame then return end
  bar.frame:ClearAllPoints()
  local cfg = bar.statKey and STAT_BAR_CONFIG[bar.statKey]
  local isValueOnly = cfg and cfg.valueOnly
  local yPosition
  if isValueOnly then
    -- Align value-only rows with the label row
    yPosition = yOffset + ROW_Y_ADJUST
  else
    yPosition =
      yOffset - LAYOUT.ROW_HEIGHT - (LAYOUT.ROW_HEIGHT - STAT_BAR_HEIGHT) / 2 + BAR_VERTICAL_SHIFT
  end
  local left = (layoutOptions and layoutOptions.left) or (LAYOUT.ROW_INDENT + STAT_BAR_INSET)
  if layoutOptions and layoutOptions.width then
    local width = layoutOptions.width
    bar.frame:SetPoint('TOPLEFT', parent, 'TOPLEFT', left, yPosition)
    bar.frame:SetPoint('TOPRIGHT', parent, 'TOPLEFT', left + width, yPosition)
  else
    bar.frame:SetPoint('TOPLEFT', parent, 'TOPLEFT', left, yPosition)
    bar.frame:SetPoint(
      'TOPRIGHT',
      parent,
      'TOPRIGHT',
      -LAYOUT.ROW_INDENT - STAT_BAR_INSET,
      yPosition
    )
  end
end

local function CreateBarRow(parent, statKey, yOffset, isLast, layoutOptions)
  local bar = CreateStatBar(parent)
  bar.statKey = statKey
  bar.minText = parent:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
  bar.maxText = parent:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')

  -- Store statKey on tier text for toast toggle functionality
  bar.tier.statKey = statKey

  -- Initialize toast settings if needed (default: all enabled)
  if not GLOBAL_SETTINGS.statisticsToastEnabled then
    GLOBAL_SETTINGS.statisticsToastEnabled = {}
  end
  if GLOBAL_SETTINGS.statisticsToastEnabled[statKey] == nil then
    GLOBAL_SETTINGS.statisticsToastEnabled[statKey] = true
  end

  bar.tier:ClearAllPoints()
  bar.tier:SetPoint('TOPRIGHT', bar.frame, 'TOPRIGHT', 0, 9)

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
  if bar.tierIcon and statKey then
    local iconKey = statKey
    bar.tierIcon:SetTexture(
      'Interface\\AddOns\\UltraHardcore\\Textures\\stats-icons\\' .. iconKey .. '.png'
    )
  end
  PositionStatBar(bar, parent, yOffset, layoutOptions)
  return bar
end

local TWO_COLUMN_GAP = 24
local LABEL_BAR_OFFSET = (LAYOUT.ROW_INDENT + 12) - (LAYOUT.ROW_INDENT + STAT_BAR_INSET)

local function AttachSettingCheckbox(radio, settingName)
  if not radio or not settingName then return end
  radio:SetChecked(false)
  radioButtons[settingName] = radio
  radio:SetScript('OnClick', function(self)
    tempSettings[settingName] = self:GetChecked()
    GLOBAL_SETTINGS[settingName] = self:GetChecked()
    if UltraHardcoreStatsFrame and UltraHardcoreStatsFrame.UpdateRowVisibility then
      UltraHardcoreStatsFrame.UpdateRowVisibility()
    end
  end)
end

local function CreateStatsGrid(parent, statsList, options)
  if not parent or not statsList or #statsList == 0 then
    return 0
  end

  local opts = options or {}
  local defaultWidth = opts.defaultWidth or 0.5
  local columnGap = opts.columnGap or TWO_COLUMN_GAP
  local rowHeight = opts.rowHeight or DEFAULT_BAR_ROW_HEIGHT
  local baseYOffset = opts.baseYOffset or -LAYOUT.CONTENT_PADDING
  local parentWidth = parent:GetWidth()
  if not parentWidth or parentWidth == 0 then
    parentWidth = opts.fallbackWidth or 540
  end
  local barLeftBase = LAYOUT.ROW_INDENT + STAT_BAR_INSET
  local fullBarWidth = math.max(0, parentWidth - barLeftBase * 2)
  local halfBarWidth = (fullBarWidth - columnGap) / 2
  if halfBarWidth < 0 then
    halfBarWidth = fullBarWidth / 2
    columnGap = 0
  end

  local rowCount = 0
  local nextColumn = 0
  local accumulatedHeight = 0
  local pendingRowHeight = 0
  local pendingRowYOffset = baseYOffset
  local valueOnlyRowHeight = opts.valueOnlyRowHeight or (STAT_BAR_HEIGHT + 4)

  for _, stat in ipairs(statsList) do
    local statKey = stat.key
    if statKey then
      local width = stat.width or defaultWidth
      local cfg = STAT_BAR_CONFIG[statKey]
      if cfg and cfg.valueOnly and width < 1 then
        width = 1
      end
      local isValueOnly = cfg and cfg.valueOnly
      local rowHeightForStat = isValueOnly and valueOnlyRowHeight or rowHeight
      local isFullWidth = width >= 1
      local barWidth = isFullWidth and fullBarWidth or halfBarWidth
      local columnIndex
      local yOffset

      if isFullWidth then
        if nextColumn == 1 then
          accumulatedHeight = accumulatedHeight + pendingRowHeight
          pendingRowHeight = 0
          pendingRowYOffset = baseYOffset - accumulatedHeight
          nextColumn = 0
        end
        rowCount = rowCount + 1
        columnIndex = 0
        yOffset = baseYOffset - accumulatedHeight
        accumulatedHeight = accumulatedHeight + rowHeightForStat
      else
        if nextColumn == 0 then
          rowCount = rowCount + 1
          columnIndex = 0
          pendingRowHeight = rowHeightForStat
          pendingRowYOffset = baseYOffset - accumulatedHeight
          nextColumn = 1
          yOffset = pendingRowYOffset
        else
          columnIndex = 1
          yOffset = pendingRowYOffset
          if rowHeightForStat > pendingRowHeight then
            pendingRowHeight = rowHeightForStat
          end
          nextColumn = 0
          accumulatedHeight = accumulatedHeight + pendingRowHeight
          pendingRowHeight = 0
          pendingRowYOffset = baseYOffset - accumulatedHeight
        end
      end

      local columnLeft = barLeftBase
      if not isFullWidth and columnIndex == 1 then
        columnLeft = columnLeft + halfBarWidth + columnGap
      end

      local labelLeft = columnLeft + LABEL_BAR_OFFSET + 8
      local label = parent:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
      label:SetPoint('TOPLEFT', parent, 'TOPLEFT', labelLeft, yOffset + ROW_Y_ADJUST)
      label:SetText(stat.label or statKey)
      if stat.tooltipKey then
        AddStatisticTooltip(label, stat.tooltipKey)
      end

      local bar = CreateBarRow(parent, statKey, yOffset, true, {
        left = columnLeft,
        width = barWidth,
      })

      local value
      if stat.valueFunc then
        value = stat.valueFunc()
      else
        value = CharacterStats:GetStat(statKey)
      end
      if value == nil and stat.defaultValue ~= nil then
        value = stat.defaultValue
      end
      UpdateStatBar(statKey, value)

      if opts.createCheckboxes ~= false then
        local settingName = stat.settingName
        if settingName == nil then
          settingName =
            (opts.settingPrefix or 'showMainStatisticsPanel') .. string.gsub(
              statKey,
              '^%l',
              string.upper
            )
        end
        if settingName and settingName ~= '' then
          local radio = CreateFrame('CheckButton', nil, parent, 'UICheckButtonTemplate')
          radio:SetPoint('RIGHT', label, 'LEFT', -4, 0)
          radio:SetScale(0.7)
          AttachSettingCheckbox(radio, settingName)
        end
      end
    end
  end

  if nextColumn == 1 then
    accumulatedHeight = accumulatedHeight + pendingRowHeight
  end

  local totalHeight = math.max(rowHeight, accumulatedHeight + LAYOUT.CONTENT_PADDING * 2 - 12)
  parent:SetHeight(totalHeight + SECTION_CONTENT_BOTTOM_PADDING)
  return rowCount
end

local function CalculateTierProgress(value, base, multiplier)
  local currentValue = math.max(0, value or 0)
  base = tonumber(base) or 0
  multiplier = tonumber(multiplier) or 0

  -- Robust handling:
  -- - For multiplier <= 1 (or invalid), use linear tiers: tierMax = base * tier
  --   This avoids infinite loops and still allows "tier ups" to exist.
  if base <= 0 then
    return 1, 0, 0, 0
  end
  if multiplier <= 1 then
    local tier = math.floor(currentValue / base) + 1
    local tierMin = (tier - 1) * base
    local tierMax = tier * base
    local range = tierMax - tierMin
    local progress = range > 0 and (currentValue - tierMin) / range or 0
    return tier, tierMin, tierMax, math.min(math.max(progress, 0), 1)
  end

  local tier = 1
  local tierMax = base

  -- Inclusive boundary: hitting the max of a tier counts as entering the next tier.
  while currentValue >= tierMax do
    tier = tier + 1
    tierMax = tierMax * multiplier
  end

  local tierMin = tier == 1 and 0 or (tierMax / multiplier)
  local range = tierMax - tierMin
  local progress = range > 0 and (currentValue - tierMin) / range or 0

  return tier, tierMin, tierMax, math.min(math.max(progress, 0), 1)
end

function UpdateStatBar(statKey, value)
  local bar = statBars[statKey]
  if not bar then return end

  local cfg = STAT_BAR_CONFIG[statKey] or STAT_BAR_CONFIG.default
  local valueOnly = cfg.valueOnly
  local fillColor = cfg.color or STAT_BAR_CONFIG.default.color
  local bgColor = cfg.bgColor or STAT_BAR_CONFIG.default.bgColor
  local effectiveFillColor = fillColor

  if valueOnly then
    -- Value-only mode: simple label + value (no bar visuals)
    if bar.bg then
      bar.bg:Hide()
    end
    if bar.fill then
      bar.fill:Hide()
    end
    local rawValue = value or 0
    local isZero = rawValue == 0
    local displayText
    local textColor = fillColor or { 1, 1, 1, 1 }
    if cfg.type == 'percent' then
      local pctMax = cfg.max or 100
      local percent = math.max(0, math.min(value or 0, pctMax))
      displayText = isZero and '-' or string.format('%.1f%%', percent)
      -- Hide tier for percent stats
      if bar.tier then
        bar.tier:SetText('')
        bar.tier:Hide()
      end
      if bar.tierBg then
        bar.tierBg:Hide()
      end
    else
      local suffix = cfg.suffix or ''
      displayText = isZero and '-' or (formatNumberWithCommas(rawValue) .. suffix)

      -- Calculate and show tier for non-percent valueOnly stats (unless noTier is set)
      if not cfg.noTier then
        local base = cfg.base or STAT_BAR_CONFIG.default.base
        local multiplier = cfg.multiplier or STAT_BAR_CONFIG.default.multiplier
        if multiplier <= 1 then
          multiplier = STAT_BAR_CONFIG.default.multiplier
        end

        local tier, tierMin, tierMax, progress = CalculateTierProgress(value or 0, base, multiplier)
        local tierName = TIER_NAMES[tier] or TIER_NAMES[5] -- Default to Demon for tier 5+
        -- Get tier color
        local tierColorIndex = math.min(tier, #TIER_COLORS)
        local tierColor = TIER_COLORS[tierColorIndex] or { 1, 1, 1, 1 }
        -- Use tier color for value text
        textColor = tierColor
        -- Store tier info for positioning after value text is set up
        if bar.tier then
          bar.tier:SetText(tierName)
          -- Check if toast is disabled and grey out if so
          local toastEnabled =
            GLOBAL_SETTINGS.statisticsToastEnabled and GLOBAL_SETTINGS.statisticsToastEnabled[statKey] ~= false
          if toastEnabled then
            bar.tier:SetTextColor(tierColor[1], tierColor[2], tierColor[3], 1)
          else
            bar.tier:SetTextColor(0.5, 0.5, 0.5, 1) -- Grey when toast disabled
          end
          bar.tier.tierMin = tierMin
          bar.tier.tierMax = tierMax
          bar.tier.tierCurrent = value or 0
          bar.tier.tierName = tierName
        end
      else
        -- Hide tier for stats with noTier flag
        if bar.tier then
          bar.tier:SetText('')
          bar.tier:Hide()
        end
        if bar.tierBg then
          bar.tierBg:Hide()
        end
      end
    end
    if bar.minText then
      bar.minText:Hide()
    end
    if bar.maxText then
      bar.maxText:Hide()
    end
    bar.frame:SetBackdrop(nil)
    bar.text:ClearAllPoints()
    -- Nudge value up slightly to align with label baseline
    bar.text:SetPoint('RIGHT', bar.frame, 'RIGHT', -6, 6)
    bar.text:SetJustifyH('RIGHT')
    bar.text:SetText(displayText or '')
    bar.text:SetTextColor(textColor[1] or 1, textColor[2] or 1, textColor[3] or 1, 1)

    -- Position tier text after value text is positioned (for non-percent valueOnly stats)
    if cfg.type ~= 'percent' and not cfg.noTier and bar.tier and bar.tier:GetText() ~= '' then
      bar.tier:Show()
      bar.tier:ClearAllPoints()
      -- Position tier text consistently from the right
      bar.tier:SetPoint('RIGHT', bar.frame, 'RIGHT', -100, 6)
      if bar.tierIcon then
        bar.tierIcon:ClearAllPoints()
        bar.tierIcon:SetPoint('LEFT', bar.tier, 'RIGHT', STAT_TIER_ICON_GAP, 0)
        bar.tierIcon:Show()
      end
      if bar.tierBg then
        bar.tierBg:ClearAllPoints()
        bar.tierBg:SetPoint('TOPLEFT', bar.tier, 'TOPLEFT', -8, 2)
        -- Pill should wrap tier text only (icon sits outside the pill)
        bar.tierBg:SetPoint('BOTTOMRIGHT', bar.tier, 'BOTTOMRIGHT', 8, -2)
        bar.tierBg:Show()
      end
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
    local tierColor = nil
    if not cfg.color and #TIER_COLORS > 0 then
      local tierColorIndex = math.min(tier, #TIER_COLORS)
      tierColor = TIER_COLORS[tierColorIndex] or { 1, 1, 1, 1 }
      effectiveFillColor = tierColor
    end
    local availableWidth =
      (bar.bg and (bar.bg:GetWidth() - STAT_FILL_INSET * 2)) or bar.frame:GetWidth()
    bar.fill:SetWidth(availableWidth * progress)
    bar.text:SetText(formatNumberWithCommas(value or 0))

    -- Set tier name (bronze, silver, gold, master, demon)
    local tierName = TIER_NAMES[tier] or TIER_NAMES[5] -- Default to Demon for tier 5+
    bar.tier:SetText(tierName)

    -- Set tier text color to match tier color
    if not tierColor then
      local tierColorIndex = math.min(tier, #TIER_COLORS)
      tierColor = TIER_COLORS[tierColorIndex] or { 1, 1, 1, 1 }
    end
    -- Check if toast is disabled and grey out if so
    local toastEnabled =
      GLOBAL_SETTINGS.statisticsToastEnabled and GLOBAL_SETTINGS.statisticsToastEnabled[statKey] ~= false
    if toastEnabled then
      bar.tier:SetTextColor(tierColor[1], tierColor[2], tierColor[3], 1)
    else
      bar.tier:SetTextColor(0.5, 0.5, 0.5, 1) -- Grey when toast disabled
    end

    -- Set value text color to match tier color (only if not using custom color)
    if not cfg.color then
      bar.text:SetTextColor(tierColor[1], tierColor[2], tierColor[3], 1)
    end

    -- Store tier range and name for tooltip
    if bar.tier then
      bar.tier.tierMin = tierMin
      bar.tier.tierMax = tierMax
      bar.tier.tierCurrent = value or 0
      bar.tier.tierName = tierName
    end

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
    if cfg.type == 'percent' or cfg.noTier then
      bar.tier:Hide()
      if bar.tierIcon then
        bar.tierIcon:Hide()
      end
      if bar.tierBg then
        bar.tierBg:Hide()
      end
    else
      bar.tier:Show()
      bar.tier:ClearAllPoints()
      -- Position tier text consistently from the right
      bar.tier:SetPoint('RIGHT', bar.frame, 'RIGHT', -100, 6)
      if bar.tierIcon then
        bar.tierIcon:ClearAllPoints()
        bar.tierIcon:SetPoint('LEFT', bar.tier, 'RIGHT', STAT_TIER_ICON_GAP, 0)
        bar.tierIcon:Show()
      end
      if bar.tierBg then
        bar.tierBg:ClearAllPoints()
        bar.tierBg:SetPoint('TOPLEFT', bar.tier, 'TOPLEFT', -8, 2)
        -- Pill should wrap tier text only (icon sits outside the pill)
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
function InitializeStatisticsTab(tabContents)
  -- Check if tabContents[1] exists
  if not tabContents or not tabContents[1] then return end

  -- Check if already initialized to prevent duplicates
  if tabContents[1].initialized then return end

  -- Mark as initialized
  tabContents[1].initialized = true

  local statsFrame = CreateFrame('Frame', nil, tabContents[1], 'BackdropTemplate')
  statsFrame:SetPoint('TOP', tabContents[1], 'TOP', 0, -55) -- Moved up 10px
  statsFrame:SetPoint('LEFT', tabContents[1], 'LEFT', 10, 0)
  statsFrame:SetPoint('RIGHT', tabContents[1], 'RIGHT', -10, 0)
  statsFrame:SetHeight(540) -- Height fixed, width set by LEFT/RIGHT anchors
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
          previousSection.collapsed and -LAYOUT.SECTION_SPACING or -LAYOUT.SECTION_SPACING
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
        if not section.collapsed then
          if UpdateLowestHealthDisplay then
            UpdateLowestHealthDisplay()
          end
          if UpdateXPBreakdown then
            UpdateXPBreakdown()
          end
        end
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
  local characterStatsConfig = { {
    key = 'level',
    label = 'Level:',
    tooltipKey = 'level',
    width = 1,
    settingName = 'showMainStatisticsPanelLevel',
    valueFunc = function()
      return UnitLevel('player') or 1
    end,
    defaultValue = 1,
  } }
  CreateStatsGrid(characterInfoContent, characterStatsConfig, {
    defaultWidth = 1,
    rowHeight = 36,
  })

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
  healthTrackingContent:SetSize(540, 5 * LAYOUT.ROW_HEIGHT * 2 + LAYOUT.CONTENT_PADDING * 2 - 12) -- Initial height, recalculated after grid layout
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

  local healthStats = { {
    key = 'lowestHealth',
    label = 'Lowest Health (Total):',
    tooltipKey = 'total',
    settingName = 'showMainStatisticsPanelLowestHealth',
    defaultValue = 100,
    width = 1,
  }, {
    key = 'lowestHealthThisLevel',
    label = 'Lowest Health (This Level):',
    tooltipKey = 'thisLevel',
    settingName = 'showMainStatisticsPanelThisLevel',
    defaultValue = 100,
    width = 0.5,
  }, {
    key = 'lowestHealthThisSession',
    label = 'Lowest Health (This Session):',
    tooltipKey = 'thisSession',
    settingName = 'showMainStatisticsPanelSessionHealth',
    defaultValue = 100,
    width = 0.5,
  } }
  CreateStatsGrid(healthTrackingContent, healthStats, { defaultWidth = 0.5 })

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
  combatContent:SetSize(540, 8 * LAYOUT.ROW_HEIGHT * 2 + LAYOUT.CONTENT_PADDING * 2 - 12) -- Initial height, recalculated after grid layout
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

  local combatStats = { {
    key = 'enemiesSlain',
    label = 'Enemies Slain:',
    tooltipKey = 'enemiesSlainTotal',
    settingName = 'showMainStatisticsPanelEnemiesSlain',
    defaultValue = 0,
    width = 1,
  }, {
    key = 'elitesSlain',
    label = 'Elites Slain:',
    tooltipKey = 'elitesSlain',
    settingName = 'showMainStatisticsPanelElitesSlain',
    defaultValue = 0,
    width = 1,
  }, {
    key = 'rareElitesSlain',
    label = 'Rare Elites Slain:',
    tooltipKey = 'rareElitesSlain',
    settingName = 'showMainStatisticsPanelRareElitesSlain',
    defaultValue = 0,
    width = 1,
  }, {
    key = 'worldBossesSlain',
    label = 'World Bosses Slain:',
    tooltipKey = 'worldBossesSlain',
    settingName = 'showMainStatisticsPanelWorldBossesSlain',
    defaultValue = 0,
    width = 1,
  }, {
    key = 'dungeonBossesKilled',
    label = 'Dungeon Bosses Slain:',
    tooltipKey = 'dungeonBossesSlain',
    settingName = 'showMainStatisticsPanelDungeonBosses',
    defaultValue = 0,
    width = 1,
  }, {
    key = 'dungeonsCompleted',
    label = 'Dungeons Completed:',
    tooltipKey = 'dungeonsCompleted',
    settingName = 'showMainStatisticsPanelDungeonsCompleted',
    defaultValue = 0,
    width = 1,
  }, {
    key = 'closeEscapes',
    label = 'Close Escapes:',
    tooltipKey = 'closeEscapes',
    settingName = 'showMainStatisticsPanelCloseEscapes',
    defaultValue = 0,
    width = 1,
  }, {
    key = 'highestCritValue',
    label = 'Highest Crit Value:',
    tooltipKey = 'highestCritValue',
    settingName = 'showMainStatisticsPanelHighestCritValue',
    defaultValue = 0,
    width = 1,
  }, {
    key = 'highestHealCritValue',
    label = 'Highest Heal Crit Value:',
    tooltipKey = 'highestHealCritValue',
    settingName = 'showMainStatisticsPanelHighestHealCritValue',
    defaultValue = 0,
    width = 1,
  } }

  -- Only add pet deaths for pet classes (hunter and warlock)
  local _, playerClass = UnitClass('player')
  if playerClass == 'HUNTER' or playerClass == 'WARLOCK' then
    table.insert(combatStats, {
      key = 'petDeaths',
      label = 'Pet Deaths:',
      tooltipKey = 'petDeaths',
      settingName = 'showMainStatisticsPanelPetDeaths',
      defaultValue = 0,
      width = 1,
    })
  end

  CreateStatsGrid(combatContent, combatStats, { defaultWidth = 0.5 })

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
    defaultValue = 0,
    width = 1,
  }, {
    key = 'manaPotionsUsed',
    label = 'Mana Potions Used:',
    tooltipKey = 'manaPotionsUsed',
    defaultValue = 0,
    width = 1,
  }, {
    key = 'bandagesUsed',
    label = 'Bandages Applied:',
    tooltipKey = 'bandagesApplied',
    defaultValue = 0,
    width = 1,
  } }

  -- Only add Engineering-related stats if player has Engineering profession
  if HasEngineering() then
    table.insert(survivalStats, {
      key = 'targetDummiesUsed',
      label = 'Target Dummies Used:',
      tooltipKey = 'targetDummiesUsed',
      defaultValue = 0,
      width = 1,
    })
    table.insert(survivalStats, {
      key = 'grenadesUsed',
      label = 'Grenades Used:',
      tooltipKey = 'grenadesUsed',
      defaultValue = 0,
      width = 1,
    })
  end
  CreateStatsGrid(survivalContent, survivalStats, { defaultWidth = 0.5 })
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

  local socialStats = { {
    key = 'partyMemberDeaths',
    label = 'Party Deaths Witnessed:',
    tooltipKey = 'partyDeathsWitnessed',
    settingName = 'showMainStatisticsPanelPartyMemberDeaths',
    defaultValue = 0,
    width = 1,
  }, {
    key = 'duelsTotal',
    label = 'Duels Total:',
    tooltipKey = 'duelsTotal',
    defaultValue = 0,
    width = 1,
  }, {
    key = 'duelsWon',
    label = 'Duels Won:',
    tooltipKey = 'duelsWon',
    defaultValue = 0,
    width = 1,
  }, {
    key = 'duelsLost',
    label = 'Duels Lost:',
    tooltipKey = 'duelsLost',
    defaultValue = 0,
    width = 1,
  }, {
    key = 'duelsWinPercent',
    label = 'Duel Win Percent:',
    tooltipKey = 'duelsWinPercent',
    defaultValue = 0,
    width = 1,
  } }
  CreateStatsGrid(socialContent, socialStats, { defaultWidth = 0.5 })

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
    key = 'playerJumps',
    label = 'Jumps Performed:',
    tooltipKey = 'playerJumps',
    defaultValue = 0,
    width = 1,
  }, {
    key = 'player360s',
    label = '360s During Jumps:',
    tooltipKey = 'player360s',
    defaultValue = 0,
    width = 1,
  }, {
    key = 'mapKeyPressesWhileMapBlocked',
    label = 'Blocked Map Opens (Route Planner):',
    tooltipKey = 'mapKeyPressesWhileMapBlocked',
    defaultValue = 0,
    width = 1,
  } }
  CreateStatsGrid(miscContent, miscStats, { defaultWidth = 0.5 })

  -- Create modern WoW-style Network section (collapsible)
  local networkHeader = CreateFrame('Frame', nil, statsScrollChild, 'BackdropTemplate')
  networkHeader:SetSize(560, LAYOUT.SECTION_HEADER_HEIGHT)
  -- Position will be set by updateSectionPositions
  -- Modern WoW row styling with rounded corners and greyish background
  networkHeader:SetBackdrop({
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
  networkHeader:SetBackdropColor(0.15, 0.15, 0.2, 0.85)
  networkHeader:SetBackdropBorderColor(0.5, 0.5, 0.6, 0.9)
  -- Create header text
  local networkLabel = networkHeader:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
  networkLabel:SetPoint('LEFT', networkHeader, 'LEFT', 24, 0)
  networkLabel:SetText('Network')
  networkLabel:SetTextColor(0.9, 0.85, 0.75, 1)
  networkLabel:SetShadowOffset(1, -1)
  networkLabel:SetShadowColor(0, 0, 0, 0.8)

  -- Create content frame for Network breakdown
  local networkContent = CreateFrame('Frame', nil, statsScrollChild, 'BackdropTemplate')
  networkContent:SetSize(540, 2 * LAYOUT.ROW_HEIGHT * 2 + LAYOUT.CONTENT_PADDING * 2 - 12) -- Initial height, will be corrected below
  -- Position will be set by updateSectionPositions
  networkContent:Show()

  -- Register section and make header clickable
  local networkSection = addSection(networkHeader, networkContent, 'network')
  makeHeaderClickable(networkHeader, networkContent, 'network', networkSection)
  -- Modern content frame styling
  networkContent:SetBackdrop({
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
  networkContent:SetBackdropColor(0.08, 0.08, 0.1, 0.6)
  networkContent:SetBackdropBorderColor(0.3, 0.3, 0.35, 0.5)

  -- Create network statistics display inside the content frame
  local networkStats = { {
    key = 'lagHome',
    label = 'Home Latency:',
    tooltipKey = 'lagHome',
    defaultValue = 0,
    width = 1,
  }, {
    key = 'lagWorld',
    label = 'World Latency:',
    tooltipKey = 'lagWorld',
    defaultValue = 0,
    width = 1,
  } }
  CreateStatsGrid(networkContent, networkStats, { defaultWidth = 0.5 })

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
  local XP_ROW_HEIGHT = math.max(18, LAYOUT.ROW_HEIGHT * 0.75)
  local xpGainedContent = CreateFrame('Frame', nil, statsScrollChild, 'BackdropTemplate')
  xpGainedContent:SetSize(540, 15 * XP_ROW_HEIGHT + LAYOUT.CONTENT_PADDING * 2 + 12) -- Adjusted for smaller row height
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
  xpGainedContent:SetHeight(xpGainedContent:GetHeight() + SECTION_CONTENT_BOTTOM_PADDING)

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
    yOffset = yOffset - XP_ROW_HEIGHT

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

        yOffset = yOffset - XP_ROW_HEIGHT
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
        yOffset = yOffset - XP_ROW_HEIGHT
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
          yOffset = yOffset - XP_ROW_HEIGHT
        end
      end

      -- Add extra space between sections
      yOffset = yOffset - LAYOUT.SECTION_SPACING
    end
  end

  -- Update the lowest health display
  local function UpdateLowestHealthDisplay()
    if not UltraHardcoreDB then return end

    UpdateStatBar('level', UnitLevel('player') or 1)

    UpdateStatBar('lowestHealth', CharacterStats:GetStat('lowestHealth') or 100)
    UpdateStatBar('lowestHealthThisLevel', CharacterStats:GetStat('lowestHealthThisLevel') or 100)
    UpdateStatBar(
      'lowestHealthThisSession',
      CharacterStats:GetStat('lowestHealthThisSession') or 100
    )

    -- Only update pet deaths for pet classes (hunter and warlock)
    local _, playerClass = UnitClass('player')
    if playerClass == 'HUNTER' or playerClass == 'WARLOCK' then
      UpdateStatBar('petDeaths', CharacterStats:GetStat('petDeaths') or 0)
    end
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
    UpdateStatBar('lagHome', select(3, GetNetStats()))
    UpdateStatBar('lagWorld', select(4, GetNetStats()))

    for _, stat in ipairs(survivalStats) do
      UpdateStatBar(stat.key, CharacterStats:GetStat(stat.key) or 0)
    end

    for _, stat in ipairs(socialStats) do
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
