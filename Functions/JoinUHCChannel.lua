function JoinUHCChannel()
  local channelName = 'uhc'

  -- Check if already in the channel
  local numChannels = GetNumDisplayChannels()
  for i = 1, numChannels do
    local name = GetChannelDisplayInfo(i)
    if name == channelName then
      return -- Already in the channel
    end
  end

  -- Try to join the channel
  local success = JoinChannelByName(channelName)
  if success then
    -- Add a small delay before adding to chat frame
    C_Timer.After(0.5, function()
      local channelID = GetChannelName(channelName)
      if channelID then
        ChatFrame_AddChannel(DEFAULT_CHAT_FRAME, channelName)
      else
        print("UltraHardcore: Failed to get channel ID for " .. channelName)
      end
    end)
  else
    print("UltraHardcore: Failed to join channel " .. channelName)
    -- If we failed to join, try again in 5 seconds
    C_Timer.After(5, function()
      JoinUHCChannel()
    end)
  end
end

-- Function to send death message to UHC channel
local function SendDeathMessage()
  local channelName = "uhc"
  local channelID = GetChannelName(channelName)
  if channelID then
    local characterName = UnitName("player")
    local level = UnitLevel("player")
    local class = UnitClass("player")
    SendChatMessage(characterName .. " (" .. class .. ") has died at level " .. level .. "!", "CHANNEL", nil, channelID)
  end
end

-- Function to send level up message to UHC channel
local function SendLevelUpMessage(newLevel)
  -- Only send message for every 5th level
  if newLevel % 5 == 0 then
    local channelName = "uhc"
    local channelID = GetChannelName(channelName)
    if channelID then
      local characterName = UnitName("player")
      local class = UnitClass("player")
      SendChatMessage(characterName .. " (" .. class .. ") has reached level " .. newLevel .. "!", "CHANNEL", nil, channelID)
    end
  end
end

-- Register for ADDON_LOADED to try joining the channel when the addon loads
local frame = CreateFrame('Frame')
frame:RegisterEvent('ADDON_LOADED')
frame:RegisterEvent('PLAYER_DEAD')
frame:RegisterEvent('PLAYER_LEVEL_UP')
frame:SetScript('OnEvent', function(self, event, addonName, newLevel)
  if event == 'ADDON_LOADED' and addonName == 'UltraHardcore' then
    JoinUHCChannel()
  elseif event == 'PLAYER_DEAD' then
    SendDeathMessage()
  elseif event == 'PLAYER_LEVEL_UP' then
    SendLevelUpMessage(newLevel)
  end
end)

-- Add slash command for testing death message
SLASH_TESTDEATH1 = "/testdeath"
SlashCmdList["TESTDEATH"] = function()
  SendDeathMessage()
end

-- Add slash command for testing level up message
SLASH_TESTLEVEL1 = "/testlevel"
SlashCmdList["TESTLEVEL"] = function()
  SendLevelUpMessage(UnitLevel("player"))
end
