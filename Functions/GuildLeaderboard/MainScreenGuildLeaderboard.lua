-- On-screen ULTRA guild leaderboard: same single roster as settings, globally sorted.

local FRAME_WIDTH = 220
local ROW_H = 18
local ROW_GAP = 2
local VISIBLE_ROWS = 5
-- Asymmetric: 1px tighter on the left so the table sits slightly left (inner width unchanged).
local FRAME_PAD_LEFT = 5
local FRAME_PAD_RIGHT = 5
-- Top 1px tighter than bottom so content sits higher inside the dialog art.
local FRAME_PAD_TOP = 5
local FRAME_PAD_BOTTOM = 5
local BOTTOM_PAD = 5
-- Inset for level header + values from the row right (beyond `rEdge` in layoutRowColumns).
local LVL_PAD_RIGHT = 3

-- Same values as settings tab local-player row (`GuildLeaderboardTab.lua`).
local ROW_HIGHLIGHT_LOCAL = { bg = { r = 0.55, g = 0.38, b = 0.14, a = 1 }, border = { r = 1, g = 0.85, b = 0.25, a = 1 } }

local function getPrimaryRowTint()
  return UHC_GetGuildLeaderboardRowTint()
end

local function setRowBackdropPlain(row)
  row:SetBackdrop({
    bgFile = 'Interface\\Buttons\\WHITE8x8',
    edgeFile = nil,
    tile = false,
    edgeSize = 0,
  })
end

local function setRowBackdropLocalHighlight(row)
  row:SetBackdrop({
    bgFile = 'Interface\\Buttons\\WHITE8x8',
    edgeFile = 'Interface\\Buttons\\WHITE8x8',
    tile = false,
    edgeSize = 1,
    insets = { left = 0, right = 0, top = 0, bottom = 0 },
  })
  row:SetBackdropColor(ROW_HIGHLIGHT_LOCAL.bg.r, ROW_HIGHLIGHT_LOCAL.bg.g, ROW_HIGHLIGHT_LOCAL.bg.b, ROW_HIGHLIGHT_LOCAL.bg.a)
  row:SetBackdropBorderColor(
    ROW_HIGHLIGHT_LOCAL.border.r,
    ROW_HIGHLIGHT_LOCAL.border.g,
    ROW_HIGHLIGHT_LOCAL.border.b,
    ROW_HIGHLIGHT_LOCAL.border.a
  )
end

local function contentWidth(frameW)
  return frameW - FRAME_PAD_LEFT - FRAME_PAD_RIGHT
end

local innerW = contentWidth(FRAME_WIDTH)

-- #, Name, AP, Lvl — packs to width `w`
local function layoutRowColumns(w)
  w = math.max(80, math.floor(w + 0.5))
  local lEdge, rEdge, gapRN = 1, 2, 1
  local colRankW = math.floor(math.min(28, math.max(16, w * 0.10))) + 5
  local xName = lEdge + colRankW + gapRN
  local colLvlW = math.floor(math.min(28, math.max(16, w * 0.10)))
  local mid = w - rEdge - xName - colLvlW - gapRN
  local colApW = math.floor(math.max(36, math.min(80, w * 0.23)))
  local colNameW = mid - colApW
  if colNameW < 22 then
    colNameW = 22
    colApW = math.max(24, mid - colNameW)
  end
  local AP_NAME_DELTA = 30
  colApW = colApW + AP_NAME_DELTA
  colNameW = colNameW - AP_NAME_DELTA
  if colNameW < 22 then
    colNameW = 22
    colApW = math.max(24, mid - colNameW)
  end
  local xAp = xName + colNameW + gapRN
  return colRankW, colNameW, colApW, colLvlW, lEdge, rEdge, xName, xAp
end

local mainFrame = CreateFrame('Frame', 'UHCGuildLeaderboardMainFrame', UIParent, 'BackdropTemplate')
mainFrame:SetSize(FRAME_WIDTH, 279)
mainFrame:SetPoint('TOPLEFT', UIParent, 'TOPLEFT', 360, -10)
mainFrame:SetFrameStrata('LOW')
mainFrame:SetFrameLevel(5)

