--[[ 
  XP Tracking System - Tracks XP gained without the addon active
  Compares "current total XP" to the last saved session end XP.
  If first-time install (no lastSessionXP) and you are already > level 1 (or have nonzero XP),
  we treat all current XP as "gained without the addon".
]]

-- Static XP table (Classic Era/HC: XP to go from L -> L+1)
local xpForLevel = {
  [1]=400,[2]=900,[3]=1400,[4]=2100,[5]=2800,[6]=3600,[7]=4500,[8]=5400,[9]=6500,
  [10]=7600,[11]=8800,[12]=10100,[13]=11400,[14]=12900,[15]=14400,[16]=16000,[17]=17700,[18]=19400,[19]=21300,
  [20]=23200,[21]=25200,[22]=27300,[23]=29500,[24]=31700,[25]=34100,[26]=36600,[27]=39100,[28]=41800,[29]=44600,
  [30]=47500,[31]=50500,[32]=53600,[33]=56800,[34]=60200,[35]=63700,[36]=67200,[37]=71000,[38]=74800,[39]=78700,
  [40]=82800,[41]=87000,[42]=91300,[43]=95800,[44]=100400,[45]=105000,[46]=109800,[47]=114700,[48]=119700,[49]=124800,
  [50]=130000,[51]=135200,[52]=140600,[53]=146000,[54]=151600,[55]=157300,[56]=163100,[57]=169000,[58]=175000,[59]=181000,
}

-- Session tracking variables
local sessionStartXP = nil

-- Calculate how much xp has been gained total
local sessionStartXP = nil

local function GetTotalXP()
  -- Cumulative XP since level 1
  local lvl = UnitLevel("player") or 1
  local inLevelXP = UnitXP("player") or 0
  local sum = 0
  for L = 1, (lvl - 1) do
    sum = sum + (xpForLevel[L] or 0)
  end
  return sum + inLevelXP
end

local function CS_GetStats()
  if CharacterStats and CharacterStats.GetCurrentCharacterStats then
    return CharacterStats:GetCurrentCharacterStats() or {}
  end
  return {}
end

local function CS_Update(key, value)
  if CharacterStats and CharacterStats.UpdateStat then
    CharacterStats:UpdateStat(key, value)
  end
end

-- Function to initialize session tracking
local function InitializeSessionTracking()
  local stats = CS_GetStats()
  local lastSessionEndXP = tonumber(stats.lastSessionXP) or 0
  local xpGainedWithoutAddon = tonumber(stats.xpGainedWithoutAddon) or 0

  local currentXP = GetTotalXP()

  -- Determine if player has used the addon before, if not ensure player is new (level 1)
  if lastSessionEndXP > 0 then
    local newXPWithoutAddon = currentXP - lastSessionEndXP
    if newXPWithoutAddon > 0 then
      CS_Update("xpGainedWithoutAddon", xpGainedWithoutAddon + newXPWithoutAddon)
    end
  else
    local lvl = UnitLevel("player") or 1
    local inLevelXP = UnitXP("player") or 0
    if lvl > 1 or inLevelXP > 0 then
      CS_Update("xpGainedWithoutAddon", currentXP)
    end
  end

  sessionStartXP = currentXP
end

-- Function to end session and save data
local function EndSession()
  if sessionStartXP then
    local currentXP = GetTotalXP()
    CS_Update("lastSessionXP", currentXP)
  end
end

-- Function to get XP gained with addon (current session)
ocal function GetXPWithAddon()
  if sessionStartXP then
    local currentXP = GetTotalXP()
    return math.max(0, currentXP - sessionStartXP)
  end
  return 0
end

-- Function to display current XP tracking
local function DisplayXP()
  local stats = CS_GetStats()
  local xpWithout = tonumber(stats.xpGainedWithoutAddon) or 0
  local xpWith = GetXPWithAddon()
  local currentXP = GetTotalXP()
  local totalXPGained = xpWithout + xpWith

  print("UHC - XP gained with addon (this session): " .. xpWith)
  print("UHC - Total XP gained without addon: " .. xpWithout)
  print("UHC - Current character XP (lifetime): " .. currentXP)
  print("UHC - Total XP gained across all sessions: " .. totalXPGained)
end

-- Export functions globally
_G.InitializeSessionTracking = InitializeSessionTracking
_G.EndSession = EndSession
_G.GetXPWithAddon = GetXPWithAddon
_G.DisplayXP = DisplayXP

-- Register slash command to display XP tracking (read-only)
SLASH_XP1 = "/xp"
SlashCmdList["XP"] = function()
  DisplayXP()
end

-- Register events for automatic session tracking
local sessionFrame = CreateFrame("Frame")
sessionFrame:RegisterEvent("PLAYER_LOGOUT")
sessionFrame:RegisterEvent("PLAYER_LEAVING_WORLD")
sessionFrame:RegisterEvent("ADDON_LOADED")
sessionFrame:SetScript("OnEvent", function(self, event, ...)
  if event == "PLAYER_LOGOUT" or event == "PLAYER_LEAVING_WORLD" then
    EndSession()
  elseif event == "ADDON_LOADED" and select(1, ...) == "UltraHardcore" then
    -- Initialize session tracking when addon loads
    InitializeSessionTracking()
  end
end)
