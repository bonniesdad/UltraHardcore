-- Statistics Tracking Toast Notifications
-- Shows short-lived notifications when certain statistics are updated.

StatisticsTrackingToast = StatisticsTrackingToast or {}

local TOAST_WIDTH = 260
local TOAST_HEIGHT = 42
local TOAST_MINIMAL_HEIGHT = 24
local TOAST_GAP = 4
local TOAST_LIFETIME_SECONDS = 2
local TOAST_MOVE_SPEED = 18 -- higher = snappier smoothing toward the moving target
local TOAST_DRIFT_PX_PER_SEC = 22 -- continuous downward drift while visible
local TOAST_ANCHOR_X = -400 -- 200px in from the right edge
local TOAST_ANCHOR_Y = 0
local TOAST_FADE_OUT_SECONDS = 0.35 -- fade out near end of lifetime (no fade-in)
local TOAST_TEXT_PADDING_LEFT = 10
local TOAST_TEXT_PADDING_RIGHT = 10
local TOAST_MIN_WIDTH = 100
local TOAST_MAX_WIDTH = 460
local TOAST_PUSH_REDUCTION_PX = 20 -- reduce how far existing toasts get pushed down when a new one arrives

local function GetFontStringPixelWidth(fs)
  if not fs then return 0 end
  if fs.GetUnboundedStringWidth then
    return fs:GetUnboundedStringWidth() or 0
  end
  if fs.GetStringWidth then
    return fs:GetStringWidth() or 0
  end
  return 0
end

local function Clamp(n, minV, maxV)
  if n < minV then return minV end
  if n > maxV then return maxV end
  return n
end

local function ResizeToastToText(toast)
  if not toast or not toast.text then return end
  local textW = GetFontStringPixelWidth(toast.text)
  local desired = textW + (TOAST_TEXT_PADDING_LEFT + TOAST_TEXT_PADDING_RIGHT)
  local w = Clamp(desired, TOAST_MIN_WIDTH, TOAST_MAX_WIDTH)
  toast:SetWidth(w)
end

local function HumanizeStatKey(statKey)
  if type(statKey) ~= 'string' then
    return 'Statistic'
  end
  -- Convert camelCase / mixedCase to "Title Case"
  local spaced = statKey:gsub('([a-z])([A-Z])', '%1 %2')
  spaced = spaced:gsub('(%a)(%d)', '%1 %2')
  spaced = spaced:gsub('(%d)(%a)', '%1 %2')
  -- Uppercase first letter
  spaced = spaced:gsub('^%l', string.upper)
  return spaced
end

local function GetStatBarConfig(statKey)
  local cfgTable = _G.ULTRA_STAT_BAR_CONFIG
  if type(cfgTable) ~= 'table' then
    return nil, nil
  end
  local cfg = cfgTable[statKey]
  local def = cfgTable.default
  return cfg, def
end

local function GetTierName(tier)
  local names = _G.ULTRA_TIER_NAMES
  if type(names) == 'table' then
    return names[tier] or names[5] or tostring(tier)
  end
  -- Fallback (should match StatisticsTab.lua)
  local fallback = {
    [1] = 'Bronze',
    [2] = 'Silver',
    [3] = 'Gold',
    [4] = 'Master',
    [5] = 'Demon',
  }
  return fallback[tier] or fallback[5] or tostring(tier)
end

