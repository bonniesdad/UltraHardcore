-- Per-level XP recording for Verification tab: Lite / Recommended / Extreme preset tiers (Classic Era XP table).
-- Tier XP is cumulative: Recommended only logs if Lite is complete; Extreme only if Lite + Recommended are complete.
-- First login with no stored XP data: backfills from current tier toggles; sets xpVerificationBackfilled on the character save.

UHC_XPVerification = UHC_XPVerification or {}

-- Max XP while *at* player level L (toward L+1), same as UnitXPMax at that level. E.g. level 2 → [2] = 900.
UHC_XPVerification.LEVEL_XP_MAX = {
  [1] = 400,
  [2] = 900,
  [3] = 1400,
  [4] = 2100,
  [5] = 2800,
  [6] = 3600,
  [7] = 4500,
  [8] = 5400,
  [9] = 6500,
  [10] = 7600,
  [11] = 8800,
  [12] = 10100,
  [13] = 11400,
  [14] = 12900,
  [15] = 14400,
  [16] = 16000,
  [17] = 17700,
  [18] = 19400,
  [19] = 21300,
  [20] = 23200,
  [21] = 25200,
  [22] = 27300,
  [23] = 29400,
  [24] = 31700,
  [25] = 34000,
  [26] = 36400,
  [27] = 38900,
  [28] = 41400,
  [29] = 44300,
  [30] = 47400,
  [31] = 50800,
  [32] = 54500,
  [33] = 58600,
  [34] = 62800,
  [35] = 67100,
  [36] = 71600,
  [37] = 76100,
  [38] = 80800,
  [39] = 85700,
  [40] = 90700,
  [41] = 95800,
  [42] = 101000,
  [43] = 106300,
  [44] = 111800,
  [45] = 117500,
  [46] = 123200,
  [47] = 129100,
  [48] = 135100,
  [49] = 141200,
  [50] = 147500,
  [51] = 153900,
  [52] = 160400,
  [53] = 167100,
  [54] = 173900,
  [55] = 180800,
  [56] = 187900,
  [57] = 195000,
  [58] = 202300,
  [59] = 209800,
  [60] = 217400,
}

local TIER_LITE = 1
local TIER_RECOMMENDED = 2
local TIER_EXTREME = 3

local state = {
  lastUnitXP = 0,
  trackedLevel = 0,
  segmentLite = 0,
  segmentRecommended = 0,
  segmentExtreme = 0,
  completed = {},
  --- True if this character's verification XP was seeded from settings (no prior live logging).
  xpVerificationBackfilled = false,
}

local function getGuid()
  return UnitGUID('player')
end

local function dbRoot()
  if not UltraHardcoreDB then
    UltraHardcoreDB = {}
  end
  if not UltraHardcoreDB.xpVerification then
    UltraHardcoreDB.xpVerification = {}
  end
  return UltraHardcoreDB.xpVerification
end

--- Every setting in PRESET_SECTIONS[tierIndex] must be truthy on GLOBAL_SETTINGS.
local function tierAllEnabled(tierIndex)
  if not GLOBAL_SETTINGS then
    return false
  end
  local sections = _G.PRESET_SECTIONS
  if not sections then
    return false
  end
  local sec = sections[tierIndex]
  if not sec or not sec.settings then
    return false
  end
  for _, key in ipairs(sec.settings) do
    local v = GLOBAL_SETTINGS[key]
    if v == nil or v == false then
      return false
    end
  end
  return true
end

--- Lite, Recommended, Extreme stack: XP for tier N is recorded only if tiers 1..N are all fully enabled.
local function tierChainEnabled(upToTierIndex)
  for i = 1, upToTierIndex do
    if not tierAllEnabled(i) then
      return false
    end
  end
  return true
end

local function applyTierXP(amount)
  if amount <= 0 then return end
  if tierChainEnabled(TIER_LITE) then
    state.segmentLite = state.segmentLite + amount
  end
  if tierChainEnabled(TIER_RECOMMENDED) then
    state.segmentRecommended = state.segmentRecommended + amount
  end
  if tierChainEnabled(TIER_EXTREME) then
    state.segmentExtreme = state.segmentExtreme + amount
  end
