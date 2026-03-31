-- XP Verification tab: per-level recorded XP vs expected (Lite / Recommended / Extreme tiers)

local SUMMARY_ICON_SIZE = 72
local SUMMARY_ICON_MARGIN = 8
--- Reserve space on the right so verdict / tier / certainty text does not overlap the icon.
local SUMMARY_TEXT_RIGHT_INSET = SUMMARY_ICON_SIZE + SUMMARY_ICON_MARGIN

local TEX_SKULL_LITE = 'Interface\\AddOns\\UltraHardcore\\Textures\\skull1_100.png'
local TEX_SKULL_RECOMMENDED = 'Interface\\AddOns\\UltraHardcore\\Textures\\skull2_100.png'
local TEX_SKULL_EXTREME = 'Interface\\AddOns\\UltraHardcore\\Textures\\skull3_100.png'
local TEX_SUMMARY_FAILED = 'Interface\\AddOns\\UltraHardcore\\Textures\\bonnie0.png'

local ui = {
  summaryVerdict = nil,
  summaryBackdated = nil,
  summaryTier = nil,
  summaryCertainty = nil,
  summaryIcon = nil,
  summaryFrame = nil,
  rows = {},
  rowsLayoutVer = 0,
  scrollChild = nil,
  verifyScroll = nil,
  lastThrottle = 0,
}

-- Bump when row chrome changes so ensureRows rebuilds (avoid stale frames stuck on old layout).
local ROW_LAYOUT_VER = 4

local ROW_HEIGHT = 40
local BAR_WIDTH_FALLBACK = 280
local BAR_HEIGHT = 18
local BAR_PAD_X = 4
local BAR_PAD_Y = 3
local LEGEND_SWATCH = 11
local MAX_ROWS = 60

--- Desaturate and nudge toward neutral for a softer, pastel-adjacent read.
local function verificationDullRgb(r, g, b)
  local lum = 0.299 * r + 0.587 * g + 0.114 * b
  local desat = 0.42
  r = r + (lum - r) * desat
  g = g + (lum - g) * desat
  b = b + (lum - b) * desat
  local neutral = 0.74
  local wash = 0.1
  r = r * (1 - wash) + neutral * wash
  g = g * (1 - wash) + neutral * wash
  b = b * (1 - wash) + neutral * wash
  return r, g, b
end

local lr, lg, lb = verificationDullRgb(0.2, 0.85, 0.35)
local COLOR_LITE = { lr, lg, lb, 0.95 }
lr, lg, lb = verificationDullRgb(0.96, 0.9, 0.22)
local COLOR_RECOMMENDED = { lr, lg, lb, 0.95 }
lr, lg, lb = verificationDullRgb(0.92, 0.25, 0.22)
local COLOR_EXTREME = { lr, lg, lb, 0.95 }
-- Drift: slightly stronger cyan so it reads on dark bar backgrounds
lr, lg, lb = verificationDullRgb(0.35, 0.75, 1.0)
local COLOR_DRIFT = { lr, lg, lb, 0.95 }

local function maxLogged(L, R, E)
  return math.max(L or 0, R or 0, E or 0)
end

local TIER_MIX_THRESHOLD = 0.85

--- Cumulative tier XP vs max(sumL,sumR,sumE); prefer highest tier (Extreme → Recommended → Lite) that is ≥85%.
local function tierMixName(sumLite, sumRec, sumExt)
  local ref = math.max(sumLite or 0, sumRec or 0, sumExt or 0)
  if ref <= 0 then
    return nil
  end
  local function qualifies(n)
    return (n or 0) / ref >= TIER_MIX_THRESHOLD
  end
  if qualifies(sumExt) then
    return 'Extreme'
  end
  if qualifies(sumRec) then
    return 'Recommended'
  end
  if qualifies(sumLite) then
    return 'Lite'
  end
  return 'Mixed'
end

--- 0–100 score from max(logged tiers) ÷ reference XP; matches row pass (≥90%) / warn (≥70%) bands.
local function levelCertaintyFromLogRatio(ratio)
  ratio = math.max(0, math.min(1, ratio or 0))
  if ratio >= 0.9 then
    return 100
  end
  if ratio >= 0.7 then
    return 70 + (ratio - 0.7) / 0.2 * 30
  end
  if ratio <= 0 then
    return 0
  end
  return ratio / 0.7 * 70
