--[[
  Removes health information (and power) from the target frames.
  Uses the same logic as HidePartyInformation.lua
]]

TARGET_FRAME_SUBFRAMES_TO_HIDE =
  {
    'HealthBar',
    'ManaBar',
    'Texture',
    'Background',
    'LevelText',
    'Name',
    'NameBackground',
    'StatusTexture',
    'TextureFrameHealthBarText',
    'TextureFrameManaBarText',
    'NumericalThreat',
    'Buff1',
    'Buff2',
    'Buff3',
    'Buff4',
    'Buff5',
    'Buff6',
    'Buff7',
    'Buff8',
    'Debuff1',
    'Debuff2',
    'Debuff3',
    'Debuff4',
    'Debuff5',
    'Debuff6',
    'Debuff7',
    'Debuff8',
  }

TARGET_OF_TARGET_SUBFRAMES_TO_HIDE =
  {
    'HealthBar',
    'ManaBar',
    'Texture',
    'Background',
    'LevelText',
    'Name',
    'NameBackground',
    'TextureFrameHealthBarText',
    'TextureFrameManaBarText',
    'Buff1',
    'Buff2',
    'Buff3',
    'Buff4',
    'Buff5',
    'Buff6',
    'Buff7',
    'Buff8',
    'Debuff1',
    'Debuff2',
    'Debuff3',
    'Debuff4',
    'Debuff5',
    'Debuff6',
    'Debuff7',
    'Debuff8',
  }

-- Global variable to track if target frame hiding is enabled
local targetFrameHidingEnabled = false
local targetFrameEventFrame = nil
local targetAuraHookInstalled = false

-- Helper to read the experimental toggle safely
local function IsShowTargetDebuffsEnabled()
  return _G.GLOBAL_SETTINGS and _G.GLOBAL_SETTINGS.showTargetDebuffs == true
end

local MAX_AURAS = 40

-- Forward declaration to allow calls before definition
local RepositionTargetDebuffs

-- Determine if the target aura policy should be applied right now (even before setter runs)
local function ShouldApplyTargetAuraPolicyNow()
  if targetFrameHidingEnabled then return true end
  if _G.GLOBAL_SETTINGS then
    return (_G.GLOBAL_SETTINGS.hideTargetFrame == true) or (_G.GLOBAL_SETTINGS.completelyRemoveTargetFrame == true)
  end
  return false
end

-- Central policy: enforce buffs/debuffs visibility for the target frame
local function ApplyTargetDebuffPolicy()
  if not ShouldApplyTargetAuraPolicyNow then return end
  if not ShouldApplyTargetAuraPolicyNow() then return end

  -- Always hide buffs while target-frame hiding is active
  for i = 1, MAX_AURAS do
    local bf = _G['TargetFrameBuff' .. i]
    if bf then
      ForceHideFrame(bf)
    end
  end

  -- If experimental toggle is off, hide debuffs and return early
  if not IsShowTargetDebuffsEnabled() then
    for i = 1, MAX_AURAS do
      local df = _G['TargetFrameDebuff' .. i]
      if df then
        ForceHideFrame(df)
      end
    end
    return
  end

  -- Otherwise, show and reposition debuffs
  for i = 1, MAX_AURAS do
    local df = _G['TargetFrameDebuff' .. i]
    if df then
      RestoreAndShowFrame(df)
    end
  end
  RepositionTargetDebuffs()
end

-- Reposition target debuffs relative to their original anchor by a fixed offset
RepositionTargetDebuffs = function()
  if not IsShowTargetDebuffsEnabled() then return end
  for i = 1, MAX_AURAS do
    local debuffFrame = _G['TargetFrameDebuff' .. i]
    if debuffFrame then
      -- Record original point once to prevent cumulative drift
      if not debuffFrame.__UHC_OrigPoint then
        local p, rel, rp, x, y = debuffFrame:GetPoint(1)
        if p then
          debuffFrame.__UHC_OrigPoint = p
          debuffFrame.__UHC_OrigRelativeTo = rel
          debuffFrame.__UHC_OrigRelativePoint = rp
          debuffFrame.__UHC_OrigX = x or 0
          debuffFrame.__UHC_OrigY = y or 0
        else
          -- Fallback orig if no point is available
          debuffFrame.__UHC_OrigPoint = 'TOPLEFT'
          debuffFrame.__UHC_OrigRelativeTo = TargetFrame or UIParent
          debuffFrame.__UHC_OrigRelativePoint = 'TOPLEFT'
          debuffFrame.__UHC_OrigX = 0
          debuffFrame.__UHC_OrigY = 0
        end
      end

      local op = debuffFrame.__UHC_OrigPoint
      local orrel = debuffFrame.__UHC_OrigRelativeTo or TargetFrame or UIParent
      local orrp = debuffFrame.__UHC_OrigRelativePoint or op
      local ox = debuffFrame.__UHC_OrigX or 0
      local oy = debuffFrame.__UHC_OrigY or 0

      -- Only add the global offset if this debuff is anchored to a base frame
      -- (TargetFrame/UIParent/etc.). If it's anchored to another aura, the parent
      -- will have moved, so we keep the original local offset to avoid double-shifting.
      local relName = (orrel and orrel.GetName and orrel:GetName()) or ''
      local isAnchoredToAura = relName:find('^TargetFrameDebuff') ~= nil or relName:find('^TargetFrameBuff') ~= nil
      local dx = isAnchoredToAura and 0 or 200
      local dy = isAnchoredToAura and 0 or 35

      debuffFrame:ClearAllPoints()
      debuffFrame:SetPoint(op, orrel, orrp, ox + dx, oy + dy)
    end
  end
