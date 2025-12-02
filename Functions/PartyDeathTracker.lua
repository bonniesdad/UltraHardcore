-- Party Death Tracker
-- Handles tracking of party member deaths and related effects

-- Initialize global table
PartyDeathTracker = {}

-- Check if a unit is a party member
local function IsPartyMember(destGUID)
  local playerGUID = UnitGUID('player')
  if destGUID == playerGUID or not IsInGroup() then
    return false, nil
  end

  local isPartyMember = false
  local deadPlayerName = nil

  if IsInRaid() then
    for i = 1, GetNumGroupMembers() do
      local name, _, _, _, _, _, _, _, _, _, _, guid = GetRaidRosterInfo(i)
      if guid == destGUID then
        isPartyMember = true
        deadPlayerName = name
        break
      end
    end
  else
    -- Regular party (not raid)
    for i = 1, GetNumGroupMembers() do
      local unitID = 'party' .. i
      if UnitGUID(unitID) == destGUID then
        isPartyMember = true
        deadPlayerName = UnitName(unitID)
        break
      end
    end
  end

  return isPartyMember, deadPlayerName
end

-- Check if a party member is feigning death
local function IsPartyMemberFeigningDeath(destGUID)
  if IsInRaid() then
    -- For raids, we need to find the unit ID to check feign death status
    for i = 1, GetNumGroupMembers() do
      local name, _, _, _, _, _, _, _, _, _, _, guid = GetRaidRosterInfo(i)
      if guid == destGUID then
        local unitID = 'raid' .. i
        return UnitIsFeignDeath(unitID)
      end
    end
  else
    -- For regular parties, find the unit ID
    for i = 1, GetNumGroupMembers() do
      local unitID = 'party' .. i
      if UnitGUID(unitID) == destGUID then
        return UnitIsFeignDeath(unitID)
      end
    end
  end
  return false
end

-- Handle party member death
function PartyDeathTracker.HandlePartyMemberDeath(destGUID)
  local playerGUID = UnitGUID('player')

  if destGUID == playerGUID then
    -- Player death sound
    if GLOBAL_SETTINGS.playPlayerDeathSoundbite then
      PlaySoundFile('Interface\\AddOns\\UltraHardcore\\Sounds\\PlayerDeath.ogg', 'SFX')
    end
    return
  end

  local isPartyMember, deadPlayerName = IsPartyMember(destGUID)

  if not isPartyMember or not deadPlayerName then return end

  -- Check if the dead party member is feigning death
  local isFeigningDeath = IsPartyMemberFeigningDeath(destGUID)

  -- Only increment death count if they're not feigning death
  if not isFeigningDeath then
    local currentPartyDeaths = CharacterStats:GetStat('partyMemberDeaths') or 0
    local newCount = currentPartyDeaths + 1
    CharacterStats:UpdateStat('partyMemberDeaths', newCount)

    if GLOBAL_SETTINGS.playPartyDeathSoundbite then
      local randomNumber = random(1, 4)
      -- Play sound file on party death
      PlaySoundFile(
        'Interface\\AddOns\\UltraHardcore\\Sounds\\PartyDeath' .. randomNumber .. '.ogg',
        'SFX'
      )
    end

    -- Optional: Print a message to chat
    DEFAULT_CHAT_FRAME:AddMessage(
      '|cFFFF0000[ULTRA]|r Party member ' .. deadPlayerName .. ' has died. Total party deaths: ' .. newCount,
      1,
      0,
      0
    )
  else
    -- Optional: Print a message indicating feign death was detected
    DEFAULT_CHAT_FRAME:AddMessage(
      '|cFFFF8000[ULTRA]|r Party member ' .. deadPlayerName .. ' is feigning death - death count not incremented.',
      1,
      0.5,
      0
    )
  end
end