end

local function getSummaryStatusTexture(verdict, mixName)
  if verdict == 'Failed' then
    return TEX_SUMMARY_FAILED
  end
  if mixName == 'Extreme' then
    return TEX_SKULL_EXTREME
  end
  if mixName == 'Recommended' then
    return TEX_SKULL_RECOMMENDED
  end
  if mixName == 'Lite' then
    return TEX_SKULL_LITE
  end
  if mixName == 'Mixed' then
    return TEX_SKULL_RECOMMENDED
  end
  if verdict == 'Sceptical' then
    return TEX_SKULL_RECOMMENDED
  end
  return TEX_SKULL_LITE
end

--- Bar fill length is in-game XP for this level only (UnitXP); never inflate from logged tier totals.
--- Drift (blue) = XP not "covered" by tier buckets: rVis − max(L,R,E) (then tier colours split the remainder).
--- Tier slice uses proportional weights E, (R−E)+, (L−R)+; when L=R=E (all tiers logged the same), the slice is 100% Extreme by design.
local function priorityTierXp(L, R, E, real, maxXp)
  L = tonumber(L) or 0
  R = tonumber(R) or 0
  E = tonumber(E) or 0
  maxXp = tonumber(maxXp) or 0
  local realC = math.max(0, tonumber(real) or 0)
  local rVis = math.min(maxXp, realC)
  if rVis <= 0 or maxXp <= 0 then
    return 0, 0, 0, 0, 0
  end

  local maxLogged = math.max(L, R, E)
  local dXp = math.max(0, rVis - maxLogged)
  local tXp = rVis - dXp

  if tXp <= 0 then
    return 0, 0, 0, dXp, rVis
  end

  local wE = E
  local wR = math.max(0, R - E)
  local wL = math.max(0, L - R)
  local sumW = wE + wR + wL
  if sumW <= 0 then
    return 0, 0, 0, rVis, rVis
  end

  local extXp = tXp * wE / sumW
  local recXp = tXp * wR / sumW
  local liteXp = tXp * wL / sumW
  local driftXp = dXp + math.max(0, tXp - extXp - recXp - liteXp)
  return extXp, recXp, liteXp, driftXp, rVis
end

local function setSegmentTex(tex, w, r, g, b, a)
  if w > 0 then
    tex:SetWidth(w)
    tex:SetColorTexture(r, g, b, a)
    tex:Show()
  else
    tex:SetWidth(0)
    tex:Hide()
  end
end

local function getBarInnerWidth(row)
  local bw = row.barBg and row.barBg:GetWidth() or 0
  if (not bw or bw < 16) and row then
    local rw = row:GetWidth()
    if rw and rw > 20 then
      bw = rw - 10
    end
  end
  if not bw or bw < 24 then
    bw = BAR_WIDTH_FALLBACK
  end
  return math.max(8, math.floor(bw - 2 * BAR_PAD_X + 0.5))
end

