-- Guild leaderboard tab: one full-width panel for the guild roster table.

local ROW_HEIGHT = 18
local ROW_GAP = 1
local HEADER_ROW_HEIGHT = 20
local PANEL_SIDE_MARGIN = 0
local PANEL_PAD = 3
-- Right-hand gutter matches scrollbar width so the bar sits inside the bordered table.
local SCROLL_BAR_WIDTH = 26
-- Shift UIPanelScrollFrameTemplate chrome left (negative x on TOPRIGHT/BOTTOMRIGHT to scroll).
local SCROLL_BAR_NUDGE_LEFT = 21
local HEADER_STRIP = {
  r = 0.12,
  g = 0.10,
  b = 0.08,
  a = 0.98,
}

local AP_COLUMN_PAD = 32
local ENEMIES_COLUMN_PAD = 32
local DUNGEONS_COLUMN_PAD = 26
local JUMPS_COLUMN_PAD = 8
local ULTRA_COLUMN_PAD = 8
local ULTRA_ICON_SIZE = 14
local NAME_COL_SHRINK = 22
local NAME_TO_LEVEL_SHIFT = 14
local PANEL_BACKDROP = {
  bgFile = 'Interface\\DialogFrame\\UI-DialogBox-Background',
  edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border',
  tile = true,
  tileSize = 64,
  edgeSize = 12,
  insets = {
    left = 3,
    right = 3,
    top = 3,
    bottom = 3,
  },
}

local function getPrimaryRowTint()
  return UHC_GetGuildLeaderboardRowTint()
end

local SYNC_BAR_HEIGHT = 34
local TABLE_LAYOUT_GAP = 8 -- space between champion block and table
-- Tab content starts at -50; tab row sits at -57 with up to 38px height — clear it inside the tab frame.
local LEADERBOARD_MOUNT_TOP_INSET = 48
local LEADERBOARD_MOUNT_BOTTOM_INSET = 12
local MOUNT_VERTICAL_INSET = LEADERBOARD_MOUNT_TOP_INSET + LEADERBOARD_MOUNT_BOTTOM_INSET

local function computeLeaderboardTableHeight(content, championH)
  local contentH = (content and content.GetHeight and content:GetHeight()) or 650
  local mountH = contentH - MOUNT_VERTICAL_INSET
  local tableH = mountH - (championH or 0) - TABLE_LAYOUT_GAP - SYNC_BAR_HEIGHT - 4
  return math.max(120, math.floor(tableH))
end