end

--- At the current tracked level, tier buckets cannot exceed Unit XP toward the next level (guards stale DB / duplicate events).
local function clampSegmentsToUnitXp()
  if state.trackedLevel ~= UnitLevel('player') then return end
  local u = UnitXP('player')
  if not u or u < 0 then return end
  state.segmentLite = math.min(state.segmentLite or 0, u)
  state.segmentRecommended = math.min(state.segmentRecommended or 0, u)
  state.segmentExtreme = math.min(state.segmentExtreme or 0, u)
end

function UHC_XPVerification.IsLiteTierTracking()
  return tierChainEnabled(TIER_LITE)
end

function UHC_XPVerification.IsRecommendedTierTracking()
  return tierChainEnabled(TIER_RECOMMENDED)
end

function UHC_XPVerification.IsExtremeTierTracking()
  return tierChainEnabled(TIER_EXTREME)
end

function UHC_XPVerification.GetTierTrackingFlags()
  return {
    lite = UHC_XPVerification.IsLiteTierTracking(),
    recommended = UHC_XPVerification.IsRecommendedTierTracking(),
    extreme = UHC_XPVerification.IsExtremeTierTracking(),
  }
end

function UHC_XPVerification.GetMaxXpForLevel(level)
  if not level or level < 1 then
    return nil
  end
  local t = UHC_XPVerification.LEVEL_XP_MAX[level]
  if t then
    return t
  end
  if UnitLevel('player') == level then
    local m = UnitXPMax('player')
    if m and m > 0 then
      return m
    end
  end
  return nil
end

local function normalizeCompletedEntry(v)
  if type(v) == 'number' and v >= 0 then
    return {
      lite = v,
      recommended = v,
      extreme = v,
    }
  end
  if type(v) == 'table' then
    return {
      lite = math.max(0, tonumber(v.lite) or 0),
      recommended = math.max(0, tonumber(v.recommended) or 0),
      extreme = math.max(0, tonumber(v.extreme) or 0),
    }
  end
  return nil
end

--- True when this save has never recorded tier XP (no completed levels, no segment totals).
local function shouldBackdateXpVerification(data)
  if data and (data.xpVerificationBackfilled == true or data.backfilledFromSettingsV1 == true) then
    return false
  end
  if data then
    if type(data.completed) == 'table' and next(data.completed) ~= nil then
      return false
    end
    local sl = tonumber(data.segmentLite) or 0
    local sr = tonumber(data.segmentRecommended) or 0
    local se = tonumber(data.segmentExtreme) or 0
    if sl > 0 or sr > 0 or se > 0 then
      return false
    end
    local legacy = tonumber(data.segmentRecorded)
    if legacy and legacy > 0 then
      return false
    end
  end

  -- IMPORTANT: Only backdate when we have evidence the character has already been played.
  -- Otherwise, a brand-new character (level 1, 0 XP, no stats) would be incorrectly labeled "Backdated".
  local function hasPlayedEvidence()
    local pl = UnitLevel('player') or 0
    if pl > 1 then
      return true
    end
    local xp = UnitXP('player') or 0
    if xp > 0 then
      return true
    end
    return false
  end

  return hasPlayedEvidence()
end

--- One-time: assume all past and current XP was earned under today's tier toggles (chain rules).
local function backdateXpVerificationFromCurrentSettings()
  local pl = UnitLevel('player')
  local maxL = GetMaxPlayerLevel and GetMaxPlayerLevel() or 60
  local liteOn = tierChainEnabled(TIER_LITE)
  local recOn = tierChainEnabled(TIER_RECOMMENDED)
  local extOn = tierChainEnabled(TIER_EXTREME)

  state.completed = {}

  for L = 1, math.max(0, pl - 1) do
    local cap = UHC_XPVerification.GetMaxXpForLevel(L)
    if cap and cap > 0 then
      state.completed[L] = {
        lite = liteOn and cap or 0,
        recommended = recOn and cap or 0,
        extreme = extOn and cap or 0,
      }
    end
  end

  if pl < maxL then
    local u = UnitXP('player') or 0
    state.segmentLite = liteOn and u or 0
    state.segmentRecommended = recOn and u or 0
    state.segmentExtreme = extOn and u or 0
    state.trackedLevel = pl
    state.lastUnitXP = u
  else
    state.segmentLite = 0
    state.segmentRecommended = 0
    state.segmentExtreme = 0
    state.trackedLevel = pl
    state.lastUnitXP = 0
  end

  clampSegmentsToUnitXp()
