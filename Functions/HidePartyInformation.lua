--[[
  Removes health information (and power) from the party frames.
  Compact party frames are not supported yet.
]]

PARTY_MEMBER_SUBFRAMES_TO_HIDE =
  {
    'HealthBar',
    'ManaBar',
    'Texture',
    'Background',
    'PetFrameBackground',
    'PetFrameTexture',
    'PetFrameHealthBar',
    'PetFrameManaBar',
  }

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
    local nameFrame = _G['PartyMemberFrame' .. n .. 'Name']

    if nameFrame and nameFrame.SetPoint and nameFrame.ClearAllPoints then
      nameFrame:ClearAllPoints()
      nameFrame:SetPoint('BOTTOMLEFT', 55, 25)
    end
  end

  -- Move the entire party frame to the right by 100px and stack vertically
  local partyFrame = _G['PartyMemberFrame' .. n]
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
  local frame = _G['PartyMemberFrame' .. n .. subFrame]
  if frame then
    ForceHideFrame(frame)
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
      if elem then
        ForceHideFrame(elem)
      end
    end
    if frame.statusText and frame.statusText.Hide then
      frame.statusText:Hide()
    end
  else
    -- Fallback to global-named health bar if direct frame not available
    local healthBar = _G['CompactRaidFrame' .. i .. 'HealthBar']
    if healthBar then
      ForceHideFrame(healthBar)
    end
    local healthText = _G['CompactRaidFrame' .. i .. 'HealthBarText']
    if healthText and healthText.Hide then
      healthText:Hide()
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
      if elem then
        RestoreAndShowFrame(elem)
      end
    end
    if frame.statusText and frame.statusText.Show then
      frame.statusText:Show()
    end
  else
    local healthBar = _G['CompactRaidFrame' .. i .. 'HealthBar']
    if healthBar then
      RestoreAndShowFrame(healthBar)
    end
    local healthText = _G['CompactRaidFrame' .. i .. 'HealthBarText']
    if healthText and healthText.Show then
      healthText:Show()
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
      if elem then
        ForceHideFrame(elem)
      end
    end
    -- Explicitly hide common background globals if they exist
    local frameName = frame.GetName and frame:GetName() or nil
    if frameName then
      local bg = _G[frameName .. 'Background']
      if bg then
        ForceHideFrame(bg)
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
          ForceHideFrame(b)
        end
      end
    end
    if _G['CompactRaidFrameBackground'] then
      ForceHideFrame(_G['CompactRaidFrameBackground'])
    end
    if _G['CompactRaidFrameContainerBorderFrame'] then
      ForceHideFrame(_G['CompactRaidFrameContainerBorderFrame'])
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
      if frame.uhcCircle.SetVertexColor then
        frame.uhcCircle:SetVertexColor(0, 0, 0, 0.2)
      else
        frame.uhcCircle:SetAlpha(0.2)
      end
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
          nameFrame:SetFont(font, math.max(8, size - 3), flags)
        end
      elseif nameFrame.SetTextHeight then
        nameFrame:SetTextHeight(8)
      end
    end
    -- Re-anchor and resize the health indicator to match the circle/frame
    if frame.uhcCircle and RAID_HEALTH_INDICATOR_FRAMES then
      UHC_UpdateRaidCircleAndIndicatorSizes(frame)
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
        if elem then
          ForceHideFrame(elem)
        end
      end
      if frame.statusText and frame.statusText.Hide then
        frame.statusText:Hide()
      end
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
      if _G['CompactRaidFrameContainerBorderFrame'] then
        ForceHideFrame(_G['CompactRaidFrameContainerBorderFrame'])
      end
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
