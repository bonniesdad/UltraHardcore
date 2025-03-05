function SetPlayerFrameDisplay(value)
  if value then
    HidePlayerFrame()
  else
    ShowPlayerFrame()
  end
end

function HidePlayerFrame()
  PlayerFrame:UnregisterAllEvents() -- Stop updates
  PlayerFrame:SetScript('OnUpdate', nil) -- Remove update scripts
  PlayerFrame:SetScript('OnEvent', nil) -- Remove event handling
  PlayerFrame:SetScript('OnShow', function(self)
    self:Hide()
  end)

  hooksecurefunc(PlayerFrame, 'Show', function(self)
    self:Hide()
  end)

  PlayerFrame:Hide()
end

function ShowPlayerFrame()
  PlayerFrame:Show() -- Ensure it shows up again
end
