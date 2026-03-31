-- Global mask and event frame
local targetFrameMask = {}
local targetFrameEventFrame = nil

-- Buff Limits
local maxBuffs = BUFF_MAX_DISPLAY or 32
local maxDebuffs = DEBUFF_MAX_DISPLAY or 16

-- Top-level frames that can be hidden
local HIDEABLE_SUBFRAMES =
  { 'HealthBar', 'ManaBar', 'Name', 'NameBackground', 'HealthBarText', 'ManaBarText', 'Background' }

-- Cache commonly accessed frames
local TargetFrame, TargetFrameTextureFrame, TargetFramePortrait
local TargetFrameToT, TargetFrameToTTextureFrame, TargetFrameToTPortrait
local TargetFrameTextureFrameRaidTargetIcon

-- TBC: Focus frame equivalents
local FocusFrame, FocusFrameTextureFrame, FocusFramePortrait
local FocusFrameToT, FocusFrameToTTextureFrame, FocusFrameToTPortrait
local FocusFrameTextureFrameRaidTargetIcon

local function IsTBCClient()
  return type(IsTBC) == 'function' and IsTBC()
end

-- Update cached frame references
local function UpdateCachedFrames()
  TargetFrame = _G.TargetFrame
  TargetFrameTextureFrame = _G.TargetFrameTextureFrame
  TargetFramePortrait = _G.TargetFramePortrait
  TargetFrameToT = _G.TargetFrameToT
  TargetFrameToTTextureFrame = _G.TargetFrameToTTextureFrame
  TargetFrameToTPortrait = _G.TargetFrameToTPortrait
  TargetFrameTextureFrameRaidTargetIcon = _G.TargetFrameTextureFrameRaidTargetIcon

  if IsTBCClient() then
    FocusFrame = _G.FocusFrame
    FocusFrameTextureFrame = _G.FocusFrameTextureFrame
    -- Focus portrait globals vary by client/build; try a few common names.
    -- FocusFramePortrait = _G.FocusFramePortrait or _G.FocusFrameTextureFramePortrait or _G.FocusFramePortraitFramePortrait
    FocusFrameToT = _G.FocusFrameToT
    FocusFrameToTTextureFrame = _G.FocusFrameToTTextureFrame
    FocusFrameToTPortrait = _G.FocusFrameToTPortrait or _G.FocusFrameToTTextureFramePortrait
    FocusFrameTextureFrameRaidTargetIcon =
      _G.FocusFrameTextureFrameRaidTargetIcon or _G.FocusFrameTextureFrameRaidIcon
  end
end

-- Hide all texture regions inside frame except portrait, raid icon
local function HideTextureRegions(frame)
  if not frame or targetFrameMask.all then return end

  local regions = { frame:GetRegions() }
  for i = 1, #regions do
    local region = regions[i]
    if region and not region:IsProtected() then
      region:SetAlpha(0)
    end
  end
end

-- Hide texture regions but keep specific region objects visible (e.g. portrait/raid icon).
local function HideTextureRegionsExcept(frame, exceptions)
  if not frame or targetFrameMask.all then return end

  local keep = {}
  if type(exceptions) == 'table' then
    for i = 1, #exceptions do
      local obj = exceptions[i]
      if obj then
        keep[obj] = true
      end
    end
  end

  local regions = { frame:GetRegions() }
  for i = 1, #regions do
    local region = regions[i]
    if region and not keep[region] and not region:IsProtected() then
      region:SetAlpha(0)
    end
  end
end

local function GetFocusPortrait()
  -- Focus portrait globals vary by client/build.
  return _G.FocusFramePortrait or _G.FocusFrameTextureFramePortrait or _G.FocusFramePortraitFramePortrait
end

-- Apply alpha to hide subframes
local function HideSubFrames(framePrefix)
  if targetFrameMask.all then return end

  for i = 1, #HIDEABLE_SUBFRAMES do
    local f = _G[framePrefix .. HIDEABLE_SUBFRAMES[i]]
    if f and not f:IsProtected() then
      f:SetAlpha(0)
    end
  end
