local UltraToTFrame = nil

local function SaveUltraToTPosition()
  if not UltraToTFrame then return end
  -- Save position
  local point, relativeTo, relativePoint, xOfs, yOfs = UltraToTFrame:GetPoint()
  GLOBAL_SETTINGS.showTargetOfTargetPosition = {
    point = point,
    relativeTo = relativeTo and relativeTo:GetName() or "UIParent",
    relativePoint = relativePoint,
    x = xOfs,
    y = yOfs
  }
  SaveCharacterSettings(GLOBAL_SETTINGS)
end

-- Custom ToT Frame (portrait only)
local function CreateUltraToTFrame()
  UltraToTFrame = CreateFrame("Button", "UltraToTFrame", UIParent, "SecureActionButtonTemplate")
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
      SaveUltraToTPosition()
    end
  end)
end

-- Restore position on login
local function RestoreUltraToTPosition()
  if GLOBAL_SETTINGS and GLOBAL_SETTINGS.showTargetOfTargetPosition then
    local p = GLOBAL_SETTINGS.showTargetOfTargetPosition
    local rel = _G[p.relativeTo] or UIParent
    UltraToTFrame:ClearAllPoints()
    UltraToTFrame:SetPoint(p.point, rel, p.relativePoint, p.x, p.y)
    UltraToTFrame:SetScale(GLOBAL_SETTINGS.showTargetOfTargetScale or 1.0)
  end
end


-- Update portrait visibility
local function UpdateUltraToT()
  if not GLOBAL_SETTINGS.showTargetOfTarget then return end
  -- If we are hiding the target frame it will look weird 
  -- if we still show the target of target frame.
  if GLOBAL_SETTINGS.completelyRemoveTargetFrame then return end
  if not UltraToTFrame then return end

  if UnitExists("targettarget") then
    SetPortraitTexture(UltraToTFrame.Portrait, "targettarget")
    UltraToTFrame:SetAlpha(1)
  else
    UltraToTFrame:SetAlpha(0)
  end
end

-- Hide Blizzard ToT Frame since it becomes protected
-- and we cannot hide the parts we want
local function HideBlizzardToT()
  -- A hidden frame we can parent Blizzards ToT to
  local hiddenFrame = CreateFrame("Frame")
  hiddenFrame:Hide()

  local frame = TargetFrameToT
  if frame then
    UnregisterUnitWatch(frame)
    frame:UnregisterAllEvents()
    frame:Hide()
    frame:SetParent(hiddenFrame)
  end
end

-- Reset ToT position function
local function ResetToTPosition()
  if not UltraToTFrame then return end
  -- Clear existing points first
  UltraToTFrame:ClearAllPoints()
  -- Set to default position
  UltraToTFrame:SetPoint("TOPRIGHT", TargetFrame, "BOTTOM", 20, 22) -- adjust position as desired
  -- Reset scale
  GLOBAL_SETTINGS.showTargetOfTargetScale = 1
  UltraToTFrame:SetScale(GLOBAL_SETTINGS.showTargetOfTargetScale)
  SaveUltraToTPosition()
end

-- Event handler
local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("ZONE_CHANGED_NEW_AREA")
f:RegisterEvent("PLAYER_TARGET_CHANGED")
f:RegisterEvent("UNIT_TARGET")
f:SetScript("OnEvent", UpdateUltraToT)

local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
initFrame:SetScript("OnEvent", function()
  -- Initial run (for first login)
  C_Timer.After(0.5, function()
    HideBlizzardToT()
    CreateUltraToTFrame()
    RestoreUltraToTPosition()
    UpdateUltraToT()
  end)
  initFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
end)

-- Slash command to reset ToT position
-- TODO  move all our slash commands to a common file under the /ultra prefix
SLASH_ULTRA1 = "/ultra"
SlashCmdList["ULTRA"] = function(msg)
  if msg == "reset tot" then
    print("ULTRA ToT position reset")
    ResetToTPosition()
  end
end