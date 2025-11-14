function HidePlayerCastBar()
    if not GLOBAL_SETTINGS.hidePlayerCastBar then
        return
    end

    if not CastingBarFrame then
        return
    end
    -- Hide the default player castbar
    if CastingBarFrame then
        CastingBarFrame:Hide()
        CastingBarFrame:SetAlpha(0)
    end
end