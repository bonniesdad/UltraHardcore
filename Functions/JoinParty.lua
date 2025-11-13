local frame = CreateFrame('Frame')

frame:RegisterEvent('GROUP_JOINED')
frame:RegisterEvent('GROUP_ROSTER_UPDATE')

-- Track previous party members to detect new joins
local previousPartyMembers = {}
local previousPartyCount = 0
local isInitialized = false

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

-- Function to automatically post warning message
local function postWarningMessage()

  local isHardcoreActive = C_GameRules.IsHardcoreActive()
  
  if not isHardcoreActive then
    return
  end

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
        local dungeonsCompleted = CharacterStats:GetStat('dungeonsCompleted') or 0
        messageSuffix = ' ' .. 'I have completed ' .. dungeonsCompleted .. (dungeonsCompleted == 1 and ' dungeon' or ' dungeons') .. '.'
      end

      if GLOBAL_SETTINGS.announcePartyDeathsOnGroupJoin then
        local partyDeathsWitnessed = CharacterStats:GetStat('partyMemberDeaths') or 0
        messageSuffix = messageSuffix .. ' ' .. partyDeathsWitnessed .. ' ' .. (partyDeathsWitnessed == 1 and 'person has' or 'people have') .. ' died in my party so far.'
      end

      local chatType = IsInRaid() and 'RAID' or 'PARTY'
      
      SendChatMessage(
        '[ULTRA] I am using the Ultra Hardcore addon. You are at a higher risk of death if you group with me.' .. messageSuffix,
        chatType
      )
    end
  end
end

frame:SetScript('OnEvent', function(self, event, ...)
  if event == 'GROUP_JOINED' then
    -- Automatically post warning message when joining a group
    postWarningMessage()
    
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
  end
end)