--- Fill width follows real in-game XP; left→right: Extreme (red), Recommended (yellow), Lite (green), drift (light blue).
local function setTierBar(row, L, R, E, maxXp, realGame)
  local segH = BAR_HEIGHT - 2 * BAR_PAD_Y
  row.segExt:SetHeight(segH)
  row.segRec:SetHeight(segH)
  row.segLite:SetHeight(segH)
  row.segDrift:SetHeight(segH)

  maxXp = tonumber(maxXp) or 0
  if maxXp <= 0 then
    setSegmentTex(row.segExt, 0, unpack(COLOR_EXTREME))
    setSegmentTex(row.segRec, 0, unpack(COLOR_RECOMMENDED))
    setSegmentTex(row.segLite, 0, unpack(COLOR_LITE))
    setSegmentTex(row.segDrift, 0, unpack(COLOR_DRIFT))
    return
  end
  realGame = tonumber(realGame) or 0
  local inner = getBarInnerWidth(row)
  local extXp, recXp, liteXp, driftXp, r = priorityTierXp(L, R, E, realGame, maxXp)
  local fillW = math.floor(inner * math.min(1, r / maxXp) + 0.5)
  if r > 0 and fillW < 1 then
    fillW = 1
  end
  local wExt, wRec, wLite, wDrift = 0, 0, 0, 0
  if r > 0 and fillW > 0 then
    wExt = math.floor(extXp * fillW / r + 0.5)
    wRec = math.floor(recXp * fillW / r + 0.5)
    wLite = math.floor(liteXp * fillW / r + 0.5)
    wDrift = fillW - wExt - wRec - wLite
    if wDrift < 0 then
      wDrift = 0
    end
  end

  -- Anchor every segment from barBg so hidden zero-width textures do not break the chain (Classic UI quirk).
  local x = BAR_PAD_X
  row.segExt:ClearAllPoints()
  row.segExt:SetPoint('TOPLEFT', row.barBg, 'TOPLEFT', x, -BAR_PAD_Y)
  x = x + wExt
  row.segRec:ClearAllPoints()
  row.segRec:SetPoint('TOPLEFT', row.barBg, 'TOPLEFT', x, -BAR_PAD_Y)
  x = x + wRec
  row.segLite:ClearAllPoints()
  row.segLite:SetPoint('TOPLEFT', row.barBg, 'TOPLEFT', x, -BAR_PAD_Y)
  x = x + wLite
  row.segDrift:ClearAllPoints()
  row.segDrift:SetPoint('TOPLEFT', row.barBg, 'TOPLEFT', x, -BAR_PAD_Y)

  setSegmentTex(row.segExt, wExt, unpack(COLOR_EXTREME))
  setSegmentTex(row.segRec, wRec, unpack(COLOR_RECOMMENDED))
  setSegmentTex(row.segLite, wLite, unpack(COLOR_LITE))
  setSegmentTex(row.segDrift, wDrift, unpack(COLOR_DRIFT))
end

local function syncVerifyScrollChildWidth()
  if ui.verifyScroll and ui.scrollChild then
    local w = ui.verifyScroll:GetWidth()
    if w and w > 48 then
      ui.scrollChild:SetWidth(w)
    end
  end
end

local function setLegendItemTooltip(frame, body)
  frame:SetScript('OnEnter', function(self)
    if GameTooltip and GameTooltip.SetOwner then
      GameTooltip:SetOwner(self, 'ANCHOR_TOPRIGHT')
      GameTooltip:ClearLines()
      GameTooltip:AddLine(body, 1, 1, 1, true)
      GameTooltip:Show()
    end
  end)
  frame:SetScript('OnLeave', function()
    if GameTooltip then
      GameTooltip:Hide()
    end
  end)
end

--- Swatches left→reverse of bar (Unverified/drift … Extreme). Hover for full meaning.
--- Items share the host width in equal columns, each entry centered in its column.
local function buildVerificationLegend(parent)
  local f = CreateFrame('Frame', nil, parent)
  f:SetPoint('TOPLEFT', parent, 'TOPLEFT', 0, 0)
  f:SetPoint('TOPRIGHT', parent, 'TOPRIGHT', 0, 0)
  f:SetHeight(26)

  local items =
    {
      {
        'Unverified',
        COLOR_DRIFT,
        'Drift: in-game XP for this level that is not covered by your highest tier log (max of Lite / Recommended / Extreme). Shown as the cyan segment, usually on the right of the tier colours.',
      },
      { 'Lite', COLOR_LITE, 'Lite preset: XP credited to the Lite tier bucket (green segment).' },
      {
        'Recommended',
        COLOR_RECOMMENDED,
        'Recommended preset: XP credited to the Recommended tier bucket (yellow segment).',
      },
      {
        'Extreme',
        COLOR_EXTREME,
        'Extreme preset: XP credited to the Extreme tier bucket. Shown as the left (red) segment when that slice uses the proportional Extreme share.',
      },
    }

  local hits = {}
  for _, it in ipairs(items) do
    local hit = CreateFrame('Frame', nil, f)
    hit:EnableMouse(true)
    hit:SetHeight(22)

    local sw = hit:CreateTexture(nil, 'ARTWORK')
    sw:SetSize(LEGEND_SWATCH, LEGEND_SWATCH)
    sw:SetPoint('TOPLEFT', hit, 'TOPLEFT', 0, -6)
    sw:SetColorTexture(it[2][1], it[2][2], it[2][3], it[2][4] or 1)

    local lbl = hit:CreateFontString(nil, 'OVERLAY', 'GameFontNormalSmall')
    lbl:SetPoint('LEFT', sw, 'RIGHT', 4, 0)
    lbl:SetPoint('TOP', sw, 'TOP', 0, 1)
    lbl:SetText(it[1])
    do
      local tr, tg, tb = verificationDullRgb(0.88, 0.85, 0.78)
      lbl:SetTextColor(tr, tg, tb, 1)
    end

    local w = LEGEND_SWATCH + 4 + (lbl:GetStringWidth() or 0)
    hit:SetWidth(w)
    setLegendItemTooltip(hit, it[3])
    hits[#hits + 1] = {
      frame = hit,
      width = w,
    }
  end

  local function relayoutLegend()
    local W = f:GetWidth()
    if (not W or W < 32) and parent.GetWidth then
      W = parent:GetWidth()
    end
    if not W or W < 32 then return end
    local n = #hits
    local cellW = W / n
    for i, h in ipairs(hits) do
      local x = (i - 1) * cellW + (cellW - h.width) * 0.5
      h.frame:ClearAllPoints()
      h.frame:SetPoint('TOPLEFT', f, 'TOPLEFT', x, -4)
    end
  end

  f:SetScript('OnSizeChanged', relayoutLegend)
  relayoutLegend()

  return f
