local fullHealthOverlayFrame = nil

function ShowFullHealthOverlay()
  if not fullHealthOverlayFrame then
    local success, err = pcall(function()
      fullHealthOverlayFrame = CreateFrame('Frame', 'FullHealthOverlay', UIParent)
      if not fullHealthOverlayFrame then return end

      fullHealthOverlayFrame:SetFrameStrata('FULLSCREEN_DIALOG')
      fullHealthOverlayFrame:SetAllPoints(UIParent)

      fullHealthOverlayFrame.texture = fullHealthOverlayFrame:CreateTexture(nil, 'ARTWORK')
      if not fullHealthOverlayFrame.texture then return end

      fullHealthOverlayFrame.texture:SetAllPoints()
      fullHealthOverlayFrame.texture:SetTexture(
        'Interface\\AddOns\\UltraHardcore\\Textures\\full-health-overlay.png'
      )
      fullHealthOverlayFrame:SetAlpha(0)
      fullHealthOverlayFrame:Hide()
    end)

    if not success then
      print('UltraHardcore: Error creating full health overlay frame:', err)
      return
    end
  end

  if not fullHealthOverlayFrame then return end

  fullHealthOverlayFrame:Show()
  UIFrameFadeIn(fullHealthOverlayFrame, 0.3, 0, 1)

  C_Timer.After(0.7, function()
    if fullHealthOverlayFrame and fullHealthOverlayFrame:IsShown() then
      UIFrameFadeOut(fullHealthOverlayFrame, 0.3, 1, 0)
    end
  end)
end