end

function UHC_XPVerification.Save()
  local guid = getGuid()
  if not guid then return end
  local root = dbRoot()
  root[guid] = {
    trackedLevel = state.trackedLevel,
    segmentLite = state.segmentLite,
    segmentRecommended = state.segmentRecommended,
    segmentExtreme = state.segmentExtreme,
    completed = state.completed,
    xpVerificationBackfilled = state.xpVerificationBackfilled and true or nil,
  }
end

function UHC_XPVerification.LoadFromDB()
  local guid = getGuid()
  if not guid then return end
  local root = dbRoot()
  local data = root[guid]
  state.completed = {}
  state.segmentLite = 0
  state.segmentRecommended = 0
  state.segmentExtreme = 0
  state.trackedLevel = 0
  state.xpVerificationBackfilled = false

  if data then
    if type(data.completed) == 'table' then
      for k, v in pairs(data.completed) do
        local nk = tonumber(k)
        local norm = normalizeCompletedEntry(v)
        if nk and norm then
          state.completed[nk] = norm
        end
      end
    end

    state.trackedLevel = tonumber(data.trackedLevel) or 0
    state.xpVerificationBackfilled =
      data.xpVerificationBackfilled == true or data.backfilledFromSettingsV1 == true

    local legacy = tonumber(data.segmentRecorded)
    if data.segmentLite ~= nil or data.segmentRecommended ~= nil or data.segmentExtreme ~= nil then
      state.segmentLite = math.max(0, tonumber(data.segmentLite) or 0)
      state.segmentRecommended = math.max(0, tonumber(data.segmentRecommended) or 0)
      state.segmentExtreme = math.max(0, tonumber(data.segmentExtreme) or 0)
    elseif legacy then
      state.segmentLite = legacy
      state.segmentRecommended = legacy
      state.segmentExtreme = legacy
    end
  end

  if shouldBackdateXpVerification(data) then
    backdateXpVerificationFromCurrentSettings()
    state.xpVerificationBackfilled = true
    UHC_XPVerification.Save()
  end
end

function UHC_XPVerification.WasXpVerificationBackfilled()
  return state.xpVerificationBackfilled == true
end

function UHC_XPVerification.SyncBaseline()
  local pl = UnitLevel('player')
  local xp = UnitXP('player')
  state.lastUnitXP = xp

  if state.trackedLevel == 0 then
    state.trackedLevel = pl
    return
  end

  if state.trackedLevel ~= pl then
    state.segmentLite = 0
    state.segmentRecommended = 0
    state.segmentExtreme = 0
    state.trackedLevel = pl
  end
  clampSegmentsToUnitXp()
end

function UHC_XPVerification.Init()
  UHC_XPVerification.LoadFromDB()
  UHC_XPVerification.SyncBaseline()
end

function UHC_XPVerification.OnEnteringWorld()
  local pl = UnitLevel('player')
  if state.trackedLevel ~= pl then
    UHC_XPVerification.SyncBaseline()
  else
    state.lastUnitXP = UnitXP('player')
    clampSegmentsToUnitXp()
  end
end

