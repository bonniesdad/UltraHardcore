function RotateScreenEffect()

  local function shake(n, speed, seconds)
    if n > 0 then
      MoveViewLeftStart(speed)
      C_Timer.After(seconds, function()
        MoveViewLeftStop()
        MoveViewRightStart(speed)
        C_Timer.After(seconds, function()
          MoveViewRightStop()
          shake(n - 1, speed, seconds)
        end)
      end)
    else
      -- Failsafe in case one of the MoveView functions leaves the camera spinning.
      C_Timer.After(0.5, function()
        MoveViewLeftStop()
        MoveViewRightStop()
      end)
    end
  end

  local stopMovement = true
  local moveSeconds = 0.2 + 0.1*math.random()       -- was 0.2, now 0.2 - 0.3
  local moveSpeed = 2.0 + 1.5*math.random()         -- was 2.0, now 2.0 - 3.5
  local randomNum = math.random(1, 8)               -- Pick a random direction (1-5) or the shake effect (6-8)
  if randomNum == 1 then
    --print("CRIT R")
    MoveViewRightStart(moveSpeed)
  elseif randomNum == 2 then
    --print("CRIT L")
    MoveViewLeftStart(moveSpeed)
  elseif randomNum == 3 then
    --print("CRIT U")
    MoveViewUpStart(moveSpeed)
  elseif randomNum == 4 then
    --print("CRIT UR")
    MoveViewUpStart(moveSpeed)
    MoveViewRightStart(moveSpeed)
  elseif randomNum == 5 then
    --print("CRIT UL")
    MoveViewUpStart(moveSpeed)
    MoveViewLeftStart(moveSpeed)
  else
    stopMovement = false
    local moveSeconds = 0.03 + 0.02*math.random()
    local moveSpeed = 3.0 + 2.0*math.random()
    local nShakes = random(3, 5)
    --print("CRIT SHAKE: seconds=" .. moveSeconds .. ", speed=" .. moveSpeed .. ", nShakes=" .. nShakes)
    shake(nShakes, moveSpeed, moveSeconds)
  end

  if stopMovement then
    C_Timer.After(moveSeconds, function()
      MoveViewLeftStop()
      MoveViewRightStop()
      MoveViewUpStop()
      MoveViewDownStop()
    end)
  end

end