local function GetTierDisplayName(tier)
  local name = GetTierName(tier)
  -- After the named tiers, include the numeric tier so each upgrade is clearly distinct.
  local names = _G.ULTRA_TIER_NAMES
  local maxNamedTier = (type(names) == 'table' and #names) or 5
  if type(tier) == 'number' and tier > maxNamedTier then
    return string.format('%s (Tier %d)', tostring(name), tier)
  end
  return tostring(name)
end

local EXCLUDED_STATS = {
  lowestHealth = true,
  lowestHealthThisLevel = true,
  lowestHealthThisSession = true,
}

local function formatNumber(n)
  if _G.formatNumberWithCommas then
    return _G.formatNumberWithCommas(n)
  end
  return tostring(n or 0)
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

  while currentValue > tierMax do
    tier = tier + 1
    tierMax = tierMax * multiplier
  end

  local tierMin = tier == 1 and 0 or (tierMax / multiplier)
  local range = tierMax - tierMin
  local progress = range > 0 and (currentValue - tierMin) / range or 0

  return tier, tierMin, tierMax, math.min(math.max(progress, 0), 1)
end

local function EnsureFrames()
  if StatisticsTrackingToast.frame then
    -- Allow live repositioning if this file is reloaded / settings change
    StatisticsTrackingToast.frame:ClearAllPoints()
    StatisticsTrackingToast.frame:SetPoint('TOPRIGHT', UIParent, 'TOPRIGHT', TOAST_ANCHOR_X, TOAST_ANCHOR_Y)
    return
  end

  local f = CreateFrame('Frame', 'UltraHardcoreStatisticsTrackingFrame', UIParent, 'BackdropTemplate')
  f:SetSize(TOAST_WIDTH, 10)
  f:SetPoint('TOPRIGHT', UIParent, 'TOPRIGHT', TOAST_ANCHOR_X, TOAST_ANCHOR_Y)
  f:SetFrameStrata('DIALOG')
  f:Hide()

  StatisticsTrackingToast.frame = f
  StatisticsTrackingToast.toasts = {}

  f._uhcAnimating = false
  f._uhcDriftOffset = 0
  f:SetScript('OnUpdate', function(self, elapsed)
    if not self._uhcAnimating then return end

    local now = GetTime()
    -- Drift the whole stack together so spacing stays consistent.
    self._uhcDriftOffset = (self._uhcDriftOffset or 0) + (elapsed * TOAST_DRIFT_PX_PER_SEC)
    local drift = self._uhcDriftOffset or 0

    local anyVisible = false
    for _, toast in ipairs(StatisticsTrackingToast.toasts or {}) do
      if toast and toast:IsShown() and toast._uhcBaseY ~= nil then
        anyVisible = true
        -- Fade out near the end of the toast lifetime
        if toast._uhcExpireAt and TOAST_FADE_OUT_SECONDS and TOAST_FADE_OUT_SECONDS > 0 then
          local remaining = toast._uhcExpireAt - now
          if remaining <= 0 then
            toast:SetAlpha(0)
          elseif remaining < TOAST_FADE_OUT_SECONDS then
            toast:SetAlpha(remaining / TOAST_FADE_OUT_SECONDS)
          else
            toast:SetAlpha(1)
          end
        else
          toast:SetAlpha(1)
        end

        local targetY = (toast._uhcBaseY or 0) + drift

        if toast._uhcY == nil then
          toast._uhcY = targetY
        end

        local dy = targetY - toast._uhcY
        if math.abs(dy) > 0.25 then
          local step = dy * math.min(1, elapsed * TOAST_MOVE_SPEED)
          toast._uhcY = toast._uhcY + step
        else
          toast._uhcY = targetY
        end

        toast:ClearAllPoints()
        toast:SetPoint('TOPRIGHT', self, 'TOPRIGHT', 0, -toast._uhcY)
      end
    end

    if not anyVisible then
      self._uhcAnimating = false
      self._uhcDriftOffset = 0
      self:Hide()
    end
  end)
end

local function ReflowToasts()
  local f = StatisticsTrackingToast.frame
  if not f then return end

  -- Conveyor model: never pull items up when others disappear.
  -- We only need to ensure the container is visible and animating if any toast is visible.
  local anyVisible = false
  for _, toast in ipairs(StatisticsTrackingToast.toasts or {}) do
    if toast and toast:IsShown() then
      anyVisible = true
      break
    end
  end

  if anyVisible then
    f:Show()
    f._uhcAnimating = true
  else
    f:Hide()
    f._uhcAnimating = false
    f._uhcDriftOffset = 0
  end
end

local function CreateToast()
  local parent = StatisticsTrackingToast.frame

  local toast = CreateFrame('Frame', nil, parent, 'BackdropTemplate')
  toast:SetSize(TOAST_WIDTH, TOAST_HEIGHT)
  toast:SetBackdrop({
    bgFile = 'Interface\\Buttons\\WHITE8X8',
    edgeFile = 'Interface\\Tooltips\\UI-Tooltip-Border',
    tile = true,
    tileSize = 8,
    edgeSize = 10,
    insets = { left = 3, right = 3, top = 3, bottom = 3 },
  })
  toast:SetBackdropColor(0.05, 0.05, 0.08, 0.65)
  toast:SetBackdropBorderColor(0.35, 0.35, 0.45, 0.9)

  local text = toast:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
  text:SetPoint('TOPLEFT', toast, 'TOPLEFT', TOAST_TEXT_PADDING_LEFT, -6)
  text:SetPoint('TOPRIGHT', toast, 'TOPRIGHT', -TOAST_TEXT_PADDING_RIGHT, -6)
  text:SetJustifyH('LEFT')
  if text.SetWordWrap then
    text:SetWordWrap(false)
  end
  text:SetText('')
  toast.text = text

  local bar = CreateFrame('StatusBar', nil, toast)
  bar:SetPoint('TOPLEFT', toast, 'TOPLEFT', TOAST_TEXT_PADDING_LEFT, -22)
  bar:SetPoint('TOPRIGHT', toast, 'TOPRIGHT', -TOAST_TEXT_PADDING_RIGHT, -22)
  bar:SetHeight(12)
  bar:SetMinMaxValues(0, 1)
  bar:SetValue(0)
  bar:SetStatusBarTexture('Interface\\TARGETINGFRAME\\UI-StatusBar')
  bar:GetStatusBarTexture():SetHorizTile(false)
  bar:GetStatusBarTexture():SetVertTile(false)
  bar:SetStatusBarColor(0.25, 0.65, 0.9, 0.95)
  toast.bar = bar

  local barBg = toast:CreateTexture(nil, 'BACKGROUND')
  barBg:SetPoint('TOPLEFT', bar, 'TOPLEFT', -1, 1)
  barBg:SetPoint('BOTTOMRIGHT', bar, 'BOTTOMRIGHT', 1, -1)
  barBg:SetColorTexture(0, 0, 0, 0.35)
  toast.barBg = barBg

  local barText = toast:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
  barText:SetPoint('CENTER', bar, 'CENTER', 0, 0)
  barText:SetText('')
  toast.barText = barText

  toast:Hide()
  return toast
end

function StatisticsTrackingToast:ClearAll()
  if not self.toasts then return end
  for _, toast in ipairs(self.toasts) do
    if toast then toast:Hide() end
  end
  ReflowToasts()
end

function StatisticsTrackingToast:NotifyStatDelta(statKey, delta, newValue, oldValue)
  EnsureFrames()

  -- Only show if enabled
  if not _G.GLOBAL_SETTINGS or not _G.GLOBAL_SETTINGS.showStatisticsTracking then
    self:ClearAll()
    return
  end

  local cfg, defCfg = GetStatBarConfig(statKey)
  if not cfg or statKey == 'default' or statKey == 'percent' then
    return -- not tracked in StatisticsTab config
  end

  if EXCLUDED_STATS[statKey] then
    return
  end

  local displayName = HumanizeStatKey(statKey)

  local tierOnly = _G.GLOBAL_SETTINGS.statisticsTrackingTierOnly or false

  local isPercent = (cfg.type == 'percent')
  local hasTier = (not isPercent) and (not cfg.noTier)
  local base = cfg.base or (defCfg and defCfg.base) or nil
  local multiplier = cfg.multiplier or (defCfg and defCfg.multiplier) or nil

  local achievementToast = nil
  local toast = nil

  local function pushExistingDown(pixels)
    if not pixels or pixels <= 0 then return end
    for _, existing in ipairs(self.toasts or {}) do
      if existing and existing:IsShown() then
        existing._uhcBaseY = (existing._uhcBaseY or 0) + pixels
      end
    end
  end

  local function insertToast(newToast)
    newToast._uhcSpawnTime = GetTime()
    newToast._uhcExpireAt = newToast._uhcSpawnTime + TOAST_LIFETIME_SECONDS
    newToast._uhcY = nil
    -- Spawn at the anchor (y=0) in *screen space*; baseY is stored relative to the current drift offset.
    local f = StatisticsTrackingToast.frame
    local drift = (f and f._uhcDriftOffset) or 0
    newToast._uhcBaseY = -drift
    newToast:SetAlpha(1)

    table.insert(self.toasts, 1, newToast) -- newest at top
    if #self.toasts > 8 then
      local old = table.remove(self.toasts)
      if old then old:Hide() end
    end
  end

  local function scheduleHide(t)
    C_Timer.After(TOAST_LIFETIME_SECONDS, function()
      if not t or not t.Hide then return end
      t:Hide()
      ReflowToasts()
    end)
  end

  -- Tier upgrade toast is ALWAYS shown (independent) as long as showStatisticsTracking is enabled.
  if hasTier and base and base > 0 and multiplier then
    local prevVal = tonumber(oldValue) or 0
    local nextVal = tonumber(newValue) or 0
    local prevTier = select(1, CalculateTierProgress(prevVal, base, multiplier)) or 1
    local nextTier = select(1, CalculateTierProgress(nextVal, base, multiplier)) or 1

    if nextTier > prevTier then
      achievementToast = CreateToast()
      achievementToast.text:SetText(
        string.format('You achieved %s tier for %s', GetTierDisplayName(nextTier), displayName)
      )
      achievementToast:SetHeight(TOAST_MINIMAL_HEIGHT)
      achievementToast.bar:Hide()
      achievementToast.barBg:Hide()
      achievementToast.barText:Hide()
      ResizeToastToText(achievementToast)
      local pushAmount =
        (achievementToast:GetHeight() or TOAST_MINIMAL_HEIGHT) + TOAST_GAP - TOAST_PUSH_REDUCTION_PX
      if pushAmount < 0 then
        pushAmount = 0
      end
      pushExistingDown(pushAmount)
      insertToast(achievementToast)
    end
  end

  -- If user wants ONLY tier achievements, skip the regular "+X stat" toast.
  if tierOnly then
    if achievementToast then
      achievementToast:Show()
      ReflowToasts()
      scheduleHide(achievementToast)
    end
    return
  end

  toast = CreateToast()

  local sign = (delta or 0) >= 0 and '+' or ''
  toast.text:SetText(string.format('%s%s %s', sign, tostring(delta or 0), displayName))

  -- Minimal tracking is now the default/only mode: text-only (no progress bar).
  toast:SetHeight(TOAST_MINIMAL_HEIGHT)
  toast.bar:Hide()
  toast.barBg:Hide()
  toast.barText:Hide()
  ResizeToastToText(toast)

  do
    local pushAmount = (toast:GetHeight() or TOAST_MINIMAL_HEIGHT) + TOAST_GAP - TOAST_PUSH_REDUCTION_PX
    if pushAmount < 0 then
      pushAmount = 0
    end
    pushExistingDown(pushAmount)
  end
  insertToast(toast)

  if achievementToast then
    achievementToast:Show()
  end
  toast:Show()
  ReflowToasts()
  -- In some UI states, width metrics may update next frame; refresh once more.
  C_Timer.After(0, function()
    if achievementToast and achievementToast:IsShown() then
      ResizeToastToText(achievementToast)
    end
    if toast and toast:IsShown() then
      ResizeToastToText(toast)
    end
    ReflowToasts()
  end)
  if achievementToast then
    scheduleHide(achievementToast)
  end
  scheduleHide(toast)
end

-- Keep the container hidden if setting is off on login
do
  local gate = CreateFrame('Frame')
  gate:RegisterEvent('PLAYER_LOGIN')
  gate:SetScript('OnEvent', function()
    EnsureFrames()
    if not _G.GLOBAL_SETTINGS or not _G.GLOBAL_SETTINGS.showStatisticsTracking then
      StatisticsTrackingToast:ClearAll()
    end
  end)
end