function UHC_XPVerification.OnXPUpdate()
  local pl = UnitLevel('player')
  local maxL = GetMaxPlayerLevel and GetMaxPlayerLevel() or 60
  if pl >= maxL then return end

  local now = UnitXP('player')

  if state.trackedLevel == 0 then
    state.trackedLevel = pl
    state.segmentLite = 0
    state.segmentRecommended = 0
    state.segmentExtreme = 0
    state.lastUnitXP = now
    return
  end

  -- Level dropped (unusual): reset to saved baseline
  if pl < state.trackedLevel then
    UHC_XPVerification.SyncBaseline()
    return
  end

  -- Ding: UnitXP resets low while level goes up — delta would be negative and the last chunk would be lost.
  if pl > state.trackedLevel then
    if pl == state.trackedLevel + 1 then
      local cap = UHC_XPVerification.GetMaxXpForLevel(state.trackedLevel)
      if cap and cap > 0 then
        local finish = cap - state.lastUnitXP
        if finish > 0 then
          applyTierXP(finish)
        end
      end
      state.trackedLevel = pl
      state.lastUnitXP = now
    else
      -- Multiple levels in one update (rare): resync to avoid corrupt totals
      UHC_XPVerification.SyncBaseline()
    end
    if RefreshVerificationTabIfVisible then
      RefreshVerificationTabIfVisible()
    end
    return
  end

  local delta = now - state.lastUnitXP
  if delta > 0 then
    applyTierXP(delta)
  end
  state.lastUnitXP = now
  clampSegmentsToUnitXp()
  if RefreshVerificationTabIfVisible then
    RefreshVerificationTabIfVisible()
  end
end

function UHC_XPVerification.OnPlayerLevelUp(newLevel)
  newLevel = tonumber(newLevel) or UnitLevel('player')
  local oldLevel = newLevel - 1
  local oldMax = (oldLevel >= 1) and UHC_XPVerification.GetMaxXpForLevel(oldLevel) or nil
  oldMax = oldMax or 0

  if oldLevel >= 1 then
    local fin = function(seg, tierIdx)
      if tierChainEnabled(tierIdx) then
        return math.max(seg, oldMax)
      end
      return math.max(0, seg)
    end
    state.completed[oldLevel] = {
      lite = fin(state.segmentLite, TIER_LITE),
      recommended = fin(state.segmentRecommended, TIER_RECOMMENDED),
      extreme = fin(state.segmentExtreme, TIER_EXTREME),
    }
  end

  local nowXp = UnitXP('player')
  state.segmentLite = tierChainEnabled(TIER_LITE) and nowXp or 0
  state.segmentRecommended = tierChainEnabled(TIER_RECOMMENDED) and nowXp or 0
  state.segmentExtreme = tierChainEnabled(TIER_EXTREME) and nowXp or 0
  state.trackedLevel = UnitLevel('player')
  state.lastUnitXP = nowXp
  clampSegmentsToUnitXp()
  UHC_XPVerification.Save()
  if RefreshVerificationTabIfVisible then
    RefreshVerificationTabIfVisible()
  end
end

function UHC_XPVerification.GetSnapshot()
  local pl = UnitLevel('player')
  local maxL = GetMaxPlayerLevel and GetMaxPlayerLevel() or 60
  local completed = {}
  for L, t in pairs(state.completed) do
    local n = normalizeCompletedEntry(t)
    if n then
      completed[L] = n
    end
  end

  local current
  if pl >= maxL then
    current = nil
  else
    current = {
      lite = state.segmentLite,
      recommended = state.segmentRecommended,
      extreme = state.segmentExtreme,
    }
  end

  return {
    playerLevel = pl,
    maxPlayerLevel = maxL,
    completed = completed,
    current = current,
    tiersActive = UHC_XPVerification.GetTierTrackingFlags(),
    xpVerificationBackfilled = state.xpVerificationBackfilled == true,
  }
end

--- Party broadcast / UI summary: match aggregation logic in Settings/VerificationTab.lua (RefreshVerificationTab).
local VERIFY_MIX_THRESHOLD = 0.85

local function tierMixNameFromTotals(sumLite, sumRec, sumExt)
  local ref = math.max(sumLite or 0, sumRec or 0, sumExt or 0)
  if ref <= 0 then
    return nil
  end
  local function qualifies(n)
    return (n or 0) / ref >= VERIFY_MIX_THRESHOLD
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

