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
    end
  end

  local stopMovement = true
  local moveSeconds = 0.2 + 0.1*math.random()       -- was 0.2, now 0.2 - 0.3
  local moveSpeed = 2.0 + 1.5*math.random()         -- was 2.0, now 2.0 - 3.5
  local randomNum = math.random(1, 6)               -- Pick a random direction (1-4) or the shake effect (5-6)
  if randomNum == 1 then
    MoveViewDownStart(moveSpeed)
  elseif randomNum == 2 then
    MoveViewRightStart(moveSpeed)
  elseif randomNum == 3 then
    MoveViewLeftStart(moveSpeed)
  elseif randomNum == 4 then
    MoveViewUpStart(moveSpeed)
  elseif randomNum == 5 or randomNum == 6 then
    stopMovement = false
    local moveSeconds = 0.03 + 0.02*math.random()
    local moveSpeed = 3.0 + 2.0*math.random()
    local nShakes = random(3, 5)
    --print("CRIT: seconds=" .. moveSeconds .. ", speed=" .. moveSpeed .. ", nShakes=" .. nShakes)
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
