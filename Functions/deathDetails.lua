-- Death Details Tracker
-- Posts death information as an emote when player dies

-- Initialize global table
DeathDetails = {}

-- Store the last damage event information
local lastDamageInfo = {
  sourceGUID = nil,
  sourceName = nil,
  sourceHealth = nil,
  sourceMaxHealth = nil,
  timestamp = 0,
}

-- Get unit name by GUID (for when sourceName is not available)
local function GetUnitNameByGUID(targetGUID)
  if not targetGUID then
    return nil
  end

  -- Check if it's the current target
  if UnitGUID('target') == targetGUID then
    return UnitName('target')
  end

  -- Check if it's a focus
  if UnitGUID('focus') == targetGUID then
    return UnitName('focus')
  end

  -- Check party members
  if IsInGroup() then
    if IsInRaid() then
      for i = 1, GetNumGroupMembers() do
        local unitID = 'raid' .. i
        if UnitGUID(unitID) == targetGUID then
          return UnitName(unitID)
        end
      end
    else
      for i = 1, GetNumGroupMembers() do
        local unitID = 'party' .. i
        if UnitGUID(unitID) == targetGUID then
          return UnitName(unitID)
        end
      end
    end
  end

  -- Try to get name from combat log cache or use GUID as fallback
  return nil
end

-- Get unit health by GUID
local function GetUnitHealthByGUID(targetGUID)
  if not targetGUID then
    return nil, nil
  end

  -- Check if it's the current target
  if UnitGUID('target') == targetGUID then
    return UnitHealth('target'), UnitHealthMax('target')
  end

  -- Check if it's a focus
  if UnitGUID('focus') == targetGUID then
    return UnitHealth('focus'), UnitHealthMax('focus')
  end

  -- Check party members
  if IsInGroup() then
    if IsInRaid() then
      for i = 1, GetNumGroupMembers() do
        local unitID = 'raid' .. i
        if UnitGUID(unitID) == targetGUID then
          return UnitHealth(unitID), UnitHealthMax(unitID)
        end
      end
    else
      for i = 1, GetNumGroupMembers() do
        local unitID = 'party' .. i
        if UnitGUID(unitID) == targetGUID then
          return UnitHealth(unitID), UnitHealthMax(unitID)
        end
      end
    end
  end

  -- Couldn't find the unit
  return nil, nil
end

-- Track damage events to the player
function DeathDetails.TrackDamageEvent(subEvent, sourceGUID, sourceName, destGUID)
  local playerGUID = UnitGUID('player')

  -- Only track damage events where the player is the target
  if destGUID ~= playerGUID then return end

  -- Track damage events (swing, spell, ranged, etc.)
  if subEvent == 'SWING_DAMAGE' or subEvent == 'SPELL_DAMAGE' or subEvent == 'RANGE_DAMAGE' or subEvent == 'DAMAGE_SHIELD' or subEvent == 'DAMAGE_SPLIT' then
    -- Only track if the source is an enemy (not the player themselves)
    if sourceGUID and sourceGUID ~= playerGUID then
      lastDamageInfo.sourceGUID = sourceGUID
      -- Try to get name from sourceName, or try to get it from GUID
      if sourceName and sourceName ~= '' then
        lastDamageInfo.sourceName = sourceName
      else
        -- Try to get name from unit if it's targetable
        lastDamageInfo.sourceName = GetUnitNameByGUID(sourceGUID) or 'Unknown'
      end

      -- Try to get and store the killer's health at the time of damage
      -- First check if it's the current target (most common case)
      local health, maxHealth = nil, nil
      if UnitGUID('target') == sourceGUID and UnitExists('target') then
        health, maxHealth = UnitHealth('target'), UnitHealthMax('target')
      else
        -- Try other methods
        health, maxHealth = GetUnitHealthByGUID(sourceGUID)
      end

      if health and maxHealth then
        lastDamageInfo.sourceHealth = health
        lastDamageInfo.sourceMaxHealth = maxHealth
      end

      lastDamageInfo.timestamp = GetTime()
    end
  end
