--[[
  Route Planner Compass
  - Adds horizontal compass to the screen
]]


function createCompassText(parent, offsetX, text)
    local compassText = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    compassText:SetFontHeight(18)
    compassText:SetPoint("CENTER", offsetX, 0)
    compassText:SetText(text)
end

function createCompass()
    local width = 400
    local height = 30

    local compassFrame = CreateFrame("Frame", nil, UIParent)
    compassFrame:SetSize(width, height)
    compassFrame:SetPoint("TOP", 0, -25)

    local background = compassFrame:CreateTexture(nil, "BACKGROUND")
    background:SetAllPoints(true)
    background:SetColorTexture(0, 0, 0, 0.3)

    local borderSize = 3
    local borderAlpha = 0.5

    local top = compassFrame:CreateTexture(nil, "OVERLAY")
    top:SetColorTexture(0, 0, 0, borderAlpha)
    top:SetPoint("TOPLEFT")
    top:SetPoint("TOPRIGHT")
    top:SetHeight(borderSize)

    local bottom = compassFrame:CreateTexture(nil, "OVERLAY")
    bottom:SetColorTexture(0, 0, 0, borderAlpha)
    bottom:SetPoint("BOTTOMLEFT")
    bottom:SetPoint("BOTTOMRIGHT")
    bottom:SetHeight(borderSize)

    local left = compassFrame:CreateTexture(nil, "OVERLAY")
    left:SetColorTexture(0, 0, 0, borderAlpha / 2)
    left:SetPoint("LEFT")
    left:SetWidth(borderSize)
    left:SetHeight(height - borderSize * 2)

    local right = compassFrame:CreateTexture(nil, "OVERLAY")
    right:SetColorTexture(0, 0, 0, borderAlpha / 2)
    right:SetPoint("RIGHT")
    right:SetWidth(borderSize)
    right:SetHeight(height - borderSize * 2)


    local compassMask = CreateFrame("Frame", nil, compassFrame)
    compassMask:SetPoint("CENTER")
    compassMask:SetSize(width - borderSize * 2, height - borderSize * 2)
    compassMask:SetClipsChildren(true)

    local compassContent = CreateFrame("Frame", nil, compassMask)
    local compassContentWidth = width * 2.5
    compassContent:SetSize(compassContentWidth, height)

    local directionDistance = compassContentWidth / (math.pi * 2)

    -- offset(2) here needed due to jump when going from 6.28 radians to 0 radians
    createCompassText(compassContent, 2, "N")

    createCompassText(compassContent, directionDistance, "NE")
    createCompassText(compassContent, directionDistance * 2, "E")
    createCompassText(compassContent, directionDistance * 3, "SE")
    createCompassText(compassContent, directionDistance * 4, "S")
    createCompassText(compassContent, directionDistance * 5, "SW")
    createCompassText(compassContent, directionDistance * 6, "W")
    createCompassText(compassContent, directionDistance * 7, "NW")
    createCompassText(compassContent, directionDistance * 8, "N")
    createCompassText(compassContent, directionDistance * 9, "NE")

    createCompassText(compassContent, directionDistance * -1, "NW")
    createCompassText(compassContent, directionDistance * -2, "W")
    createCompassText(compassContent, directionDistance * -3, "SW")
    createCompassText(compassContent, directionDistance * -4, "S")
    createCompassText(compassContent, directionDistance * -5, "SE")
    createCompassText(compassContent, directionDistance * -6, "E")
    createCompassText(compassContent, directionDistance * -7, "NE")
    createCompassText(compassContent, directionDistance * -8, "N")
    createCompassText(compassContent, directionDistance * -9, "NW")

    local marker = compassMask:CreateTexture(nil, "OVERLAY")
    marker:SetSize(12, 20)
    marker:SetPoint("CENTER", 0, -18)
    marker:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcon_1")

    local compassSpeed = directionDistance * 1.27
    compassFrame:SetScript("OnUpdate", function()
        local facing = GetPlayerFacing()
        if facing then
	            local offset = facing * compassSpeed
	            compassContent:ClearAllPoints()
	            compassContent:SetPoint("CENTER", compassMask, "CENTER", offset, -1)
        end
    end)
end

local isCompassCreated = false
function SetRoutePlannerCompass(compassEnabled)
  if compassEnabled and not isCompassCreated then
    createCompass()
    isCompassCreated = true
  end
end

