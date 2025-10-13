-- Track lowest health percentage
local pvpPause = false
local isDueling = false

local combatLowest = nil

local function IsFeigningDeath()
  for i = 1, 40 do
  local name, _, _, _, _, _, _, _, _, spellId = UnitBuff("player", i)
    if not name then
      break
    end
    if spellId == 5384 or name == "Feign Death" then
      return true
    end
  end
  return false
end

local function leftCombat()
	if combatLowest == nil then
		return
	end

	local currentLowestHealth = CharacterStats:GetStat("lowestHealth")
	local currentLowestHealthThisLevel = CharacterStats:GetStat("lowestHealthThisLevel")
	local currentLowestHealthThisSession = CharacterStats:GetStat("lowestHealthThisSession")

	-- Only record new lows during normal tracking on UNIT_HEALTH and OUTSIDE of combat
	if combatLowest < currentLowestHealth then
		CharacterStats:UpdateStat("lowestHealth", combatLowest)
	end

	-- Track This Level lowest health (same conditions as total)
	if combatLowest < currentLowestHealthThisLevel then
		CharacterStats:UpdateStat("lowestHealthThisLevel", combatLowest)
	end

	-- Track This Session lowest health (same conditions as total)
	if combatLowest < currentLowestHealthThisSession then
		CharacterStats:UpdateStat("lowestHealthThisSession", combatLowest)
	end

	combatLowest = nil
end

local function TrackLowestHealth(event)
	local health = UnitHealth("player")
	local maxHealth = UnitHealthMax("player")

	local inCombat = UnitAffectingCombat("player")

	local healthPercent = (health / maxHealth) * 100
	local currentLowestHealth = CharacterStats:GetStat("lowestHealth")
	local currentLowestHealthThisLevel = CharacterStats:GetStat("lowestHealthThisLevel")
	local currentLowestHealthThisSession = CharacterStats:GetStat("lowestHealthThisSession")

	-- Return early if any stats are nil (not initialized yet)
	if not currentLowestHealth or not currentLowestHealthThisLevel or not currentLowestHealthThisSession then
		return
	end

	if pvpPause then
		-- End pause after 1) not dueling, 2) HP% is above or equal to previous lowest, or you somehow died
		if not isDueling and (healthPercent >= currentLowestHealth or health == 0) then
			pvpPause = false
			print(
				"|cfff44336[UHC]|r |cfff0f000Health has returned above your previous lowest health stat. Lowest Health tracking has resumed!|r"
			)
		else
			return
		end
	end

	-- Only record new lows during normal tracking on UNIT_HEALTH and OUTSIDE of combat
	if inCombat then
		combatLowest = math.min(healthPercent, combatLowest or 100)
		return
	end

	if event == "UNIT_HEALTH" and not inCombat and healthPercent < currentLowestHealth then
		CharacterStats:UpdateStat("lowestHealth", healthPercent)
	end

	-- Track This Level lowest health (same conditions as total)
	if event == "UNIT_HEALTH" and not inCombat and healthPercent < currentLowestHealthThisLevel then
		CharacterStats:UpdateStat("lowestHealthThisLevel", healthPercent)
	end

	-- Track This Session lowest health (same conditions as total)
	if event == "UNIT_HEALTH" and not inCombat and healthPercent < currentLowestHealthThisSession then
		CharacterStats:UpdateStat("lowestHealthThisSession", healthPercent)
	end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("UNIT_HEALTH")
frame:RegisterEvent("DUEL_REQUESTED") -- Fired when another player initiates a duel against you. Intentionally ignoring DUEL_TO_THE_DEATH_REQUESTED as that is full combat and should count
frame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED") -- SpellID 7266 is Duel. Fired when player initiates the duel
frame:RegisterEvent("DUEL_FINISHED") -- Fired every time a duel is over or cancelled
frame:RegisterEvent("PLAYER_REGEN_DISABLED") -- In combat, if we want it
frame:RegisterEvent("PLAYER_REGEN_ENABLED") -- Out of combat, if we want it
frame:RegisterEvent("PLAYER_LEVEL_UP") -- Reset This Level stats when leveling up
frame:RegisterEvent("PLAYER_LOGIN") -- Reset This Session stats when logging in

frame:SetScript("OnEvent", function(self, event, arg1, arg2, arg3)
	if event == "UNIT_HEALTH" and arg1 ~= "player" then
		return
	end

	if event == "DUEL_REQUESTED" or (event == "UNIT_SPELLCAST_SUCCEEDED" and arg1 == "player" and arg3 == 7266) then
		pvpPause = true
		isDueling = true
		print("|cfff44336[UHC]|r |cfff0f000A duel has been initiated. Lowest Health tracking is paused.|r")
	elseif event == "DUEL_FINISHED" then
		isDueling = false
		print(
			"|cfff44336[UHC]|r |cfff0f000Dueling has finished. Please wait for your health to return above your previous lowest health stat.|r"
		)
	elseif event == "PLAYER_LEVEL_UP" then
		-- Reset This Level stats when leveling up
		CharacterStats:ResetLowestHealthThisLevel()
		print("|cfff44336[UHC]|r |cfff0f000Level up! This Level lowest health has been reset.|r")
	elseif event == "PLAYER_LOGIN" then
		-- Reset This Session stats when logging in
		CharacterStats:ResetLowestHealthThisSession()
		print("|cfff44336[UHC]|r |cfff0f000New session! This Session lowest health has been reset.|r")
	elseif event == "PLAYER_REGEN_ENABLED" then
		leftCombat()
		return
	end

	local feigning  = IsFeigningDeath()

	if feigning then
		return
	end

	TrackLowestHealth(event)
end)

