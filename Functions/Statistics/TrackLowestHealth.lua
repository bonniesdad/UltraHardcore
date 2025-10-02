-- Track lowest health percentage
local pvpPause = false
local isDueling = false

local function TrackLowestHealth(event)
  local health = UnitHealth("player")
  local maxHealth = UnitHealthMax("player")

  local healthPercent = (health / maxHealth) * 100
  local currentLowestHealth = CharacterStats:GetStat("lowestHealth")

  if pvpPause then
    -- End pause after 1) not dueling, 2) HP% is above or equal to previous lowest, or you somehow died
    if not isDueling and (healthPercent >= currentLowestHealth or health == 0) then
      pvpPause = false
      print("|cfff44336[Ultra Hardcore]|r |cfff0f000Health has returned above your previous lowest stat. Lowest Health tracking has resumed|r")
    else
      return
    end
  end

  -- Only record new lows during normal tracking on UNIT_HEALTH and OUTSIDE of comabt
  if event == "UNIT_HEALTH" and not UnitAffectingCombat("player") and healthPercent < currentLowestHealth then
    CharacterStats:UpdateStat("lowestHealth", healthPercent)
  end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("UNIT_HEALTH")
frame:RegisterEvent("DUEL_REQUESTED") -- Fired when another player initiates a duel against you. Intentionally ignoring DUEL_TO_THE_DEATH_REQUESTED as that is full combat and should count
frame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED") -- SpellID 7266 is Duel. Fired when player initiates the duel
frame:RegisterEvent("DUEL_FINISHED") -- Fired every time a duel is over or cancelled
frame:RegisterEvent("PLAYER_REGEN_DISABLED") -- In combat, if we want it
frame:RegisterEvent("PLAYER_REGEN_ENABLED")  -- Out of combat, if we want it

frame:SetScript("OnEvent", function(self, event, arg1, arg2, arg3)
  if event == "UNIT_HEALTH" and arg1 ~= "player" then return end

  if event == "DUEL_REQUESTED" or (event == "UNIT_SPELLCAST_SUCCEEDED" and arg1 == "player" and arg3 == 7266) then
    pvpPause = true
    isDueling = true
    print("|cfff44336[Ultra Hardcore]|r |cfff0f000A duel has been initiated. Lowest Health tracking is paused|r")
  elseif event == "DUEL_FINISHED" then
    isDueling = false
    print("|cfff44336[Ultra Hardcore]|r |cfff0f000Dueling has finished. Please wait for your health|r")
  end

  TrackLowestHealth(event)
end)
