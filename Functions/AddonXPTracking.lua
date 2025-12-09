local statsInitialized = false

local AddonXPTracking = {
  TotalXPTable = {
    [1]=400, [2]=900, [3]=1400, [4]=2100, [5]=2800, [6]=3600, [7]=4500, [8]=5400, [9]=6500, [10] = 7600,
    [11] = 8800, [12] = 10100, [13] = 11400, [14] = 12900, [15] = 14400, [16] = 16000, [17] = 17700, [18] = 19400, [19] = 21300, [20] = 23200,
    [21] = 25200, [22] = 27300, [23] = 29400, [24] = 31700, [25] = 34000, [26] = 36400, [27] = 38900, [28] = 41400, [29] = 44300, [30] = 47400,
    [31] = 50800, [32] = 54500, [33] = 58600, [34] = 62800, [35] = 67100, [36] = 71600, [37] = 76100, [38] = 80800, [39] = 85700, [40] = 90700,
    [41] = 95800, [42] = 101000, [43] = 106300, [44] = 111800, [45] = 117500, [46] = 123200, [47] = 129100, [48] = 135100, [49] = 141200, [50] = 147500,
    [51] = 153900, [52] = 160400, [53] = 167100, [54] = 173900, [55] = 180800, [56] = 187900, [57] = 195000, [58] = 202300, [59] = 209800, [60] = 217400
  },
  highXpMark = 999999999,
  DEBUGXP = false,
  trackingInitialized = false
}

function AddonXPTracking:Stats()
    return CharacterStats:GetCurrentCharacterStats() 
end 

function AddonXPTracking:UpdateStat(variable, value)
  self:Stats()[variable] = value
end

function AddonXPTracking:DefaultSettings()
    return CharacterStats.defaults
end

function AddonXPTracking:GetMinXPForLevel(currentLevel)
  local totalXP = 0

  for i, xp in ipairs(self.TotalXPTable) do
    if i < currentLevel then
      totalXP = totalXP + xp
    end
  end
  return totalXP
end

-- This function adds XP from the level up table and current xp
function AddonXPTracking:GetTotalXP()
    local currentLevel = UnitLevel("player")
    local currentXP = UnitXP('player')
    return self:GetMinXPForLevel(currentLevel) + currentXP
end

function AddonXPTracking:CalculateTotalXPGained()
    Printing:Debug("Calculating Total XP for " .. Colours:Red(UnitGUID("player")))
    local stats = self:Stats()
    local totalXP = self:GetTotalXP()
    Printing:Debug("Total XP is " .. totalXP)
    stats["xpTotal"] = totalXP
    return totalXP
end

function AddonXPTracking:ShouldRecalculateXPGainedWithAddon()
  local stats = self:Stats()
  local playerLevel = UnitLevel("player")
  if stats.xpTrackedByAddon == nil then
    Printing:Debug("Recalculating because xpTrackedByAddon is nil")
    return true
  else
    Printing:Debug("Addon XP should not be recalculated")
    return false
  end
end

function AddonXPTracking:ShouldCheckStat(statName)
  local result = statName ~= "xpTotal"
                  and statName ~= "xpTrackedByAddon"
                  and statName ~= "playerJumps"
                  and statName ~= "lastSessionXP"
                  and statName ~= "LastReloadedAt"
                  and string.find(statName, "lowestHealth") == nil
  --Printing:Debug("Should we count stats for " .. statName .. "? " .. tostring(result))
  return result                  
end

function AddonXPTracking:GetHighestNonHealthStat()
  local stats = self:Stats()
  local highestXPStatName = ""
  local highestXp = 0

  for statName, _ in pairs(self:DefaultSettings()) do
    local xpForStat = stats[statName] 
    if self:ShouldCheckStat(statName) then
      if xpForStat == nil then xpForStat = 0 end
      if xpForStat > highestXp then
        highestXPStatName = statName
        highestXp = xpForStat
      end
    end
  end
  Printing:Debug("Highest non-health XP stat is " .. highestXPStatName .. "=" .. highestXp)
  return highestXp
end

