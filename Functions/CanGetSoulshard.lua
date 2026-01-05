-- Soulshard Icon Frame
local soulshardsFrame = CreateFrame('Frame', 'UltraHardcoreSoulshardsFrame', UIParent)
soulshardsFrame:SetSize(32, 32)
-- Position above the custom resource bar (which is at BOTTOM 140)
soulshardsFrame:SetPoint('BOTTOM', UIParent, 'BOTTOM', 0, 215)
soulshardsFrame:SetFrameStrata('MEDIUM')
soulshardsFrame:SetClampedToScreen(true)
soulshardsFrame:EnableMouse(true)
soulshardsFrame:SetMovable(true)
soulshardsFrame:RegisterForDrag('LeftButton')
soulshardsFrame:Hide()

local soulshardsIcon = soulshardsFrame:CreateTexture(nil, 'ARTWORK')
soulshardsIcon:SetAllPoints()
soulshardsIcon:SetTexture('Interface\\Icons\\spell_shadow_felmending')
soulshardsFrame.icon = soulshardsIcon

-- Tooltip for soulshard icon
soulshardsFrame:SetScript('OnEnter', function(self)
  GameTooltip:SetOwner(self, 'ANCHOR_TOP')
  GameTooltip:SetText('Soulshard Harvestable', 1, 1, 1)
  GameTooltip:AddLine('This enemy will grant a soulshard upon defeat', 0.7, 0.7, 0.7)
  GameTooltip:Show()
end)

soulshardsFrame:SetScript('OnLeave', function(self)
  GameTooltip:Hide()
end)

-- Position persistence functions
local function SaveSoulshardPosition()
  if not UltraHardcoreDB then return end

  local point, _, relPoint, x, y = soulshardsFrame:GetPoint()
  UltraHardcoreDB.soulshardPosition = {
    point = point,
    relPoint = relPoint,
    x = x,
    y = y,
  }
end

local function LoadSoulshardPosition()
  if not UltraHardcoreDB then
    return -- Database not initialized yet, skip loading
  end

  local pos = UltraHardcoreDB.soulshardPosition
  soulshardsFrame:ClearAllPoints()
  if pos then
    local point = pos.point or 'BOTTOM'
    local relPoint = pos.relPoint or 'BOTTOM'
    local x = pos.x or 0
    local y = pos.y or 215
    soulshardsFrame:SetPoint(point, UIParent, relPoint, x, y)
  else
    soulshardsFrame:SetPoint('BOTTOM', UIParent, 'BOTTOM', 0, 215)
  end
end

local function ResetSoulshardPosition()
  soulshardsFrame:ClearAllPoints()
  soulshardsFrame:SetPoint('BOTTOM', UIParent, 'BOTTOM', 0, 215)
  if UltraHardcoreDB then
    UltraHardcoreDB.soulshardPosition = nil
  end
  print('|cfff44336[ULTRA]|r Soulshard Indicator position reset.')
end

-- Make ResetSoulshardPosition globally accessible for combined reset commands
_G.ResetSoulshardPosition = ResetSoulshardPosition

-- Drag handlers with lock support
soulshardsFrame:SetScript('OnDragStart', function(self)
  if GLOBAL_SETTINGS and not GLOBAL_SETTINGS.lockSoulshardPosition then
    self:StartMoving()
  end
end)

soulshardsFrame:SetScript('OnDragStop', function(self)
  self:StopMovingOrSizing()
  SaveSoulshardPosition()
end)

-- Load position after database is initialized
-- Defer loading until PLAYER_LOGIN to ensure database is ready
local loadPositionFrame = CreateFrame('Frame')
loadPositionFrame:RegisterEvent('PLAYER_LOGIN')
loadPositionFrame:SetScript('OnEvent', function()
  C_Timer.After(0.1, function()
    LoadSoulshardPosition()
  end)
end)

-- You can change this to anything. I used the felmending icon for visibility.
local SOULSHARD_ICON_PATH = 'Interface\\Icons\\spell_shadow_felmending'

local function playerKnowsDrainSoul()
  -- Check if player knows the Drain Soul spell (required for soulshard harvesting)
  local playerKnowsDrainSoul = IsSpellKnown(1120)
  if not playerKnowsDrainSoul then
    return false
  end
  return true
end