end

-- Show/hide portrait
local function ApplyPortraitFor(portraitFrame)
  if portraitFrame then
    portraitFrame:SetAlpha(targetFrameMask.portrait and 1 or 0)
  end
end

-- Show PVP icon
local function ApplyPVPIcon()
  if not GLOBAL_SETTINGS.completelyRemoveTargetFrame then
    local pvpIcon = _G.TargetFrameTextureFramePVPIcon
    if pvpIcon then
      pvpIcon:SetAlpha(1)
    end
  end
end

-- Show/hide buffs/debuffs
local function ApplyAuras()
  local showBuffs = targetFrameMask.buffs
  local showDebuffs = targetFrameMask.debuffs

  for i = 1, maxBuffs do
    local buff = _G['TargetFrameBuff' .. i]
    if buff then
      buff:SetAlpha(showBuffs and 1 or 0)
    end
  end

  for i = 1, maxDebuffs do
    local debuff = _G['TargetFrameDebuff' .. i]
    if debuff then
      debuff:SetAlpha(showDebuffs and 1 or 0)
    end
  end
end

-- Position buffs and debuffs
local function PositionAuras()
  local spacing = 5 -- spacing between icons
  local size = 16 -- icon size
  local maxPerRow = 10 -- how many buffs/debuffs before we start a new row - TODO:  make this configurable
  -- Buffs
  local buffRowsUsed = 0

  if targetFrameMask.buffs then
    local shownIndex = 0

    for i = 1, maxBuffs do
      local buff = _G['TargetFrameBuff' .. i]
      if buff and buff:IsShown() then
        shownIndex = shownIndex + 1

        local row = math.floor((shownIndex - 1) / maxPerRow)
        local col = (shownIndex - 1) % maxPerRow

        buff:ClearAllPoints()
        buff:SetPoint(
          'LEFT',
          TargetFramePortrait,
          'RIGHT',
          spacing + col * (size + spacing),
          15 - row * (size + spacing)
        )

        buffRowsUsed = row + 1
      end
    end
  end

  -- Debuffs
  if targetFrameMask.debuffs then
    local shownIndex = 0

    -- debuffs start below the last buff row
    local baseYOffset = 5 - buffRowsUsed * (size + spacing) - spacing

    for i = 1, maxDebuffs do
      local debuff = _G['TargetFrameDebuff' .. i]
      if debuff and debuff:IsShown() then
        shownIndex = shownIndex + 1

        local row = math.floor((shownIndex - 1) / maxPerRow)
        local col = (shownIndex - 1) % maxPerRow

        debuff:ClearAllPoints()
        debuff:SetPoint(
          'LEFT',
          TargetFramePortrait,
          'RIGHT',
          spacing + col * (size + spacing),
          baseYOffset - row * (size + spacing)
        )
      end
    end
  end
end

-- Show/hide raid icon
local function ApplyRaidIconFor(raidIconFrame)
  if raidIconFrame then
    raidIconFrame:SetAlpha(targetFrameMask.raidIcon and 1 or 0)
  end
end

local function ApplyAurasFor(framePrefix, showBuffs, showDebuffs)
  for i = 1, maxBuffs do
    local buff = _G[framePrefix .. 'Buff' .. i]
    if buff then
      buff:SetAlpha(showBuffs and 1 or 0)
    end
  end

  for i = 1, maxDebuffs do
    local debuff = _G[framePrefix .. 'Debuff' .. i]
    if debuff then
      debuff:SetAlpha(showDebuffs and 1 or 0)
    end
  end
end