function AddonXPTracking:GetHighestXpGainedStat()
  local stats = self:Stats()
  local highestXPStatName = ""
  local highestXp = 0

  for statName, _ in pairs(self:DefaultSettings()) do
    local xpForStat = stats[statName] 
    local startIdx = string.find(statName, "xpGainedWithoutOption")

    if startIdx == 1 then
      if xpForStat == nil then xpForStat = 0 end
      if xpForStat > highestXp then
        highestXPStatName = statName
        highestXp = xpForStat
      end
    end
  end
  Printing:Debug("Highest XP stat is " .. highestXPStatName .. "=" ..highestXp)
  return highestXp
end

function AddonXPTracking:GetLowestXpGainedStat() 
  local stats = self:Stats()
  local lowestXPStatName = ""
  local lowestXP = self.highXpMark

  for statName, _ in pairs(self:DefaultSettings()) do
    local xpForStat = stats[statName] 

    -- Only use XP Gained Without stats for finding lowest XP value
    local startIdx = string.find(statName, "xpGainedWithoutOption")

    if startIdx == 1 then
      -- xpGainedWithoutOption stats that have never get incremented seem to be nil in the stats for some characters
      if xpForStat == nil then xpForStat = 0 end
      if xpForStat < lowestXP then
        lowestXPStatName = statName
        lowestXP = xpForStat
      end
    end
  end
  Printing:Debug("Lowest XP stat is " .. lowestXPStatName .. "=" .. lowestXP)
  return lowestXP
end

-- This will retroactively figure out the amount of XP gained _with_ the addon
function AddonXPTracking:ResetXPGainedWithAddon(forceReset)
  local playerLevel = UnitLevel("player")
  local xpDiff = 0
  local totalXP = self:GetTotalXP()
  local lowestXP = self:GetLowestXpGainedStat() or nil
  local highestXP = self:GetHighestXpGainedStat() or nil
  local anyStat = self:GetHighestNonHealthStat()

  if highestXP == 0 and anyStat == 0 and playerLevel > 1 then
    Printing:Debug("All high stats are 0, player level is " .. playerLevel)
    -- This player looks to have just turned ultra on so all their XP is without addon
    xpDiff = 0
  else
    xpDiff = totalXP - lowestXP
  end

  self:UpdateStat("xpTrackedByAddon", xpDiff)
  self:UpdateStat("xpTotal", totalXP)
end

function AddonXPTracking:ForceSave()
  local stats = self:Stats()
  local totalXP = self:CalculateTotalXPGained()

  self:UpdateStat("xpTotal", totalXP)
  self.UpdateStat("xpTrackedByAddon", stats.xpTrackedByAddon)
  AddonXPTracking:XPTrackingDebug("Setting XP values: " .. totalXP 
                                  .. " - " .. stats.xpTrackedByAddon
                                  .. " = " .. self:WithoutAddon()
                                )
end

function AddonXPTracking:Initialize(lastXPValue)
  if self.trackingInitialized ~= true then
    -- Because we disabled XP tracking, xpGWA is no longer valid so lets get rid of it
    self:UpdateStat("xpGWA", nil)

    -- This sets the last reload time
    ReloadReminder:Touch()

    local playerLevel = UnitLevel("player")
    if lastXPValue == 0 and playerLevel > 1 then
      -- This shouldn't happen but just in case, don't run until later
      return false
    end

    local xp = self:CalculateTotalXPGained()
    self:UpdateStat("xpTotal", xp)
    Printing:Debug("Player XP total is " .. xp)

    if playerLevel == 1 and lastXPValue == 0 then
      self:UpdateStat("xpTotal", 0)
      self:UpdateStat("xpTrackedByAddon", 0)
    elseif self:ShouldRecalculateXPGainedWithAddon() == true then
      self:ResetXPGainedWithAddon(true)
    end
    self.trackingInitialized = true
  end
end

function AddonXPTracking:ShouldStoreStat(xpVariable)
  return xpVariable ~= "xpTotal"
end

function AddonXPTracking:ShouldTrackStat(xpVariable)
  if xpVariable == "xpTrackedByAddon" then
    return true
  else
    return false
  end
end

function AddonXPTracking:TotalXP()
  return self:GetTotalXP()
end

function AddonXPTracking:WithAddon()
  return self:Stats()["xpTrackedByAddon"]
end

-- xpGWOA is no longer a thing.  We always calculate this value.
function AddonXPTracking:WithoutAddon()
  return self:GetTotalXP() - self:WithAddon()
