--[[
  Removes health information (and power) from the party frames.
  Compact party frames are not supported yet.
]]

--[[
BUGS:
- On player or raid memeber level up, all health in raid is shown.
- On player or raid member logout, all health in raid is shown.
- On player leave raid, frames become blizzard blocked
- 
]]
PARTY_MEMBER_SUBFRAMES_TO_HIDE =
  {
    'HealthBar',
    'ManaBar',
    'Texture',
    'Background',
    'PartyMemberOverlay',
    'PetFrameBackground',
    'PetFrameTexture',
    'PetFrameHealthBar',
    'PetFrameManaBar',
  }

-- Party frame compatibility (Classic vs TBC+ UI layouts)
-- Classic: global frames like PartyMemberFrame1HealthBar, PartyMemberFrame1Name, etc.
-- TBC+: party frames are children of PartyFrame, e.g. PartyFrame.MemberFrame1 (and children by name)
local function UHC_GetPartyMemberFrame(n)
  local classic = _G['PartyMemberFrame' .. n]
  if classic then
    return classic
  end

  if _G.PartyFrame then
    local modern = _G.PartyFrame['MemberFrame' .. n]
    if modern then
      return modern
    end
  end

  return nil
end

local function UHC_GetPartyMemberSubFrame(n, suffix)
  -- Try classic global naming first
  local classic = _G['PartyMemberFrame' .. n .. suffix]
  if classic then
    return classic
  end

  local member = UHC_GetPartyMemberFrame(n)
  if not member then
    return nil
  end

  -- Try "memberFrameName + suffix" pattern (works when children are still globally named)
  if member.GetName then
    local name = member:GetName()
    if name then
      local byName = _G[name .. suffix]
      if byName then
        return byName
      end
    end
  end

  -- Try direct field access (varies by client)
  local direct = member[suffix] or member[string.lower(suffix)]
  if direct then
    return direct
  end

  -- Common mappings (defensive)
  if suffix == 'HealthBar' then
    return member.healthBar or member.HealthBar
  end
  if suffix == 'ManaBar' then
    return member.manaBar or member.powerBar or member.ManaBar or member.PowerBar
  end
  if suffix == 'Name' then
    return member.name or member.Name
  end

  return nil
end

-- Fix for PartyMemberHealthCheck error when health bars are reparented
-- Blizzard's PartyMemberHealthCheck tries to access fields on the health bar's parent,
-- but when we reparent to UltraHiddenParent, those fields don't exist.
-- We hook the health bar's OnValueChanged to temporarily restore the parent.
local partyHealthBarsHooked = {}
local function HookPartyHealthBarValueChanged()
  for i = 1, 5 do
    local healthBar = UHC_GetPartyMemberSubFrame(i, 'HealthBar')
    if healthBar and healthBar.GetScript and not partyHealthBarsHooked[i] then
      local originalOnValueChanged = healthBar:GetScript('OnValueChanged')
      if originalOnValueChanged then
        partyHealthBarsHooked[i] = true
        healthBar:SetScript('OnValueChanged', function(self, value)
          -- If this health bar has been reparented to UltraHiddenParent,
          -- temporarily restore the original parent before calling Blizzard's code
          local originalParent = nil
          local needsRestore = false
          local ultraHiddenParent = _G['UltraHiddenParent']
          local inCombat = InCombatLockdown()

          if self and self.GetParent and self._UltraOriginalParent then
            local currentParent = self:GetParent()
            if currentParent == ultraHiddenParent then
              originalParent = self._UltraOriginalParent
              -- Temporarily restore parent for Blizzard's code (only if not in combat)
              if originalParent and not inCombat then
                self:SetParent(originalParent)
                needsRestore = true
              end
            end
          end

          -- Call the original OnValueChanged handler
          -- Wrap in pcall to catch any errors from PartyMemberHealthCheck
          local success, err = pcall(originalOnValueChanged, self, value)

          -- Restore parent to UltraHiddenParent if we changed it
          if needsRestore and self and self.SetParent and ultraHiddenParent and not inCombat then
            self:SetParent(ultraHiddenParent)
            self:Hide()
          end

          -- If there was an error and we couldn't restore the parent (combat),
          -- the error is expected - the health bar is hidden anyway
          if not success and not needsRestore then
            -- Error occurred but we couldn't fix it (likely in combat)
            -- This is expected behavior when health bars are hidden
          end
        end)
      end
    end
  end