local function PositionAurasFor(framePrefix, portraitFrame, showBuffs, showDebuffs)
  if not portraitFrame then return end

  local spacing = 5 -- spacing between icons
  local size = 16 -- icon size
  local maxPerRow = 10 -- how many buffs/debuffs before we start a new row - TODO:  make this configurable
  -- Buffs
  local buffRowsUsed = 0
  if showBuffs then
    local shownIndex = 0
    for i = 1, maxBuffs do
      local buff = _G[framePrefix .. 'Buff' .. i]
      if buff and buff:IsShown() then
        shownIndex = shownIndex + 1

        local row = math.floor((shownIndex - 1) / maxPerRow)
        local col = (shownIndex - 1) % maxPerRow

        buff:ClearAllPoints()
        buff:SetPoint(
          'LEFT',
          portraitFrame,
          'RIGHT',
          spacing + col * (size + spacing),
          15 - row * (size + spacing)
        )

        buffRowsUsed = row + 1
      end
    end
  end

  -- Debuffs
  if showDebuffs then
    local shownIndex = 0
    local baseYOffset = 5 - buffRowsUsed * (size + spacing) - spacing

    for i = 1, maxDebuffs do
      local debuff = _G[framePrefix .. 'Debuff' .. i]
      if debuff and debuff:IsShown() then
        shownIndex = shownIndex + 1

        local row = math.floor((shownIndex - 1) / maxPerRow)
        local col = (shownIndex - 1) % maxPerRow

        debuff:ClearAllPoints()
        debuff:SetPoint(
          'LEFT',
          portraitFrame,
          'RIGHT',
          spacing + col * (size + spacing),
          baseYOffset - row * (size + spacing)
        )
      end
    end
  end
end

-- Hide all target of target frames (but keep portrait like target frame)
local function HideTargetOfTargetFrames()
  if targetFrameMask.all then return end

  -- Keep the main TargetFrameToT frame visible (same as target frame)
  if TargetFrameToT then
    TargetFrameToT:SetAlpha(1)
  end

  -- Hide all TargetFrameToT subframes
  HideSubFrames('TargetFrameToT')

  -- Explicitly hide TargetFrameToTBackground
  local totBackground = _G.TargetFrameToTBackground
  if totBackground and not totBackground:IsProtected() then
    totBackground:SetAlpha(0)
  end

  -- Hide health and mana bar backgrounds (semi-transparent black backgrounds)
  local totHealthBar = _G.TargetFrameToTHealthBar
  if totHealthBar then
    HideTextureRegions(totHealthBar)
    local healthBarBg = _G.TargetFrameToTHealthBarBackground
    if healthBarBg and not healthBarBg:IsProtected() then
      healthBarBg:SetAlpha(0)
    end
  end

  local totManaBar = _G.TargetFrameToTManaBar
  if totManaBar then
    HideTextureRegions(totManaBar)
    local manaBarBg = _G.TargetFrameToTManaBarBackground
    if manaBarBg and not manaBarBg:IsProtected() then
      manaBarBg:SetAlpha(0)
    end
  end

  -- Hide texture regions but preserve portrait (same as target frame)
  if TargetFrameToTTextureFrame then
    HideTextureRegions(TargetFrameToTTextureFrame)
    local totTexture = _G.TargetFrameToTTextureFrameTexture
    if totTexture and not totTexture:IsProtected() then
      totTexture:SetAlpha(0)
    end
  end

  -- Show/hide portrait based on mask (same as target frame)
  if TargetFrameToTPortrait then
    ApplyPortraitFor(TargetFrameToTPortrait)
  end
end

