-- Create the button
local button = CreateFrame("Button", "GameMenuButtonUltraHardcore", GameMenuFrame, "GameMenuButtonTemplate")
button:SetText("Ultra Hardcore")

-- Set initial position
button:SetPoint("TOP", GameMenuFrame, "TOP", 0, 0)

-- Set the click handler
button:SetScript("OnClick", function()
    -- Hide the game menu
    HideUIPanel(GameMenuFrame)
    -- Toggle settings using the existing function
    ToggleSettings()
end)

-- Hook into the GameMenuFrame's OnShow event to adjust height
GameMenuFrame:HookScript("OnShow", function(self)
    -- Get current height and add our extra space
    local currentHeight = self:GetHeight()
    self:SetHeight(currentHeight )  -- Add 65 pixels to accommodate our button
    
    -- Position our button
    button:SetPoint("TOP", GameMenuFrame, "TOP", 0, -135)
    
    -- Adjust other buttons
    GameMenuButtonLogout:SetPoint("TOP", GameMenuFrame, "TOP", 0, -158)
    GameMenuButtonQuit:SetPoint("TOP", GameMenuButtonLogout, "BOTTOM", 0, -1)
    GameMenuButtonContinue:SetPoint("TOP", GameMenuButtonQuit, "BOTTOM", 0, -1)
end) 