-- Outer panel fill only (no edge); border is a separate overlay above the table.
mainFrame:SetBackdrop({
  bgFile = 'Interface\\DialogFrame\\UI-DialogBox-Background',
  edgeFile = nil,
  tile = true,
  tileSize = 32,
  edgeSize = 16,
  insets = { left = 6, right = 6, top = 6, bottom = 6 },
})
mainFrame:SetBackdropColor(1, 1, 1, 1)

local TABLE_HEADER_H = 18

local LAYER_BG = 1
local LAYER_TABLE = 3
local LAYER_BORDER = 10

-- Solid fill behind the table (header + rows); sits under them, above the outer panel texture.
local tableContentBg = CreateFrame('Frame', nil, mainFrame, 'BackdropTemplate')
tableContentBg:SetPoint('TOPLEFT', mainFrame, 'TOPLEFT', FRAME_PAD_LEFT, -FRAME_PAD_TOP)
tableContentBg:SetPoint('BOTTOMRIGHT', mainFrame, 'BOTTOMRIGHT', -FRAME_PAD_RIGHT, FRAME_PAD_BOTTOM)
tableContentBg:SetFrameStrata(mainFrame:GetFrameStrata())
tableContentBg:SetFrameLevel(mainFrame:GetFrameLevel() + LAYER_BG)
tableContentBg:EnableMouse(false)
tableContentBg:SetBackdrop({
  bgFile = 'Interface\\Buttons\\WHITE8x8',
  edgeFile = nil,
  tile = false,
  edgeSize = 0,
})
tableContentBg:SetBackdropColor(0.07, 0.06, 0.055, 1)

-- Header inset matches table horizontal inset.
local function buildTableHeader(parent, w)
  local cr, cn, cap, cl, lEdge, rEdge, xName, xAp = layoutRowColumns(w)
  local strip = CreateFrame('Frame', nil, parent, 'BackdropTemplate')
  strip:SetHeight(TABLE_HEADER_H)
  strip:SetPoint('TOPLEFT', parent, 'TOPLEFT', FRAME_PAD_LEFT, -FRAME_PAD_TOP)
  strip:SetPoint('TOPRIGHT', parent, 'TOPRIGHT', -FRAME_PAD_RIGHT, -FRAME_PAD_TOP)
  strip:SetBackdrop({ bgFile = 'Interface\\Buttons\\WHITE8x8', edgeFile = nil, tile = false, edgeSize = 0 })
  strip:SetBackdropColor(0.12, 0.1, 0.08, 0.98)

  local hRank = strip:CreateFontString(nil, 'OVERLAY', 'GameFontNormalSmall')
  hRank:SetPoint('LEFT', strip, 'LEFT', lEdge, 0)
  hRank:SetWidth(cr)
  hRank:SetJustifyH('CENTER')
  hRank:SetText('#')
  hRank:SetTextColor(1, 0.92, 0.62)
  local hName = strip:CreateFontString(nil, 'OVERLAY', 'GameFontNormalSmall')
  hName:SetPoint('LEFT', strip, 'LEFT', xName, 0)
  hName:SetWidth(cn)
  hName:SetJustifyH('LEFT')
  hName:SetText('Name')
  hName:SetTextColor(1, 0.92, 0.62)
  local hAp = strip:CreateFontString(nil, 'OVERLAY', 'GameFontNormalSmall')
  hAp:SetPoint('LEFT', strip, 'LEFT', xAp, 0)
  hAp:SetWidth(cap)
  hAp:SetJustifyH('LEFT')
  hAp:SetText('Points')
  hAp:SetTextColor(1, 0.92, 0.62)
  local hLvl = strip:CreateFontString(nil, 'OVERLAY', 'GameFontNormalSmall')
  hLvl:SetPoint('RIGHT', strip, 'RIGHT', -(rEdge + LVL_PAD_RIGHT), 0)
  hLvl:SetWidth(cl)
  hLvl:SetJustifyH('RIGHT')
  hLvl:SetText('Lvl')
  hLvl:SetTextColor(1, 0.92, 0.62)
  return strip
end

local tableHeader = buildTableHeader(mainFrame, innerW)