local function HideFocusTargetOfTargetFrames()
  if targetFrameMask.all then return end
  if not IsTBCClient() then return end

  if FocusFrameToT then
    FocusFrameToT:SetAlpha(1)
  end

  -- Hide all FocusFrameToT subframes (best-effort; names vary by client/build)
  HideSubFrames('FocusFrameToT')

  local totBackground = _G.FocusFrameToTBackground
  if totBackground and not totBackground:IsProtected() then
    totBackground:SetAlpha(0)
  end

  local totHealthBar = _G.FocusFrameToTHealthBar
  if totHealthBar then
    HideTextureRegions(totHealthBar)
    local healthBarBg = _G.FocusFrameToTHealthBarBackground
    if healthBarBg and not healthBarBg:IsProtected() then
      healthBarBg:SetAlpha(0)
    end
  end

  local totManaBar = _G.FocusFrameToTManaBar
  if totManaBar then
    HideTextureRegions(totManaBar)
    local manaBarBg = _G.FocusFrameToTManaBarBackground
    if manaBarBg and not manaBarBg:IsProtected() then
      manaBarBg:SetAlpha(0)
    end
  end

  if FocusFrameToTTextureFrame then
    -- Only wipe texture regions if we can restore the portrait; some TBC builds
    -- embed the portrait within the texture frame regions.
    if FocusFrameToTPortrait then
      HideTextureRegions(FocusFrameToTTextureFrame)
    end
    local totTexture = _G.FocusFrameToTTextureFrameTexture
    if totTexture and not totTexture:IsProtected() then
      totTexture:SetAlpha(0)
    end
  end

  if FocusFrameToTPortrait then
    ApplyPortraitFor(FocusFrameToTPortrait)
  end
end

-- Apply the full mask (combat-safe with alpha instead of Show/Hide)
local function ApplyMask()
  -- Update cached frames in case they changed
  UpdateCachedFrames()

  if TargetFrame then
    TargetFrame:SetAlpha(1)
  end
  if TargetFrameTextureFrame then
    TargetFrameTextureFrame:SetAlpha(1)
  end

  local function ApplyTargetMask()
    if targetFrameMask.all then
      if TargetFrame then
        TargetFrame:SetAlpha(1)
      end
      if TargetFrameTextureFrame then
        TargetFrameTextureFrame:SetAlpha(1)
      end
      if TargetFrameToT then
        TargetFrameToT:SetAlpha(1)
      end
      return
    end

    if not UnitExists('target') then
      if TargetFrame then
        TargetFrame:SetAlpha(0)
      end
      if TargetFrameTextureFrame then
        TargetFrameTextureFrame:SetAlpha(0)
      end
      if TargetFrameToT then
        TargetFrameToT:SetAlpha(0)
      end
      return
    end

    HideSubFrames('TargetFrame')
    HideTextureRegions(TargetFrameTextureFrame)
    ApplyPVPIcon()
    ApplyPortraitFor(TargetFramePortrait)
    ApplyRaidIconFor(TargetFrameTextureFrameRaidTargetIcon)
    ApplyAuras()
    PositionAuras()
    HideTargetOfTargetFrames()
  end

  local function ApplyFocusMask()
    if not IsTBCClient() or not FocusFrame then return end

    if targetFrameMask.all then
      FocusFrame:SetAlpha(1)
      if FocusFrameTextureFrame then
        FocusFrameTextureFrame:SetAlpha(1)
      end
      if FocusFrameToT then
        FocusFrameToT:SetAlpha(1)
      end
      return
    end

    if not UnitExists('focus') then
      FocusFrame:SetAlpha(0)
      if FocusFrameTextureFrame then
        FocusFrameTextureFrame:SetAlpha(0)
      end
      if FocusFrameToT then
        FocusFrameToT:SetAlpha(0)
      end
      return
    end

    -- Focus exists: keep the main art container visible.
    FocusFrame:SetAlpha(1)
    if FocusFrameTextureFrame then
      FocusFrameTextureFrame:SetAlpha(1)
    end

    -- Best-effort: mirror the same hiding we do for target.
    local focusPortrait = GetFocusPortrait()
    HideSubFrames('FocusFrame')
    -- Hide the focus frame artwork textures but keep the portrait visible.
    if FocusFrameTextureFrame then
      HideTextureRegionsExcept(FocusFrameTextureFrame, {
        focusPortrait,
        FocusFrameTextureFrameRaidTargetIcon,
      })
    end
    ApplyPortraitFor(focusPortrait)
    ApplyRaidIconFor(FocusFrameTextureFrameRaidTargetIcon)
    ApplyAurasFor('FocusFrame', targetFrameMask.buffs, targetFrameMask.debuffs)
    PositionAurasFor('FocusFrame', focusPortrait, targetFrameMask.buffs, targetFrameMask.debuffs)
    HideFocusTargetOfTargetFrames()
  end

  ApplyTargetMask()
  ApplyFocusMask()
