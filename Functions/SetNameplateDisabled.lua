-- Nameplate Prevention System
-- When enabled, completely prevents nameplates from being turned on

-- Global frame to prevent nameplates
local nameplatePreventionFrame = nil
local originalSetCVar = SetCVar
-- local originalGetCVar = GetCVar

-- Complete list of all nameplate CVars
local nameplateCVars = {
	"nameplateShowEnemies",
	"nameplateShowAll",
	"nameplateShowFriends",
	"nameplateShowMinions",
	"nameplateShowMinor",
	"nameplateShowEnemyMinus", -- Correct CVar for minor enemy units
	"nameplateShowEnemyMinions",
	"nameplateShowEnemyPets",
	"nameplateShowEnemyGuardians",
	"nameplateShowEnemyTotems",
	"nameplateShowFriendlyMinions",
	"nameplateShowFriendlyPets",
	"nameplateShowFriendlyGuardians",
	"nameplateShowFriendlyTotems",
	"nameplateShowFriendlyNPCs",
}

local function targetValue(cvar)
	local useIcons = GLOBAL_SETTINGS.showFriendlyNameplateIcons or false
	local inInstance = IsInInstance()

	if not useIcons or inInstance then
		return 0
	end

	if cvar == "nameplateShowAll" or cvar == "nameplateShowFriends" then
		return 1
	end

	return 0
end

function SetNameplateDisabled(disabled)
	if not disabled then
		-- If disabled is false, restore normal nameplate behavior
		if nameplatePreventionFrame then
			nameplatePreventionFrame:UnregisterAllEvents()
			nameplatePreventionFrame:SetScript("OnEvent", nil)
			nameplatePreventionFrame:SetScript("OnUpdate", nil)
			nameplatePreventionFrame = nil
		end
		-- Restore original functions
		SetCVar = originalSetCVar
		return
	end

	-- Force all nameplates off immediately
	for _, cvar in ipairs(nameplateCVars) do
		local target = targetValue(cvar)
		originalSetCVar(cvar, target)
	end

	-- Override SetCVar to prevent nameplate enabling
	SetCVar = function(cvar, value)
		-- Check if this is a nameplate CVar
		for _, nameplateCvar in ipairs(nameplateCVars) do
			if cvar == nameplateCvar then
				-- Always set nameplate CVars to 0 (disabled)
				local target = targetValue(cvar)
				originalSetCVar(cvar, target)
				return
			end
		end
		-- Allow other CVars to work normally
		originalSetCVar(cvar, value)
	end
end
