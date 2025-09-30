local blurFrame = CreateFrame('Frame', nil, UIParent)
blurFrame:SetAllPoints(UIParent)
blurFrame:SetFrameStrata('FULLSCREEN_DIALOG')
blurFrame:SetFrameLevel(100)

local blurTexture = blurFrame:CreateTexture(nil, 'BACKGROUND')
blurTexture:SetAllPoints()
blurTexture:SetTexture('Interface\\FullScreenTextures\\OutOfControl')
blurTexture:SetAlpha(0.3)
blurFrame:Hide()

function ShowDazedOverlay(enable)
  if enable then
    blurFrame:Show()
  else
    blurFrame:Hide()
  end
end
