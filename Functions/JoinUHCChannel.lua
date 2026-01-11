function JoinUHCChannel(force)
  if not force and GLOBAL_SETTINGS and GLOBAL_SETTINGS.autoJoinUHCChannel == false then return end

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
          local channelConfiguredInShownFrame = false
          for i = 1, NUM_CHAT_WINDOWS do
            local chatFrame = _G['ChatFrame' .. i]
            if chatFrame and chatFrame.channelList then
              for _, channel in pairs(chatFrame.channelList) do
                -- Only check for UHC channels specifically
                if channel == channelName then
                  channelAlreadyConfigured = true
                  if chatFrame.IsShown and chatFrame:IsShown() then
                    channelConfiguredInShownFrame = true
                  end
                  break
                end
              end
            end
            if channelAlreadyConfigured and channelConfiguredInShownFrame then
              break
            end
          end

          local function EnsureChannelVisibleInDefaultChatFrame()
            -- Also ensure the chat frame is allowed to display channel messages at all.
            if ChatFrame_AddMessageGroup and DEFAULT_CHAT_FRAME then
              ChatFrame_AddMessageGroup(DEFAULT_CHAT_FRAME, 'CHANNEL')
            end

            -- Client compatibility:
            -- - Some clients expose ChatFrame_AddChannel(chatFrame, channelName)
            -- - TBC-era clients commonly use AddChatWindowChannel(windowIndex, channelName)
            if ChatFrame_AddChannel and DEFAULT_CHAT_FRAME then
              ChatFrame_AddChannel(DEFAULT_CHAT_FRAME, channelName)
            elseif AddChatWindowChannel then
              local windowIndex = 1
              if DEFAULT_CHAT_FRAME and DEFAULT_CHAT_FRAME.GetID then
                windowIndex = DEFAULT_CHAT_FRAME:GetID() or 1
              end
              AddChatWindowChannel(windowIndex, channelName)
            end
          end

          -- Only skip adding to default if it's already configured in a visible chat window.
          -- This avoids the "joined but can't see messages anywhere" situation.
          if not channelConfiguredInShownFrame then
            EnsureChannelVisibleInDefaultChatFrame()
          end
        end)
      end
    end
  end)
end

-- Suppress channel notice spam for the 'uhc' channel (optional; defaults ON via DB setting).
local function ShouldSuppressUHCJoinLeaveNotices()
  -- If settings haven't loaded yet, default to "true" so we don't spam on login.
  if not GLOBAL_SETTINGS then
    return true
  end
  if GLOBAL_SETTINGS.suppressUHCChannelJoinLeaveNotices == nil then
    return true
  end
  return GLOBAL_SETTINGS.suppressUHCChannelJoinLeaveNotices == true
end

local function EventHasChannelName(targetChannelName, ...)
  local target = string.lower(targetChannelName)
  for i = 1, select('#', ...) do
    local v = select(i, ...)
    if type(v) == 'string' and string.lower(v) == target then
      return true
    end
  end
  return false
end

local function UHCChannelNoticeFilter(_, event, ...)
  if not ShouldSuppressUHCJoinLeaveNotices() then
    return false
  end

  local noticeType = ...
  -- Hide common channel-notice spam (varies slightly by client/version).
  -- JOIN/LEAVE: join/leave spam
  -- MODERATOR/OWNER: moderator privileges, owner changes
  if noticeType ~= 'JOIN' and noticeType ~= 'LEAVE' and noticeType ~= 'MODERATOR' and noticeType ~= 'OWNER' and noticeType ~= 'YOU_CHANGED' then
    return false
  end

  -- We avoid relying on argument positions by scanning for the channel name.
  if not EventHasChannelName('uhc', ...) then
    return false
  end

  return true
end

-- Some moderation/owner messages arrive as CHAT_MSG_SYSTEM rather than channel notice events.
local function UHCSystemMessageFilter(_, event, message, ...)
  if not ShouldSuppressUHCJoinLeaveNotices() then
    return false
  end
  if type(message) ~= 'string' then
    return false
  end

  -- Only apply when the player is actually in the UHC channel.
  local channelID = select(1, GetChannelName('uhc'))
  if not channelID or channelID == 0 then
    return false
  end

  -- English client strings. These are intentionally broad to match minor punctuation differences.
  -- Examples:
  -- "Moderation privileges given to X."
  -- "Owner changed to Y."
  local msg = message:lower()
  if msg:find('moderation privileges given to', 1, true) then
    return true
  end
  if msg:find('owner changed to', 1, true) then
    return true
  end

  return false
end

-- Filter both notice events; different message variants fire across versions/contexts.
if ChatFrame_AddMessageEventFilter then
  ChatFrame_AddMessageEventFilter('CHAT_MSG_CHANNEL_NOTICE', UHCChannelNoticeFilter)
  ChatFrame_AddMessageEventFilter('CHAT_MSG_CHANNEL_NOTICE_USER', UHCChannelNoticeFilter)
  ChatFrame_AddMessageEventFilter('CHAT_MSG_SYSTEM', UHCSystemMessageFilter)
end

-- Slash command to toggle the filter:
--   /uhcnotices off  -> hide channel notice spam (default)
--   /uhcnotices on   -> show channel notice spam
SLASH_UHCNOTICES1 = '/uhcnotices'
SlashCmdList.UHCNOTICES = function(msg)
  msg = (msg or ''):lower():gsub('^%s+', ''):gsub('%s+$', '')

  if msg == 'on' or msg == 'show' then
    GLOBAL_SETTINGS.suppressUHCChannelJoinLeaveNotices = false
    print('|cFF33FF99UltraHardcore|r: UHC channel notices are now |cFF00FF00ON|r.')
    return
  end

  if msg == 'off' or msg == 'hide' or msg == '' then
    GLOBAL_SETTINGS.suppressUHCChannelJoinLeaveNotices = true
    print('|cFF33FF99UltraHardcore|r: UHC channel notices are now |cFFFF0000OFF|r.')
    return
  end

  print('|cFF33FF99UltraHardcore|r: Usage: /uhcnotices on|off')
end

-- Register for events
local frame = CreateFrame('Frame')
frame:RegisterEvent('PLAYER_ENTERING_WORLD')
frame:SetScript('OnEvent', function(self, event)
  if event == 'PLAYER_ENTERING_WORLD' then
    JoinUHCChannel()
  end
end)