end

-- Handle player death and post details as an emote
function DeathDetails.HandlePlayerDeath(destGUID)
  local playerGUID = UnitGUID('player')

  -- Only handle player's own death
  if destGUID ~= playerGUID then return end

  -- Get location information
  local zoneName = GetZoneText() or 'Unknown Zone'
  local subZoneName = GetSubZoneText()
  local location = zoneName
  if subZoneName and subZoneName ~= '' then
    location = subZoneName .. ', ' .. zoneName
  end

  -- Get killer information from last damage event
  local killerName = 'Unknown'
  local killerHealth = nil
  local killerMaxHealth = nil

  -- Check if we have recent damage info (within last 10 seconds)
  if lastDamageInfo.sourceGUID and (GetTime() - lastDamageInfo.timestamp) < 10 then
    -- Try to get name from stored info, or try to get it from GUID
    if lastDamageInfo.sourceName and lastDamageInfo.sourceName ~= 'Unknown' then
      killerName = lastDamageInfo.sourceName
    else
      killerName = GetUnitNameByGUID(lastDamageInfo.sourceGUID) or 'Unknown'
    end

    -- First try to use stored health from damage event
    if lastDamageInfo.sourceHealth and lastDamageInfo.sourceMaxHealth then
      killerHealth = lastDamageInfo.sourceHealth
      killerMaxHealth = lastDamageInfo.sourceMaxHealth
    else
      -- If no stored health, try to get it now (might not work if enemy is gone)
      killerHealth, killerMaxHealth = GetUnitHealthByGUID(lastDamageInfo.sourceGUID)
    end
  else
    -- If no recent damage info, try to get killer from current target
    if UnitExists('target') and UnitCanAttack('target', 'player') then
      killerName = UnitName('target') or 'Unknown'
      killerHealth, killerMaxHealth = UnitHealth('target'), UnitHealthMax('target')
    end
  end

  -- Format health information
  local healthText = 'Unknown'
  if killerHealth and killerMaxHealth then
    local healthPercent = math.floor((killerHealth / killerMaxHealth) * 100)
    healthText = killerHealth .. '/' .. killerMaxHealth .. ' (' .. healthPercent .. '%)'
  elseif killerHealth then
    healthText = tostring(killerHealth)
  end

  -- Construct death message
  -- Use " - " instead of " | " because pipe characters are used for color codes in WoW chat
  local message =
    string.format(
      "I've been slain by %s in %s. Their health was %s!",
      killerName,
      location,
      healthText
    )

  -- Track death history for Resource tab
  if CharacterStats and CharacterStats.AddDeathRecord then
    CharacterStats:AddDeathRecord({
      killer = killerName,
      location = location,
      healthText = healthText,
      level = UnitLevel('player'),
      timestamp = time(),
    })
    if type(UpdateResourceTabDeathCounter) == 'function' then
      UpdateResourceTabDeathCounter()
    end
  end

  -- Always print to chat frame first (works even when dead)
  DEFAULT_CHAT_FRAME:AddMessage('|cFFFF0000[ULTRA]|r ' .. message, 1, 0, 0)

  -- Try to post as emote (required when dead, cannot use SAY)
  local emoteSuccess, emoteErr = pcall(function()
    SendChatMessage(message, 'EMOTE')
  end)

  -- Send to guild if player is in a guild
  local isInGuild = IsInGuild()
  if isInGuild then
    SendChatMessage(message, 'GUILD')
  end

  -- Reset damage tracking
  lastDamageInfo.sourceGUID = nil
  lastDamageInfo.sourceName = nil
  lastDamageInfo.sourceHealth = nil
  lastDamageInfo.sourceMaxHealth = nil
  lastDamageInfo.timestamp = 0
end
