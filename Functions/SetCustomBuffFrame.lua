function SetCustomBuffFrame(hideBuffFrame)
  if hideBuffFrame then
    SetBuffFrame()
  end
end

function SetBuffFrame()
  -- Make the buff frame draggable
  BuffFrame:SetMovable(true)
  BuffFrame:EnableMouse(true)
  BuffFrame:RegisterForDrag('LeftButton')
  BuffFrame:SetScript('OnDragStart', function(self)
    self:StartMoving()
  end)
  BuffFrame:SetScript('OnDragStop', function(self)
    self:StopMovingOrSizing()
  end)

  BuffFrame:ClearAllPoints()
  BuffFrame:SetPoint('BOTTOMRIGHT', UIParent, 'BOTTOMRIGHT', -175, 90)

end
