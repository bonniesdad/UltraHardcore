function HidePlayerCastBar()
  if not GLOBAL_SETTINGS.hidePlayerCastBar then return end

  -- Hide the default player castbar
  if CastingBarFrame then
    CastingBarFrame:Hide()
    CastingBarFrame:SetAlpha(0)
  end

  -- TBC
  if PlayerCastingBarFrame then
    PlayerCastingBarFrame:Hide()
    PlayerCastingBarFrame:SetAlpha(0)
  end
end