end

-- Try to hook party health bars when frames are available
local function TryHookPartyHealthBars()
  -- Check if at least one party frame exists
  if UHC_GetPartyMemberSubFrame(1, 'HealthBar') then
    HookPartyHealthBarValueChanged()
    return true
  end
  return false
end

function SetPartyFramesInfo(hideGroupHealth)
  if hideGroupHealth then
    for n = 1, 5 do
      SetPartyFrameInfo(n)
    end
  end
end

function SetPartyFrameInfo(n)
  -- Check if we're in combat lockdown before modifying frames
  if InCombatLockdown() then
    -- Defer frame modifications until combat ends
    C_Timer.After(0.1, function()
      if not InCombatLockdown() then
        SetPartyFrameInfo(n)
      end
    end)
    return
  end

  -- Hook health bar value changed handlers to fix PartyMemberHealthCheck errors
  TryHookPartyHealthBars()

  for _, subFrame in ipairs(PARTY_MEMBER_SUBFRAMES_TO_HIDE) do
    HidePartySubFrame(n, subFrame)

    -- Move Name subframe down a few pixels to be centered with the portrait
    local nameFrame = UHC_GetPartyMemberSubFrame(n, 'Name')

    if nameFrame and nameFrame.SetPoint and nameFrame.ClearAllPoints then
      nameFrame:ClearAllPoints()
      nameFrame:SetPoint('BOTTOMLEFT', 55, 25)
    end
  end

  -- Move the entire party frame to the right by 100px and stack vertically
  local partyFrame = UHC_GetPartyMemberFrame(n)
  if partyFrame and partyFrame.SetPoint and partyFrame.ClearAllPoints then
    -- Clear any existing anchor points to prevent anchor family connection errors
    partyFrame:ClearAllPoints()

    -- Position each party frame vertically below the previous one
    local verticalOffset = -120 - ((n - 1) * 60) -- 60px spacing between frames
    partyFrame:SetPoint('TOPLEFT', UIParent, 'TOPLEFT', 80, verticalOffset)

    -- Set party frame to highest tooltip level (above 1000)
    if partyFrame.SetFrameLevel then
      partyFrame:SetFrameLevel(1500)
    end
  end

  -- Reposition target highlights to match the moved party frame
  if RepositionAllPartyTargetHighlights then
    RepositionAllPartyTargetHighlights()
  end

  -- TODO move buffs/debuffs up
end

function HidePartySubFrame(n, subFrame)
  local frame = UHC_GetPartyMemberSubFrame(n, subFrame)
  if frame then
    ForceHideFrame(frame)
  end
end

-- Cosmetic suppression helpers (avoid taint by leaving Show() intact)
local function UHC_SetElementSuppressed(frame, suppress)
  if not frame then return end

  local function getAlphaSafe(f)
    if not f or not f.GetAlpha then
      return nil
    end
    local ok, alpha = pcall(f.GetAlpha, f)
    if ok then
      return alpha
    end
    return nil
  end

  if suppress then
    if frame.uhcOriginalAlpha == nil then
      frame.uhcOriginalAlpha = getAlphaSafe(frame) or 1
    end
    if frame.SetAlpha then
      frame:SetAlpha(0)
    end
  else
    local restoreAlpha = frame.uhcOriginalAlpha
    if restoreAlpha == nil then
      restoreAlpha = getAlphaSafe(frame) or 1
    end
    if frame.SetAlpha then
      frame:SetAlpha(restoreAlpha)
    end
    frame.uhcOriginalAlpha = nil
  end

  if frame.GetObjectType and frame:GetObjectType() == 'StatusBar' and frame.GetStatusBarTexture then
    local tex = frame:GetStatusBarTexture()
    if tex then
      UHC_SetElementSuppressed(tex, suppress)
    end
  end
end

