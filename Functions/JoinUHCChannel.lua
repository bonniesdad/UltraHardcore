function JoinUHCChannel()
  local channelName = 'uhc'
  -- Wait a moment on login
  C_Timer.After(0.5, function()
    local channelID = select(1, GetChannelName(channelName))
    if channelID == 0 then
      local success = JoinChannelByName(channelName)
      if success then
        C_Timer.After(0.5, function()
          -- Check if UHC channel is already configured in any chat frame
          local channelAlreadyConfigured = false
          for i = 1, NUM_CHAT_WINDOWS do
            local chatFrame = _G["ChatFrame" .. i]
            if chatFrame and chatFrame.channelList then
              for _, channel in pairs(chatFrame.channelList) do
                -- Only check for UHC channels specifically
                if channel == channelName then
                  channelAlreadyConfigured = true
                  break
                end
              end
            end
            if channelAlreadyConfigured then break end
          end
          
          -- Only add to default frame if not already configured elsewhere
          if not channelAlreadyConfigured then
            ChatFrame_AddChannel(DEFAULT_CHAT_FRAME, channelName)
          end
        end)
      end
    end
  end)
end
-- Function to send death message to UHC channel
local function SendDeathMessage()
  local channelName = "uhc"
  local channelID = select(1, GetChannelName(channelName))
  if channelID and channelID > 0 then
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
    local channelID = select(1, GetChannelName(channelName))
    if channelID and channelID > 0 then
      local characterName = UnitName("player")
      local class = UnitClass("player")
      SendChatMessage(characterName .. " (" .. class .. ") has reached level " .. newLevel .. "!", "CHANNEL", nil, channelID)
    end
  end
end

-- Register for events
local frame = CreateFrame('Frame')
frame:RegisterEvent('PLAYER_ENTERING_WORLD')
frame:RegisterEvent('PLAYER_DEAD')
frame:RegisterEvent('PLAYER_LEVEL_UP')
frame:SetScript('OnEvent', function(self, event, addonName, newLevel)
  if event == 'PLAYER_ENTERING_WORLD' then
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