local function createLeaderboardPanel(
parent,
  rows,
  rowTint,
  panelWidth,
  anchorSide,
  panelTopInset,
  bottomInset,
  panelHeight
)
  bottomInset = bottomInset or 0
  local panel = CreateFrame('Frame', nil, parent, 'BackdropTemplate')
  panel:SetBackdrop(PANEL_BACKDROP)
  panel:SetBackdropColor(0.06, 0.05, 0.05, 0.92)
  panel:SetBackdropBorderColor(0.45, 0.4, 0.3, 0.9)
  if anchorSide ~= 'FULL' then
    panel:SetWidth(math.max(80, panelWidth))
  end
  if anchorSide == 'FULL' then
    local topY = panelTopInset or 0
    panel:SetPoint('TOPLEFT', parent, 'TOPLEFT', 0, topY)
    panel:SetPoint('RIGHT', parent, 'RIGHT', 0, 0)
    if panelHeight and panelHeight > 0 then
      panel:SetHeight(panelHeight)
    else
      panel:SetPoint('BOTTOMRIGHT', parent, 'BOTTOMRIGHT', 0, bottomInset)
    end
  elseif anchorSide == 'LEFT' then
    panel:SetPoint('TOPLEFT', parent, 'TOPLEFT', 0, 0)
    panel:SetPoint('BOTTOMLEFT', parent, 'BOTTOMLEFT', 0, 0)
  else
    panel:SetPoint('TOPRIGHT', parent, 'TOPRIGHT', 0, 0)
    panel:SetPoint('BOTTOMRIGHT', parent, 'BOTTOMRIGHT', 0, 0)
  end

  local tableTopY = -3
  local tableTop = CreateFrame('Frame', nil, panel)
  tableTop:SetPoint('TOPLEFT', panel, 'TOPLEFT', PANEL_PAD, tableTopY)
  tableTop:SetPoint('TOPRIGHT', panel, 'TOPRIGHT', -PANEL_PAD, tableTopY)
  tableTop:SetPoint('BOTTOMLEFT', panel, 'BOTTOMLEFT', PANEL_PAD, PANEL_PAD)
  tableTop:SetPoint('BOTTOMRIGHT', panel, 'BOTTOMRIGHT', -PANEL_PAD, PANEL_PAD)

  local tableInnerWidth = panelWidth - (PANEL_PAD * 2)
  if tableInnerWidth < 80 then
    tableInnerWidth = 200
  end
  local listInnerW = tableInnerWidth
  if listInnerW < 60 then
    listInnerW = tableInnerWidth * 0.88
  end
  local dataInnerW = math.max(60, listInnerW - SCROLL_BAR_WIDTH)

  if UHC_SortGuildLeaderboardInPlace then
    UHC_SortGuildLeaderboardInPlace(rows)
  end

  local ACHIEVEMENT_POINTS_LABEL = 'Points'
  local ENEMIES_LABEL = 'Enemies'
  local DUNGEONS_LABEL = 'Dungeons'
  local JUMPS_LABEL = 'Jumps'
  local ULTRA_LABEL = 'Ultra'

  local measureFs = panel:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
  measureFs:SetText(ULTRA_LABEL)
  local colUltraW = math.max(ULTRA_ICON_SIZE + 6, math.ceil(measureFs:GetStringWidth()) + ULTRA_COLUMN_PAD)
  measureFs:SetText(ACHIEVEMENT_POINTS_LABEL)
  measureFs:SetText(ACHIEVEMENT_POINTS_LABEL)
  local colApW = math.ceil(measureFs:GetStringWidth()) + AP_COLUMN_PAD
  measureFs:SetText('12450')
  colApW = math.max(colApW, math.ceil(measureFs:GetStringWidth()) + AP_COLUMN_PAD)
  measureFs:SetText(ENEMIES_LABEL)
  local colEnemiesW = math.ceil(measureFs:GetStringWidth()) + ENEMIES_COLUMN_PAD
  measureFs:SetText('12450')
  colEnemiesW = math.max(colEnemiesW, math.ceil(measureFs:GetStringWidth()) + ENEMIES_COLUMN_PAD)
  measureFs:SetText(DUNGEONS_LABEL)
  local colDungeonsW = math.ceil(measureFs:GetStringWidth()) + DUNGEONS_COLUMN_PAD
  measureFs:SetText('1245')
  colDungeonsW = math.max(colDungeonsW, math.ceil(measureFs:GetStringWidth()) + DUNGEONS_COLUMN_PAD)
  measureFs:SetText(JUMPS_LABEL)
  local colJumpsW = math.ceil(measureFs:GetStringWidth()) + JUMPS_COLUMN_PAD
  measureFs:SetText('12450')
  colJumpsW = math.max(colJumpsW, math.ceil(measureFs:GetStringWidth()) + JUMPS_COLUMN_PAD)
  measureFs:Hide()

  local colRankW = math.floor(math.min(32, math.max(22, dataInnerW * 0.065))) + 5
  local colLevelW = math.floor(math.min(32, math.max(24, dataInnerW * 0.078)))
  colLevelW = colLevelW + NAME_TO_LEVEL_SHIFT
  local restW =
    math.max(
      40,
      dataInnerW - colRankW - colUltraW - colApW - colEnemiesW - colDungeonsW - colJumpsW - colLevelW
    )
  local colNameW = math.max(48, restW - NAME_COL_SHRINK)
  local xName = colRankW
  local xAp = xName + colNameW
  local xEnemies = xAp + colApW
  local xDungeons = xEnemies + colEnemiesW
  local xJumps = xDungeons + colDungeonsW
  local xLevel = xJumps + colJumpsW
  local xUltra = xLevel + colLevelW

  local headerBg = CreateFrame('Frame', nil, tableTop, 'BackdropTemplate')
  headerBg:SetHeight(HEADER_ROW_HEIGHT)
  headerBg:SetPoint('TOPLEFT', tableTop, 'TOPLEFT', 0, 0)
  headerBg:SetPoint('TOPRIGHT', tableTop, 'TOPRIGHT', 0, 0)
  headerBg:SetBackdrop({
    bgFile = 'Interface\\Buttons\\WHITE8x8',
    edgeFile = nil,
    tile = false,
    edgeSize = 0,
  })
  headerBg:SetBackdropColor(HEADER_STRIP.r, HEADER_STRIP.g, HEADER_STRIP.b, HEADER_STRIP.a)

  local hRank = headerBg:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
  hRank:SetPoint('TOPLEFT', headerBg, 'TOPLEFT', 2, -3)
  hRank:SetWidth(colRankW - 2)
  hRank:SetJustifyH('CENTER')
  hRank:SetText('#')
  hRank:SetTextColor(1, 0.92, 0.62)

  local hName = headerBg:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
  hName:SetPoint('TOPLEFT', headerBg, 'TOPLEFT', xName + 2, -3)
  hName:SetWidth(colNameW - 4)
  hName:SetJustifyH('LEFT')
  hName:SetText('Character Name')
  hName:SetTextColor(1, 0.92, 0.62)

  local hAp = headerBg:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
  hAp:SetPoint('TOPLEFT', headerBg, 'TOPLEFT', xAp, -3)
  hAp:SetWidth(colApW)
  hAp:SetJustifyH('LEFT')
  hAp:SetText(ACHIEVEMENT_POINTS_LABEL)
  hAp:SetTextColor(1, 0.92, 0.62)
  local hEnemies = headerBg:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
  hEnemies:SetPoint('TOPLEFT', headerBg, 'TOPLEFT', xEnemies, -3)
  hEnemies:SetWidth(colEnemiesW)
  hEnemies:SetJustifyH('LEFT')
  hEnemies:SetText(ENEMIES_LABEL)
  hEnemies:SetTextColor(1, 0.92, 0.62)
  local hDungeons = headerBg:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
  hDungeons:SetPoint('TOPLEFT', headerBg, 'TOPLEFT', xDungeons, -3)
  hDungeons:SetWidth(colDungeonsW)
  hDungeons:SetJustifyH('LEFT')
  hDungeons:SetText(DUNGEONS_LABEL)
  hDungeons:SetTextColor(1, 0.92, 0.62)
  local hJumps = headerBg:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
  hJumps:SetPoint('TOPLEFT', headerBg, 'TOPLEFT', xJumps, -3)
  hJumps:SetWidth(colJumpsW)
  hJumps:SetJustifyH('LEFT')
  hJumps:SetText(JUMPS_LABEL)
  hJumps:SetTextColor(1, 0.92, 0.62)

  local hLvl = headerBg:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
  hLvl:SetPoint('TOPLEFT', headerBg, 'TOPLEFT', xLevel, -3)
  hLvl:SetWidth(colLevelW)
  hLvl:SetJustifyH('LEFT')
  hLvl:SetText('Level')
  hLvl:SetTextColor(1, 0.92, 0.62)

  local hUltra = headerBg:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
  hUltra:SetPoint('TOPLEFT', headerBg, 'TOPLEFT', xUltra, -3)
  hUltra:SetWidth(colUltraW)
  hUltra:SetJustifyH('CENTER')
  hUltra:SetText(ULTRA_LABEL)
  hUltra:SetTextColor(1, 0.92, 0.62)

  local rowStep = ROW_HEIGHT + ROW_GAP

  local scroll = CreateFrame('ScrollFrame', nil, tableTop, 'UIPanelScrollFrameTemplate')
  scroll:SetFrameStrata(panel:GetFrameStrata())
  scroll:SetFrameLevel(tableTop:GetFrameLevel() + 5)
  scroll:SetPoint('TOPLEFT', headerBg, 'BOTTOMLEFT', 0, -ROW_GAP)
  scroll:SetPoint('BOTTOMRIGHT', tableTop, 'BOTTOMRIGHT', 0, 0)
  scroll:EnableMouseWheel(true)

  local function nudgeScrollChromeLeft(px)
    if not px or px == 0 then return end
    local function nudgeAnchorsToScroll(f)
      if not f or not f.GetNumPoints or not f.ClearAllPoints then return end
      local n = f:GetNumPoints()
      if not n or n < 1 then return end
      local pts = {}
      for i = 1, n do
        pts[i] = { f:GetPoint(i) }
      end
      f:ClearAllPoints()
      for _, p in ipairs(pts) do
        local point, rel, relPoint, x, y = p[1], p[2], p[3], p[4], p[5]
        x = x or 0
        y = y or 0
        if rel == scroll then
          x = x - px
        end
        f:SetPoint(point, rel, relPoint, x, y)
      end
    end
    nudgeAnchorsToScroll(scroll.ScrollUpButton)
    nudgeAnchorsToScroll(scroll.ScrollDownButton)
    nudgeAnchorsToScroll(scroll.ScrollBar)
  end
  nudgeScrollChromeLeft(SCROLL_BAR_NUDGE_LEFT)

  local scrollChild = CreateFrame('Frame', nil, scroll)
  scrollChild:SetFrameLevel(scroll:GetFrameLevel() + 1)
  scrollChild:SetWidth(math.max(1, listInnerW))
  scrollChild:SetHeight(1)
  scroll:SetScrollChild(scrollChild)

  local function raiseScrollChrome()
    local topLevel = scroll:GetFrameLevel() + 25
    local sb = scroll.ScrollBar
    if not sb then
      for i = 1, select('#', scroll:GetChildren()) do
        local c = select(i, scroll:GetChildren())
        if c and c.GetObjectType and c:GetObjectType() == 'Slider' then
          sb = c
          break
        end
      end
    end
    if sb then
      sb:SetFrameLevel(topLevel)
      sb:Show()
    end
    for i = 1, select('#', scroll:GetChildren()) do
      local c = select(i, scroll:GetChildren())
      if c and c.GetObjectType and c:GetObjectType() == 'Button' then
        c:SetFrameLevel(topLevel)
        c:Show()
      end
    end
  end

  -- Full-width child matches headerBg; clamp horizontal scroll. Refresh rect + chrome so the bar stays visible.
  local function syncScrollChildWidth()
    local w = tableTop:GetWidth()
    if not w or w <= 4 then
      w = scroll:GetWidth()
    end
    if w and w > 4 then
      scrollChild:SetWidth(w)
    end
    scroll:SetHorizontalScroll(0)
    if scroll.UpdateScrollChildRect then
      scroll:UpdateScrollChildRect()
    end
    raiseScrollChrome()
  end
  scroll:SetScript('OnSizeChanged', syncScrollChildWidth)
  scroll:SetScript('OnUpdate', function(self)
    if (self.GetHorizontalScroll and self:GetHorizontalScroll() or 0) ~= 0 then
      self:SetHorizontalScroll(0)
    end
  end)
  if scroll.HookScript then
    scroll:HookScript('OnScrollRangeChanged', function()
      raiseScrollChrome()
    end)
  end
  syncScrollChildWidth()
  if C_Timer and C_Timer.After then
    C_Timer.After(0, syncScrollChildWidth)
  end

  local rowPool = {}

  local function ensureRow(i)
    local row = rowPool[i]
    if row then
      return row
    end
    row = CreateFrame('Frame', nil, scrollChild, 'BackdropTemplate')
    row:SetHeight(ROW_HEIGHT)
    row:SetPoint('TOPLEFT', scrollChild, 'TOPLEFT', 0, -((i - 1) * rowStep))
    row:SetPoint('TOPRIGHT', scrollChild, 'TOPRIGHT', 0, -((i - 1) * rowStep))

    row.rankFs = row:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
    row.rankFs:SetPoint('LEFT', row, 'LEFT', 2, 0)
    row.rankFs:SetWidth(colRankW - 2)
    row.rankFs:SetJustifyH('CENTER')

    row.nameFs = row:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
    row.nameFs:SetPoint('LEFT', row, 'LEFT', xName + 2, 0)
    row.nameFs:SetWidth(colNameW - 4)
    row.nameFs:SetJustifyH('LEFT')

    row.apFs = row:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
    row.apFs:SetPoint('LEFT', row, 'LEFT', xAp, 0)
    row.apFs:SetWidth(colApW)
    row.apFs:SetJustifyH('LEFT')
    row.enemiesFs = row:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
    row.enemiesFs:SetPoint('LEFT', row, 'LEFT', xEnemies, 0)
    row.enemiesFs:SetWidth(colEnemiesW)
    row.enemiesFs:SetJustifyH('LEFT')
    row.dungeonsFs = row:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
    row.dungeonsFs:SetPoint('LEFT', row, 'LEFT', xDungeons, 0)
    row.dungeonsFs:SetWidth(colDungeonsW)
    row.dungeonsFs:SetJustifyH('LEFT')
    row.jumpsFs = row:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
    row.jumpsFs:SetPoint('LEFT', row, 'LEFT', xJumps, 0)
    row.jumpsFs:SetWidth(colJumpsW)
    row.jumpsFs:SetJustifyH('LEFT')

    row.lvlFs = row:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
    row.lvlFs:SetPoint('LEFT', row, 'LEFT', xLevel, 0)
    row.lvlFs:SetWidth(colLevelW)
    row.lvlFs:SetJustifyH('LEFT')

    row.ultraIcon = row:CreateTexture(nil, 'OVERLAY')
    row.ultraIcon:SetSize(ULTRA_ICON_SIZE, ULTRA_ICON_SIZE)
    row.ultraIcon:SetPoint('LEFT', row, 'LEFT', xUltra + math.floor((colUltraW - ULTRA_ICON_SIZE) / 2), 0)

    row.ultraHit = CreateFrame('Frame', nil, row)
    row.ultraHit:SetSize(colUltraW, ROW_HEIGHT)
    row.ultraHit:SetPoint('LEFT', row, 'LEFT', xUltra, 0)
    row.ultraHit:EnableMouse(true)
    row.ultraHit:SetScript('OnEnter', function(self)
      local tip = self._ultraTip
      if not tip then
        return
      end
      GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
      GameTooltip:SetText(tip, 1, 1, 1)
      GameTooltip:Show()
    end)
    row.ultraHit:SetScript('OnLeave', GameTooltip_Hide)

    rowPool[i] = row
    return row
  end

  local function ultraStatusTooltip(status)
    status = UHC_NormalizeGuildLeaderboardUltraStatus and UHC_NormalizeGuildLeaderboardUltraStatus(status)
      or status
    if status == 'valid' then
      return 'Ultra: Verified'
    end
    if status == 'failed' then
      return 'Ultra: Not verified'
    end
    return 'Ultra: No status received yet'
  end

  function panel:UpdateRows(newRows, newRowTint)
    if UHC_SortGuildLeaderboardInPlace then
      UHC_SortGuildLeaderboardInPlace(newRows)
    end
    local n = #newRows
    local scrollChildHeight = n * ROW_HEIGHT + math.max(0, n - 1) * ROW_GAP
    scrollChild:SetHeight(math.max(scrollChildHeight, 1))

    local tint = newRowTint or rowTint
    for i = 1, n do
      local data = newRows[i]
      local row = ensureRow(i)
      row:Show()
      local isLocal =
        UHC_IsLocalGuildLeaderboardRow and UHC_IsLocalGuildLeaderboardRow(
          data
        ) or (UHC_IsLocalGuildLeaderboardName and UHC_IsLocalGuildLeaderboardName(data.name))
      if isLocal then
        row:SetBackdrop({
          bgFile = 'Interface\\Buttons\\WHITE8x8',
          edgeFile = 'Interface\\Buttons\\WHITE8x8',
          tile = false,
          edgeSize = 1,
          insets = {
            left = 0,
            right = 0,
            top = 0,
            bottom = 0,
          },
        })
        row:SetBackdropColor(0.55, 0.38, 0.14, 1)
        row:SetBackdropBorderColor(1, 0.85, 0.25, 1)
        row.rankFs:SetTextColor(1, 0.95, 0.5)
        if row.ultraIcon then
          row.ultraIcon:SetAlpha(1)
        end
        row.nameFs:SetTextColor(1, 0.95, 0.5)
        row.apFs:SetTextColor(1, 0.92, 0.55)
        row.enemiesFs:SetTextColor(1, 0.92, 0.55)
        row.dungeonsFs:SetTextColor(1, 0.92, 0.55)
        row.jumpsFs:SetTextColor(1, 0.92, 0.55)
        row.lvlFs:SetTextColor(1, 0.92, 0.55)
      else
        row:SetBackdrop({
          bgFile = 'Interface\\Buttons\\WHITE8x8',
          edgeFile = nil,
          tile = false,
          edgeSize = 0,
        })
        row:SetBackdropColor(tint.r, tint.g, tint.b, tint.a)
        row.rankFs:SetTextColor(0.85, 0.85, 0.78)
        if row.ultraIcon then
          row.ultraIcon:SetAlpha(0.95)
        end
        row.nameFs:SetTextColor(0.95, 0.95, 0.9)
        row.apFs:SetTextColor(0.9, 0.88, 0.82)
        row.enemiesFs:SetTextColor(0.9, 0.88, 0.82)
        row.dungeonsFs:SetTextColor(0.9, 0.88, 0.82)
        row.jumpsFs:SetTextColor(0.9, 0.88, 0.82)
        row.lvlFs:SetTextColor(0.9, 0.88, 0.82)
      end
      local displayName =
        UHC_GuildLeaderboardDisplayName and UHC_GuildLeaderboardDisplayName(data.name) or data.name
      local ultraStatus = 'unsure'
      if UHC_GetGuildLeaderboardUltraStatusForRow then
        ultraStatus = UHC_GetGuildLeaderboardUltraStatusForRow(data)
      end
      if row.ultraIcon and UHC_GetGuildLeaderboardUltraTexture then
        row.ultraIcon:SetTexture(UHC_GetGuildLeaderboardUltraTexture(ultraStatus))
        row.ultraIcon:Show()
      end
      if row.ultraHit then
        row.ultraHit._ultraTip = ultraStatusTooltip(ultraStatus)
      end
      row.rankFs:SetText(tostring(i))
      row.nameFs:SetText(displayName)
      row.apFs:SetText(tostring(data.achievementPoints or 0))
      row.enemiesFs:SetText(tostring(data.enemiesSlain or 0))
      row.dungeonsFs:SetText(tostring(data.dungeonsCompleted or 0))
      row.jumpsFs:SetText(tostring(data.playerJumps or 0))
      row.lvlFs:SetText(tostring(data.level))
    end
    for i = n + 1, #rowPool do
      rowPool[i]:Hide()
    end
    syncScrollChildWidth()
  end

  panel:UpdateRows(rows, rowTint)
  return panel
