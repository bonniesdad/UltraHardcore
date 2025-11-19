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

-- Immediate buff/debuff blocking - runs on addon load
local function BlockBuffDebuffFrames()
  -- Use a more targeted approach that doesn't override global CreateFrame
  local function hideTargetBuffDebuffFrames()
    for i = 1, 8 do
      local buffFrame = _G['TargetFrameBuff' .. i]
      if buffFrame then
        buffFrame.Show = function() end
        buffFrame:Hide()
      end
      local debuffFrame = _G['TargetFrameDebuff' .. i]
      if debuffFrame then
        debuffFrame.Show = function() end
        debuffFrame:Hide()
      end
    end
  end

  -- Hide frames immediately and set up periodic checking
  hideTargetBuffDebuffFrames()

  -- Set up a timer to periodically check and hide any new buff/debuff frames
  local checkTimer = C_Timer.NewTicker(0.1, function()
    hideTargetBuffDebuffFrames()
  end)

  -- Store the timer so we can stop it later if needed
  _G.UltraHardcoreTargetFrameTimer = checkTimer
end

-- Run the blocking immediately
BlockBuffDebuffFrames()

function SetTargetFrameDisplay(hideDetails, completelyRemove)
  targetFrameHidingEnabled = hideDetails

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
                for i = 1, 8 do
                  local buffFrame = _G['TargetFrameBuff' .. i]
                  if buffFrame then
                    buffFrame:Hide()
                    buffFrame.Show = function() end
                  end
                  local debuffFrame = _G['TargetFrameDebuff' .. i]
                  if debuffFrame then
                    debuffFrame:Hide()
                    debuffFrame.Show = function() end
                  end
                end
              end)
            else
              -- Small delay to ensure frames are created before hiding
              C_Timer.After(0.1, function()
                SetTargetFrameInfo()
                SetTargetOfTargetFrameInfo()
              end)
            end
          end
        end)
      end
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
