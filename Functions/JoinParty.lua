local frame = CreateFrame('Frame')

frame:RegisterEvent('GROUP_JOINED')
frame:RegisterEvent('GROUP_ROSTER_UPDATE')
frame:RegisterEvent('CHAT_MSG_ADDON')

local VERIFY_PREFIX = 'UHCVerify'

do
  if C_ChatInfo and C_ChatInfo.RegisterAddonMessagePrefix then
    C_ChatInfo.RegisterAddonMessagePrefix(VERIFY_PREFIX)
  elseif RegisterAddonMessagePrefix then
    RegisterAddonMessagePrefix(VERIFY_PREFIX)
  end
end

-- Track previous party members to detect new joins
local previousPartyMembers = {}
local previousPartyCount = 0
local isInitialized = false

local lastVerifyBroadcast = 0

local VALID_VERDICT = {
  Failed = true,
  Sceptical = true,
  Verified = true,
}

-- Function to get current party member names
local function getCurrentPartyMembers()
  local members = {}
  if IsInRaid() then
    for i = 1, GetNumGroupMembers() do
      local name = GetRaidRosterInfo(i)
      if name then
        table.insert(members, name)
      end
    end
  elseif IsInGroup() then
    for i = 1, GetNumGroupMembers() do
      local name = UnitName('party' .. i)
      if name then
        table.insert(members, name)
      end
    end
  end
  return members
end

local function groupHasOtherMembers()
  if not IsInGroup() then
    return false
  end
  local numMembers = GetNumGroupMembers()
  local playerName = UnitName('player')
  if IsInRaid() then
    for i = 1, numMembers do
      local name = GetRaidRosterInfo(i)
      if name and name ~= playerName then
        return true
      end
    end
  else
    for i = 1, numMembers do
      local name = UnitName('party' .. i)
      if name and name ~= playerName then
        return true
      end
    end
  end
  return false
end

local function senderDisplayName(sender)
  if not sender or sender == '' then
    return '?'
  end
  if type(Ambiguate) == 'function' then
    return Ambiguate(sender, 'short')
  end
  return sender:match('^([^%-]+)') or sender
end

local function sendVerificationBroadcast()
  if not groupHasOtherMembers() then return end
  local now = (GetTime and GetTime()) or 0
  if now - lastVerifyBroadcast < 2.0 then return end
  if not (UHC_XPVerification and UHC_XPVerification.BuildVerificationPartyBroadcastPayload) then return end
  local payload = UHC_XPVerification.BuildVerificationPartyBroadcastPayload()
  if not payload or payload == '' or #payload > 255 then return end
  local chatType = IsInRaid() and 'RAID' or 'PARTY'
  if C_ChatInfo and C_ChatInfo.SendAddonMessage then
    C_ChatInfo.SendAddonMessage(VERIFY_PREFIX, payload, chatType)
  elseif SendAddonMessage then
    SendAddonMessage(VERIFY_PREFIX, payload, chatType)
  end
  lastVerifyBroadcast = now
end

local function onVerificationAddonMessage(message, sender)
  local version, verdict, tierLabel, _lite, _rec, _ext, backdatedFlag = strsplit('|', message or '')
  if version ~= '1' or not verdict or not tierLabel then return end
  if not VALID_VERDICT[verdict] then return end
  local name = senderDisplayName(sender)
  local isBackdated = tostring(backdatedFlag) == '1'
  local backdatedSuffix = isBackdated and ' (Backdated)' or ''
  local line = string.format('[ULTRA] %s %s%s: %s', name, verdict, backdatedSuffix, tierLabel)
  if DEFAULT_CHAT_FRAME and DEFAULT_CHAT_FRAME.AddMessage then
    DEFAULT_CHAT_FRAME:AddMessage(line, 1, 0.82, 0)
  else
    print(line)
  end
end