local OFFLINE_LABEL = PLAYER_OFFLINE or OFFLINE or 'Offline'
local function UHC_UpdateRaidOfflineStatus(frame)
  if not frame or not frame.statusText then return end
  local statusText = frame.statusText
  local unit = frame.displayedUnit or frame.unit
  local isOffline = false

  if unit and type(UnitIsConnected) == 'function' then
    local ok, connected = pcall(UnitIsConnected, unit)
    if ok and connected == false then
      isOffline = true
    end
  end

  if isOffline then
    if statusText.ClearAllPoints and statusText.SetPoint then
      statusText:ClearAllPoints()
      statusText:SetPoint('CENTER', frame.uhcCircle or frame, 'CENTER', 0, -2)
    end
    local ok, font, size, flags = pcall(statusText.GetFont, statusText)
    if ok and font and statusText.SetFont then
      statusText:SetFont(font, math.max(10, size or 10), flags)
    end
    if statusText.SetTextColor then
      statusText:SetTextColor(0.9, 0.35, 0.35, 1)
    end
    if statusText.SetText then
      statusText:SetText(OFFLINE_LABEL)
    end
    UHC_SetElementSuppressed(statusText, false)
  else
    if statusText.SetText then
      statusText:SetText('')
    end
    UHC_SetElementSuppressed(statusText, true)
  end
end

-- Compact group frame compatibility:
-- Some clients/builds (notably TBC variants and "compact party frames") expose the visible compact
-- unit frames as CompactPartyFrameMember{n} instead of CompactRaidFrame{n}.
local function UHC_GetCompactGroupFramePrefix()
  -- Prefer actual raid frames when they exist (prevents breaking raid mode if both exist)
  if _G['CompactRaidFrame1'] then
    return 'CompactRaidFrame'
  end

  if type(IsTBC) == 'function' and IsTBC() then
    if _G['CompactPartyFrameMember1'] then
      return 'CompactPartyFrameMember'
    end
  end

  if _G['CompactPartyFrameMember1'] then
    return 'CompactPartyFrameMember'
  end

  return 'CompactRaidFrame'
end

local function UHC_GetCompactGroupFrame(i)
  local prefix = UHC_GetCompactGroupFramePrefix()
  return _G[prefix .. i], prefix
end

-- Raid (Compact) Frames: Hide only the health bar so the name remains visible
local function HideRaidHealthBar(i)
  local frame, prefix = UHC_GetCompactGroupFrame(i)
  if frame then
    -- Hide all health-related elements defensively
    local elements =
      {
        frame.healthBar,
        frame.healthBarBackground,
        frame.myHealPredictionBar,
        frame.otherHealPredictionBar,
        frame.totalAbsorbBar,
        frame.totalAbsorbBarOverlay,
        frame.overAbsorbGlow,
        frame.overHealAbsorbGlow,
        frame.healAbsorbBar,
      }
    for _, elem in ipairs(elements) do
      UHC_SetElementSuppressed(elem, true)
    end
    if frame.statusText then
      UHC_UpdateRaidOfflineStatus(frame)
    end
  else
    -- Fallback to global-named health bar if direct frame not available
    local usePrefix = prefix or UHC_GetCompactGroupFramePrefix()
    local healthBar = _G[usePrefix .. i .. 'HealthBar']
    if healthBar then
      UHC_SetElementSuppressed(healthBar, true)
    end
    local healthText = _G[usePrefix .. i .. 'HealthBarText']
    if healthText then
      UHC_SetElementSuppressed(healthText, true)
    end
  end
end

local function ShowRaidHealthBar(i)
  local frame, prefix = UHC_GetCompactGroupFrame(i)
  if frame then
    local elements =
      {
        frame.healthBar,
        frame.healthBarBackground,
        frame.myHealPredictionBar,
        frame.otherHealPredictionBar,
        frame.totalAbsorbBar,
        frame.totalAbsorbBarOverlay,
        frame.overAbsorbGlow,
        frame.overHealAbsorbGlow,
        frame.healAbsorbBar,
      }
    for _, elem in ipairs(elements) do
      UHC_SetElementSuppressed(elem, false)
    end
    if frame.statusText then
      UHC_SetElementSuppressed(frame.statusText, false)
    end
  else
    local usePrefix = prefix or UHC_GetCompactGroupFramePrefix()
    local healthBar = _G[usePrefix .. i .. 'HealthBar']
    if healthBar then
      UHC_SetElementSuppressed(healthBar, false)
    end
    local healthText = _G[usePrefix .. i .. 'HealthBarText']
    if healthText then
      UHC_SetElementSuppressed(healthText, false)
    end
  end
end