local function playerLevelRange(playerLevel)
  --[[
		Credit to Tulhur for providing this level range table:
		1-10  ┃ Playerlevel-4
		10-19 ┃ Playerlevel-5
		20-29 ┃ Playerlevel-6
		30-39 ┃ Playerlevel-7
		40-44 ┃ Playerlevel-8
		45-49 ┃ Playerlevel-10
		50-55 ┃ Playerlevel-11
		56-60 ┃ Playerlevel-12
	]] --

  local levelDifference = 0
  if playerLevel >= 1 and playerLevel <= 9 then
    levelDifference = 4
  elseif playerLevel >= 10 and playerLevel <= 19 then
    levelDifference = 5
  elseif playerLevel >= 20 and playerLevel <= 29 then
    levelDifference = 6
  elseif playerLevel >= 30 and playerLevel <= 39 then
    levelDifference = 7
  elseif playerLevel >= 40 and playerLevel <= 44 then
    levelDifference = 8
  elseif playerLevel >= 45 and playerLevel <= 49 then
    levelDifference = 10
  elseif playerLevel >= 50 and playerLevel <= 55 then
    levelDifference = 11
  elseif playerLevel >= 56 and playerLevel <= 60 then
    levelDifference = 12
  end
  return levelDifference
end

--[[ Function to check if player can gain experience from target
    If we already have a function like this elsewhere, we can reuse it.
    Returns true if target exists and is valid for XP gain ]]
local function CanGainXPFromTarget()
  if not UnitExists('target') then
    return false
  end

  if UnitIsDead('target') then
    return false
  end

  if UnitIsPlayer('target') then
    return false
  end

  if UnitIsFriend('player', 'target') then
    return false
  end

  -- Don't gain XP from trivial enemies (grey names)
  -- UnitLevel returns nil for invalid units
  local targetLevel = UnitLevel('target')
  if not targetLevel or targetLevel < 0 then
    return false
  end

  local playerLevel = UnitLevel('player')

  local levelDifference = playerLevelRange(playerLevel)

  -- Target is trivial only if it's MORE than levelDifference levels below
  -- So a target at (playerLevel - levelDifference) is still worth XP
  if targetLevel < (playerLevel - levelDifference) then
    return false
  end

  return true
end

-- Function to check if player can get a soulshard from current target
-- This checks both conditions: is warlock AND can gain XP from target
function CanGetSoulshardFromTarget()
  return CanGainXPFromTarget() and playerKnowsDrainSoul()
end

-- Function to update soulshard icon visibility
local function UpdateSoulshardsIcon()
  if not GLOBAL_SETTINGS.showSoulshardIndicator then
    soulshardsFrame:Hide()
    return
  elseif CanGetSoulshardFromTarget() then
    soulshardsFrame:Show()
    return
  else
    soulshardsFrame:Hide()
    return
  end
end

local updateFrame = CreateFrame('Frame')
updateFrame:RegisterEvent('PLAYER_TARGET_CHANGED')
updateFrame:RegisterEvent('UNIT_LEVEL')
updateFrame:RegisterEvent('PLAYER_LOGIN')
updateFrame:RegisterEvent('PLAYER_ENTERING_WORLD')
updateFrame:RegisterEvent('UNIT_HEALTH')

updateFrame:SetScript('OnEvent', function(self, event, unit)
  local playerKnowsDrainSoul = playerKnowsDrainSoul()
  if not playerKnowsDrainSoul then return end

  -- Always update on target change and login events
  if event == 'PLAYER_TARGET_CHANGED' or event == 'PLAYER_LOGIN' or event == 'PLAYER_ENTERING_WORLD' then
    UpdateSoulshardsIcon()
    return
  end

  -- Update on level changes for player or target
  if event == 'UNIT_LEVEL' and (unit == 'player' or unit == 'target') then
    UpdateSoulshardsIcon()
    return
  end

  -- Update on health changes for target (catches death and respawn)
  if event == 'UNIT_HEALTH' and unit == 'target' then
    UpdateSoulshardsIcon()
    return
  end
end)

-- Slash commands for soulshard position reset
SLASH_ULTRAHARDCORESOULSHARDRESET1 = '/uhcresetsoulshardindicator'
SLASH_ULTRAHARDCORESOULSHARDRESET2 = '/uhcsi'
SlashCmdList['ULTRAHARDCORESOULSHARDRESET'] = function(msg)
  ResetSoulshardPosition()
end

-- Export functions globally so other modules can use them
_G.CanGetSoulshardFromTarget = CanGetSoulshardFromTarget
_G.CanGainXPFromTarget = CanGainXPFromTarget
