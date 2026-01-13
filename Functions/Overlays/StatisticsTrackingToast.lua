-- Statistics Tracking Toast Notifications
-- Shows short-lived notifications when certain statistics are updated.

StatisticsTrackingToast = StatisticsTrackingToast or {}

local TOAST_WIDTH = 260
local TOAST_HEIGHT = 42
local TOAST_MINIMAL_HEIGHT = 24
local TOAST_GAP = 4
local TOAST_LIFETIME_SECONDS = 3
local TOAST_MOVE_SPEED = 18 -- higher = snappier smoothing toward the moving target
local TOAST_DRIFT_PX_PER_SEC = 22 -- continuous downward drift while visible
local TOAST_ANCHOR_X = -400 -- 200px in from the right edge (default, can be overridden by saved position)
local TOAST_ANCHOR_Y = 0
local TOAST_FADE_OUT_SECONDS = 0.35 -- fade out near end of lifetime (no fade-in)
local TOAST_ACHIEVEMENT_DELAY_SECONDS = 0.05 -- small delay so "+X" lays out before tier achievement is inserted
local TOAST_TEXT_PADDING_LEFT = 10
local TOAST_TEXT_PADDING_RIGHT = 10
local TOAST_MIN_WIDTH = 10
local TOAST_MAX_WIDTH = 460
-- NOTE: This must NOT be > 0, otherwise multiple toasts created in the same moment can overlap.
-- (Most toasts are `TOAST_MINIMAL_HEIGHT`, and reducing the push distance causes collisions.)
local TOAST_PUSH_REDUCTION_PX = 1

local STAT_ICON_SIZE = 14

local function GetStatIconMarkup(statKey)
  if type(statKey) ~= 'string' or statKey == '' then
    return ''
  end
  -- Prefer a built-in icon for money stats so we don't require custom textures.
  if statKey == 'goldGained' or statKey == 'goldSpent' then
    local goldIconPath = 'Interface\\MoneyFrame\\UI-GoldIcon'
    return string.format('|T%s:%d:%d:0:0|t', goldIconPath, STAT_ICON_SIZE, STAT_ICON_SIZE)
  end
  -- Icon path convention: Textures/stats-icons/<statKey>.png
  local path = 'Interface\\AddOns\\UltraHardcore\\Textures\\stats-icons\\' .. statKey .. '.png'
  return string.format('|T%s:%d:%d:0:0|t', path, STAT_ICON_SIZE, STAT_ICON_SIZE)
end

local function GetFontStringPixelWidth(fs)
  if not fs then
    return 0
  end
  if fs.GetUnboundedStringWidth then
    return fs:GetUnboundedStringWidth() or 0
  end
  if fs.GetStringWidth then
    return fs:GetStringWidth() or 0
  end
  return 0
end

local function Clamp(n, minV, maxV)
  if n < minV then
    return minV
  end
  if n > maxV then
    return maxV
  end
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

local function ClampInt(n, minV, maxV)
  if n < minV then
    return minV
  end
  if n > maxV then
    return maxV
  end
  return n
end

local function ToHexByte01(x)
  local n = tonumber(x) or 0
  n = math.max(0, math.min(1, n))
  return string.format('%02x', math.floor(n * 255 + 0.5))
end