end

function AddonXPTracking:PercentXPTracked()
  return (1 - (self:WithAddon() / self:GetTotalXP())) * 100
end

function AddonXPTracking:PercentXPMissing()
  return (1 - (self:WithoutAddon() / self:GetTotalXP())) * 100
end

function AddonXPTracking:XPIsVerified()
  local result = self:IsAddonXPValid(UnitLevel('player'))
  Printing:Debug("Addon XP verification status: " .. tostring(result))
  return result
end

function AddonXPTracking:XPForLevel(level)
  return self.TotalXPTable[level]
end

function AddonXPTracking:GetXP(levelUp) 
  if levelUp == nil then levelUp = false end

  if levelUp then
    local newLevel = UnitLevel("player")
    local levelXP = AddonXPTracking:XPForLevel(newLevel)
    Printing:Debug("Leveling up, reporting XP as " .. levelXP)
    return levelXP
  else
    return UnitXP("player")
  end
end

function AddonXPTracking:NewLastXPValue(levelUp, currentXp)
  if levelUp == nil then levelUp = false end

  if levelUp then
    Printing:Debug("New XP value is 0 due to level up.  XP was " .. currentXp)
    return 0
  else
    return currentXp
  end
end

function AddonXPTracking:NewLastXPUpdate(levelUp, currentTime) 
  if levelUp == nil then levelUp = false end

  if levelUp then
    local newTime = currentTime - 2
    Printing:Debug("Falsifying last update timestamp from " .. currentTime .. " to " .. newTime)
    return newTime
  else
    return currentTime
  end
end

function AddonXPTracking:IsAddonXPValid(currentLevel) 
  local pctMissing = self:PercentXPMissing()
  Printing:Debug("Percent XP untracked: " .. pctMissing .. "%")
  local result = false
  if currentLevel <= 10 and pctMissing <= 10 then
    result = true
  elseif currentLevel <= 20 and pctMissing <= 11 then
    result = true  
  elseif currentLevel <= 30 and pctMissing <= 12 then
    result = true  
  elseif currentLevel <= 40 and pctMissing <= 13 then
    result = true  
  elseif currentLevel <= 50 and pctMissing <= 14 then
    result = true  
  elseif currentLevel <= 20 and pctMissing <= 15 then
    result = true  
  end
  return result
end

function AddonXPTracking:PrintXPVerificationWarning()
  --[[
    local totalXP = self:GetTotalXP()
    local storedTotalXP = self:TotalXP()
    print(msgPrefix .. redTextColour .. "WARNING!|r Detected " .. yellowTextColour ..  totalXP - storedTotalXP .. "|r missing XP!")
    ]]
end

function AddonXPTracking:XPReport()
  Printing:P(Colours:Yellow("Total XP: ") .. tostring(AddonXPTracking:TotalXP()))
  Printing:P(Colours:Yellow("XP Gained With Addon: ") .. Colours:Green(tostring(AddonXPTracking:WithAddon())))

  local pctMissing = self:PercentXPMissing()

  if pctMissing > 0 then 
    Printing:P(Colours:Yellow("The addon could not track ") .. Colours:ByName("Indigo", pctMissing .. "%") .. Colours:Yellow(" of your XP."))
    local level = UnitLevel("player")

    local isValid = self:IsAddonXPValid(level)
    if isValid then 
      Printing:P("At level " .. Colours:ByName("Silver", level) .. " your XP drift is considered " .. Colours:Green("LOW"))
    else
      Printing:P("At level " .. Colours:ByName("Silver", level) .. " your XP drift is considered " .. Colours:ByName("OrangeRed", "HIGH"))
    end
  end

end 

SLASH_XPFORLEVEL1 = '/uhcxpforlevel'
SlashCmdList['XPFORLEVEL'] = function(msg)
  local totalXP = 0
  for i, xp in ipairs(AddonXPTracking.TotalXPTable) do
    if i < tonumber(msg) then
      totalXP = totalXP + xp
    end
  end
  Printing:P("A level " .. Colours:Green(msg)
        .. " character has at least " 
        .. Colours:ByName("Cyan", formatNumberWithCommas(totalXP)) 
        .. " XP")
end

_G.AddonXPTracking = AddonXPTracking
