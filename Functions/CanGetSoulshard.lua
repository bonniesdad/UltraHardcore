-- Soulshard Icon Frame
local soulshardsFrame = CreateFrame("Frame", "UltraHardcoreSoulshardsFrame", UIParent)
soulshardsFrame:SetSize(32, 32)
-- Position above the custom resource bar (which is at BOTTOM 140)
soulshardsFrame:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 215)
soulshardsFrame:SetFrameStrata("MEDIUM")
soulshardsFrame:SetClampedToScreen(true)
soulshardsFrame:EnableMouse(true)
soulshardsFrame:SetMovable(true)
soulshardsFrame:RegisterForDrag("LeftButton")

local soulshardsIcon = soulshardsFrame:CreateTexture(nil, "ARTWORK")
soulshardsIcon:SetAllPoints()
soulshardsIcon:SetTexture("Interface\\Icons\\spell_shadow_felmending")
soulshardsFrame.icon = soulshardsIcon

-- Tooltip for soulshard icon
soulshardsFrame:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_TOP")
    GameTooltip:SetText("Soulshard Harvestable", 1, 1, 1)
    GameTooltip:AddLine("This enemy will grant a soulshard upon defeat", 0.7, 0.7, 0.7)
    GameTooltip:Show()
end)

soulshardsFrame:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
end)

-- Position persistence functions
local function SaveSoulshardPosition()
    if not UltraHardcoreDB then
        UltraHardcoreDB = {}
    end

    local point, _, relPoint, x, y = soulshardsFrame:GetPoint()
    UltraHardcoreDB.soulshardPosition = { point = point, relPoint = relPoint, x = x, y = y }
end

local function LoadSoulshardPosition()
    if not UltraHardcoreDB then
        UltraHardcoreDB = {}
    end

    local pos = UltraHardcoreDB.soulshardPosition
    soulshardsFrame:ClearAllPoints()
    if pos then
        local point = pos.point or "BOTTOM"
        local relPoint = pos.relPoint or "BOTTOM"
        local x = pos.x or 0
        local y = pos.y or 215
        soulshardsFrame:SetPoint(point, UIParent, relPoint, x, y)
    else
        soulshardsFrame:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 215)
    end
end

local function ResetSoulshardPosition()
    soulshardsFrame:ClearAllPoints()
    soulshardsFrame:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 215)
    if UltraHardcoreDB then
        UltraHardcoreDB.soulshardPosition = nil
    end
    print("|cfff44336[ULTRA]|r Soulshard Indicator position reset.")
end

-- Drag handlers with lock support
soulshardsFrame:SetScript("OnDragStart", function(self)
    if GLOBAL_SETTINGS and not GLOBAL_SETTINGS.lockSoulshardPosition then
        self:StartMoving()
    end
end)

soulshardsFrame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    SaveSoulshardPosition()
end)

-- Load position on initialization
LoadSoulshardPosition()


-- You can change this to anything. I used the felmending icon for visibility.
local SOULSHARD_ICON_PATH = "Interface\\Icons\\spell_shadow_felmending"


local function playerKnowsDrainSoul()
	    -- Check if player knows the Drain Soul spell (required for soulshard harvesting)
    local playerKnowsDrainSoul = isSpellKnown(1120) 
    if not playerKnowsDrainSoul then
        return false
	end
	return true
end

local function playerLevelRange(playerLevel)
	--[[
	ZD =  5, when Char Level =  1 -  7
	ZD =  6, when Char Level =  8 -  9
	ZD =  7, when Char Level = 10 - 11
	ZD =  8, when Char Level = 12 - 15
	ZD =  9, when Char Level = 16 - 19 
	ZD = 11, when Char Level = 20 - 29
	ZD = 12, when Char Level = 30 - 39
	ZD = 13, when Char Level = 40 - 44
	ZD = 14, when Char Level = 45 - 49
	ZD = 15, when Char Level = 50 - 54
	ZD = 16, when Char Level = 55 - 59
	ZD = 17, when Char Level = 60 - 84
	]]--

	local levelDifference = 0
	if playerLevel >= 1 and playerLevel <= 7 then
		levelDifference = 5
	elseif playerLevel >= 8 and playerLevel <= 9 then
		levelDifference = 6
	elseif playerLevel >= 10 and playerLevel <= 11 then
		levelDifference = 7
	elseif playerLevel >= 12 and playerLevel <= 15 then
		levelDifference = 8
	elseif playerLevel >= 16 and playerLevel <= 19 then
		levelDifference = 9
	elseif playerLevel >= 20 and playerLevel <= 29 then
		levelDifference = 11
	elseif playerLevel >= 30 and playerLevel <= 39 then
		levelDifference = 12
	elseif playerLevel >= 40 and playerLevel <= 44 then
		levelDifference = 13
	elseif playerLevel >= 45 and playerLevel <= 49 then
		levelDifference = 14
	elseif playerLevel >= 50 and playerLevel <= 54 then
		levelDifference = 15
	elseif playerLevel >= 55 and playerLevel <= 59 then
		levelDifference = 16
	elseif playerLevel >= 60 and playerLevel <= 84 then
		levelDifference = 17
	end
	return levelDifference
end


--[[ Function to check if player can gain experience from target
    If we already have a function like this elsewhere, we can reuse it.
    Returns true if target exists and is valid for XP gain ]]
local function CanGainXPFromTarget()
	if not UnitExists("target") then
		return false
	end

	if UnitIsDead("target") then
		return false
	end

	if UnitIsPlayer("target") then
		return false
	end

	if UnitIsFriend("player", "target") then
		return false
	end

	-- Don't gain XP from trivial enemies (grey names)
	-- UnitLevel returns nil for invalid units
	local targetLevel = UnitLevel("target")
	if not targetLevel or targetLevel < 0 then
		return false
	end

	local playerLevel = UnitLevel("player")

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


local updateFrame = CreateFrame("Frame")
updateFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
updateFrame:RegisterEvent("UNIT_LEVEL")
updateFrame:RegisterEvent("PLAYER_LOGIN")
updateFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
updateFrame:RegisterEvent("UNIT_HEALTH")

updateFrame:SetScript("OnEvent", function(self, event, unit)
	-- Always update on target change and login events
	if event == "PLAYER_TARGET_CHANGED" or event == "PLAYER_LOGIN" or event == "PLAYER_ENTERING_WORLD" then
		UpdateSoulshardsIcon()
		return
	end
	
	-- Update on level changes for player or target
	if event == "UNIT_LEVEL" and (unit == "player" or unit == "target") then
		UpdateSoulshardsIcon()
		return
	end
	
	-- Update on health changes for target (catches death and respawn)
	if event == "UNIT_HEALTH" and unit == "target" then
		UpdateSoulshardsIcon()
		return
	end
end)

-- Slash commands for soulshard position reset
SLASH_ULTRAHARDCORESOULSHARDRESET1 = "/uhcresetsoulshardindicator"
SLASH_ULTRAHARDCORESOULSHARDRESET2 = "/uhcsi"
SlashCmdList["ULTRAHARDCORESOULSHARDRESET"] = function(msg)
    ResetSoulshardPosition()
end

-- Export functions globally so other modules can use them
_G.CanGetSoulshardFromTarget = CanGetSoulshardFromTarget
_G.CanGainXPFromTarget = CanGainXPFromTarget