local function GetTierColorCode(tier)
  local colors = _G.ULTRA_TIER_COLORS
  if type(colors) ~= 'table' or #colors == 0 then
    return 'ffffff'
  end
  local idx = tonumber(tier) or 1
  idx = ClampInt(idx, 1, #colors)
  local c = colors[idx] or { 1, 1, 1, 1 }
  return ToHexByte01(c[1]) .. ToHexByte01(c[2]) .. ToHexByte01(c[3])
end

local function ColorizeTierText(tier, text)
  local hex = GetTierColorCode(tier)
  return '|cff' .. hex .. tostring(text) .. '|r'
end

local function GetTierColorRGB(tier)
  local colors = _G.ULTRA_TIER_COLORS
  if type(colors) ~= 'table' or #colors == 0 then
    return 0.35, 0.35, 0.45
  end
  local idx = tonumber(tier) or 1
  idx = ClampInt(idx, 1, #colors)
  local c = colors[idx] or { 0.35, 0.35, 0.45, 1 }
  return c[1] or 0.35, c[2] or 0.35, c[3] or 0.45
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
  duelsWinPercent = true,
  lagHome = true,
  lagWorld = true,
}

local function formatNumber(n)
  if _G.formatNumberWithCommas then
    return _G.formatNumberWithCommas(n)
  end
  return tostring(n or 0)
end

local function FormatMoneyText(copper)
  copper = tonumber(copper) or 0
  if copper < 0 then
    copper = -copper
  end
  if copper == 0 then
    return '-'
  end
  local g = math.floor(copper / 10000)
  local s = math.floor((copper % 10000) / 100)
  local c = math.floor(copper % 100)

  local parts = {}
  local iconSize = 12
  if g > 0 then
    local goldIcon = string.format('|TInterface\\MoneyFrame\\UI-GoldIcon:%d:%d:0:0|t', iconSize, iconSize)
    table.insert(parts, string.format('%d%s', g, goldIcon))
  end
  if s > 0 then
    local silverIcon = string.format('|TInterface\\MoneyFrame\\UI-SilverIcon:%d:%d:0:0|t', iconSize, iconSize)
    table.insert(parts, string.format('%d%s', s, silverIcon))
  end
  -- Only show copper if it's non-zero.
  if c > 0 then
    local copperIcon = string.format('|TInterface\\MoneyFrame\\UI-CopperIcon:%d:%d:0:0|t', iconSize, iconSize)
    table.insert(parts, string.format('%d%s', c, copperIcon))
  end
  return (#parts > 0) and table.concat(parts, ' ') or '-'
end

local function FormatSignedMoney(delta, forcedSign)
  delta = tonumber(delta) or 0
  local sign
  if forcedSign == '+' or forcedSign == '-' then
    sign = forcedSign
  else
    sign = delta >= 0 and '+' or '-'
  end
  local absText = FormatMoneyText(math.abs(delta))
  if absText == '-' then
    absText = '0'
  end
  return sign .. absText
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

-- Position persistence functions
local function SaveStatisticsTrackingToastPosition()
  local f = StatisticsTrackingToast.frame
  if not f or not UltraHardcoreDB then
    return -- Frame or database not initialized yet, skip saving
  end

  local point, relativeTo, relativePoint, xOfs, yOfs = f:GetPoint()
  -- Always save UIParent as the relativeTo frame to avoid reference issues
  UltraHardcoreDB.statisticsTrackingToastPosition = {
    point = point,
    relativeTo = 'UIParent',
    relativePoint = relativePoint,
    xOfs = xOfs,
    yOfs = yOfs,
  }

  if SaveDBData then
    SaveDBData('statisticsTrackingToastPosition', UltraHardcoreDB.statisticsTrackingToastPosition)
  end
end

local function LoadStatisticsTrackingToastPosition()
  local f = StatisticsTrackingToast.frame
  if not f or not UltraHardcoreDB then
    return -- Frame or database not initialized yet, skip loading
  end

  local pos = UltraHardcoreDB.statisticsTrackingToastPosition
  f:ClearAllPoints()

  -- If no saved position exists, use default position
  if not pos then
    f:SetPoint('TOPRIGHT', UIParent, 'TOPRIGHT', TOAST_ANCHOR_X, TOAST_ANCHOR_Y)
  else
    -- Always anchor to UIParent to avoid frame reference issues
    f:SetPoint(pos.point, UIParent, pos.relativePoint, pos.xOfs, pos.yOfs)
  end
end

-- Reset Statistics Tracking Toast position to default
local function ResetStatisticsTrackingToastPosition()
  -- Clear saved position from database first
  if UltraHardcoreDB then
    UltraHardcoreDB.statisticsTrackingToastPosition = nil
  end

  if SaveDBData then
    SaveDBData('statisticsTrackingToastPosition', nil)
  end

  -- Reset frame position if it exists
  local f = StatisticsTrackingToast.frame
  if f then
    f:ClearAllPoints()
    f:SetPoint('TOPRIGHT', UIParent, 'TOPRIGHT', TOAST_ANCHOR_X, TOAST_ANCHOR_Y)
  end

  print('|cfff44336[ULTRA]|r Statistics Tracking Toast position reset to default.')
end

-- Make ResetStatisticsTrackingToastPosition globally accessible for reset commands
_G.ResetStatisticsTrackingToastPosition = ResetStatisticsTrackingToastPosition

-- Enable repositioning mode - highlights the frame and makes it draggable
function StatisticsTrackingToast:EnableRepositioningMode()
  local f = self.frame
  if not f then
    EnsureFrames()
    f = self.frame
  end
  if not f then return end

  -- Enable dragging
  f._uhcRepositioningMode = true
  f:EnableMouse(true)
  f:RegisterForDrag('LeftButton')
  f:SetScript('OnDragStart', function(self)
    if not self:IsMovable() then return end
    self:StartMoving()
  end)
  f:SetScript('OnDragStop', function(self)
    self:StopMovingOrSizing()
    -- Don't save yet - wait for confirm
  end)

  -- Create or show highlight
  if not f._uhcHighlight then
    local highlight = f:CreateTexture(nil, 'OVERLAY')
    highlight:SetAllPoints(f)
    highlight:SetColorTexture(1, 1, 0, 0.4) -- Yellow highlight
    highlight:SetBlendMode('ADD')
    f._uhcHighlight = highlight

    -- Create border effect using backdrop
    f:SetBackdrop({
      bgFile = 'Interface\\Buttons\\WHITE8X8',
      edgeFile = 'Interface\\Buttons\\WHITE8X8',
      tile = true,
      tileSize = 8,
      edgeSize = 3,
      insets = {
        left = 0,
        right = 0,
        top = 0,
        bottom = 0,
      },
    })
    f:SetBackdropColor(1, 1, 0, 0.2)
    f:SetBackdropBorderColor(1, 1, 0, 1)
  end
  f._uhcHighlight:Show()
  f:SetAlpha(1) -- Make frame fully visible
  -- Create or show confirm button
  if not f._uhcConfirmButton then
    local confirmButton = CreateFrame('Button', nil, f, 'UIPanelButtonTemplate')
    confirmButton:SetSize(80, 25)
    confirmButton:SetPoint('CENTER', f, 'CENTER', 0, 0)
    confirmButton:SetText('Confirm')
    confirmButton:SetFrameStrata('DIALOG')
    confirmButton:SetFrameLevel(f:GetFrameLevel() + 20)
    confirmButton:SetScript('OnClick', function()
      SaveStatisticsTrackingToastPosition()
      StatisticsTrackingToast:DisableRepositioningMode()
      print('|cfff44336[ULTRA]|r Statistics Tracking Toast position saved.')
    end)
    f._uhcConfirmButton = confirmButton
  end
  f._uhcConfirmButton:Show()
end

-- Disable repositioning mode - removes highlight and makes frame non-draggable
function StatisticsTrackingToast:DisableRepositioningMode()
  local f = self.frame
  if not f then return end

  f._uhcRepositioningMode = false
  f:EnableMouse(false)
  f:SetScript('OnDragStart', nil)
  f:SetScript('OnDragStop', nil)

  -- Hide highlight
  if f._uhcHighlight then
    f._uhcHighlight:Hide()
  end

  -- Remove backdrop if it was added
  f:SetBackdrop(nil)

  -- Hide confirm button
  if f._uhcConfirmButton then
    f._uhcConfirmButton:Hide()
  end

  -- Restore frame alpha based on notification state
  if not f._uhcAnimating then
    f:SetAlpha(0.01)
  else
    f:SetAlpha(1)
  end
end

-- Make functions globally accessible
_G.EnableStatisticsTrackingToastRepositioning = function()
  StatisticsTrackingToast:EnableRepositioningMode()
end

_G.DisableStatisticsTrackingToastRepositioning = function()
  StatisticsTrackingToast:DisableRepositioningMode()
end

-- Slash command to reset Statistics Tracking Toast position
SLASH_RESETSTATISTICSTRACKINGTOAST1 = '/resetstatisticstrackingtoast'
SLASH_RESETSTATISTICSTRACKINGTOAST2 = '/rstt'
SlashCmdList['RESETSTATISTICSTRACKINGTOAST'] = ResetStatisticsTrackingToastPosition

local function EnsureFrames()
  if StatisticsTrackingToast.frame then
    -- Allow live repositioning if this file is reloaded / settings change
    LoadStatisticsTrackingToastPosition()
    return
  end

  local f =
    CreateFrame('Frame', 'UltraHardcoreStatisticsTrackingFrame', UIParent, 'BackdropTemplate')
  f:SetSize(TOAST_WIDTH, 30) -- Frame size for notifications
  f:SetFrameStrata('DIALOG')
  f:Show() -- Always show
  f:SetAlpha(0.01) -- Very low alpha (not 0) when no notifications
  f:EnableMouse(false) -- Disabled by default, enabled only in repositioning mode
  StatisticsTrackingToast.frame = f
  StatisticsTrackingToast.toasts = {}

  f._uhcAnimating = false
  f._uhcDriftOffset = 0

  -- Load saved position or use default
  LoadStatisticsTrackingToastPosition()

  -- Frame is not draggable by default - only when repositioning mode is active
  f:SetMovable(true)
  f:EnableMouse(false) -- Disable mouse by default
  f._uhcRepositioningMode = false
  f._uhcHighlight = nil
  f._uhcConfirmButton = nil
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
      -- Keep frame visible but nearly transparent
      self:Show()
      if not self._uhcRepositioningMode then
        self:SetAlpha(0.01) -- Very low alpha (not 0)
        self:EnableMouse(false) -- Only enable mouse if in repositioning mode
      end
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
    if not f._uhcRepositioningMode then
      f:SetAlpha(1)
    end
    f._uhcAnimating = true
  else
    -- Keep frame visible but nearly transparent
    f:Show()
    if not f._uhcRepositioningMode then
      f:SetAlpha(0.01) -- Very low alpha (not 0) so it can receive mouse events if needed
    end
    f._uhcAnimating = false
    f._uhcDriftOffset = 0
    -- Only enable mouse if in repositioning mode
    if not f._uhcRepositioningMode then
      f:EnableMouse(false)
    end
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
    insets = {
      left = 3,
      right = 3,
      top = 3,
      bottom = 3,
    },
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
    if toast then
      toast:Hide()
    end
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

  if EXCLUDED_STATS[statKey] then return end

  -- Check if toast notifications are enabled for this specific stat
  if _G.GLOBAL_SETTINGS.statisticsToastEnabled then
    local toastEnabled = _G.GLOBAL_SETTINGS.statisticsToastEnabled[statKey]
    -- Default to true if not set (all stats enabled by default)
    if toastEnabled == false then
      return -- Toast disabled for this stat
    end
  end

  local displayName = HumanizeStatKey(statKey)

  local minimal = _G.GLOBAL_SETTINGS.minimalStatisticsTracking ~= false
  local tierOnly = _G.GLOBAL_SETTINGS.statisticsTrackingTierOnly or false

  local isPercent = (cfg.type == 'percent')
  local hasTier = not isPercent and not cfg.noTier
  local base = cfg.base or (defCfg and defCfg.base) or nil
  local multiplier = cfg.multiplier or (defCfg and defCfg.multiplier) or nil

  local achievementToast = nil
  local toast = nil
  local achievedTier = nil

  local function pushExistingDownFromIndex(pixels, startIndex)
    if not pixels or pixels <= 0 then return end
    local list = self.toasts or {}
    local start = startIndex or 1
    for i = start, #list do
      local existing = list[i]
      -- Push down any toast we've inserted (even if it's not shown yet),
      -- otherwise back-to-back toasts (tier-up + "+1") can overlap.
      if existing and existing._uhcExpireAt then
        existing._uhcBaseY = (existing._uhcBaseY or 0) + pixels
      end
    end
  end

  local function insertToastAt(newToast, index, baseYOverride)
    newToast._uhcSpawnTime = GetTime()
    newToast._uhcExpireAt = newToast._uhcSpawnTime + TOAST_LIFETIME_SECONDS
    newToast._uhcY = nil
    -- Spawn at the anchor (y=0) in *screen space*; baseY is stored relative to the current drift offset.
    local f = StatisticsTrackingToast.frame
    local drift = (f and f._uhcDriftOffset) or 0
    newToast._uhcBaseY = (baseYOverride ~= nil) and baseYOverride or -drift
    newToast:SetAlpha(1)

    table.insert(self.toasts, index or 1, newToast)
    if #self.toasts > 8 then
      local old = table.remove(self.toasts)
      if old then
        old:Hide()
      end
    end
  end

  local function scheduleHide(t)
    C_Timer.After(TOAST_LIFETIME_SECONDS, function()
      if not t or not t.Hide then return end
      t:Hide()
      ReflowToasts()
    end)
  end

  -- Determine tier upgrade.
  -- IMPORTANT: The achievement toast should reflect the tier you just COMPLETED.
  -- Example: if tier 1 is 0-1000 and hitting 1000 moves you into tier 2,
  -- then the achievement is "Bronze" (tier 1), not "Silver" (tier 2).
  if hasTier and base and base > 0 and multiplier then
    local prevVal = tonumber(oldValue) or 0
    local nextVal = tonumber(newValue) or 0
    local prevTier = select(1, CalculateTierProgress(prevVal, base, multiplier)) or 1
    local nextTier = select(1, CalculateTierProgress(nextVal, base, multiplier)) or 1

    if nextTier > prevTier then
      achievedTier = math.max(1, (tonumber(nextTier) or 1) - 1)
    end
  end

  -- Check for custom messages that should show even in tierOnly mode
  local shouldShowCustomMessage = false
  local customMessage = nil
  if statKey == 'highestCritValue' then
    local newVal = tonumber(newValue) or 0
    local oldVal = tonumber(oldValue) or 0
    if newVal > oldVal then
      customMessage = string.format('New Highest crit value: %s', formatNumber(newVal))
      shouldShowCustomMessage = true
    end
  elseif statKey == 'highestHealCritValue' then
    local newVal = tonumber(newValue) or 0
    local oldVal = tonumber(oldValue) or 0
    if newVal > oldVal then
      customMessage = string.format('New Highest heal crit value: %s', formatNumber(newVal))
      shouldShowCustomMessage = true
    end
  elseif statKey == 'lowestHealth' then
    local newVal = tonumber(newValue) or 100
    local oldVal = tonumber(oldValue) or 100
    -- Show when health gets lower (new value is less than old value)
    if newVal < oldVal then
      customMessage = string.format('New lowest health: %.1f%%', newVal)
      shouldShowCustomMessage = true
    end
  elseif statKey == 'lowestHealthThisLevel' then
    local newVal = tonumber(newValue) or 100
    local oldVal = tonumber(oldValue) or 100
    -- Show when health gets lower (new value is less than old value)
    if newVal < oldVal then
      customMessage = string.format('New lowest health (this level): %.1f%%', newVal)
      shouldShowCustomMessage = true
    end
  elseif statKey == 'lowestHealthThisSession' then
    local newVal = tonumber(newValue) or 100
    local oldVal = tonumber(oldValue) or 100
    -- Show when health gets lower (new value is less than old value)
    if newVal < oldVal then
      customMessage = string.format('New lowest health (this session): %.1f%%', newVal)
      shouldShowCustomMessage = true
    end
  elseif statKey == 'petDeaths' then
    local newVal = tonumber(newValue) or 0
    customMessage = string.format('Your pet has died')
    shouldShowCustomMessage = true
  elseif statKey == 'partyMemberDeaths' then
    local newVal = tonumber(newValue) or 0
    customMessage = string.format('You have witnessed a party member death')
    shouldShowCustomMessage = true
  elseif statKey == 'duelsTotal' then
    local newVal = tonumber(newValue) or 0
    customMessage = string.format('You have dueled %s times', formatNumber(newVal))
    shouldShowCustomMessage = true
  elseif statKey == 'duelsWon' then
    customMessage = string.format('You won a duel')
    shouldShowCustomMessage = true
  elseif statKey == 'duelsLost' then
    customMessage = string.format('You lost a duel')
    shouldShowCustomMessage = true
  elseif statKey == 'mapKeyPressesWhileMapBlocked' then
    customMessage = string.format('The map is blocked by the route planner setting')
    shouldShowCustomMessage = true
  elseif statKey == 'level' then
    local newVal = tonumber(newValue) or 1
    customMessage = string.format('You are now level %s', formatNumber(newVal))
    shouldShowCustomMessage = true
  end

  -- If user wants ONLY tier achievements, skip the regular "+X stat" toast.
  -- But still show custom messages for highest crit values and lowest health stats.
  if tierOnly then
    if shouldShowCustomMessage then
      -- Show custom message even in tierOnly mode
      toast = CreateToast()
      toast.text:SetText(customMessage)
      toast:SetHeight(TOAST_MINIMAL_HEIGHT)
      toast.bar:Hide()
      toast.barBg:Hide()
      toast.barText:Hide()
      ResizeToastToText(toast)

      local pushAmount =
        (toast:GetHeight() or TOAST_MINIMAL_HEIGHT) + TOAST_GAP - TOAST_PUSH_REDUCTION_PX
      local minPush = (toast:GetHeight() or TOAST_MINIMAL_HEIGHT) + TOAST_GAP
      if pushAmount < minPush then
        pushAmount = minPush
      end
      pushExistingDownFromIndex(pushAmount, 1)
      insertToastAt(toast, 1)
      toast:Show()
      ReflowToasts()
      scheduleHide(toast)
      return
    elseif achievedTier then
      achievementToast = CreateToast()
      achievementToast.text:SetText(
        string.format(
          'You achieved %s tier for %s',
          ColorizeTierText(achievedTier, GetTierDisplayName(achievedTier)),
          displayName
        )
      )
      do
        local r, g, b = GetTierColorRGB(achievedTier)
        achievementToast:SetBackdropBorderColor(r, g, b, 0.95)
      end
      achievementToast:SetHeight(TOAST_MINIMAL_HEIGHT)
      achievementToast.bar:Hide()
      achievementToast.barBg:Hide()
      achievementToast.barText:Hide()
      ResizeToastToText(achievementToast)

      local pushAmount =
        (achievementToast:GetHeight() or TOAST_MINIMAL_HEIGHT) + TOAST_GAP - TOAST_PUSH_REDUCTION_PX
      -- Prevent overlap when multiple toasts are inserted simultaneously.
      local minPush = (achievementToast:GetHeight() or TOAST_MINIMAL_HEIGHT) + TOAST_GAP
      if pushAmount < minPush then
        pushAmount = minPush
      end
      pushExistingDownFromIndex(pushAmount, 1)
      insertToastAt(achievementToast, 1)

      achievementToast:Show()
      ReflowToasts()
      scheduleHide(achievementToast)
    end
    return
  end

  toast = CreateToast()

  local deltaText
  if cfg.type == 'money' then
    -- These are cumulative totals that increase, but semantically represent "loss" to the player.
    local forcedSign = nil
    if statKey == 'goldSpent' then
      forcedSign = '-'
    elseif statKey == 'goldGained' then
      forcedSign = '+'
    end
    deltaText = FormatSignedMoney(delta or 0, forcedSign)
  else
    local sign = (delta or 0) >= 0 and '+' or ''
    deltaText = sign .. tostring(delta or 0)
  end
  -- Don't add icon for money stats since FormatSignedMoney already includes gold/silver/copper icons
  local iconMarkup = (cfg.type == 'money') and '' or GetStatIconMarkup(statKey)

  -- Custom messages for specific stats (if not already set above)
  if not customMessage then
    if statKey == 'highestCritValue' then
      -- Only show for increases (new highest)
      local newVal = tonumber(newValue) or 0
      local oldVal = tonumber(oldValue) or 0
      if newVal > oldVal then
        customMessage = string.format('New Highest crit value: %s', formatNumber(newVal))
      else
        -- Don't show toast if value didn't increase
        toast:Hide()
        return
      end
    elseif statKey == 'highestHealCritValue' then
      -- Only show for increases (new highest)
      local newVal = tonumber(newValue) or 0
      local oldVal = tonumber(oldValue) or 0
      if newVal > oldVal then
        customMessage = string.format('New Highest heal crit value: %s', formatNumber(newVal))
      else
        -- Don't show toast if value didn't increase
        toast:Hide()
        return
      end
    elseif statKey == 'lowestHealth' then
      -- Only show when health gets lower (new value is less than old value)
      local newVal = tonumber(newValue) or 100
      local oldVal = tonumber(oldValue) or 100
      if newVal < oldVal then
        customMessage = string.format('New lowest health: %.1f%%', newVal)
      else
        -- Don't show toast if value didn't decrease
        toast:Hide()
        return
      end
    elseif statKey == 'lowestHealthThisLevel' then
      -- Only show when health gets lower (new value is less than old value)
      local newVal = tonumber(newValue) or 100
      local oldVal = tonumber(oldValue) or 100
      if newVal < oldVal then
        customMessage = string.format('New lowest health (this level): %.1f%%', newVal)
      else
        -- Don't show toast if value didn't decrease
        toast:Hide()
        return
      end
    elseif statKey == 'lowestHealthThisSession' then
      -- Only show when health gets lower (new value is less than old value)
      local newVal = tonumber(newValue) or 100
      local oldVal = tonumber(oldValue) or 100
      if newVal < oldVal then
        customMessage = string.format('New lowest health (this session): %.1f%%', newVal)
      else
        -- Don't show toast if value didn't decrease
        toast:Hide()
        return
      end
    elseif statKey == 'petDeaths' then
      local newVal = tonumber(newValue) or 0
      customMessage = string.format('Your pet has died')
    elseif statKey == 'partyMemberDeaths' then
      local newVal = tonumber(newValue) or 0
      customMessage = string.format('You have witnessed a party member death')
    elseif statKey == 'duelsTotal' then
      local newVal = tonumber(newValue) or 0
      customMessage = string.format('You have dueled %s times', formatNumber(newVal))
    elseif statKey == 'duelsWon' then
      customMessage = string.format('You won a duel')
    elseif statKey == 'duelsLost' then
      customMessage = string.format('You lost a duel')
    elseif statKey == 'mapKeyPressesWhileMapBlocked' then
      customMessage = string.format('The map is blocked by the route planner setting')
    elseif statKey == 'level' then
      local newVal = tonumber(newValue) or 1
      customMessage = string.format('You are now level %s', formatNumber(newVal))
    elseif cfg.noTier then
      -- For other noTier stats that don't have custom messages above, show "X updated"
      -- Exclude stats that already have custom messages
      local statsWithCustomMessages = {
        petDeaths = true,
        partyMemberDeaths = true,
        duelsTotal = true,
        duelsWon = true,
        duelsLost = true,
        mapKeyPressesWhileMapBlocked = true,
        level = true,
        highestCritValue = true,
        highestHealCritValue = true,
        lowestHealth = true,
        lowestHealthThisLevel = true,
        lowestHealthThisSession = true,
      }
      if not statsWithCustomMessages[statKey] then
        customMessage = string.format('%s updated', displayName)
      end
    end
  end

  if customMessage then
    toast.text:SetText(customMessage)
  elseif minimal then
    -- Minimal: "+X [icon]" only
    toast.text:SetText(string.format('%s %s', deltaText, iconMarkup))
  else
    -- Non-minimal: "+X [icon] Stat Name"
    toast.text:SetText(
      string.format('%s %s %s', deltaText, iconMarkup, displayName)
    )
  end

  -- Text-only stat update toast (no progress bar). Minimal mode hides the stat name text.
  toast:SetHeight(TOAST_MINIMAL_HEIGHT)
  toast.bar:Hide()
  toast.barBg:Hide()
  toast.barText:Hide()
  ResizeToastToText(toast)

  do
    local pushAmount =
      (toast:GetHeight() or TOAST_MINIMAL_HEIGHT) + TOAST_GAP - TOAST_PUSH_REDUCTION_PX
    -- Prevent overlap when multiple toasts are inserted simultaneously.
    local minPush = (toast:GetHeight() or TOAST_MINIMAL_HEIGHT) + TOAST_GAP
    if pushAmount < minPush then
      pushAmount = minPush
    end
    pushExistingDownFromIndex(pushAmount, 1)
  end
  insertToastAt(toast, 1)

  toast:Show()
  ReflowToasts()
  -- Insert the achievement toast slightly after the "+X" toast so we avoid any same-frame overlap.
  if achievedTier then
    C_Timer.After(TOAST_ACHIEVEMENT_DELAY_SECONDS, function()
      -- The user may have disabled tracking during the delay.
      if not _G.GLOBAL_SETTINGS or not _G.GLOBAL_SETTINGS.showStatisticsTracking then return end

      achievementToast = CreateToast()
      achievementToast.text:SetText(
        string.format(
          'You achieved %s tier for %s',
          ColorizeTierText(achievedTier, GetTierDisplayName(achievedTier)),
          displayName
        )
      )
      do
        local r, g, b = GetTierColorRGB(achievedTier)
        achievementToast:SetBackdropBorderColor(r, g, b, 0.95)
      end
      achievementToast:SetHeight(TOAST_MINIMAL_HEIGHT)
      achievementToast.bar:Hide()
      achievementToast.barBg:Hide()
      achievementToast.barText:Hide()
      ResizeToastToText(achievementToast)

      -- Use full spacing for the achievement toast so it can't overlap the toast below.
      local pushAmount = (achievementToast:GetHeight() or TOAST_MINIMAL_HEIGHT) + TOAST_GAP
      pushExistingDownFromIndex(pushAmount, 1)
      insertToastAt(achievementToast, 1)

      achievementToast:Show()
      ReflowToasts()
      scheduleHide(achievementToast)
    end)
  end

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
  scheduleHide(toast)
end

-- Keep the container hidden if setting is off on login
do
  local gate = CreateFrame('Frame')
  gate:RegisterEvent('PLAYER_LOGIN')
  gate:SetScript('OnEvent', function()
    EnsureFrames()
    -- Load position after database is ready
    LoadStatisticsTrackingToastPosition()
    if not _G.GLOBAL_SETTINGS or not _G.GLOBAL_SETTINGS.showStatisticsTracking then
      StatisticsTrackingToast:ClearAll()
    end
  end)
end
