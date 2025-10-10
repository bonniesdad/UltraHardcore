-- Track lowest health percentage
local pvpPause = false
local isDueling = false
local pendingCombatLow = nil

local function TrackLowestHealth(event)
  local health = UnitHealth("player")
  local maxHealth = UnitHealthMax("player")
  
  local healthPercent = (health / maxHealth) * 100
  
  local currentLowestHealth = CharacterStats:GetStat("lowestHealth")
  local currentLowestHealthThisLevel = CharacterStats:GetStat("lowestHealthThisLevel")
  local currentLowestHealthThisSession = CharacterStats:GetStat("lowestHealthThisSession")
  
  -- Return early if any stats are nil (not initialized yet)
  if not currentLowestHealth or not currentLowestHealthThisLevel or not currentLowestHealthThisSession then
    return
  end

  if pvpPause then
    if not isDueling and (healthPercent >= currentLowestHealth or health == 0) then
      pvpPause = false
      print("|cfff44336[Ultra Hardcore]|r |cfff0f000Health has returned above your previous lowest stat. Lowest Health tracking has resumed|r")
    else
      return
    end
  end

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

  local inCombat = UnitAffectingCombat("player")
  local feigning  = IsFeigningDeath()

  -- Only record new lows during normal tracking on UNIT_HEALTH and OUTSIDE of comabt with a Feign Death bypass
  if event == "UNIT_HEALTH" then
    if inCombat then
      -- Collect but don't publish during combat (hide panel updates)
      if not feigning then
        if not pendingCombatLow or healthPercent < pendingCombatLow then
          pendingCombatLow = healthPercent
        end
      end
      return
    else
      -- Outside combat: normal immediate updates, still skip Feign Death zeros
      if not feigning and healthPercent < currentLowestHealth then
        CharacterStats:UpdateStat("lowestHealth", healthPercent)
        if healthPercent < CharacterStats:GetStat("lowestHealthThisLevel") then
          CharacterStats:UpdateStat("lowestHealthThisLevel", healthPercent)
        end
        if healthPercent < CharacterStats:GetStat("lowestHealthThisSession") then
          CharacterStats:UpdateStat("lowestHealthThisSession", healthPercent)
        end
      end
    end
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

frame:SetScript("OnEvent", function(self, event, arg1, arg2, arg3)
  if event == "UNIT_HEALTH" and arg1 ~= "player" then return end

  if event == "PLAYER_REGEN_DISABLED" then
    pendingCombatLow = nil
  end

  if event == "DUEL_REQUESTED" or (event == "UNIT_SPELLCAST_SUCCEEDED" and arg1 == "player" and arg3 == 7266) then
    pvpPause = true
    isDueling = true
    print("|cfff44336[Ultra Hardcore]|r |cfff0f000A duel has been initiated. Lowest Health tracking is paused|r")
  elseif event == "DUEL_FINISHED" then
    isDueling = false
    print("|cfff44336[Ultra Hardcore]|r |cfff0f000Dueling has finished. Please wait for your health|r")
  end

  TrackLowestHealth(event)

  if event == "PLAYER_REGEN_ENABLED" then
    if not pvpPause and pendingCombatLow then
      local currentLowestHealth = CharacterStats:GetStat("lowestHealth")
      if pendingCombatLow < currentLowestHealth then
        CharacterStats:UpdateStat("lowestHealth", pendingCombatLow)
      end
      if pendingCombatLow < CharacterStats:GetStat("lowestHealthThisLevel") then
          CharacterStats:UpdateStat("lowestHealthThisLevel", pendingCombatLow)
        end
      if pendingCombatLow < CharacterStats:GetStat("lowestHealthThisSession") then
        CharacterStats:UpdateStat("lowestHealthThisSession", pendingCombatLow)
      end
    end
    pendingCombatLow = nil
  elseif event == "PLAYER_LEVEL_UP" then
    -- Reset This Level stats when leveling up
    CharacterStats:ResetLowestHealthThisLevel()
    print("|cfff44336[UHC]|r |cfff0f000Level up! This Level lowest health has been reset.|r")
  elseif event == "PLAYER_LOGIN" then
    -- Reset This Session stats when logging in
    CharacterStats:ResetLowestHealthThisSession()
    print("|cfff44336[UHC]|r |cfff0f000New session! This Session lowest health has been reset.|r")
  end
end)