end

-- Starts/stops a periodic hider for target buff/debuff frames while target-frame hiding is active
local function StartOrUpdateAuraHideTicker()
  -- Stop any existing ticker first
  if _G.UltraHardcoreTargetFrameTimer then
    _G.UltraHardcoreTargetFrameTimer:Cancel()
    _G.UltraHardcoreTargetFrameTimer = nil
  end

  -- Only run the ticker if we are hiding target frame details
  if not targetFrameHidingEnabled then
    return
  end

  local function hideTargetAurasOnce()
    ApplyTargetDebuffPolicy()

  end

  -- Run immediately once
  hideTargetAurasOnce()
  -- Then keep hiding newly-created aura buttons as Blizzard updates them
  _G.UltraHardcoreTargetFrameTimer = C_Timer.NewTicker(0.1, function()
    hideTargetAurasOnce()
  end)
end

-- Ensure we hook into Blizzard aura layout early so positions are set before showing
local function EnsureTargetAuraHookInstalled()
  if targetAuraHookInstalled then return end
  targetAuraHookInstalled = true
  hooksecurefunc('TargetFrame_UpdateAuras', function(frame)
    if frame ~= TargetFrame then return end
    if not ShouldApplyTargetAuraPolicyNow() then return end
    ApplyTargetDebuffPolicy()
  end)

  -- Secure hook frame creation to immediately neuter new aura buttons before they can show
  hooksecurefunc('CreateFrame', function(_, name, parent, template)
    if not name then return end
    if not ShouldApplyTargetAuraPolicyNow() then return end
    local isAura = string.match(name, '^TargetFrameBuff%d+$') or string.match(name, '^TargetFrameDebuff%d+$')
    if not isAura then return end
    local f = _G[name]
    if not f then return end
    if string.match(name, '^TargetFrameBuff%d+$') then
      -- Always hide buffs while target-frame hiding is active
      ForceHideFrame(f)
    else
      -- Debuffs only if experimental toggle is off
      if not IsShowTargetDebuffsEnabled() then
        ForceHideFrame(f)
      end
    end
  end)
end

function SetTargetFrameDisplay(hideDetails, completelyRemove)
  targetFrameHidingEnabled = hideDetails

  -- Install aura layout hook as early as possible so first layout respects settings
  EnsureTargetAuraHookInstalled()

  if hideDetails then
    if completelyRemove then
      -- Completely hide the entire target frame
      CompletelyHideTargetFrame()
    else
      SetTargetFrameInfo()
      SetTargetOfTargetFrameInfo()

      -- Create event frame to monitor target changes and buff/debuff updates
      if not targetFrameEventFrame then
        targetFrameEventFrame = CreateFrame('Frame')
        targetFrameEventFrame:RegisterEvent('PLAYER_TARGET_CHANGED')
        targetFrameEventFrame:RegisterEvent('UNIT_TARGET')
        targetFrameEventFrame:RegisterEvent('UNIT_AURA')
        targetFrameEventFrame:RegisterEvent('PLAYER_TARGET_CHANGED')
        targetFrameEventFrame:SetScript('OnEvent', function(self, event, unit)
          if targetFrameHidingEnabled then
            if event == 'UNIT_AURA' and (unit == 'target' or unit == 'targettarget') then
              -- Immediately hide buffs/debuffs when auras update
              C_Timer.After(0.01, function()
                ApplyTargetDebuffPolicy()
              end)
            else
              -- Small delay to ensure frames are created before hiding
              C_Timer.After(0.1, function()
                SetTargetFrameInfo()
                SetTargetOfTargetFrameInfo()
                ApplyTargetDebuffPolicy()
              end)
            end
          end
        end)
      end

      -- Ensure our aura-hider reflects current setting
      StartOrUpdateAuraHideTicker()
      -- Install aura layout hook for pre-show positioning
      EnsureTargetAuraHookInstalled()
    end
  else
    if completelyRemove then
      -- Completely restore the entire target frame
      CompletelyShowTargetFrame()
    else
      RestoreTargetFrameInfo()
      RestoreTargetOfTargetFrameInfo()

      -- Clean up event frame
      if targetFrameEventFrame then
        targetFrameEventFrame:UnregisterAllEvents()
        targetFrameEventFrame:SetScript('OnEvent', nil)
        targetFrameEventFrame = nil
      end

      -- Stop the periodic timer for buff/debuff hiding
      if _G.UltraHardcoreTargetFrameTimer then
        _G.UltraHardcoreTargetFrameTimer:Cancel()
        _G.UltraHardcoreTargetFrameTimer = nil
      end
    end
  end
