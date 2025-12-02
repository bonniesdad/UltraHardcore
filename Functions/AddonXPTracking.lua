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

local yellowTextColour = '|cffffd000'
local greenTextColour = '|cff33F24C'
local redTextColour = '|cffFF4444'
local msgPrefix = yellowTextColour .. "[|r" .. redTextColour .. "ULTRA|r" .. yellowTextColour .. "]|r "

function AddonXPTracking:Stats()
    return CharacterStats:GetCurrentCharacterStats() 
end 

function AddonXPTracking:UpdateStat(variable, value)
  self:Stats()[variable] = value
end

function AddonXPTracking:DefaultSettings()
    return CharacterStats.defaults
end

function AddonXPTracking:XPTrackingDebug(msg)
  if self.DEBUGXP ~= true then return end
  print(msgPrefix .. "(" .. yellowTextColour .. "AddonXPTracking DEBUG|r) " ..  msg)
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
    self:XPTrackingDebug("Calculating Total XP for " .. redTextColour .. UnitGUID("player") .. "|r")
    local stats = self:Stats()
    local totalXP = self:GetTotalXP()
    self:XPTrackingDebug("Total XP is " .. totalXP)
    stats["xpTotal"] = totalXP
    if stats.xpGWA ~= nil and stats.xpGWA > 0 then
      local xpGWOA = totalXP - stats.xpGWA
      stats["xpGWOA"] = xpGWOA
      self:XPTrackingDebug("XP Gained without Addon is " .. xpGWOA)
    end
    return totalXP
end

function AddonXPTracking:ShouldRecalculateXPGainedWithAddon()
  local stats = self:Stats()
  local playerLevel = UnitLevel("player")
  if stats.xpGWA == nil and stats.xpGWOA == nil then
    self:XPTrackingDebug("Recalculating because xpGWA and xpGWOA are both nil")
    return true
  elseif stats.xpGWA == 0 and stats.xpGWOA == 0 and stats.xpTotal > 0 then
    self:XPTrackingDebug("Recalculating because xpGWA and xpGWOA are both 0, xpTotal is " .. stats.xpTotal)
    return true
  else
    self:XPTrackingDebug("Addon XP should not be recalculated")
    return false
  end
end

function AddonXPTracking:ShouldCheckStat(statName)
  local result = statName ~= "xpTotal"
                  and statName ~= "xpGWA"
                  and statName ~= "xpGWOA"
                  and statName ~= "playerJumps"
                  and statName ~= "lastSessionXP"
                  and string.find(statName, "lowestHealth") == nil
  --self:XPTrackingDebug("Should we count stats for " .. statName .. "? " .. tostring(result))
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
  self:XPTrackingDebug("Highest non-health XP stat is " .. highestXPStatName .. "=" .. highestXp)
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
  self:XPTrackingDebug("Highest XP stat is " .. highestXPStatName .. "=" ..highestXp)
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
  self:XPTrackingDebug("Lowest XP stat is " .. lowestXPStatName .. "=" .. lowestXP)
  return lowestXP
end

-- This will retroactively figure out the amount of XP gained _with_ the addon
function AddonXPTracking:ResetXPGainedWithAddon(forceReset)
  local playerLevel = UnitLevel("player")
  local xpDiff = 0
  local xpWithoutAddon = 0
  local totalXP = 0

  local lowestXP = self:GetLowestXpGainedStat() or nil
  local highestXP = self:GetHighestXpGainedStat() or nil

  if lowestXP < self.highXpMark then
    totalXP = self:CalculateTotalXPGained()
    local anyStat = self:GetHighestNonHealthStat()

    if highestXP == 0 and anyStat == 0 and playerLevel > 1 then
      self:XPTrackingDebug("All high stats are 0, player level is " .. playerLevel)
      -- This player looks to have just turned ultra on so all their XP is without addon
      xpDiff = 0
    else
      xpDiff = totalXP - lowestXP
    end
    xpWithoutAddon = totalXP - xpDiff

    self:UpdateStat("xpGWA", xpDiff)
    self:UpdateStat("xpGWOA", xpWithoutAddon)
    self:UpdateStat("xpTotal", totalXP)
  end
end

function AddonXPTracking:ForceSave()
  local stats = self:Stats()
  local totalXP = self:CalculateTotalXPGained()

  self:UpdateStat("xpTotal", totalXP)
  self.UpdateStat("xpGWA", stats.xpGWA)
  self.UpdateStat("xpGWOA", totalXP - stats.xpGWA)
  AddonXPTracking:XPTrackingDebug("Setting XP values: " .. totalXP 
                                  .. " - " .. stats.xpGWA
                                  .. " = " .. stats.xpGWOA
                                )
end