local function makeDataRow(parent, w)
  local cr, cn, cap, cl, lEdge, rEdge, xName, xAp = layoutRowColumns(w)
  local row = CreateFrame('Frame', nil, parent, 'BackdropTemplate')
  row:SetHeight(ROW_H)
  setRowBackdropPlain(row)
  row.rankFs = row:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
  row.rankFs:SetPoint('LEFT', row, 'LEFT', lEdge, 0)
  row.rankFs:SetWidth(cr)
  row.rankFs:SetJustifyH('CENTER')
  row.nameFs = row:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
  row.nameFs:SetPoint('LEFT', row, 'LEFT', xName, 0)
  row.nameFs:SetWidth(cn)
  row.nameFs:SetJustifyH('LEFT')
  row.achievementFs = row:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
  row.achievementFs:SetPoint('LEFT', row, 'LEFT', xAp, 0)
  row.achievementFs:SetWidth(cap)
  row.achievementFs:SetJustifyH('LEFT')
  row.lvlFs = row:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
  row.lvlFs:SetPoint('RIGHT', row, 'RIGHT', -(rEdge + LVL_PAD_RIGHT), 0)
  row.lvlFs:SetWidth(cl)
  row.lvlFs:SetJustifyH('RIGHT')
  return row
end

local dataRows = {}
for i = 1, VISIBLE_ROWS do
  dataRows[i] = makeDataRow(mainFrame, innerW)
  if i == 1 then
    dataRows[i]:SetPoint('TOPLEFT', tableHeader, 'BOTTOMLEFT', 0, -ROW_GAP)
    dataRows[i]:SetPoint('TOPRIGHT', tableHeader, 'BOTTOMRIGHT', 0, -ROW_GAP)
  else
    dataRows[i]:SetPoint('TOPLEFT', dataRows[i - 1], 'BOTTOMLEFT', 0, -ROW_GAP)
    dataRows[i]:SetPoint('TOPRIGHT', dataRows[i - 1], 'BOTTOMRIGHT', 0, -ROW_GAP)
  end
end

-- Border only (no visible fill): draws on top of the table so the frame sits over the cells.
local borderOverlay = CreateFrame('Frame', nil, mainFrame, 'BackdropTemplate')
borderOverlay:SetAllPoints()
borderOverlay:SetFrameStrata(mainFrame:GetFrameStrata())
borderOverlay:SetFrameLevel(mainFrame:GetFrameLevel() + LAYER_BORDER)
borderOverlay:EnableMouse(false)
borderOverlay:SetBackdrop({
  bgFile = 'Interface\\Buttons\\WHITE8x8',
  edgeFile = 'Interface\\DialogFrame\\UI-DialogBox-Border',
  tile = true,
  tileSize = 32,
  edgeSize = 16,
  insets = { left = 0, right = 0, top = 0, bottom = 0 },
})
borderOverlay:SetBackdropColor(1, 1, 1, 0)
borderOverlay:SetBackdropBorderColor(0.6, 0.6, 0.6, 0.85)

local baseLevel = mainFrame:GetFrameLevel()
tableHeader:SetFrameLevel(baseLevel + LAYER_TABLE)
for i = 1, VISIBLE_ROWS do
  dataRows[i]:SetFrameLevel(baseLevel + LAYER_TABLE)
end

-- Row tint for the single roster.
local function styleDataRow(row, data, pos)
  if not data then
    row:Hide()
    return
  end
  row:Show()
  local isLocalPlayer = UHC_IsLocalGuildLeaderboardRow and UHC_IsLocalGuildLeaderboardRow(data)
    or UHC_IsLocalGuildLeaderboardName(data.name)
  if isLocalPlayer then
    setRowBackdropLocalHighlight(row)
    row.rankFs:SetTextColor(1, 0.95, 0.5)
    row.nameFs:SetTextColor(1, 0.95, 0.5)
    row.achievementFs:SetTextColor(1, 0.92, 0.55)
    row.lvlFs:SetTextColor(1, 0.92, 0.55)
  else
    local rowTint = getPrimaryRowTint()
    setRowBackdropPlain(row)
    row:SetBackdropColor(rowTint.r, rowTint.g, rowTint.b, rowTint.a)
    row.rankFs:SetTextColor(0.88, 0.82, 1)
    row.nameFs:SetTextColor(0.95, 0.92, 1)
    row.achievementFs:SetTextColor(0.9, 0.86, 0.98)
    row.lvlFs:SetTextColor(0.9, 0.86, 0.98)
  end
  row.rankFs:SetText(tostring(pos))
  local displayName = UHC_GuildLeaderboardDisplayName and UHC_GuildLeaderboardDisplayName(data.name)
    or data.name
  row.nameFs:SetText(displayName)
  row.achievementFs:SetText(tostring(data.achievementPoints or 0))
  row.lvlFs:SetText(tostring(data.level))