end

local function ensureRows(parent)
  if #ui.rows > 0 and ui.rowsLayoutVer == ROW_LAYOUT_VER then return end
  ui.rows = {}
  ui.rowsLayoutVer = ROW_LAYOUT_VER
  for i = 1, MAX_ROWS do
    local row = CreateFrame('Frame', nil, parent)
    row:SetHeight(ROW_HEIGHT)
    row:SetPoint('TOPLEFT', parent, 'TOPLEFT', 0, -((i - 1) * ROW_HEIGHT))
    row:SetPoint('RIGHT', parent, 'RIGHT', 0, 0)

    local title = row:CreateFontString(nil, 'OVERLAY', 'GameFontNormalSmall')
    title:SetPoint('TOPLEFT', row, 'TOPLEFT', 4, -2)
    title:SetPoint('RIGHT', row, 'RIGHT', -6, 0)
    title:SetJustifyH('LEFT')
    title:SetJustifyV('TOP')
    row.title = title

    local barBg = CreateFrame('Frame', nil, row, 'BackdropTemplate')
    barBg:SetHeight(BAR_HEIGHT)
    barBg:SetPoint('TOPLEFT', title, 'BOTTOMLEFT', 0, -4)
    barBg:SetPoint('RIGHT', row, 'RIGHT', -6, 0)
    barBg:SetBackdrop({
      bgFile = 'Interface\\Buttons\\WHITE8x8',
      edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border',
      tile = false,
      edgeSize = 10,
      insets = {
        left = 2,
        right = 2,
        top = 2,
        bottom = 2,
      },
    })
    barBg:SetBackdropColor(0.08, 0.08, 0.09, 0.92)
    barBg:SetBackdropBorderColor(0.38, 0.36, 0.33, 0.82)

    local h = math.max(4, BAR_HEIGHT - 2 * BAR_PAD_Y)
    local segExt = barBg:CreateTexture(nil, 'ARTWORK')
    segExt:SetHeight(h)
    segExt:SetPoint('LEFT', barBg, 'LEFT', 1, 0)

    local segRec = barBg:CreateTexture(nil, 'ARTWORK')
    segRec:SetHeight(h)
    segRec:SetPoint('LEFT', segExt, 'RIGHT', 0, 0)

    local segLite = barBg:CreateTexture(nil, 'ARTWORK')
    segLite:SetHeight(h)
    segLite:SetPoint('LEFT', segRec, 'RIGHT', 0, 0)

    local segDrift = barBg:CreateTexture(nil, 'ARTWORK')
    segDrift:SetHeight(h)
    segDrift:SetPoint('LEFT', segLite, 'RIGHT', 0, 0)

    row.segLite = segLite
    row.segRec = segRec
    row.segExt = segExt
    row.segDrift = segDrift
    row.barBg = barBg
    row:Hide()
    ui.rows[i] = row
  end
end