end

local manualRefreshInProgress = false

local function applyGuildRosterSyncFromButton()
  if InCombatLockdown and InCombatLockdown() then return end
  if manualRefreshInProgress then return end
  manualRefreshInProgress = true
  if GuildRoster then
    GuildRoster()
  end
  local function finishRefresh()
    if UHC_MergeGuildRosterIntoLeaderboard then
      UHC_MergeGuildRosterIntoLeaderboard(true)
    end
    if UHC_NotifyGuildLeaderboardDataChanged then
      UHC_NotifyGuildLeaderboardDataChanged()
    end
    manualRefreshInProgress = false
  end
  if C_Timer and C_Timer.After then
    -- One delayed pass gives GuildRoster time to populate without doing multiple expensive full-table rebuilds.
    C_Timer.After(0.3, finishRefresh)
  else
    finishRefresh()
  end
end

function InitializeGuildLeaderboardTab(tabContents, tabIndex, forceRefresh)
  if not tabContents or not tabContents[tabIndex] then return end
  local content = tabContents[tabIndex]
  local container = content.leaderboardMount
  if container and not forceRefresh then return end
  if not container then
    container = CreateFrame('Frame', nil, content)
    content.leaderboardMount = container
  end
  container:ClearAllPoints()
  container:SetPoint('TOPLEFT', content, 'TOPLEFT', PANEL_SIDE_MARGIN, -LEADERBOARD_MOUNT_TOP_INSET)
  container:SetPoint('BOTTOMRIGHT', content, 'BOTTOMRIGHT', -PANEL_SIDE_MARGIN, LEADERBOARD_MOUNT_BOTTOM_INSET)

  local contentW = content:GetWidth()
  if not contentW or contentW < 100 then
    contentW = 348
  end

  local innerW = contentW
  local rows = (UHC_GetSortedGuildLeaderboardCopy and UHC_GetSortedGuildLeaderboardCopy()) or {}
  local championH = 0
  if container.championRoot then
    container.championRoot:Hide()
    container.championRoot:SetParent(nil)
    container.championRoot = nil
  end
  if UHC_CreateGuildChampionSection then
    local championRoot, championHeight = UHC_CreateGuildChampionSection(container, rows, 0)
    container.championRoot = championRoot
    championH = championHeight or 0
  end
  local panelTop = championH > 0 and -(championH + TABLE_LAYOUT_GAP) or 0
  local tableHeight = computeLeaderboardTableHeight(content, championH)

  if not container.syncBar then
    local syncBar = CreateFrame('Frame', nil, container)
    container.syncBar = syncBar
    syncBar:SetHeight(SYNC_BAR_HEIGHT)
    syncBar:SetPoint('BOTTOMLEFT', container, 'BOTTOMLEFT', 0, 0)
    syncBar:SetPoint('BOTTOMRIGHT', container, 'BOTTOMRIGHT', 0, 0)

    local syncBtn = CreateFrame('Button', nil, syncBar)
    container.syncBtn = syncBtn
    syncBtn:SetSize(30, 30)
    syncBtn:SetPoint('BOTTOMRIGHT', syncBar, 'BOTTOMRIGHT', -4, -5)
    local refreshTex = 'Interface\\Buttons\\UI-RefreshButton'
    local combatTex = 'Interface\\Buttons\\UI-GroupLoot-Pass-Up'
    syncBtn:SetNormalTexture(refreshTex)
    syncBtn:SetHighlightTexture('Interface\\Buttons\\ButtonHilight-Square', 'ADD')
    syncBtn:SetPushedTexture(refreshTex)
    syncBtn:SetScript('OnEnter', function(self)
      GameTooltip:SetOwner(self, 'ANCHOR_LEFT')
      GameTooltip:SetText('Refetch guild data', 1, 1, 1)
      GameTooltip:Show()
    end)
    syncBtn:SetScript('OnLeave', GameTooltip_Hide)
    syncBtn:SetScript('OnClick', applyGuildRosterSyncFromButton)
    syncBar.syncBtn = syncBtn

    local function updateSyncBtnCombatState()
      if InCombatLockdown and InCombatLockdown() then
        syncBtn:SetNormalTexture(combatTex)
        syncBtn:SetPushedTexture(combatTex)
        syncBtn:SetDisabledTexture(combatTex)
        syncBtn:Disable()
        syncBtn:SetAlpha(0.75)
      else
        syncBtn:SetNormalTexture(refreshTex)
        syncBtn:SetPushedTexture(refreshTex)
        syncBtn:SetDisabledTexture(refreshTex)
        syncBtn:Enable()
        syncBtn:SetAlpha(1)
      end
    end

    local combatWatcher = CreateFrame('Frame', nil, syncBar)
    combatWatcher:RegisterEvent('PLAYER_REGEN_DISABLED')
    combatWatcher:RegisterEvent('PLAYER_REGEN_ENABLED')
    combatWatcher:SetScript('OnEvent', updateSyncBtnCombatState)
    updateSyncBtnCombatState()

    if InitializeGuildLeaderboardOptions then
      InitializeGuildLeaderboardOptions(syncBar)
    end
  end

  if not container.leaderboardPanel then
    container.leaderboardPanel =
      createLeaderboardPanel(
        container,
        rows,
        getPrimaryRowTint(),
        innerW,
        'FULL',
        panelTop,
        SYNC_BAR_HEIGHT,
        tableHeight
      )
  else
    container.leaderboardPanel:ClearAllPoints()
    container.leaderboardPanel:SetPoint('TOPLEFT', container, 'TOPLEFT', 0, panelTop)
    container.leaderboardPanel:SetPoint('RIGHT', container, 'RIGHT', 0, 0)
    container.leaderboardPanel:SetHeight(tableHeight)
    container.leaderboardPanel:UpdateRows(rows, getPrimaryRowTint())
  end
end

function RefreshGuildLeaderboardTabUI()
  if not TabManagerGetTabContent or not TabManagerGetActiveTab then return end
  if TabManagerGetActiveTab() ~= GUILD_LEADERBOARD_TAB_INDEX then return end
  local c = TabManagerGetTabContent(GUILD_LEADERBOARD_TAB_INDEX)
  if not c then return end
  InitializeGuildLeaderboardTab(
    { [GUILD_LEADERBOARD_TAB_INDEX] = c },
    GUILD_LEADERBOARD_TAB_INDEX,
    true
  )
end
