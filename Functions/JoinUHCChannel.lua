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
            local chatFrame = _G['ChatFrame' .. i]
            if chatFrame and chatFrame.channelList then
              for _, channel in pairs(chatFrame.channelList) do
                -- Only check for UHC channels specifically
                if channel == channelName then
                  channelAlreadyConfigured = true
                  break
                end
              end
            end
            if channelAlreadyConfigured then
              break
            end
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

-- Register for events
local frame = CreateFrame('Frame')
frame:RegisterEvent('PLAYER_ENTERING_WORLD')
frame:SetScript('OnEvent', function(self, event)
  if event == 'PLAYER_ENTERING_WORLD' then
    JoinUHCChannel()
  end
end)