function RefreshVerificationTab()
  if not ui.scrollChild or not UHC_XPVerification then return end

  syncVerifyScrollChildWidth()

  local snap = UHC_XPVerification.GetSnapshot()
  local pl = snap.playerLevel
  local maxPl = snap.maxPlayerLevel or 60
  local completed = snap.completed
  local current = snap.current

  local lastSegLevel = pl < maxPl and pl or (pl - 1)
  if lastSegLevel < 1 then
    lastSegLevel = 1
  end

  local pass, warn, fail = 0, 0, 0
  local sumLite, sumRec, sumExt = 0, 0, 0
  local certSum, certCount = 0, 0

  ensureRows(ui.scrollChild)

  local rowIdx = 0
  for L = lastSegLevel, 1, -1 do
    local maxXp = UHC_XPVerification.GetMaxXpForLevel(L)
    if maxXp and maxXp > 0 then
      rowIdx = rowIdx + 1
      if rowIdx > MAX_ROWS then
        break
      end

      local row = ui.rows[rowIdx]
      row:Show()
      row.title:SetText(string.format('Level %d', L))

      local isCurrent = (pl < maxPl) and (L == pl)

      if not isCurrent and completed[L] == nil then
        setSegmentTex(row.segLite, 0, unpack(COLOR_LITE))
        setSegmentTex(row.segRec, 0, unpack(COLOR_RECOMMENDED))
        setSegmentTex(row.segExt, 0, unpack(COLOR_EXTREME))
        setSegmentTex(row.segDrift, 0, unpack(COLOR_DRIFT))
      elseif isCurrent then
        local c = current or {}
        local lx, rx, ex = c.lite or 0, c.recommended or 0, c.extreme or 0
        sumLite = sumLite + lx
        sumRec = sumRec + rx
        sumExt = sumExt + ex
        local real = UnitXP('player')
        local loggedMax = maxLogged(lx, rx, ex)
        setTierBar(row, lx, rx, ex, maxXp, real)
        if real > 0 then
          certSum = certSum + levelCertaintyFromLogRatio(loggedMax / real)
          certCount = certCount + 1
        end
      else
        local t = completed[L]
        local lx, rx, ex = t.lite or 0, t.recommended or 0, t.extreme or 0
        sumLite = sumLite + lx
        sumRec = sumRec + rx
        sumExt = sumExt + ex
        local loggedMax = maxLogged(lx, rx, ex)
        local ratio = loggedMax / maxXp
        certSum = certSum + levelCertaintyFromLogRatio(ratio)
        certCount = certCount + 1
        if ratio >= 0.9 then
          pass = pass + 1
        elseif ratio >= 0.7 then
          warn = warn + 1
        else
          fail = fail + 1
        end
        setTierBar(row, lx, rx, ex, maxXp, maxXp)
      end
    end
  end

  for j = rowIdx + 1, MAX_ROWS do
    ui.rows[j]:Hide()
  end

  local totalHeight = math.max(1, rowIdx * ROW_HEIGHT)
  ui.scrollChild:SetHeight(totalHeight)

  local currentFail, currentWarn = false, false
  if pl < maxPl and current then
    local maxXpCur = UHC_XPVerification.GetMaxXpForLevel(pl)
    if maxXpCur and maxXpCur > 0 then
      local lx, rx, ex = current.lite or 0, current.recommended or 0, current.extreme or 0
      local loggedMax = maxLogged(lx, rx, ex)
      local real = UnitXP('player')
      if real > 0 then
        local rratio = loggedMax / real
        if rratio < 0.7 then
          currentFail = true
        elseif rratio < 0.9 then
          currentWarn = true
        end
      end
    end
  end

  local hasGraded = (pass + warn + fail) > 0
  local hasCurrentXp = pl < maxPl and UnitXP('player') > 0
  local inconclusive = not hasGraded and not hasCurrentXp

  local verdict, vr, vg, vb
  if fail > 0 or currentFail then
    verdict = 'Failed'
    vr, vg, vb = 0.92, 0.28, 0.22
  elseif warn > 0 or currentWarn or inconclusive then
    verdict = 'Sceptical'
    vr, vg, vb = 0.95, 0.58, 0.18
  else
    verdict = 'Verified'
    vr, vg, vb = 0.2, 0.85, 0.35
  end

  if ui.summaryVerdict then
    local isBackdated = snap and snap.xpVerificationBackfilled == true
    ui.summaryVerdict:SetText(verdict)
    vr, vg, vb = verificationDullRgb(vr, vg, vb)
    ui.summaryVerdict:SetTextColor(vr, vg, vb, 1)
  end
  if ui.summaryBackdated then
    local isBackdated = snap and snap.xpVerificationBackfilled == true
    if isBackdated then
      ui.summaryBackdated:SetText('(Backdated)')
      ui.summaryBackdated:Show()
    else
      ui.summaryBackdated:SetText('')
      ui.summaryBackdated:Hide()
    end
  end

  local mix = tierMixName(sumLite, sumRec, sumExt)
  if ui.summaryTier then
    if mix then
      ui.summaryTier:SetText(string.format('Setting: %s', mix))
      ui.summaryTier:Show()
    else
      ui.summaryTier:SetText('')
      ui.summaryTier:Hide()
    end
  end

  if ui.summaryCertainty and ui.summaryFrame then
    ui.summaryCertainty:ClearAllPoints()
    ui.summaryCertainty:SetPoint('LEFT', ui.summaryFrame, 'LEFT', 12, 0)
    ui.summaryCertainty:SetPoint('RIGHT', ui.summaryFrame, 'RIGHT', -SUMMARY_TEXT_RIGHT_INSET, 0)
    ui.summaryCertainty:SetJustifyH('LEFT')
    local above, yOfs = ui.summaryVerdict, -8
    if mix and ui.summaryTier then
      above = ui.summaryTier
      yOfs = -6
    end
    ui.summaryCertainty:SetPoint('TOP', above, 'BOTTOM', 0, yOfs)
    if certCount > 0 then
      local pct = certSum / certCount
      ui.summaryCertainty:SetText(string.format('%.0f%% certainty of valid playthrough', pct))
      do
        local xr, xg, xb = verificationDullRgb(0.78, 0.74, 0.68)
        ui.summaryCertainty:SetTextColor(xr, xg, xb, 1)
      end
    else
      ui.summaryCertainty:SetText('Not enough logged XP checks to estimate certainty.')
      do
        local yr, yg, yb = verificationDullRgb(0.62, 0.59, 0.54)
        ui.summaryCertainty:SetTextColor(yr, yg, yb, 1)
      end
    end
    ui.summaryCertainty:Show()
  end

  if ui.summaryIcon then
    ui.summaryIcon:SetTexture(getSummaryStatusTexture(verdict, mix))
    ui.summaryIcon:SetTexCoord(0, 1, 0, 1)
    ui.summaryIcon:Show()
  end
