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

-- Export functions globally
_G.InitializeSessionTracking = InitializeSessionTracking
_G.EndSession = EndSession

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