end

local function applyMainScreenLeaderboardVisibility()
  if UltraHardcoreDB and UltraHardcoreDB.showOnScreenGuildLeaderboard == false then
    mainFrame:Hide()
  else
    mainFrame:Show()
  end
end

local function refreshMainLeaderboard()
  if UHC_GetMainScreenGuildLeaderboardWindow then
    local window, rankStart = UHC_GetMainScreenGuildLeaderboardWindow(VISIBLE_ROWS)
    for i = 1, VISIBLE_ROWS do
      local data = window[i]
      local pos = data and ((rankStart or 1) + i - 1) or nil
      styleDataRow(dataRows[i], data, pos)
    end
  end

  local topBlock = FRAME_PAD_TOP + TABLE_HEADER_H
  local rowsBlock = VISIBLE_ROWS * (ROW_H + ROW_GAP)
  mainFrame:SetHeight(math.max(109, topBlock + rowsBlock + BOTTOM_PAD - 1))
  applyMainScreenLeaderboardVisibility()
end

local function updateMainLeaderboardCombatInteraction()
  if InCombatLockdown and InCombatLockdown() then
    mainFrame:EnableMouse(false)
  else
    mainFrame:EnableMouse(true)
  end
end

mainFrame:SetMovable(true)
mainFrame:EnableMouse(true)
mainFrame:RegisterForDrag('LeftButton')
mainFrame:SetScript('OnDragStart', function(self)
  self:StartMoving()
end)
mainFrame:SetScript('OnDragStop', function(self)
  self:StopMovingOrSizing()
end)

local mouseDownPos
mainFrame:SetScript('OnMouseDown', function(_, button)
  if button == 'LeftButton' then
    local x, y = GetCursorPosition()
    local s = mainFrame:GetEffectiveScale()
    mouseDownPos = { x = x / s, y = y / s }
  end
end)
mainFrame:SetScript('OnMouseUp', function(_, button)
  if button == 'LeftButton' and mouseDownPos then
    local x, y = GetCursorPosition()
    local s = mainFrame:GetEffectiveScale()
    x, y = x / s, y / s
    local dx = math.abs(x - mouseDownPos.x)
    local dy = math.abs(y - mouseDownPos.y)
    mouseDownPos = nil
    if dx < 4 and dy < 4 and (not InCombatLockdown or not InCombatLockdown()) then
      if OpenSettingsToTab and GUILD_LEADERBOARD_TAB_INDEX then
        OpenSettingsToTab(GUILD_LEADERBOARD_TAB_INDEX)
      elseif _G.ToggleSettings then
        _G.ToggleSettings()
      end
    end
  end
end)
mainFrame:SetScript('OnEnter', function()
  GameTooltip:SetOwner(mainFrame, 'ANCHOR_RIGHT')
  GameTooltip:SetText(
    'Left-click: open ULTRA menu\nDrag: move panel',
    nil,
    nil,
    nil,
    nil,
    true
  )
  GameTooltip:Show()
end)
mainFrame:SetScript('OnLeave', function()
  mouseDownPos = nil
  GameTooltip:Hide()
end)

mainFrame:RegisterEvent('PLAYER_LOGIN')
mainFrame:RegisterEvent('PLAYER_LEVEL_UP')
mainFrame:RegisterEvent('PLAYER_REGEN_DISABLED')
mainFrame:RegisterEvent('PLAYER_REGEN_ENABLED')
mainFrame:SetScript('OnEvent', function(self, event)
  if event == 'PLAYER_LOGIN' or event == 'PLAYER_LEVEL_UP' then
    updateMainLeaderboardCombatInteraction()
    refreshMainLeaderboard()
  elseif event == 'PLAYER_REGEN_DISABLED' or event == 'PLAYER_REGEN_ENABLED' then
    updateMainLeaderboardCombatInteraction()
  end
end)

UHCGuildLeaderboardMainFrame = mainFrame
UHC_RefreshMainScreenGuildLeaderboard = refreshMainLeaderboard
_G.UHC_ApplyMainScreenGuildLeaderboardVisibility = applyMainScreenLeaderboardVisibility

refreshMainLeaderboard()
