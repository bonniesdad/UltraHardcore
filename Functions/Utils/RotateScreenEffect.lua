function RotateScreenEffect()
  local randomNum = math.random(1, 4)
  -- Pick a random direction
  if randomNum == 1 then
    MoveViewDownStart(2)
  elseif randomNum == 2 then
    MoveViewRightStart(2)
  elseif randomNum == 3 then
    MoveViewLeftStart(2)
  elseif randomNum == 4 then
    MoveViewUpStart(2)
  end

  -- Stop movement after 0.5 seconds
  C_Timer.After(0.2, function()
    MoveViewLeftStop()
    MoveViewRightStop()
    MoveViewUpStop()
    MoveViewDownStop()
  end)
end
