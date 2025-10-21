local hearthingOverlayFrame = nil

function ShowHearthingOverlay()
    if not hearthingOverlayFrame then
        local success, err = pcall(function()
            hearthingOverlayFrame = CreateFrame("Frame", "HearthOverlay", UIParent)
            if not hearthingOverlayFrame then return end
            
            hearthingOverlayFrame:SetFrameStrata("DIALOG")
            --hearthingOverlayFrame:SetAllPoints(UIParent)

            hearthingOverlayFrame.texture = hearthingOverlayFrame:CreateTexture(nil, "ARTWORK")
            if not hearthingOverlayFrame.texture then return end
            
            hearthingOverlayFrame.texture:SetAllPoints()
            hearthingOverlayFrame.texture:SetTexture("Interface\\AddOns\\UltraHardcore\\Textures\\RoachOverlay.png")
            hearthingOverlayFrame:SetSize(1024, 1024)
            hearthingOverlayFrame:SetPoint('CENTER')
            hearthingOverlayFrame:SetAlpha(0)
            hearthingOverlayFrame:Hide()
        end)

        if not success then
            print("UltraHardcore: Error creating hearthing overlay frame:", err)
            return
        end
    end

    if not hearthingOverlayFrame then return end

    hearthingOverlayFrame:Show()
    UIFrameFadeIn(hearthingOverlayFrame, 0.3, 0, 1)
    
    C_Timer.After(9.0, function()
        HideHearthingOverlay()
    end)
end

function HideHearthingOverlay()
    if hearthingOverlayFrame and hearthingOverlayFrame:IsShown() then
        UIFrameFadeOut(hearthingOverlayFrame, 0.3, 1, 0)
    end
end