function SetRaidFramesInfo(hideGroupHealth)
  -- Only touch raid frames; leave party compact frames alone (we already force classic party frames)
  for i = 1, 40 do
    if hideGroupHealth then
      HideRaidHealthBar(i)
    else
      ShowRaidHealthBar(i)
    end
  end

  -- Container/background global names vary by client/build; suppress what exists.
  local globalsToSuppress =
    {
      'CompactRaidFrameContainerBorderFrame',
      'CompactRaidFrameBackground',
      'CompactPartyFrameContainerBorderFrame',
      'CompactPartyFrameBackground',
    }
  for _, gName in ipairs(globalsToSuppress) do
    local g = _G[gName]
    if g then
      UHC_SetElementSuppressed(g, hideGroupHealth)
    end
  end
end

-- Securely hook Blizzard compact unit frame updates to keep health hidden
local uhcRaidHealthHooked = false
local function HookCompactRaidHealthHiding()
  if uhcRaidHealthHooked then return end
  if type(hooksecurefunc) ~= 'function' then return end
  uhcRaidHealthHooked = true
  -- Keep the custom circle and health indicator sized to the raid frame
  local function UHC_SafeGetName(obj)
    if not obj or not obj.GetName then
      return nil
    end
    local ok, name = pcall(obj.GetName, obj)
    if ok then
      return name
    end
    return nil
  end

  local function UHC_SafeGetParent(obj)
    if not obj or not obj.GetParent then
      return nil
    end
    local ok, parent = pcall(obj.GetParent, obj)
    if ok then
      return parent
    end
    return nil
  end

  local function UHC_IsNameplateFrame(frame)
    if not frame then
      return false
    end
    local function isNameplateUnit(unitToken)
      return type(unitToken) == 'string' and unitToken:sub(1, 9) == 'nameplate'
    end
    if isNameplateUnit(frame.unit) or isNameplateUnit(frame.displayedUnit) then
      return true
    end
    if type(frame.namePlateUnitToken) == 'string' and frame.namePlateUnitToken:sub(
      1,
      9
    ) == 'nameplate' then
      return true
    end
    if frame.unitFrame then
      if isNameplateUnit(frame.unitFrame.unit) or isNameplateUnit(
        frame.unitFrame.displayedUnit
      ) then
        return true
      end
      if type(
        frame.unitFrame.namePlateUnitToken
      ) == 'string' and frame.unitFrame.namePlateUnitToken:sub(1, 9) == 'nameplate' then
        return true
      end
    end
    local name = UHC_SafeGetName(frame)
    if type(name) == 'string' and name:match('^NamePlate') then
      return true
    end
    local parent = UHC_SafeGetParent(frame)
    if parent then
      local parentName = UHC_SafeGetName(parent)
      if type(parentName) == 'string' and parentName:match('^NamePlate') then
        return true
      end
    end
    return false
  end
  local function UHC_IsTargetRaidCompactFrame(frame)
    if not frame then
      return false
    end
    if UHC_IsNameplateFrame(frame) then
      return false
    end
    local name = UHC_SafeGetName(frame)
    if type(name) ~= 'string' then
      return false
    end
    if name:match('^CompactRaidFrame') or name:match('^CompactRaidGroup') then
      return true
    end
    -- TBC/compact-party variants
    if name:match('^CompactPartyFrameMember') or name:match('^CompactPartyFrame') then
      return true
    end
    return false
  end
  local function UHC_UpdateRaidCircleAndIndicatorSizes(frame)
    if not frame then return end
    if not frame.uhcCircle then return end
    if InCombatLockdown() then
      C_Timer.After(0.2, function()
        if not InCombatLockdown() then
          UHC_UpdateRaidCircleAndIndicatorSizes(frame)
        end
      end)
      return
    end
    local w = frame.GetWidth and frame:GetWidth() or 0
    local h = frame.GetHeight and frame:GetHeight() or 0
    if not w or not h or w == 0 or h == 0 then return end
    -- Preserve 1:1 aspect ratio using the smaller dimension
    local size = (w < h) and w or h
    frame.uhcCircle:ClearAllPoints()
    frame.uhcCircle:SetPoint('CENTER', frame, 'CENTER', 0, 0)
    frame.uhcCircle:SetSize(size, size)
    if RAID_HEALTH_INDICATOR_FRAMES then
      for i = 1, 40 do
        local ind = RAID_HEALTH_INDICATOR_FRAMES[i]
        if ind and ind.GetParent and ind:GetParent() == frame then
          ind:ClearAllPoints()
          ind:SetPoint('CENTER', frame.uhcCircle, 'CENTER', 0, 0)
          ind:SetSize(size, size)
          if ind.SetDrawLayer then
            ind:SetDrawLayer('ARTWORK')
          end
        end
      end
    end
  end
  local function styleCompactRaidFrame(frame)
    if not frame then return end
    if not UHC_IsTargetRaidCompactFrame(frame) then return end
    if InCombatLockdown() then
      C_Timer.After(0.2, function()
        if not InCombatLockdown() then
          styleCompactRaidFrame(frame)
        end
      end)
      return
    end
    -- Hide borders/backgrounds if present
    local borderCandidates =
      {
        frame.border,
        frame.borderFrame,
        frame.background,
        frame.selectionHighlight,
        frame.aggroHighlight,
      }
    for _, elem in ipairs(borderCandidates) do
      UHC_SetElementSuppressed(elem, true)
    end
    -- Explicitly hide common background globals if they exist
    local frameName = UHC_SafeGetName(frame)
    if frameName then
      local bg = _G[frameName .. 'Background']
      if bg then
        UHC_SetElementSuppressed(bg, true)
      end
      -- Hide per-frame border slices if present
      local borderNames = {
        frameName .. 'HorizTopBorder',
        frameName .. 'HorixTopBorder', -- handle possible typo
        frameName .. 'VertRightBorder',
        frameName .. 'HorizBottomBorder',
        frameName .. 'VertLeftBorder',
      }
      for _, bn in ipairs(borderNames) do
        local b = _G[bn]
        if b then
          UHC_SetElementSuppressed(b, true)
        end
      end
    end
    if _G['CompactRaidFrameBackground'] then
      UHC_SetElementSuppressed(_G['CompactRaidFrameBackground'], true)
    end
    if _G['CompactRaidFrameContainerBorderFrame'] then
      UHC_SetElementSuppressed(_G['CompactRaidFrameContainerBorderFrame'], true)
    end
    if _G['CompactPartyFrameBackground'] then
      UHC_SetElementSuppressed(_G['CompactPartyFrameBackground'], true)
    end
    if _G['CompactPartyFrameContainerBorderFrame'] then
      UHC_SetElementSuppressed(_G['CompactPartyFrameContainerBorderFrame'], true)
    end
    -- Add circular frame if not present
    if not frame.uhcCircle then
      frame.uhcCircle = frame:CreateTexture(nil, 'ARTWORK')
      frame.uhcCircle:SetTexture(
        'Interface\\AddOns\\UltraHardcore\\Textures\\circle-with-border.png'
      )
      if frame.uhcCircle.SetDrawLayer then
        frame.uhcCircle:SetDrawLayer('ARTWORK')
      end
    end
    -- Ensure the circle uses normal blending and is a subtle dark overlay
    if frame.uhcCircle then
      if frame.uhcCircle.SetBlendMode then
        frame.uhcCircle:SetBlendMode('BLEND')
      end
      -- Default color is black with low opacity
      local r, g, b, a = 0, 0, 0, 0.2
      -- Check if class colors are enabled and apply class color if available
      -- Defensive against any of these methods not being available or returning unexpected values
      local success, err = pcall(function()
        local activeProfile = GetActiveRaidProfile()
        local unit = frame.displayedUnit or frame.unit
        if activeProfile and GetRaidProfileOption(activeProfile, 'useClassColors') and unit then
          local _, englishClass = UnitClass(unit)
          if englishClass then
            r, g, b = GetClassColor(englishClass)
            a = .4
          end
        end
      end)
      -- If any error occurred, r, g, b, a will remain at default black values
      frame.uhcCircle:SetVertexColor(r, g, b, a)
    end
    -- Size and position the circle to match the raid frame, and keep it updated
    UHC_UpdateRaidCircleAndIndicatorSizes(frame)
    if not frame.uhcSizeHooked and frame.HookScript then
      frame:HookScript('OnSizeChanged', function(f)
        UHC_UpdateRaidCircleAndIndicatorSizes(f)
      end)
      frame.uhcSizeHooked = true
    end
    -- Place the name inside the circle, small
    local nameFrameName = UHC_SafeGetName(frame)
    local nameFrame = frame.name or (nameFrameName and _G[nameFrameName .. 'Name'] or nil)
    if nameFrame and nameFrame.SetPoint and nameFrame.ClearAllPoints then
      nameFrame:ClearAllPoints()
      nameFrame:SetPoint('TOP', frame.uhcCircle, 'TOP', 0, -6)
      if nameFrame.SetDrawLayer then
        nameFrame:SetDrawLayer('OVERLAY')
      end
      if nameFrame.GetFont and nameFrame.SetFont then
        local font, size, flags = nameFrame:GetFont()
        if size and size > 8 then
          nameFrame:SetFont(font, math.max(10, size - 1), flags)
        end
      elseif nameFrame.SetTextHeight then
        nameFrame:SetTextHeight(10)
      end
    end
    -- Re-anchor and resize the health indicator to match the circle/frame
    if frame.uhcCircle and RAID_HEALTH_INDICATOR_FRAMES then
      UHC_UpdateRaidCircleAndIndicatorSizes(frame)
    end
    if frame.statusText then
      UHC_UpdateRaidOfflineStatus(frame)
    end
  end
  local function hideFromUpdate(frame)
    if not GLOBAL_SETTINGS or not GLOBAL_SETTINGS.hideGroupHealth then return end
    if not frame then return end
    -- Only act on valid compact raid frames
    if not UHC_IsTargetRaidCompactFrame(frame) then return end
    if frame.healthBar then
      -- Attempt to discover index by matching globals (best-effort)
      -- If no index can be determined, hide via frame reference directly
      local elements =
        {
          frame.healthBar,
          frame.healthBarBackground,
          frame.myHealPredictionBar,
          frame.otherHealPredictionBar,
          frame.totalAbsorbBar,
          frame.totalAbsorbBarOverlay,
          frame.overAbsorbGlow,
          frame.overHealAbsorbGlow,
          frame.healAbsorbBar,
        }
      for _, elem in ipairs(elements) do
        UHC_SetElementSuppressed(elem, true)
      end
      UHC_UpdateRaidOfflineStatus(frame)
      -- Apply styling (border removal + circular frame + name position)
      styleCompactRaidFrame(frame)
    end
  end
  hooksecurefunc('CompactUnitFrame_UpdateHealth', hideFromUpdate)
  hooksecurefunc('CompactUnitFrame_UpdateAll', hideFromUpdate)
