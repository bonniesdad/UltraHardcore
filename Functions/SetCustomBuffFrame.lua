function SetCustomBuffFrame(hideBuffFrame)
  if hideBuffFrame then
    SetBuffFrame()
  end
end

function SetBuffFrame()
  BuffFrame:ClearAllPoints()

  BuffFrame:SetPoint('BOTTOMRIGHT', UIParent, 'BOTTOMRIGHT', -175, 90)
  hooksecurefunc('BuffFrame_UpdateAllBuffAnchors', function()
    BuffFrame:ClearAllPoints()

    BuffFrame:SetPoint('BOTTOMRIGHT', UIParent, 'BOTTOMRIGHT', -175, 90)
  end)
end
