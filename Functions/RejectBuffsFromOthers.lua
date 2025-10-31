--[[
  Reject Buffs From Others
  Automatically cancels buffs that do not come from the player themselves
  Tracks buff sources from combat log events and cancels buffs not cast by the player
]]

-- Table to track buff sources
-- Key: buff spell ID, Value: GUID of who cast it
local buffSources = {}

-- Function to cancel a buff
function CancelBuff(buffName)
  -- Use CancelUnitBuff to cancel the buff
  -- We need to cancel by index because CancelUnitBuff requires an index
  for i = 1, 40 do
    local name, _, _, _, _, _, sourceUnit, _, _, spellId = UnitBuff('player', i)
    if not name then
      break
    end

    if name == buffName then
      CancelUnitBuff('player', i)
      return true
    end
  end
  return false
end

-- Function to handle buff application tracking
local function TrackBuffSource(spellID, sourceGUID)
  local playerGUID = UnitGUID('player')

  -- Store the source of the buff
  if spellID then
    buffSources[spellID] = sourceGUID
  end

  -- Clean up old entries periodically (check count)
  local count = 0
  for _ in pairs(buffSources) do
    count = count + 1
  end
  if count > 1000 then
    buffSources = {}
  end
end

-- Function to check and reject incoming buffs
local function CheckAndRejectBuffs(incomingBuffUnit)
  if not GLOBAL_SETTINGS or not GLOBAL_SETTINGS.rejectBuffsFromOthers then return end

  local inGuildFound = GLOBAL_SETTINGS and GLOBAL_SETTINGS.guildSelfFound
  local inGroupFound = GLOBAL_SETTINGS and GLOBAL_SETTINGS.groupSelfFound

  local playerGUID = UnitGUID('player')

  -- Check all active buffs
  for i = 1, 40 do
    local name, icon, count, debuffType, duration, expirationTime, source, isStealable =
      UnitBuff('player', i)
    if not name then
      break
    end

    -- Try to find the spell ID for this buff
    local spellID = nil
    local buffSourceGUID = nil

    -- Check if we can get spell ID from GetSpellInfo
    for spellIDKey, sourceGUID in pairs(buffSources) do
      local spellName = GetSpellInfo(spellIDKey)
      if spellName == name then
        spellID = spellIDKey
        buffSourceGUID = sourceGUID
        break
      end
    end

    if spellID and buffSourceGUID then
      -- If the buff was from someone other than the player, cancel it
      local incomingBuffPlayerName = nil
      if source then
        incomingBuffPlayerName = UnitName(source)
      end
      if inGuildFound and incomingBuffPlayerName and not IsAllowedByGuildList(
        incomingBuffPlayerName
      ) then
        if buffSourceGUID ~= playerGUID then
          CancelBuff(name)
        end
      elseif inGroupFound and incomingBuffPlayerName and not IsAllowedByGroupList(
        incomingBuffPlayerName
      ) then
        if buffSourceGUID ~= playerGUID then
          CancelBuff(name)
        end
      elseif not inGuildFound and not inGroupFound then
        if buffSourceGUID ~= playerGUID then
          CancelBuff(name)
          -- Remove from tracking after canceling
          buffSources[spellID] = nil
        end
      end
    end
  end
end

-- Function to mark a buff as self-applied (for food, potions, etc.)
function MarkBuffAsSelfApplied(spellID)
  if spellID then
    selfAppliedBuffs[spellID] = true
    -- Mark in buffSources as well
    local playerGUID = UnitGUID('player')
    buffSources[spellID] = playerGUID
  end
end

-- Export functions
function RejectBuffsFromOthers(event, unit)
  if event == 'UNIT_AURA' and unit == 'player' then
    -- When auras update, check and reject buffs
    CheckAndRejectBuffs(unit)
  end
end

-- Export the tracking function for combat log events
function TrackBuffApplication(subEvent, sourceGUID, destGUID, spellID)
  if not spellID then return end

  -- Track when buffs are applied to the player
  if subEvent == 'SPELL_CAST_SUCCESS' or subEvent == 'SPELL_AURA_APPLIED' then
    local playerGUID = UnitGUID('player')

    -- If buff is being applied to the player
    if destGUID == playerGUID then
      TrackBuffSource(spellID, sourceGUID)
    end
  end
end

-- Make functions globally accessible
_G.RejectBuffsFromOthers = RejectBuffsFromOthers
_G.TrackBuffApplication = TrackBuffApplication
_G.MarkBuffAsSelfApplied = MarkBuffAsSelfApplied
