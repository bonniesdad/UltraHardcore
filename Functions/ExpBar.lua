-- XP Bar Module for UltraHardcore
-- Creates a customizable experience bar at the top of the screen

local UHC_XPBar = {}
local xpBarFrame = nil
local xpBarBackground = nil
local xpBarFill = nil
local xpBarDot = nil

-- Configuration
local BAR_HEIGHT = 3

-- Initialize the XP Bar
function UHC_XPBar:Initialize()
    if xpBarFrame then
        return -- Already initialized
    end
    
    
    -- Create main frame that spans full screen width
    xpBarFrame = CreateFrame("Frame", "UHC_XPBarFrame", UIParent)
    xpBarFrame:SetHeight(BAR_HEIGHT)
    xpBarFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 0, 0)
    xpBarFrame:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", 0, 0)
    xpBarFrame:SetFrameStrata("HIGH")
    xpBarFrame:Show() -- Ensure it's visible
    
    -- Create background
    xpBarBackground = xpBarFrame:CreateTexture(nil, "BACKGROUND")
    xpBarBackground:SetAllPoints(xpBarFrame)
    xpBarBackground:SetColorTexture(0, 0, 0, 0.8) -- Black background with transparency
    
    -- Create border
    local border = xpBarFrame:CreateTexture(nil, "BORDER")
    border:SetAllPoints(xpBarFrame)
    border:SetColorTexture(0.3, 0.3, 0.3, 1) -- Gray border
    
    -- Adjust background to be slightly smaller for border effect
    xpBarBackground:SetPoint("TOPLEFT", xpBarFrame, "TOPLEFT", 1, -1)
    xpBarBackground:SetPoint("BOTTOMRIGHT", xpBarFrame, "BOTTOMRIGHT", -1, 1)
    
    -- Create XP fill bar
    xpBarFill = xpBarFrame:CreateTexture(nil, "ARTWORK")
    xpBarFill:SetPoint("TOPLEFT", xpBarBackground, "TOPLEFT", 0, 0)
    xpBarFill:SetPoint("BOTTOMLEFT", xpBarBackground, "BOTTOMLEFT", 0, 0)
    -- Use default blue color, will be overridden by settings
    xpBarFill:SetColorTexture(0.2, 0.6, 1.0, 0.8)
    xpBarFill:SetWidth(0) -- Start with no fill
    
    -- Create XP position indicator dot
    xpBarDot = xpBarFrame:CreateTexture(nil, "OVERLAY")
    xpBarDot:SetSize(6, 6) -- Slightly larger to see texture detail
    -- Use your custom circular PNG texture
    xpBarDot:SetTexture("Interface\\AddOns\\UltraHardcore\\Textures\\circle-with-border.png")
    -- Don't crop the texture coordinates since your PNG should already be circular
    -- xpBarDot:SetTexCoord(0.25, 0.75, 0.25, 0.75)
    -- Don't set vertex color initially - let the texture show as-is first
    -- xpBarDot:SetVertexColor(0.0, 0.4, 1.0, 1.0) -- We'll set this in SetBarColor
    -- Start at the left edge
    xpBarDot:SetPoint("CENTER", xpBarFrame, "LEFT", 0, 0)
    
    -- Register for experience events
    xpBarFrame:RegisterEvent("PLAYER_XP_UPDATE")
    xpBarFrame:RegisterEvent("PLAYER_LEVEL_UP")
    xpBarFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    
    -- Set up event handler
    xpBarFrame:SetScript("OnEvent", function(self, event, ...)
        UHC_XPBar:UpdateXPBar()
    end)
    
    -- Add tooltip functionality
    xpBarFrame:EnableMouse(true)
    xpBarFrame:SetScript("OnEnter", function(self)
        -- Only show tooltip if the setting is enabled
        if GLOBAL_SETTINGS.showXpBarToolTip and UHC_XPBar.currentXP and UHC_XPBar.maxXP then
            GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
            local level = UnitLevel("player")
            if level >= GetMaxPlayerLevel() then
                GameTooltip:SetText("Experience: MAX LEVEL")
            else
                local displayText = string.format("Experience: %.1f%% (%s / %s)", 
                    UHC_XPBar.xpPercent or 0, 
                    UHC_XPBar:FormatNumber(UHC_XPBar.currentXP), 
                    UHC_XPBar:FormatNumber(UHC_XPBar.maxXP)
                )
                GameTooltip:SetText(displayText)
            end
            GameTooltip:Show()
        end
    end)
    
    xpBarFrame:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)
    
    -- Initial update
    UHC_XPBar:UpdateXPBar()
    
    -- Delayed update to ensure frame is properly sized
    C_Timer.After(0.1, function()
        UHC_XPBar:UpdateXPBar()
    end)
    
end