end

-- Ensure that party frames are always configured
local frame = CreateFrame('Frame')
frame:RegisterEvent('CVAR_UPDATE')
frame:RegisterEvent('GROUP_ROSTER_UPDATE')
frame:RegisterEvent('PLAYER_ENTERING_WORLD')
frame:RegisterEvent('PLAYER_LOGIN')
frame:RegisterEvent('ADDON_LOADED')

frame:SetScript('OnEvent', function(self, event, arg1)
  -- If the compact raid frames just loaded, apply our hiding if enabled
  if event == 'ADDON_LOADED' and arg1 == 'Blizzard_CompactRaidFrames' then
    if GLOBAL_SETTINGS.hideGroupHealth then
      HookCompactRaidHealthHiding()
      SetRaidFramesInfo(true)
    end
    return
  end

  -- Try to hook party health bars when party frames might be available
  if event == 'GROUP_ROSTER_UPDATE' or event == 'PLAYER_ENTERING_WORLD' or event == 'PLAYER_LOGIN' then
    C_Timer.After(0.1, function()
      TryHookPartyHealthBars()
    end)
  end

  if GLOBAL_SETTINGS.hideGroupHealth then
    -- Only apply changes when not in combat lockdown
    if not InCombatLockdown() then
      -- Apply styling to all party frames
      for n = 1, 5 do
        SetPartyFrameInfo(n)
      end
      -- Apply raid frame health hiding (keep names visible)
      HookCompactRaidHealthHiding()
      SetRaidFramesInfo(true)
    else
      -- If in combat, defer the changes
      C_Timer.After(0.1, function()
        if not InCombatLockdown() and GLOBAL_SETTINGS.hideGroupHealth then
          for n = 1, 5 do
            SetPartyFrameInfo(n)
          end
          HookCompactRaidHealthHiding()
          SetRaidFramesInfo(true)
        end
      end)
    end
  else
    -- Setting disabled; attempt to restore raid health bars
    SetRaidFramesInfo(false)
  end
end)
