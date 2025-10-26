--[[
  Route Planner Compass
  - Adds horizontal compass to the screen
]]

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

    local compassTextOffsetY = -1
    local compassTextOffsetX = 445
    local compassText = compassMask:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    compassText:SetPoint("CENTER", compassTextOffsetX, compassTextOffsetY)
    local distance = string.rep(" ", 20)
    local directions = "N" .. distance .. "NE" .. distance .. "E" .. distance .. "SE" .. distance .. "S" .. distance .. "SW" .. distance .. "W" .. distance .. "NW" .. distance
    compassText:SetText(directions .. directions .. directions)

    local marker = compassMask:CreateTexture(nil, "OVERLAY")
    marker:SetSize(12, 20)
    marker:SetPoint("CENTER", 0, -18)
    marker:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcon_1")

    local totalTextWidth = compassText:GetStringWidth() / 3
    local compassSpeed = totalTextWidth / (1.834 * math.pi)

    compassFrame:SetScript("OnUpdate", function()
        local facing = GetPlayerFacing()
        if facing then
            local offset = facing * compassSpeed
            compassText:ClearAllPoints()
            compassText:SetPoint("CENTER", compassMask, "CENTER", -offset + compassTextOffsetX, compassTextOffsetY)
        end
    end)
end

function SetRoutePlannerCompass(compassEnabled)
  if compassEnabled then
    createCompass()
end
end