end

-- In some clients (notably TBC variants), parts of Blizzard's TargetFrame implementation
-- are not exposed as globals, so hooksecurefunc("TargetFrame_Update") can fail.
-- Prefer hooking when the function exists; otherwise rely on our event-driven ApplyMask.
local function TryHookGlobal(funcName, hookFn)
  if type(funcName) ~= 'string' then
    return false
  end
  if type(_G[funcName]) == 'function' then
    hooksecurefunc(funcName, hookFn)
    return true
  end
  return false
end

local function TryHookMethod(obj, methodName, hookFn)
  if not obj or type(methodName) ~= 'string' then
    return false
  end
  if type(obj[methodName]) == 'function' then
    hooksecurefunc(obj, methodName, hookFn)
    return true
  end
  return false
end

TryHookGlobal('TargetFrame_Update', ApplyMask)
TryHookGlobal('TargetFrame_UpdateAuras', ApplyMask)
TryHookMethod(TargetFrame, 'Update', ApplyMask)
TryHookMethod(TargetFrame, 'UpdateAuras', ApplyMask)

-- TBC: Focus frame hook points (best-effort; functions vary by client/build)
TryHookGlobal('FocusFrame_Update', ApplyMask)
TryHookGlobal('FocusFrame_UpdateAuras', ApplyMask)

-- Hook TargetFrameToT_Update if it exists
if _G.TargetFrameToT_Update then
  hooksecurefunc('TargetFrameToT_Update', ApplyMask)
end

-- Main API
function SetTargetFrameDisplay(mask)
  -- ensure mask is always a table
  if type(mask) ~= 'table' then
    mask = {}
  end
  targetFrameMask = mask

  if not targetFrameEventFrame then
    targetFrameEventFrame = CreateFrame('Frame')
    targetFrameEventFrame:RegisterEvent('PLAYER_TARGET_CHANGED')
    if IsTBCClient() then
      targetFrameEventFrame:RegisterEvent('PLAYER_FOCUS_CHANGED')
    end
    targetFrameEventFrame:RegisterEvent('GROUP_ROSTER_UPDATE')
    -- Keep aura/portrait/raid-icon masking up to date in clients where TargetFrame_Update*
    -- can't be hooked (e.g., functions are local instead of global).
    targetFrameEventFrame:RegisterEvent('UNIT_AURA')
    targetFrameEventFrame:RegisterEvent('UNIT_FACTION')
    targetFrameEventFrame:RegisterEvent('UNIT_PORTRAIT_UPDATE')
    targetFrameEventFrame:RegisterEvent('UNIT_TARGET') -- keeps Target-of-Target state fresh
    targetFrameEventFrame:RegisterEvent('RAID_TARGET_UPDATE')
    targetFrameEventFrame:RegisterEvent('PLAYER_REGEN_DISABLED') -- entering combat
    targetFrameEventFrame:SetScript('OnEvent', function(_, event, unit)
      if event == 'PLAYER_TARGET_CHANGED' or event == 'GROUP_ROSTER_UPDATE' then
        ApplyMask()
      elseif event == 'PLAYER_FOCUS_CHANGED' then
        ApplyMask()
      elseif event == 'UNIT_AURA' or event == 'UNIT_FACTION' or event == 'UNIT_PORTRAIT_UPDATE' or event == 'UNIT_TARGET' then
        if unit == 'target' or unit == 'targettarget' or unit == 'focus' or unit == 'focustarget' then
          ApplyMask()
        end
      elseif event == 'RAID_TARGET_UPDATE' then
        ApplyMask()
      elseif event == 'PLAYER_REGEN_DISABLED' then
        -- Reapply mask immediately when entering combat
        ApplyMask()
        -- Also reapply after a small delay to catch any UI updates
        C_Timer.After(0.1, ApplyMask)
      end
    end)
  end

  -- Update cached frames and apply mask immediately
  UpdateCachedFrames()
  ApplyMask()
end