function UHC_XPVerification.GetVerificationVerdictAndSettingLabel()
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

  for L = lastSegLevel, 1, -1 do
    local maxXp = UHC_XPVerification.GetMaxXpForLevel(L)
    if maxXp and maxXp > 0 then
      local isCurrent = (pl < maxPl) and (L == pl)

      if not isCurrent and completed[L] == nil then
        -- No row; does not contribute to graded counts or XP mix totals.
      elseif isCurrent then
        local c = current or {}
        local lx, rx, ex = c.lite or 0, c.recommended or 0, c.extreme or 0
        sumLite = sumLite + lx
        sumRec = sumRec + rx
        sumExt = sumExt + ex
      else
        local t = completed[L]
        local lx, rx, ex = t.lite or 0, t.recommended or 0, t.extreme or 0
        sumLite = sumLite + lx
        sumRec = sumRec + rx
        sumExt = sumExt + ex
        local loggedMax = math.max(lx or 0, rx or 0, ex or 0)
        local ratio = loggedMax / maxXp
        if ratio >= 0.9 then
          pass = pass + 1
        elseif ratio >= 0.7 then
          warn = warn + 1
        else
          fail = fail + 1
        end
      end
    end
  end

  local currentFail, currentWarn = false, false
  if pl < maxPl and current then
    local maxXpCur = UHC_XPVerification.GetMaxXpForLevel(pl)
    if maxXpCur and maxXpCur > 0 then
      local lx, rx, ex = current.lite or 0, current.recommended or 0, current.extreme or 0
      local loggedMax = math.max(lx or 0, rx or 0, ex or 0)
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

  local verdict
  if fail > 0 or currentFail then
    verdict = 'Failed'
  elseif warn > 0 or currentWarn or inconclusive then
    verdict = 'Sceptical'
  else
    verdict = 'Verified'
  end

  local tierLabel = tierMixNameFromTotals(sumLite, sumRec, sumExt)
  if not tierLabel then
    local t = snap.tiersActive or {}
    if t.extreme then
      tierLabel = 'Extreme'
    elseif t.recommended then
      tierLabel = 'Recommended'
    elseif t.lite then
      tierLabel = 'Lite'
    else
      tierLabel = 'None'
    end
  end

  return verdict, tierLabel, snap.tiersActive
end

--- Pipe-delimited payload for SendAddonMessage (stay under 255 bytes).
function UHC_XPVerification.BuildVerificationPartyBroadcastPayload()
  local verdict, tierLabel = UHC_XPVerification.GetVerificationVerdictAndSettingLabel()
  local tiers = UHC_XPVerification.GetTierTrackingFlags()
  local l = tiers.lite and 1 or 0
  local r = tiers.recommended and 1 or 0
  local e = tiers.extreme and 1 or 0
  local b =
    UHC_XPVerification.WasXpVerificationBackfilled and UHC_XPVerification.WasXpVerificationBackfilled() and 1 or 0
  return string.format('1|%s|%s|%d|%d|%d|%d', verdict, tierLabel, l, r, e, b)
end

local eventFrame = CreateFrame('Frame')
eventFrame:RegisterEvent('PLAYER_XP_UPDATE')
eventFrame:RegisterEvent('PLAYER_LEVEL_UP')
eventFrame:RegisterEvent('PLAYER_ENTERING_WORLD')
eventFrame:RegisterEvent('PLAYER_LOGOUT')
eventFrame:SetScript('OnEvent', function(_, event, ...)
  if event == 'PLAYER_XP_UPDATE' then
    UHC_XPVerification.OnXPUpdate()
  elseif event == 'PLAYER_LEVEL_UP' then
    local newLevel = ...
    UHC_XPVerification.OnPlayerLevelUp(newLevel)
  elseif event == 'PLAYER_ENTERING_WORLD' then
    UHC_XPVerification.OnEnteringWorld()
  elseif event == 'PLAYER_LOGOUT' then
    UHC_XPVerification.Save()
  end
end)
