local damageOverlayFrame = nil

function ShowShadowDamageOverlay()
    if not damageOverlayFrame then
        local success, err = pcall(function()
            damageOverlayFrame = CreateFrame("Frame", "DamageOverlay", UIParent)
            if not damageOverlayFrame then return end
            
            damageOverlayFrame:SetFrameStrata("FULLSCREEN_DIALOG")
            damageOverlayFrame:SetAllPoints(UIParent)

            damageOverlayFrame.texture = damageOverlayFrame:CreateTexture(nil, "ARTWORK")
            if not damageOverlayFrame.texture then return end
            
            damageOverlayFrame.texture:SetAllPoints()
            damageOverlayFrame.texture:SetTexture("Interface\\AddOns\\UltraHardcore\\Textures\\shadow-damage.png")
            damageOverlayFrame:SetAlpha(0)
            damageOverlayFrame:Hide()
        end)
        
        if not success then
            print("UltraHardcore: Error creating damage overlay frame:", err)
            return
        end
    end

    if not damageOverlayFrame then return end

    damageOverlayFrame:Show()
    UIFrameFadeIn(damageOverlayFrame, 0.3, 0, 1)
    
    C_Timer.After(0.7, function()
        if damageOverlayFrame and damageOverlayFrame:IsShown() then
            UIFrameFadeOut(damageOverlayFrame, 0.3, 1, 0)
        end
    end)
end 