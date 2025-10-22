local redCupOverlayFrame = nil

function ShowPikabooRestingOverlay()
    if not redCupOverlayFrame then
        local success, err = pcall(function()
            redCupOverlayFrame = CreateFrame("Frame", "PikabooRestingOverlay", UIParent)
            if not redCupOverlayFrame then return end
            
            redCupOverlayFrame:SetFrameStrata("DIALOG")
            --redCupOverlayFrame:SetAllPoints(UIParent)

            redCupOverlayFrame.texture = redCupOverlayFrame:CreateTexture(nil, "ARTWORK")
            if not redCupOverlayFrame.texture then return end
            
            redCupOverlayFrame.texture:SetAllPoints()
            redCupOverlayFrame.texture:SetTexture("Interface\\AddOns\\UltraHardcore\\Textures\\RedCup.png")
            redCupOverlayFrame:SetSize(150, 200)
            redCupOverlayFrame:SetPoint('CENTER')
            redCupOverlayFrame:SetAlpha(0)
            redCupOverlayFrame:Hide()
        end)

        if not success then
            print("UltraHardcore: Error creating Pikaboo resting overlay frame:", err)
            return
        end
    end

    if not redCupOverlayFrame then return end

    redCupOverlayFrame:Show()
    UIFrameFadeIn(redCupOverlayFrame, 0.3, 0, 1)
    
    C_Timer.After(5.0, function()
        if redCupOverlayFrame and redCupOverlayFrame:IsShown() then
            UIFrameFadeOut(redCupOverlayFrame, 0.3, 1, 0)
        end
    end)
end