end

function SetTargetFrameInfo()
  for _, subFrame in ipairs(TARGET_FRAME_SUBFRAMES_TO_HIDE) do
    HideTargetSubFrame(subFrame)
  end
end

function SetTargetOfTargetFrameInfo()
  for _, subFrame in ipairs(TARGET_OF_TARGET_SUBFRAMES_TO_HIDE) do
    HideTargetOfTargetSubFrame(subFrame)
  end
end

function HideTargetSubFrame(subFrame)
  local frame = _G['TargetFrame' .. subFrame]
  if frame then
    -- Skip hiding debuffs if experimental toggle is enabled
    if string.match(subFrame, '^Debuff%d+$') and IsShowTargetDebuffsEnabled() then
      RestoreAndShowFrame(frame)
      return
    end

    ForceHideFrame(frame)

    -- For buff/debuff frames, also hook their creation to prevent them from ever showing
    if string.match(subFrame, '^Buff%d+$') or (string.match(subFrame, '^Debuff%d+$') and not IsShowTargetDebuffsEnabled()) then
      -- Override the frame's Show method to do nothing
      frame.Show = function() end
      -- Also hook any potential parent frame creation
      hooksecurefunc(frame, 'Show', function()
        frame:Hide()
      end)
    end
  end

  -- Special case for TargetFrameTextureFrame
  if subFrame == 'TextureFrameHealthBarText' or subFrame == 'TextureFrameManaBarText' then
    local textureFrame = _G['TargetFrameTextureFrame']
    if textureFrame then
      ForceHideFrame(textureFrame)
    end
  end
end

function HideTargetOfTargetSubFrame(subFrame)
  local frame = _G['TargetFrameToT' .. subFrame]
  if frame then
    ForceHideFrame(frame)

    -- For buff/debuff frames, also hook their creation to prevent them from ever showing
    if string.match(subFrame, '^Buff%d+$') or string.match(subFrame, '^Debuff%d+$') then
      -- Override the frame's Show method to do nothing
      frame.Show = function() end
      -- Also hook any potential parent frame creation
      hooksecurefunc(frame, 'Show', function()
        frame:Hide()
      end)
    end
  end
end

function CompletelyHideTargetFrame()
  -- Hide the entire TargetFrame
  if TargetFrame then
    ForceHideFrame(TargetFrame)
  end

  -- Hide target of target frame
  if TargetFrameToT then
    ForceHideFrame(TargetFrameToT)
  end

  -- Stop the periodic timer for buff/debuff hiding since we're hiding everything
  if _G.UltraHardcoreTargetFrameTimer then
    _G.UltraHardcoreTargetFrameTimer:Cancel()
    _G.UltraHardcoreTargetFrameTimer = nil
  end
end

function CompletelyShowTargetFrame()
  -- Show the entire TargetFrame
  if TargetFrame then
    RestoreAndShowFrame(TargetFrame)
  end

  -- Show target of target frame
  if TargetFrameToT then
    RestoreAndShowFrame(TargetFrameToT)
  end
end

function RestoreTargetFrameInfo()
  for _, subFrame in ipairs(TARGET_FRAME_SUBFRAMES_TO_HIDE) do
    local frame = _G['TargetFrame' .. subFrame]
    if frame then
      RestoreAndShowFrame(frame)
    end

    -- Special case for TargetFrameTextureFrame
    if subFrame == 'TextureFrameHealthBarText' or subFrame == 'TextureFrameManaBarText' then
      local textureFrame = _G['TargetFrameTextureFrame']
      if textureFrame then
        RestoreAndShowFrame(textureFrame)
      end
    end
  end
end

function RestoreTargetOfTargetFrameInfo()
  for _, subFrame in ipairs(TARGET_OF_TARGET_SUBFRAMES_TO_HIDE) do
    local frame = _G['TargetFrameToT' .. subFrame]
    if frame then
      RestoreAndShowFrame(frame)
    end
  end
end
