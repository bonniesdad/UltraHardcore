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

local function UHC_GetPartyFrameContainer()
  if type(PartyFrame) == 'table' then
    return PartyFrame
  end
  return _G['PartyFrame']
end

function UHC_GetPartyMemberFrame(index)
  if not index then return nil end

  local candidateNames =
    {
      'PartyMemberFrame' .. index,
      'PartyFrameMemberFrame' .. index,
    }

  for _, name in ipairs(candidateNames) do
    local frame = _G[name]
    if frame then
      return frame
    end
  end

  local container = UHC_GetPartyFrameContainer()
  if not container then
    return nil
  end

  local memberKey = 'MemberFrame' .. index
  if container[memberKey] then
    return container[memberKey]
  end

  if type(container.memberFrames) == 'table' then
    local member = container.memberFrames[index]
    if member then
      return member
    end
  end

  if type(container.GetChildren) == 'function' then
    local children = {container:GetChildren()}
    for _, child in ipairs(children) do
      if child then
        local childName = child.GetName and child:GetName()
        if childName
          and (childName == ('PartyFrameMemberFrame' .. index) or childName == ('PartyMemberFrame' .. index))
        then
          return child
        end
      end
    end
  end

  return nil
end

function UHC_GetPartyMemberSubFrame(index, subFrameName)
  if not index or not subFrameName then return nil end

  local candidateNames =
    {
      'PartyMemberFrame' .. index .. subFrameName,
      'PartyFrameMemberFrame' .. index .. subFrameName,
    }

  for _, name in ipairs(candidateNames) do
    local frame = _G[name]
    if frame then
      return frame
    end
  end

  local parent = UHC_GetPartyMemberFrame(index)
  if not parent then
    return nil
  end

  if parent[subFrameName] then
    return parent[subFrameName]
  end

  local parentName = parent.GetName and parent:GetName()
  if parentName then
    local derived = _G[parentName .. subFrameName]
    if derived then
      return derived
    end
  end

  if subFrameName == 'PetFrame' then
    local petFrame = parent.PetFrame or parent.petFrame
    if not petFrame and parentName then
      petFrame = _G[parentName .. 'PetFrame']
    end
    return petFrame
  end

  if subFrameName:sub(1, 8) == 'PetFrame' then
    local petFrame = UHC_GetPartyMemberSubFrame(index, 'PetFrame')
    if petFrame then
      local suffix = subFrameName:sub(9)
      if suffix == '' then
        return petFrame
      end
      if petFrame[suffix] then
        return petFrame[suffix]
      end
      local petName = petFrame.GetName and petFrame:GetName()
      if petName then
        local derivedPet = _G[petName .. suffix]
        if derivedPet then
          return derivedPet
        end
      end
    end
  end

  return nil
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
    if not f or not f.GetAlpha then return nil end
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

-- Raid (Compact) Frames: Hide only the health bar so the name remains visible
local function HideRaidHealthBar(i)
  local frame = _G['CompactRaidFrame' .. i]
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
    local healthBar = _G['CompactRaidFrame' .. i .. 'HealthBar']
    if healthBar then
      UHC_SetElementSuppressed(healthBar, true)
    end
    local healthText = _G['CompactRaidFrame' .. i .. 'HealthBarText']
    if healthText then
      UHC_SetElementSuppressed(healthText, true)
    end
  end
end

local function ShowRaidHealthBar(i)
  local frame = _G['CompactRaidFrame' .. i]
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
    local healthBar = _G['CompactRaidFrame' .. i .. 'HealthBar']
    if healthBar then
      UHC_SetElementSuppressed(healthBar, false)
    end
    local healthText = _G['CompactRaidFrame' .. i .. 'HealthBarText']
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

  local containerBorder = _G['CompactRaidFrameContainerBorderFrame']
  if containerBorder then
    UHC_SetElementSuppressed(containerBorder, hideGroupHealth)
  end
  local raidBackground = _G['CompactRaidFrameBackground']
  if raidBackground then
    UHC_SetElementSuppressed(raidBackground, hideGroupHealth)
  end
end

-- Securely hook Blizzard compact unit frame updates to keep health hidden
local uhcRaidHealthHooked = false
local function HookCompactRaidHealthHiding()
  if uhcRaidHealthHooked then return end
  if type(hooksecurefunc) ~= 'function' then return end
  uhcRaidHealthHooked = true
  -- Keep the custom circle and health indicator sized to the raid frame
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
    local frameName = frame.GetName and frame:GetName() or nil
    if frameName then
      local bg = _G[frameName .. 'Background']
      if bg then
        UHC_SetElementSuppressed(bg, true)
      end
      -- Hide per-frame border slices if present
      local borderNames =
        {
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
    -- Add circular frame if not present
    if not frame.uhcCircle then
      frame.uhcCircle = frame:CreateTexture(nil, 'ARTWORK')
      frame.uhcCircle:SetTexture('Interface\\AddOns\\UltraHardcore\\Textures\\circle-with-border.png')
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
    local nameFrame = frame.name or _G[frame:GetName() and (frame:GetName() .. 'Name') or '']
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
    -- Only act on compact unit frames (have a healthBar and name)
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