-- Update the XP bar display
function UHC_XPBar:UpdateXPBar()
    if not xpBarFrame then
        print("UHC XP Bar: UpdateXPBar called but frame doesn't exist")
        return
    end
    
    local currentXP = UnitXP("player")
    local maxXP = UnitXPMax("player")
    local level = UnitLevel("player")
    
    
    -- Get the actual frame width
    local frameWidth = xpBarFrame:GetWidth()
    
    
    -- If frame width is 0 or nil, use screen width as fallback
    if not frameWidth or frameWidth <= 0 then
        frameWidth = UIParent:GetWidth() or 1024
    end
    
    -- Handle max level characters
    if level >= GetMaxPlayerLevel() then
        -- Max level, hide the bar
        xpBarFill:SetWidth(0)
        xpBarDot:ClearAllPoints()
        xpBarDot:SetPoint("CENTER", xpBarFrame, "LEFT", 0, 0)
        return
    end
    
    -- Calculate percentage
    local xpPercent = 0
    if maxXP > 0 then
        xpPercent = (currentXP / maxXP) * 100
    end
    
    
    -- Update fill bar width
    local fillWidth = 0
    if maxXP > 0 then
        fillWidth = ((currentXP / maxXP) * (frameWidth - 2))
    end
    
    xpBarFill:SetWidth(math.max(0, fillWidth))
    
    -- Update dot position to show current XP location
    local dotPosition = 1 -- Start at left edge (1 pixel from left to account for border)
    if maxXP > 0 then
        dotPosition = 1 + ((currentXP / maxXP) * (frameWidth - 2))
    end
    xpBarDot:ClearAllPoints()
    xpBarDot:SetPoint("CENTER", xpBarFrame, "LEFT", dotPosition, 0)
    
    -- Set XP bar color (configurable through settings)
    UHC_XPBar:SetBarColor()
    
    -- Store XP info for tooltip
    UHC_XPBar.currentXP = currentXP
    UHC_XPBar.maxXP = maxXP
    UHC_XPBar.xpPercent = xpPercent
end

-- Set the XP bar color based on settings
function UHC_XPBar:SetBarColor()
    -- Default blue color - matches classic WoW experience bar
    local r, g, b, a = 0.0, 0.4, 1.0, 0.9
    
    -- Check if there are custom color settings in resourceBarColors
    if GLOBAL_SETTINGS and GLOBAL_SETTINGS.resourceBarColors and GLOBAL_SETTINGS.resourceBarColors.EXPBAR then
        local color = GLOBAL_SETTINGS.resourceBarColors.EXPBAR
        r = color[1] or r
        g = color[2] or g
        b = color[3] or b
    end
    
    xpBarFill:SetColorTexture(r, g, b, a)
    
    -- For a custom PNG texture, we have a few options:
    if xpBarDot then
        -- Option 1: Don't color the dot, let the texture show as-is
        -- xpBarDot:SetVertexColor(1, 1, 1, 1.0) -- White = no color change
        
        -- Option 2: Tint the texture (multiply colors - works if your PNG is white/light)
        xpBarDot:SetVertexColor(r, g, b, 1.0)
        
        -- Option 3: If you want the texture to show without coloring, uncomment this:
        -- xpBarDot:SetVertexColor(1, 1, 1, 1.0)
    end
end

-- Format numbers with commas for better readability
function UHC_XPBar:FormatNumber(num)
    if not num then return "0" end
    
    local formatted = tostring(num)
    local k = 1
    
    -- Add commas every 3 digits
    while k < string.len(formatted) do
        if (string.len(formatted) - k) % 3 == 0 and k > 1 then
            formatted = string.sub(formatted, 1, k - 1) .. "," .. string.sub(formatted, k)
            k = k + 1
        end
        k = k + 1
    end
    
    return formatted
end

-- Show the XP bar
function UHC_XPBar:Show()
    if xpBarFrame then
        xpBarFrame:Show()
    end
end

-- Hide the XP bar
function UHC_XPBar:Hide()
    if xpBarFrame then
        xpBarFrame:Hide()
    end
end

-- Toggle XP bar visibility
function UHC_XPBar:Toggle()
    if not xpBarFrame then
        UHC_XPBar:Initialize()
    end
    
    if xpBarFrame:IsShown() then
        UHC_XPBar:Hide()
    else
        UHC_XPBar:Show()
    end
end

-- Cleanup function
function UHC_XPBar:Destroy()
    if xpBarFrame then
        xpBarFrame:UnregisterAllEvents()
        xpBarFrame:Hide()
        xpBarFrame = nil
        xpBarBackground = nil
        xpBarFill = nil
        xpBarDot = nil
    end
end

-- Global functions for external access
function InitializeExpBar()
    UHC_XPBar:Initialize()
end

function ShowExpBar()
    UHC_XPBar:Show()
end

function HideExpBar()
    UHC_XPBar:Hide()
end

function ToggleExpBar()
    UHC_XPBar:Toggle()
end

function UpdateExpBar()
    UHC_XPBar:UpdateXPBar()
end

function UpdateExpBarColor()
    if xpBarFrame and xpBarFrame:IsShown() then
        UHC_XPBar:SetBarColor()
    end
end

-- Slash command for testing
SLASH_UHCXPBAR1 = "/uhcxp"
SlashCmdList["UHCXPBAR"] = function(msg)
    if msg == "show" then
        print("UHC XP Bar: Manual show command")
        InitializeExpBar()
        ShowExpBar()
    elseif msg == "hide" then
        print("UHC XP Bar: Manual hide command")
        HideExpBar()
    elseif msg == "toggle" then
        print("UHC XP Bar: Manual toggle command")
        ToggleExpBar()
    elseif msg == "test" then
        print("UHC XP Bar: Test - Frame exists:", xpBarFrame ~= nil)
        if xpBarFrame then
            print("UHC XP Bar: Frame is shown:", xpBarFrame:IsShown())
            print("UHC XP Bar: Frame size:", xpBarFrame:GetWidth(), "x", xpBarFrame:GetHeight())
        end
        print("UHC XP Bar: Setting enabled:", GLOBAL_SETTINGS and GLOBAL_SETTINGS.showExpBar)
    else
        print("UHC XP Bar Commands:")
        print("/uhcxp show - Show XP bar")
        print("/uhcxp hide - Hide XP bar") 
        print("/uhcxp toggle - Toggle XP bar")
        print("/uhcxp test - Debug info")
    end
end