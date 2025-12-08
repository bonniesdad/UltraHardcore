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
soulshardsFrame:SetScript("OnDragStart", soulshardsFrame.StartMoving)
soulshardsFrame:SetScript("OnDragStop", soulshardsFrame.StopMovingOrSizing)

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


-- You can change this to anything. I used the felmending icon for visibility.
local SOULSHARD_ICON_PATH = "Interface\\Icons\\spell_shadow_felmending"

-- Function to check if player is a warlock
local function IsPlayerWarlock()
	local _, classToken = UnitClass("player")
	return classToken == "WARLOCK"
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

	-- For levels below 10, consider all enemies valid, the player doesn't have soul siphon spell yet
	if playerLevel < 10 then
		return true
	end

	-- For level 10+, check the level difference threshold
	-- This varies by expansion, but we use this formula based on WoW mechanics -> Thanks to @tulhur for the table reference
	local levelDifference = 0
	if playerLevel >= 10 and playerLevel <= 19 then
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
	return IsPlayerWarlock() and CanGainXPFromTarget()
end

-- Function to update soulshard icon visibility
local function UpdateSoulshardsIcon()
	if CanGetSoulshardFromTarget() then
		soulshardsFrame:Show()
	else
		soulshardsFrame:Hide()
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


-- Export functions globally so other modules can use them
_G.CanGetSoulshardFromTarget = CanGetSoulshardFromTarget
_G.IsPlayerWarlock = IsPlayerWarlock
_G.CanGainXPFromTarget = CanGainXPFromTarget
