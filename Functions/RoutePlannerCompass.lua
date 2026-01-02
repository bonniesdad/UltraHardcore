--[[
  Route Planner Compass
  - Displays a horizontal compass in the open world
  - Automatically hides in instanced content due to GetPlayerFacing() limitations in instances
]]

local COMPASS_FRAME_NAME = 'UltraHardcoreCompassFrame'

local isCompassCreated = false
local compassFrame

-- Visibility logic
local function UpdateCompassVisibility()
  if not compassFrame then return end

  local _, instanceType = IsInInstance()
  if instanceType == 'none' then
    compassFrame:Show()
  else
    compassFrame:Hide()
  end
end

local function createCompassText(parent, offsetX, text)
  local compassText = parent:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightLarge')
  compassText:SetFontHeight(18)
  compassText:SetPoint('CENTER', offsetX, 0)
  compassText:SetText(text)
end

-- Compass creation
local function createCompass()
  if isCompassCreated then return end

  local width = 400
  local height = 30

  compassFrame = CreateFrame('Frame', COMPASS_FRAME_NAME, UIParent)
  compassFrame:SetSize(width, height)
  compassFrame:SetPoint('TOP', 0, -25)

  local background = compassFrame:CreateTexture(nil, 'BACKGROUND')
  background:SetAllPoints(true)
  background:SetColorTexture(0, 0, 0, 0.3)

  local borderSize = 3
  local borderAlpha = 0.5

  local top = compassFrame:CreateTexture(nil, 'OVERLAY')
  top:SetColorTexture(0, 0, 0, borderAlpha)
  top:SetPoint('TOPLEFT')
  top:SetPoint('TOPRIGHT')
  top:SetHeight(borderSize)

  local bottom = compassFrame:CreateTexture(nil, 'OVERLAY')
  bottom:SetColorTexture(0, 0, 0, borderAlpha)
  bottom:SetPoint('BOTTOMLEFT')
  bottom:SetPoint('BOTTOMRIGHT')
  bottom:SetHeight(borderSize)

  local left = compassFrame:CreateTexture(nil, 'OVERLAY')
  left:SetColorTexture(0, 0, 0, borderAlpha / 2)
  left:SetPoint('LEFT')
  left:SetWidth(borderSize)
  left:SetHeight(height - borderSize * 2)

  local right = compassFrame:CreateTexture(nil, 'OVERLAY')
  right:SetColorTexture(0, 0, 0, borderAlpha / 2)
  right:SetPoint('RIGHT')
  right:SetWidth(borderSize)
  right:SetHeight(height - borderSize * 2)

  local compassMask = CreateFrame('Frame', nil, compassFrame)
  compassMask:SetPoint('CENTER')
  compassMask:SetSize(width - borderSize * 2, height - borderSize * 2)
  compassMask:SetClipsChildren(true)

  local compassContent = CreateFrame('Frame', nil, compassMask)
  local compassContentWidth = width * 2.5
  compassContent:SetSize(compassContentWidth, height)

  local directionDistance = compassContentWidth / (math.pi * 2)

  createCompassText(compassContent, 2, 'N')
  createCompassText(compassContent, directionDistance, 'NE')
  createCompassText(compassContent, directionDistance * 2, 'E')
  createCompassText(compassContent, directionDistance * 3, 'SE')
  createCompassText(compassContent, directionDistance * 4, 'S')
  createCompassText(compassContent, directionDistance * 5, 'SW')
  createCompassText(compassContent, directionDistance * 6, 'W')
  createCompassText(compassContent, directionDistance * 7, 'NW')
  createCompassText(compassContent, directionDistance * 8, 'N')
  createCompassText(compassContent, directionDistance * 9, 'NE')

  createCompassText(compassContent, directionDistance * -1, 'NW')
  createCompassText(compassContent, directionDistance * -2, 'W')
  createCompassText(compassContent, directionDistance * -3, 'SW')
  createCompassText(compassContent, directionDistance * -4, 'S')
  createCompassText(compassContent, directionDistance * -5, 'SE')
  createCompassText(compassContent, directionDistance * -6, 'E')
  createCompassText(compassContent, directionDistance * -7, 'NE')
  createCompassText(compassContent, directionDistance * -8, 'N')
  createCompassText(compassContent, directionDistance * -9, 'NW')

  local marker = compassMask:CreateTexture(nil, 'OVERLAY')
  marker:SetSize(12, 20)
  marker:SetPoint('CENTER', 0, -18)
  marker:SetTexture('Interface\\TargetingFrame\\UI-RaidTargetingIcon_1')

  local compassSpeed = directionDistance * 1.27
  compassFrame:SetScript('OnUpdate', function()
    local facing = GetPlayerFacing()
    if not facing then return end

    local offset = facing * compassSpeed
    compassContent:ClearAllPoints()
    compassContent:SetPoint('CENTER', compassMask, 'CENTER', offset, -1)
  end)

  isCompassCreated = true
  UpdateCompassVisibility()
end

function SetRoutePlannerCompass(enabled)
  if enabled and not isCompassCreated then
    createCompass()
  elseif not enabled and compassFrame then
    compassFrame:Hide()
  end
end

-- Update logic
local eventFrame = CreateFrame('Frame')
eventFrame:RegisterEvent('PLAYER_ENTERING_WORLD')
eventFrame:RegisterEvent('ZONE_CHANGED_NEW_AREA')

eventFrame:SetScript('OnEvent', function()
  UpdateCompassVisibility()
end)
