local frame = CreateFrame('Frame')

frame:RegisterEvent('GROUP_JOINED')
frame:RegisterEvent('GROUP_ROSTER_UPDATE')

-- Track previous party members to detect new joins
local previousPartyMembers = {}

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
      local chatType = IsInRaid() and 'RAID' or 'PARTY'
      SendChatMessage(
        '[ULTRA] I am using the Ultra Hardcore addon. You are at a higher risk of death if you group with me.',
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
    
  elseif event == 'GROUP_ROSTER_UPDATE' then
    -- Check if someone new joined the party
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
    
    -- Update party member tracking
    previousPartyMembers = currentMembers
  end
end)
