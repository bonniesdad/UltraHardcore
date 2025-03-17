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

  -- Join the channel
  JoinChannelByName(channelName)
  ChatFrame_AddChannel(DEFAULT_CHAT_FRAME, channelName)
end