function AddonXPTracking:Initialize(lastXPValue)
  if self.trackingInitialized ~= true then
    local playerLevel = UnitLevel("player")
    if lastXPValue == 0 and playerLevel > 1 then
      -- This shouldn't happen but just in case, don't run until later
      return false
    end

    local xp = self:CalculateTotalXPGained()
    self:UpdateStat("xpTotal", xp)
    self:XPTrackingDebug("Player XP total is " .. xp)

    if playerLevel == 1 and lastXPValue == 0 then
      self:UpdateStat("xpTotal", 0)
    end
    self.trackingInitialized = true
  end
end

function AddonXPTracking:ShouldStoreStat(xpVariable)
  return xpVariable ~= "xpGWOA" and xpVariable ~= "xpTotal"
end

function AddonXPTracking:ShouldTrackStat(xpVariable)
  if xpVariable == "xpGWA" or xpVariable == "xpGWOA" then
    return true
  else
    return false
  end
end

-- This function returns the storged total XP value from CharacterStats
function AddonXPTracking:TotalXP()
  return self:Stats()["xpTotal"]
end

function AddonXPTracking:WithAddon()
  return self:Stats()["xpGWA"]
end

function AddonXPTracking:WithoutAddon()
  return self:Stats()["xpGWOA"]
end

function AddonXPTracking:XPIsVerified()
  local stats = self:Stats()
  local isVerified = stats.xpGWA == stats.xpTotal and stats.xpGWOA == 0
  self:XPTrackingDebug("Addon XP verification status: " .. tostring(isVerified))
  return isVerified
end

function AddonXPTracking:XPForLevel(level)
  return self.TotalXPTable[level]
end

function AddonXPTracking:GetXP(levelUp) 
  if levelUp == nil then levelUp = false end

  if levelUp then
    local newLevel = UnitLevel("player")
    local levelXP = AddonXPTracking:XPForLevel(newLevel)
    self:XPTrackingDebug("Leveling up, reporting XP as " .. levelXP)
    return levelXP
  else
    return UnitXP("player")
  end
end

function AddonXPTracking:NewLastXPValue(levelUp, currentXp)
  if levelUp == nil then levelUp = false end

  if levelUp then
    self:XPTrackingDebug("New XP value is 0 due to level up.  XP was " .. currentXp)
    return 0
  else
    return currentXp
  end
end

function AddonXPTracking:NewLastXPUpdate(levelUp, currentTime) 
  if levelUp == nil then levelUp = false end

  if levelUp then
    local newTime = currentTime - 2
    self:XPTrackingDebug("Falsifying last update timestamp from " .. currentTime .. " to " .. newTime)
    return newTime
  else
    return currentTime
  end
end

function AddonXPTracking:IsAddonXPValid(currentLevel) 
  --[[local stats = self:Stats()
  local xpForLevel = self:GetMinXPForLevel(currentLevel)
  return (stats.xpGWA + stats.xpGWOA) >= xpForLevel]]
  return true
end

function AddonXPTracking:ValidateTotalStoredXP()
  return self:GetTotalXP() == self:TotalXP()
end

function AddonXPTracking:PrintXPVerificationWarning()
  --[[
    local totalXP = self:GetTotalXP()
    local storedTotalXP = self:TotalXP()
    print(msgPrefix .. redTextColour .. "WARNING!|r Detected " .. yellowTextColour ..  totalXP - storedTotalXP .. "|r missing XP!")
    ]]
end

function AddonXPTracking:XPReport()
  --[[
  local verified = AddonXPTracking:XPIsVerified() and greenTextColour .. "is fully verified|r" or redTextColour .. "is not fully verified|r"

  print(msgPrefix .. yellowTextColour .. "Total XP: |r" .. tostring(AddonXPTracking:TotalXP()))
  print(msgPrefix .. yellowTextColour .. "XP Gained With Addon: " .. greenTextColour .. tostring(AddonXPTracking:WithAddon()) .. "|r")
  print(msgPrefix .. yellowTextColour .. "XP Gained Without Addon: |r".. redTextColour .. tostring(AddonXPTracking:WithoutAddon()) .. "|r")
  print(msgPrefix .. yellowTextColour .. "Your addon XP |r" .. verified)
  ]]
end 

SLASH_XPFORLEVEL1 = '/uhcxpforlevel'
SlashCmdList['XPFORLEVEL'] = function(msg)
  local totalXP = 0
  for i, xp in ipairs(AddonXPTracking.TotalXPTable) do
    if i < tonumber(msg) then
      totalXP = totalXP + xp
    end
  end
  print("A level " .. greenTextColour .. msg 
        .. "|r character has at least " 
        .. redTextColour .. formatNumberWithCommas(totalXP) 
        .. "|r XP")
end

_G.AddonXPTracking = AddonXPTracking
