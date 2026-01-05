local spinTrackingFrame = CreateFrame('Frame')
spinTrackingFrame:RegisterEvent('ADDON_LOADED')

spinTrackingFrame:SetScript('OnEvent', function()
  local SpinCounter = {}
  SpinCounter.count = CharacterStats:GetStat('player360s') or 0

  SpinCounter.active = false
  SpinCounter.countedThisJump = false
  SpinCounter.accumulated = 0
  SpinCounter.lastFacing = nil
  SpinCounter.jumpStartTime = 0
  SpinCounter.lastStart = 0
  SpinCounter.debounce = 0.75 -- seconds between jump-starts (mirrors TrackJumps.lua)

  local TWO_PI = 2 * math.pi
  local MIN_ACTIVE_TIME = 0.1
  local MAX_JUMP_TIME = 3.0

  local function BeginJumpSpinTracking()
    local now = GetTime()
    if SpinCounter.active then return end
    if SpinCounter.lastStart and (now - SpinCounter.lastStart) < SpinCounter.debounce then return end

    SpinCounter.active = true
    SpinCounter.countedThisJump = false
    SpinCounter.accumulated = 0
    SpinCounter.lastFacing = GetPlayerFacing()
    SpinCounter.jumpStartTime = now
    SpinCounter.lastStart = now
  end

  local function EndJumpSpinTracking()
    SpinCounter.active = false
    SpinCounter.lastFacing = nil
    SpinCounter.accumulated = 0
    SpinCounter.countedThisJump = false
    SpinCounter.jumpStartTime = 0
  end

  -- Hook AscendStop (same as TrackJumps.lua) to detect a jump moment.
  hooksecurefunc('AscendStop', function()
    if not IsFalling() then
      return -- ignore if the player is on the ground
    end

    BeginJumpSpinTracking()
  end)

  spinTrackingFrame:SetScript('OnUpdate', function()
    if not SpinCounter.active then return end

    local now = GetTime()
    local elapsedSinceStart = now - (SpinCounter.jumpStartTime or now)
    if elapsedSinceStart > MAX_JUMP_TIME then
      EndJumpSpinTracking()
      return
    end

    local facing = GetPlayerFacing()
    if facing and SpinCounter.lastFacing then
      local delta = facing - SpinCounter.lastFacing
      -- Wrap delta to [-pi, pi] so we accumulate the actual turning direction correctly.
      if delta > math.pi then
        delta = delta - TWO_PI
      elseif delta < -math.pi then
        delta = delta + TWO_PI
      end

      SpinCounter.accumulated = SpinCounter.accumulated + math.abs(delta)

      if not SpinCounter.countedThisJump and SpinCounter.accumulated >= TWO_PI then
        SpinCounter.countedThisJump = true
        SpinCounter.count = SpinCounter.count + 1
        CharacterStats:UpdateStat('player360s', SpinCounter.count)
        UpdateStatistics()
      end
    end
    SpinCounter.lastFacing = facing

    -- Stop tracking once we're back on the ground. (We require a tiny minimum active time so
    -- brief state glitches don't instantly stop tracking.)
    if elapsedSinceStart >= MIN_ACTIVE_TIME and not IsFalling() then
      EndJumpSpinTracking()
    end
  end)
end)


