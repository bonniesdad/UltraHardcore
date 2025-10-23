local hearthingOverlayFrame = nil
local frameIsShowing = false

function ShowHearthingOverlay()
    if not hearthingOverlayFrame then
        local success, err = pcall(function()
            hearthingOverlayFrame = CreateFrame("Frame", "HearthOverlay", UIParent)
            if not hearthingOverlayFrame then return end
            
            hearthingOverlayFrame:SetFrameStrata("DIALOG")
            hearthingOverlayFrame:SetAllPoints(UIParent)

            hearthingOverlayFrame.texture = hearthingOverlayFrame:CreateTexture(nil, "ARTWORK")
            if not hearthingOverlayFrame.texture then return end
            
            hearthingOverlayFrame.texture:SetAllPoints()
            hearthingOverlayFrame.texture:SetTexture("Interface\\AddOns\\UltraHardcore\\Textures\\RoachOverlay.png")
        end)

        if not success then
            print("UltraHardcore: Error creating hearthing overlay frame:", err)
            return
        end
    end

    if not hearthingOverlayFrame then return end

    hearthingOverlayFrame:Show()
    UIFrameFadeIn(hearthingOverlayFrame, 0.3, 0, 1)
    frameIsShowing = true
end

function HideHearthingOverlay()
    -- Only hide if the frame exists and is currently showing based on frameIsShowing
    -- This prevents the overlay from flickering 
    if hearthingOverlayFrame and hearthingOverlayFrame:IsVisible() and frameIsShowing then
        UIFrameFadeOut(hearthingOverlayFrame, 0.3, 1, 0, function()
            hearthingOverlayFrame:SetAlpha(0)
            hearthingOverlayFrame:Hide()
        end)

        frameIsShowing = false
    end
end