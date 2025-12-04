local UltraToTFrame = nil

-- TODO:  Is there a better way to make a context menu??
local dropdown = CreateFrame("Frame", "UltraToTDropdown", UIParent, "UIDropDownMenuTemplate")
dropdown.displaymode = "MENU"

-- Ensure the menu closes if something else causes it to hide
dropdown:SetScript("OnHide", function(self)
  CloseDropDownMenus()
end)

-- Create a click-catcher frame that covers the whole screen when the menu is open
-- if you click somewhere other than the menu we will close the context menu
local clickCatcher = CreateFrame("Frame", nil, UIParent)
clickCatcher:SetAllPoints(UIParent)
clickCatcher:Hide()
clickCatcher:EnableMouse(true)
clickCatcher:SetScript("OnMouseDown", function()
  CloseDropDownMenus()
  clickCatcher:Hide()
end)

-- Save position in settings
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

-- Reset ToT position in case you threw it away
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

-- Setup a dropdown on the ToT frame with some options
-- TODO:  Is there a better way to create context menus?
local function InitializeToTMenu(self, level)
  local info = UIDropDownMenu_CreateInfo()
  info.notCheckable = true  -- no radio/check button
  info.keepShownOnClick = false  -- auto-hide after click
  
  -- Lock/Unlock toggle
  info.text = GLOBAL_SETTINGS.showTargetOfTargetLocked and "Unlock Frame" or "Lock Frame"
  info.func = function()
    GLOBAL_SETTINGS.showTargetOfTargetLocked = not GLOBAL_SETTINGS.showTargetOfTargetLocked
    UltraToTFrame:UpdateMovableState()
  end
  UIDropDownMenu_AddButton(info, level)
  -- Reset Position
  info.text = "Reset Position/Scale"
  info.func = function()
    ResetToTPosition()
  end
  UIDropDownMenu_AddButton(info, level)
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
    if not InCombatLockdown() and not GLOBAL_SETTINGS.showTargetOfTargetLocked then
      self:StartMoving()
    end
  end)

  UltraToTFrame:SetScript("OnDragStop", function(self)
    if not InCombatLockdown() then
      self:StopMovingOrSizing()
      SaveUltraToTPosition()
    end
  end)

  -- Right-click handler
  UltraToTFrame:SetScript("OnMouseUp", function(self, button)
    if button == "RightButton" then
      CloseDropDownMenus() -- close any existing menus first
      UIDropDownMenu_Initialize(dropdown, InitializeToTMenu, "MENU")
      ToggleDropDownMenu(1, nil, dropdown, "cursor", 0, 0)
      clickCatcher:Show()  -- enable click-catcher to close menu immediately
    end
  end)

  function UltraToTFrame:UpdateMovableState()
    if GLOBAL_SETTINGS.showTargetOfTargetLocked then
      self:SetMovable(false)
      self:EnableMouse(true)
      self:RegisterForDrag()
    else
      self:SetMovable(true)
      self:EnableMouse(true)
      self:RegisterForDrag("LeftButton")
    end
    -- save locked/unlocked state
    SaveCharacterSettings(GLOBAL_SETTINGS)
  end
end

-- Restore position on login
local function RestoreUltraToTPosition()
  if GLOBAL_SETTINGS and GLOBAL_SETTINGS.showTargetOfTargetPosition then
    local p = GLOBAL_SETTINGS.showTargetOfTargetPosition
    local rel = _G[p.relativeTo] or UIParent
    if not p.point then
      ResetToTPosition()
      return
    end
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
    UIDropDownMenu_Initialize(dropdown, InitializeToTMenu, "MENU")
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