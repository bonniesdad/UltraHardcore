function SetPlayerFrameDisplay(value)
  if value then
    HidePlayerFrame()
  else
    ShowPlayerFrame()
  end
end

function HidePlayerFrame()
  ForceHideFrame(PlayerFrame)
  ForceHideFrame(TargetFrameToT)
end

function ShowPlayerFrame()
  RestoreAndShowFrame(PlayerFrame)
  RestoreAndShowFrame(TargetFrameToT)
end
