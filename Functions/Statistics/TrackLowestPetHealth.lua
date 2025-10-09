-- Track lowest pet health percentage
local pvpPause = false
local isDueling = false

local function TrackLowestPetHealth(event)
  -- Check if player has a pet
  if not UnitExists("pet") then
    return
  end
  
  local health = UnitHealth("pet")
  local maxHealth = UnitHealthMax("pet")
  
  -- Return if pet has no health data
  if not health or not maxHealth or maxHealth == 0 then
    return
  end

  local healthPercent = (health / maxHealth) * 100
  local currentLowestPetHealth = CharacterStats:GetStat("lowestPetHealth")
  local currentLowestPetHealthThisLevel = CharacterStats:GetStat("lowestPetHealthThisLevel")
  local currentLowestPetHealthThisSession = CharacterStats:GetStat("lowestPetHealthThisSession")

  -- Return early if any stats are nil (not initialized yet)
  if not currentLowestPetHealth or not currentLowestPetHealthThisLevel or not currentLowestPetHealthThisSession then
    return
  end

  if pvpPause then
    -- End pause after 1) not dueling, 2) HP% is above or equal to previous lowest, or pet somehow died
    if not isDueling and (healthPercent >= currentLowestPetHealth or health == 0) then
      pvpPause = false
      print("|cfff44336[UHC]|r |cfff0f000Pet health has returned above your previous lowest pet health stat. Lowest Pet Health tracking has resumed!|r")
    else
      return
    end
  end

  -- Only record new lows during normal tracking on UNIT_HEALTH and OUTSIDE of combat
  if event == "UNIT_HEALTH" and not UnitAffectingCombat("player") and healthPercent < currentLowestPetHealth then
    CharacterStats:UpdateStat("lowestPetHealth", healthPercent)
  end
  
  -- Track This Level lowest pet health (same conditions as total)
  if event == "UNIT_HEALTH" and not UnitAffectingCombat("player") and healthPercent < currentLowestPetHealthThisLevel then
    CharacterStats:UpdateStat("lowestPetHealthThisLevel", healthPercent)
  end
  
  -- Track This Session lowest pet health (same conditions as total)
  if event == "UNIT_HEALTH" and not UnitAffectingCombat("player") and healthPercent < currentLowestPetHealthThisSession then
    CharacterStats:UpdateStat("lowestPetHealthThisSession", healthPercent)
  end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("UNIT_HEALTH")
frame:RegisterEvent("DUEL_REQUESTED") -- Fired when another player initiates a duel against you. Intentionally ignoring DUEL_TO_THE_DEATH_REQUESTED as that is full combat and should count
frame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED") -- SpellID 7266 is Duel. Fired when player initiates the duel
frame:RegisterEvent("DUEL_FINISHED") -- Fired every time a duel is over or cancelled
frame:RegisterEvent("PLAYER_REGEN_DISABLED") -- In combat, if we want it
frame:RegisterEvent("PLAYER_REGEN_ENABLED")  -- Out of combat, if we want it
frame:RegisterEvent("PLAYER_LEVEL_UP") -- Reset This Level stats when leveling up
frame:RegisterEvent("PLAYER_LOGIN") -- Reset This Session stats when logging in
frame:RegisterEvent("PET_ATTACK_START") -- Pet enters combat
frame:RegisterEvent("PET_ATTACK_STOP") -- Pet leaves combat

frame:SetScript("OnEvent", function(self, event, arg1, arg2, arg3)
  if event == "UNIT_HEALTH" and arg1 ~= "pet" then return end

  if event == "DUEL_REQUESTED" or (event == "UNIT_SPELLCAST_SUCCEEDED" and arg1 == "player" and arg3 == 7266) then
    pvpPause = true
    isDueling = true
    print("|cfff44336[UHC]|r |cfff0f000A duel has been initiated. Lowest Pet Health tracking is paused.|r")
  elseif event == "DUEL_FINISHED" then
    isDueling = false
    print("|cfff44336[UHC]|r |cfff0f000Dueling has finished. Please wait for your pet's health to return above your previous lowest pet health stat.|r")
  elseif event == "PLAYER_LEVEL_UP" then
    -- Reset This Level stats when leveling up
    CharacterStats:ResetLowestPetHealthThisLevel()
    print("|cfff44336[UHC]|r |cfff0f000Level up! This Level lowest pet health has been reset.|r")
  elseif event == "PLAYER_LOGIN" then
    -- Reset This Session stats when logging in
    CharacterStats:ResetLowestPetHealthThisSession()
    print("|cfff44336[UHC]|r |cfff0f000New session! This Session lowest pet health has been reset.|r")
  end

  TrackLowestPetHealth(event)
end)