end

function RefreshVerificationTabIfVisible()
  if not _G.UltraHardcoreSettingsFrame or not _G.UltraHardcoreSettingsFrame:IsShown() then return end
  if TabManagerGetActiveTab and TabManagerGetActiveTab() ~= 1 then return end
  local now = GetTime and GetTime() or 0
  if now - (ui.lastThrottle or 0) < 0.12 then return end
  ui.lastThrottle = now
  RefreshVerificationTab()
end

_G.RefreshVerificationTab = RefreshVerificationTab
_G.UpdateLowestHealthDisplay = RefreshVerificationTab

function InitializeVerificationTab(tabContents)
  if not tabContents or not tabContents[1] then return end
  if tabContents[1].initialized then return end
  tabContents[1].initialized = true

  local root = tabContents[1]

  local summary = CreateFrame('Frame', nil, root, 'BackdropTemplate')
  summary:SetPoint('TOP', root, 'TOP', 0, -52)
  summary:SetPoint('LEFT', root, 'LEFT', 8, 0)
  summary:SetPoint('RIGHT', root, 'RIGHT', -8, 0)
  summary:SetHeight(138)
  summary:SetBackdrop({
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
  summary:SetBackdropColor(0.12, 0.11, 0.11, 0.95)
  summary:SetBackdropBorderColor(0.36, 0.35, 0.34, 0.78)
  ui.summaryFrame = summary

  local summaryIcon = summary:CreateTexture(nil, 'ARTWORK')
  summaryIcon:SetSize(SUMMARY_ICON_SIZE, SUMMARY_ICON_SIZE)
  summaryIcon:SetPoint(
    'CENTER',
    summary,
    'RIGHT',
    -(SUMMARY_ICON_SIZE / 2 + SUMMARY_ICON_MARGIN / 2),
    -12
  )
  summaryIcon:SetTexCoord(0, 1, 0, 1)
  summaryIcon:SetTexture(getSummaryStatusTexture('Sceptical', nil))
  ui.summaryIcon = summaryIcon

  local summaryHeading = summary:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
  summaryHeading:SetPoint('TOPLEFT', summary, 'TOPLEFT', 12, -12)
  summaryHeading:SetPoint('RIGHT', summary, 'RIGHT', -SUMMARY_TEXT_RIGHT_INSET, 0)
  summaryHeading:SetText('Verification Status')
  summaryHeading:SetJustifyH('LEFT')
  do
    local hr, hg, hb = verificationDullRgb(0.922, 0.871, 0.761)
    summaryHeading:SetTextColor(hr, hg, hb, 1)
  end
  summaryHeading:SetShadowOffset(1, -1)
  summaryHeading:SetShadowColor(0, 0, 0, 0.75)

  local summaryHeadingRule = summary:CreateTexture(nil, 'ARTWORK')
  summaryHeadingRule:SetColorTexture(0.41, 0.39, 0.36, 0.55)
  summaryHeadingRule:SetPoint('TOPLEFT', summaryHeading, 'BOTTOMLEFT', 0, -5)
  summaryHeadingRule:SetPoint('RIGHT', summary, 'RIGHT', -12, 0)
  summaryHeadingRule:SetHeight(1)

  local verdictStr = summary:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightHuge')
  verdictStr:SetPoint('TOPLEFT', summaryHeadingRule, 'BOTTOMLEFT', 0, -20)
  verdictStr:SetJustifyH('LEFT')
  verdictStr:SetJustifyV('TOP')
  verdictStr:SetText('Sceptical')
  do
    local qur, qug, qub = verificationDullRgb(0.95, 0.58, 0.18)
    verdictStr:SetTextColor(qur, qug, qub, 1)
  end
  verdictStr:SetShadowOffset(1, -1)
  verdictStr:SetShadowColor(0, 0, 0, 0.8)
  ui.summaryVerdict = verdictStr

  local backdatedStr = summary:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  backdatedStr:SetPoint('LEFT', verdictStr, 'RIGHT', 8, -2)
  backdatedStr:SetJustifyH('LEFT')
  backdatedStr:SetJustifyV('TOP')
  do
    local br, bg, bb = verificationDullRgb(0.78, 0.74, 0.68)
    backdatedStr:SetTextColor(br, bg, bb, 1)
  end
  backdatedStr:Hide()
  ui.summaryBackdated = backdatedStr

  local tierStr = summary:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  tierStr:SetPoint('TOPLEFT', verdictStr, 'BOTTOMLEFT', 0, -8)
  tierStr:SetPoint('RIGHT', summary, 'RIGHT', -SUMMARY_TEXT_RIGHT_INSET, 0)
  tierStr:SetJustifyH('LEFT')
  tierStr:SetJustifyV('TOP')
  do
    local tr, tg, tb = verificationDullRgb(0.78, 0.74, 0.68)
    tierStr:SetTextColor(tr, tg, tb, 1)
  end
  tierStr:Hide()
  ui.summaryTier = tierStr

  local certaintyStr = summary:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  certaintyStr:SetPoint('TOPLEFT', tierStr, 'BOTTOMLEFT', 0, -6)
  certaintyStr:SetPoint('RIGHT', summary, 'RIGHT', -SUMMARY_TEXT_RIGHT_INSET, 0)
  certaintyStr:SetJustifyH('LEFT')
  certaintyStr:SetJustifyV('TOP')
  do
    local cr, cg, cb = verificationDullRgb(0.78, 0.74, 0.68)
    certaintyStr:SetTextColor(cr, cg, cb, 1)
  end
  ui.summaryCertainty = certaintyStr

  local summaryDivider = summary:CreateTexture(nil, 'ARTWORK')
  summaryDivider:SetColorTexture(0.41, 0.39, 0.36, 0.55)
  summaryDivider:SetPoint('BOTTOMLEFT', summary, 'BOTTOMLEFT', 10, 2)
  summaryDivider:SetPoint('BOTTOMRIGHT', summary, 'BOTTOMRIGHT', -10, 2)
  summaryDivider:SetHeight(1)

  local desc = root:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  desc:SetPoint('TOP', summary, 'BOTTOM', 0, -17)
  desc:SetPoint('LEFT', root, 'LEFT', 8, 0)
  desc:SetPoint('RIGHT', root, 'RIGHT', -8, 0)
  desc:SetHeight(135)
  desc:SetJustifyH('LEFT')
  desc:SetJustifyV('TOP')
  desc:SetNonSpaceWrap(true)
  do
    local dr, dg, db = verificationDullRgb(0.92, 0.88, 0.81)
    desc:SetTextColor(dr, dg, db, 1)
  end
  desc:SetText(
    '• Verification only reflects time played on this computer.\n\n' .. '• On another PC, copy your WTF folder there before you play so settings still match.\n\n' .. '• Characters played before this feature existed will show full verification marked as "Backdated".\n\n' .. '• To verify at a difficulty, turn on every option for that tier and every easier tier.\n\n' .. "• Certainty may move a little over time - that's normal, not a mistake on your part."
  )

  local breakdownSection = CreateFrame('Frame', nil, root, 'BackdropTemplate')
  breakdownSection:SetPoint('TOP', desc, 'BOTTOM', 0, 0)
  breakdownSection:SetPoint('LEFT', root, 'LEFT', 8, 0)
  breakdownSection:SetPoint('RIGHT', root, 'RIGHT', -8, 0)
  breakdownSection:SetPoint('BOTTOM', root, 'BOTTOM', 0, 18)
  breakdownSection:SetBackdrop({
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
  breakdownSection:SetBackdropColor(0.12, 0.11, 0.11, 0.95)
  breakdownSection:SetBackdropBorderColor(0.36, 0.35, 0.34, 0.78)

  local breakdownBlock = CreateFrame('Frame', nil, breakdownSection)
  breakdownBlock:SetPoint('TOPLEFT', breakdownSection, 'TOPLEFT', 12, -12)
  breakdownBlock:SetPoint('RIGHT', breakdownSection, 'RIGHT', -12, 0)
  breakdownBlock:SetHeight(38)

  local breakdownTitle = breakdownBlock:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
  breakdownTitle:SetPoint('TOPLEFT', breakdownBlock, 'TOPLEFT', 0, 0)
  breakdownTitle:SetText('Lifetime Breakdown')
  breakdownTitle:SetJustifyH('LEFT')
  do
    local br, bg, bb = verificationDullRgb(0.922, 0.871, 0.761)
    breakdownTitle:SetTextColor(br, bg, bb, 1)
  end
  breakdownTitle:SetShadowOffset(1, -1)
  breakdownTitle:SetShadowColor(0, 0, 0, 0.75)

  local breakdownDivider = breakdownBlock:CreateTexture(nil, 'ARTWORK')
  breakdownDivider:SetColorTexture(0.41, 0.39, 0.36, 0.55)
  breakdownDivider:SetPoint('TOPLEFT', breakdownTitle, 'BOTTOMLEFT', 0, -5)
  breakdownDivider:SetPoint('RIGHT', breakdownBlock, 'RIGHT', 0, 0)
  breakdownDivider:SetHeight(1)

  local legendHost = CreateFrame('Frame', nil, breakdownSection)
  legendHost:SetPoint('TOP', breakdownBlock, 'BOTTOM', 0, -5)
  legendHost:SetPoint('LEFT', breakdownSection, 'LEFT', 12, 0)
  legendHost:SetPoint('RIGHT', breakdownSection, 'RIGHT', -12, 0)
  legendHost:SetHeight(28)

  buildVerificationLegend(legendHost)

  local scroll =
    CreateFrame(
      'ScrollFrame',
      'UltraHardcoreVerifyScroll',
      breakdownSection,
      'UIPanelScrollFrameTemplate'
    )
  scroll:SetPoint('TOP', legendHost, 'BOTTOM', 0, -5)
  scroll:SetPoint('LEFT', breakdownSection, 'LEFT', 12, 0)
  scroll:SetPoint('RIGHT', breakdownSection, 'RIGHT', -32, 0)
  scroll:SetPoint('BOTTOM', breakdownSection, 'BOTTOM', 0, 12)

  local scrollChild = CreateFrame('Frame', nil, scroll)
  scrollChild:SetWidth(520)
  scrollChild:SetHeight(400)
  scroll:SetScrollChild(scrollChild)
  ui.scrollChild = scrollChild
  ui.verifyScroll = scroll
  scroll:SetScript('OnSizeChanged', function()
    syncVerifyScrollChildWidth()
    RefreshVerificationTab()
  end)

  tabContents[1]:SetScript('OnShow', function()
    RefreshVerificationTab()
  end)

  RefreshVerificationTab()
end

_G.UpdateXPBreakdown = function() end
