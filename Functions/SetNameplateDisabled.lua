-- Nameplate Prevention System
-- When enabled, completely prevents nameplates from being turned on

-- Global frame to prevent nameplates
local nameplatePreventionFrame = nil
local originalSetCVar = SetCVar
local originalGetCVar = GetCVar

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
}

local function targetValue(cvar)
	local useIcons = GLOBAL_SETTINGS.showFriendlyNameplateIcons or false
	local inInstance = IsInInstance()

	if not useIcons or inInstance then
		return 0
	end

	if cvar == "nameplateShowAll" then
		return true
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
		GetCVar = originalGetCVar
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

	-- Override GetCVar to always return 0 for nameplate CVars
	GetCVar = function(cvar)
		-- Check if this is a nameplate CVar
		for _, nameplateCvar in ipairs(nameplateCVars) do
			if cvar == nameplateCvar then
				-- Always return 0 (disabled) for nameplate CVars
				return "0"
			end
		end
		-- Allow other CVars to work normally
		return originalGetCVar(cvar)
	end

	-- Create a frame to monitor and prevent nameplate enabling
	-- if not nameplatePreventionFrame then
	-- 	nameplatePreventionFrame = CreateFrame("Frame")
	-- 	nameplatePreventionFrame:RegisterEvent("CVAR_UPDATE")
	-- 	nameplatePreventionFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	-- 	nameplatePreventionFrame:RegisterEvent("ADDON_LOADED")
	-- 	nameplatePreventionFrame:RegisterEvent("PLAYER_REGEN_DISABLED") -- Combat start
	-- 	nameplatePreventionFrame:RegisterEvent("PLAYER_REGEN_ENABLED") -- Combat end
	--
	-- 	nameplatePreventionFrame:SetScript("OnEvent", function(self, event, cvar)
	-- 		if event == "CVAR_UPDATE" then
	-- 			-- Check if any nameplate CVars were changed
	-- 			for _, nameplateCvar in ipairs(nameplateCVars) do
	-- 				if cvar == nameplateCvar then
	-- 					-- Force all nameplates back to 0 (disabled) immediately
	-- 					for _, cv in ipairs(nameplateCVars) do
	-- 						local target = targetValue(cvar)
	-- 						originalSetCVar(cv, 0)
	-- 					end
	-- 					break
	-- 				end
	-- 			end
	-- 		elseif
	-- 			event == "PLAYER_ENTERING_WORLD"
	-- 			or event == "ADDON_LOADED"
	-- 			or event == "PLAYER_REGEN_DISABLED"
	-- 			or event == "PLAYER_REGEN_ENABLED"
	-- 		then
	-- 			-- Ensure all nameplates are off on login/reload/combat changes
	-- 			for _, cvar in ipairs(nameplateCVars) do
	-- 				local target = targetValue(cvar)
	-- 				originalSetCVar(cvar, 0)
	-- 			end
	-- 		end
	-- 	end)
	--
	-- 	-- Use OnUpdate to continuously ensure nameplates stay off
	-- 	nameplatePreventionFrame:SetScript("OnUpdate", function(self, elapsed)
	-- 		-- Check if any nameplates are enabled and force them all off
	-- 		local anyEnabled = false
	-- 		for _, cvar in ipairs(nameplateCVars) do
	-- 			local target = targetValue(cvar)
	-- 			local current = tonumber(originalGetCVar(cvar)) or 0
	-- 			if current ~= target then
	-- 				-- print("override", cvar, "from", current, "to", target)
	-- 				anyEnabled = true
	-- 				break
	-- 			end
	-- 		end
	--
	-- 		if anyEnabled then
	-- 			-- Force all nameplates off
	-- 			for _, cvar in ipairs(nameplateCVars) do
	-- 				local target = targetValue(cvar)
	-- 				originalSetCVar(cvar, 0)
	-- 			end
	-- 		end
	-- 	end)
	-- end
end
