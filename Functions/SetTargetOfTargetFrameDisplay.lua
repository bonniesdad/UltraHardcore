-- ============================
-- Custom ToT Frame (portrait only)
-- ============================
local UltraToTFrame = CreateFrame("Button", "UltraToTFrame", UIParent, "SecureActionButtonTemplate")
UltraToTFrame:SetSize(32, 32)
UltraToTFrame:SetPoint("TOPRIGHT", TargetFrame, "BOTTOM", 20, 22) -- adjust position as desired

-- Make it clickable to target your target's target
UltraToTFrame:SetAttribute("type", "target")
UltraToTFrame:SetAttribute("unit", "targettarget")

-- Portrait texture
UltraToTFrame.Portrait = UltraToTFrame:CreateTexture(nil, "BACKGROUND")
UltraToTFrame.Portrait:SetAllPoints(UltraToTFrame)

-- Make UltraToTFrame movable
UltraToTFrame:SetMovable(true)
UltraToTFrame:EnableMouse(true)
UltraToTFrame:RegisterForDrag("LeftButton")
UltraToTFrame:SetClampedToScreen(true)

UltraToTFrame:SetScript("OnDragStart", function(self)
    if not InCombatLockdown() then
        self:StartMoving()
    end
end)

UltraToTFrame:SetScript("OnDragStop", function(self)
    if not InCombatLockdown() then
      self:StopMovingOrSizing()
    end

    -- Save position
    --local point, relativeTo, relativePoint, xOfs, yOfs = self:GetPoint()
    --UltraToTFrameDB = UltraToTFrameDB or {}
    --UltraToTFrameDB.point = { point, relativePoint, xOfs, yOfs }
end)

-- Restore position on login
local function RestoreUltraToTPosition()
    if UltraToTFrameDB and UltraToTFrameDB.point then
        local p = UltraToTFrameDB.point
        UltraToTFrame:ClearAllPoints()
        UltraToTFrame:SetPoint(p[1], UIParent, p[2], p[3], p[4])
    end
end


-- Update portrait visibility
local function UpdateMyToT()
  if UnitExists("targettarget") then
    SetPortraitTexture(UltraToTFrame.Portrait, "targettarget")
    UltraToTFrame:SetAlpha(1)
  else
    UltraToTFrame:SetAlpha(0)
  end
end

-- Hide Blizzard's TargetOfTarget Frame
local function HideBlizzardToT()
  local frame = TargetFrameToT
  if frame then
    UnregisterUnitWatch(frame)
    frame:UnregisterAllEvents()
    frame:Hide()
  end
end

-- ============================
-- Event handler
-- ============================
local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("ZONE_CHANGED_NEW_AREA")
f:RegisterEvent("PLAYER_TARGET_CHANGED")
f:RegisterEvent("UNIT_TARGET")
f:SetScript("OnEvent", UpdateMyToT)

local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
initFrame:SetScript("OnEvent", function()
  -- Initial run (for first login)
  C_Timer.After(0.5, function()
    HideBlizzardToT()
    UpdateMyToT()
  end)
  initFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
end)
