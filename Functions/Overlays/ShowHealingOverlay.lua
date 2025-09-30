local healingOverlayFrame = nil

function ShowHealingOverlay()
    if not healingOverlayFrame then
        local success, err = pcall(function()
            healingOverlayFrame = CreateFrame("Frame", "HealingOverlay", UIParent)
            if not healingOverlayFrame then return end
            
            healingOverlayFrame:SetFrameStrata("FULLSCREEN_DIALOG")
            healingOverlayFrame:SetAllPoints(UIParent)

            healingOverlayFrame.texture = healingOverlayFrame:CreateTexture(nil, "ARTWORK")
            if not healingOverlayFrame.texture then return end
            
            healingOverlayFrame.texture:SetAllPoints()
            healingOverlayFrame.texture:SetTexture("Interface\\AddOns\\UltraHardcore\\Textures\\healing-overlay.png")
            healingOverlayFrame:SetAlpha(0)
            healingOverlayFrame:Hide()
        end)
        
        if not success then
            print("UltraHardcore: Error creating healing overlay frame:", err)
            return
        end
    end

    if not healingOverlayFrame then return end

    healingOverlayFrame:Show()
    UIFrameFadeIn(healingOverlayFrame, 0.3, 0, 1)
    
    C_Timer.After(0.7, function()
        if healingOverlayFrame and healingOverlayFrame:IsShown() then
            UIFrameFadeOut(healingOverlayFrame, 0.3, 1, 0)
        end
    end)
end
