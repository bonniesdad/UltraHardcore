--[[
  XP Tracking System - Tracks XP gained without the addon active
  This system automatically tracks XP by comparing session start/end XP values
]]

-- Session tracking variables
local sessionStartXP = nil
local lastSessionEndXP = nil
local isAddonActive = true

-- Function to initialize session tracking
local function InitializeSessionTracking()
  local characterGUID = UnitGUID('player')
  local stats = CharacterStats:GetCurrentCharacterStats()
  
  -- Get the last session end XP from saved data
  lastSessionEndXP = stats.lastSessionXP or 0
  
  -- Get current XP
  local currentXP = UnitXP("player")
  
  -- If we have a last session end XP, calculate XP gained without addon
  if lastSessionEndXP > 0 and currentXP > lastSessionEndXP then
    local xpGainedWithoutAddon = currentXP - lastSessionEndXP
    
    -- Add this XP to the total XP gained without addon
    local currentXPWithoutAddon = stats.xpGainedWithoutAddon or 0
    local newXPWithoutAddon = currentXPWithoutAddon + xpGainedWithoutAddon
    
    CharacterStats:UpdateStat('xpGainedWithoutAddon', newXPWithoutAddon)
    
  end
  
  -- Start new session with current XP
  sessionStartXP = currentXP
  isAddonActive = true
  
end

-- Function to end session and save data
local function EndSession()
  if sessionStartXP then
    local currentXP = UnitXP("player")
    
    -- Save the current XP as the last session end XP
    CharacterStats:UpdateStat('lastSessionXP', currentXP)
    
  end
end

-- Function to get XP gained with addon (current session)
local function GetXPWithAddon()
  if sessionStartXP then
    local currentXP = UnitXP("player")
    return currentXP - sessionStartXP
  end
  return 0
end

-- Function to display current XP tracking
local function DisplayXP()
  local xpWithout = CharacterStats:GetStat('xpGainedWithoutAddon') or 0
  local xpWith = GetXPWithAddon()
  local currentXP = UnitXP("player")
  
  print("UHC - XP gained with addon (this session): " .. xpWith)
  print("UHC - Total XP gained without addon: " .. xpWithout)
  print("UHC - Current character XP: " .. currentXP)
  
  local totalXPGained = xpWithout + xpWith
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
