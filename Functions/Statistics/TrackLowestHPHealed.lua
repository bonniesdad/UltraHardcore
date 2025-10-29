-- Tracks the lowest health percent a player had right before you healed them

local healthCacheByGUID = {}
local CACHE_TTL_SECONDS = 5

local function now()
  return GetTime()
end

local function isPlayerGUID(guid)
  return type(guid) == 'string' and guid:match('^Player%-') ~= nil
end

local function percentForUnit(unit)
  if not UnitExists(unit) then return nil end
  local maxHealth = UnitHealthMax(unit)
  if not maxHealth or maxHealth == 0 then return nil end
  local health = UnitHealth(unit)
  return (health / maxHealth) * 100
end

local function updateCacheForUnit(unit)
  local guid = UnitGUID(unit)
  if not guid then return end
  local pct = percentForUnit(unit)
  if not pct then return end
  healthCacheByGUID[guid] = { percent = pct, ts = now() }
end

local function scanCommonUnits()
  -- Always scan these
  updateCacheForUnit('player')
  updateCacheForUnit('target')
  updateCacheForUnit('mouseover')

  -- Party
  if IsInGroup() and not IsInRaid() then
    for i = 1, 4 do
      updateCacheForUnit('party' .. i)
      updateCacheForUnit('party' .. i .. 'pet')
    end
  end

  -- Raid
  if IsInRaid() then
    for i = 1, 40 do
      updateCacheForUnit('raid' .. i)
      updateCacheForUnit('raid' .. i .. 'pet')
    end
  end
end

local function getRecentPercentByGUID(guid)
  local entry = healthCacheByGUID[guid]
  if entry and (now() - entry.ts) <= CACHE_TTL_SECONDS then
    return entry.percent
  end
  -- Try to resolve via common unit tokens if cache is stale
  local candidates = { 'player', 'target', 'mouseover' }
  for _, unit in ipairs(candidates) do
    if UnitExists(unit) and UnitGUID(unit) == guid then
      local pct = percentForUnit(unit)
      if pct then
        healthCacheByGUID[guid] = { percent = pct, ts = now() }
        return pct
      end
    end
  end
  -- Try to resolve via party / raid units if cache is stale
  if IsInGroup() and not IsInRaid() then
    for i = 1, 4 do
      local unit = 'party' .. i
      if UnitExists(unit) and UnitGUID(unit) == guid then
        local pct = percentForUnit(unit)
        if pct then
          healthCacheByGUID[guid] = { percent = pct, ts = now() }
          return pct
        end
      end
    end
  elseif IsInRaid() then
    for i = 1, 40 do
      local unit = 'raid' .. i
      if UnitExists(unit) and UnitGUID(unit) == guid then
        local pct = percentForUnit(unit)
        if pct then
          healthCacheByGUID[guid] = { percent = pct, ts = now() }
          return pct
        end
      end
    end
  end
  return nil
end

-- Prune the cache to remove old entries after the cache TTL
local function pruneCache()
  local currentTime = now()
  for guid, entry in pairs(healthCacheByGUID) do
    if not entry or (currentTime - (entry.ts or 0)) > CACHE_TTL_SECONDS then
      healthCacheByGUID[guid] = nil
    end
  end
end

local function handleHealEvent()
  local _, subEvent, _, sourceGUID, _, _, _, destGUID = CombatLogGetCurrentEventInfo()
  if subEvent ~= 'SPELL_HEAL' and subEvent ~= 'SPELL_PERIODIC_HEAL' then return end

  if not destGUID or not isPlayerGUID(destGUID) then return end

  -- Only track heals cast by the player
  if sourceGUID ~= UnitGUID('player') then return end

  local preHealPct = getRecentPercentByGUID(destGUID)
  if not preHealPct then return end

  local currentRecord = CharacterStats:GetStat('lowestHPHealed') or 100
  if preHealPct < currentRecord then
    CharacterStats:UpdateStat('lowestHPHealed', preHealPct)
    print('|cfff44336[UHC]|r Heal registered on unit at ' .. string.format('%.1f', preHealPct) .. '% HP. New record!')
  else
    print('|cfff44336[UHC]|r Heal registered on unit at ' .. string.format('%.1f', preHealPct) .. '% HP. Value is not a new record.')
  end
end

-- Create a frame and register events
local f = CreateFrame('Frame')
f:RegisterEvent('UNIT_HEALTH')
f:RegisterEvent('PLAYER_TARGET_CHANGED')
f:RegisterEvent('UPDATE_MOUSEOVER_UNIT')
f:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')

f:SetScript('OnEvent', function(self, event, ...)
  if event == 'UNIT_HEALTH' then
    local unit = ...
    updateCacheForUnit(unit)
  elseif event == 'PLAYER_TARGET_CHANGED' or event == 'UPDATE_MOUSEOVER_UNIT' then
    scanCommonUnits()
  elseif event == 'COMBAT_LOG_EVENT_UNFILTERED' then
    handleHealEvent()
  end
end)

-- Occasional refresh to keep cache fresh during combat
local elapsedSinceScan = 0
local elapsedSincePrune = 0
f:SetScript('OnUpdate', function(self, elapsed)
  elapsedSinceScan = elapsedSinceScan + elapsed
  elapsedSincePrune = elapsedSincePrune + elapsed
  if elapsedSinceScan > 0.25 then
    scanCommonUnits()
    elapsedSinceScan = 0
  end
  if elapsedSincePrune > CACHE_TTL_SECONDS then
    pruneCache()
    elapsedSincePrune = 0
  end
end)