-- Function to automatically post warning message
local function postWarningMessage()
  local isHardcoreActive = C_GameRules.IsHardcoreActive()

  if not isHardcoreActive then return end

  if IsInGroup() then
    -- Check if there are other members besides ourselves
    local numMembers = GetNumGroupMembers()
    local playerName = UnitName('player')
    local hasOtherMembers = false

    if IsInRaid() then
      for i = 1, numMembers do
        local name = GetRaidRosterInfo(i)
        if name and name ~= playerName then
          hasOtherMembers = true
          break
        end
      end
    else
      -- For party groups, check party members
      for i = 1, numMembers do
        local name = UnitName('party' .. i)
        if name and name ~= playerName then
          hasOtherMembers = true
          break
        end
      end
    end

    -- Only post message if there are other members in the group
    if hasOtherMembers then
      local messageSuffix = ''
      if GLOBAL_SETTINGS.announceDungeonsCompletedOnGroupJoin then
        local dungeonsCompleted = UltraStatisticsCharacterStats:GetStat('dungeonsCompleted') or 0
        messageSuffix =
          ' ' .. 'I have completed ' .. dungeonsCompleted .. (dungeonsCompleted == 1 and ' dungeon' or ' dungeons') .. '.'
      end

      if GLOBAL_SETTINGS.announcePartyDeathsOnGroupJoin then
        local partyDeathsWitnessed = UltraStatisticsCharacterStats:GetStat('partyMemberDeaths') or 0
        messageSuffix =
          messageSuffix .. ' ' .. partyDeathsWitnessed .. ' ' .. (partyDeathsWitnessed == 1 and 'person has' or 'people have') .. ' died in my party so far.'
      end

      local chatType = IsInRaid() and 'RAID' or 'PARTY'

      SendChatMessage(
        '[ULTRA] I am using the ULTRA addon. You are at a higher risk of death if you group with me.' .. messageSuffix,
        chatType
      )
    end
  end
end

frame:SetScript('OnEvent', function(self, event, ...)
  if event == 'GROUP_JOINED' then
    -- Automatically post warning message when joining a group
    postWarningMessage()
    sendVerificationBroadcast()

    -- Update party member tracking
    previousPartyMembers = getCurrentPartyMembers()
    previousPartyCount = GetNumGroupMembers()
    isInitialized = true
  elseif event == 'GROUP_ROSTER_UPDATE' then
    -- Skip if not initialized yet (prevents false triggers on addon load)
    if not isInitialized then
      previousPartyMembers = getCurrentPartyMembers()
      previousPartyCount = GetNumGroupMembers()
      isInitialized = true
      return
    end

    -- Only check for new members if the party count has increased
    -- This prevents sending join messages when someone levels up or leaves
    local currentPartyCount = GetNumGroupMembers()

    if currentPartyCount > previousPartyCount then
      -- Party count increased, someone actually joined
      local currentMembers = getCurrentPartyMembers()
      local playerName = UnitName('player')

      -- Check if we have new members (excluding ourselves)
      for _, member in ipairs(currentMembers) do
        local isNewMember = true
        for _, prevMember in ipairs(previousPartyMembers) do
          if member == prevMember then
            isNewMember = false
            break
          end
        end

        -- If it's a new member and not ourselves, post warning message
        if isNewMember and member ~= playerName then
          postWarningMessage()
          sendVerificationBroadcast()
          break -- Only post once per roster update
        end
      end

      -- Update party member tracking only when someone joins
      previousPartyMembers = currentMembers
    elseif currentPartyCount < previousPartyCount then
      -- Party count decreased, someone left - update tracking but don't send message
      previousPartyMembers = getCurrentPartyMembers()
    end

    -- Always update the party count for next comparison
    previousPartyCount = currentPartyCount
  elseif event == 'CHAT_MSG_ADDON' then
    local prefix, message, _channel, sender = ...
    if prefix == VERIFY_PREFIX then
      onVerificationAddonMessage(message, sender)
    end
  end
end)
