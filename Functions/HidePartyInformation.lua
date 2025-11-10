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
  ForcePartyFrames()

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
    end
  end
  hooksecurefunc('CompactUnitFrame_UpdateHealth', hideFromUpdate)
  hooksecurefunc('CompactUnitFrame_UpdateAll', hideFromUpdate)
end

function ForcePartyFrames()
  if InCombatLockdown() then
    -- If in combat, queue the CVar change for later
    C_Timer.After(0.1, function()
      if not InCombatLockdown() then
        ForcePartyFrames()
      end
    end)
  else
    -- Only change the CVar if it's not already set to 0
    local currentValue = GetCVar('useCompactPartyFrames')
    if currentValue ~= '0' then
      SetCVar('useCompactPartyFrames', 0)
    end
  end
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
      ForcePartyFrames()
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
          ForcePartyFrames()
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
