-- Player State Snapshot
-- Captures and stores player information to detect cheating by turning addon off/on

local AceSerializer = LibStub("AceSerializer-3.0")

local PlayerStateSnapshot = {}
local bankIsOpen = false

-- Equipment slot IDs (0-19)
local EQUIPMENT_SLOTS = {
  [0] = 'AMMOSLOT',
  [1] = 'HEAD',
  [2] = 'NECK',
  [3] = 'SHOULDER',
  [4] = 'SHIRT',
  [5] = 'CHEST',
  [6] = 'WAIST',
  [7] = 'LEGS',
  [8] = 'FEET',
  [9] = 'WRIST',
  [10] = 'HAND',
  [11] = 'FINGER0',
  [12] = 'FINGER1',
  [13] = 'TRINKET0',
  [14] = 'TRINKET1',
  [15] = 'BACK',
  [16] = 'MAINHAND',
  [17] = 'OFFHAND',
  [18] = 'RANGED',
  [19] = 'TABARDSLOT',
}

-- Get all equipped items
local function GetEquippedItems()
  local equippedItems = {}
  
  for slotId = 0, 19 do
    local itemId = GetInventoryItemID('player', slotId)
    if itemId then
      equippedItems[slotId] = itemId
    end
  end
  
  return equippedItems
end

-- Get all inventory items from all bags
local function GetInventoryItems()
  local inventoryItems = {}
  
  -- Backpack (bag 0) - typically 16 slots
  for bagId = 0, 4 do
    local bagSlots = {}
    local numSlots = C_Container.GetContainerNumSlots(bagId)
    
    if numSlots and numSlots > 0 then
      for slotId = 1, numSlots do
        local itemId = C_Container.GetContainerItemID(bagId, slotId)
        if itemId then
          bagSlots[slotId] = itemId
        end
      end
    end
    
    if next(bagSlots) then -- Only store if bag has items
      inventoryItems[bagId] = bagSlots
    end
  end
  
  return inventoryItems
end

-- Get all bank items
local function GetBankItems()
  local bankItems = {}
  
  -- Main bank window (bag -1) - 28 slots in Classic
  local mainBankSlots = {}
  for slotId = 1, 28 do
    local itemId = C_Container.GetContainerItemID(-1, slotId)
    if itemId then
      mainBankSlots[slotId] = itemId
    end
  end
  
  if next(mainBankSlots) then
    bankItems[-1] = mainBankSlots
  end
  
  -- Bank bags (bags 5-11 in Classic)
  for bagId = 5, 11 do
    local bagSlots = {}
    local numSlots = C_Container.GetContainerNumSlots(bagId)
    
    if numSlots and numSlots > 0 then
      for slotId = 1, numSlots do
        local itemId = C_Container.GetContainerItemID(bagId, slotId)
        if itemId then
          bagSlots[slotId] = itemId
        end
      end
    end
    
    if next(bagSlots) then
      bankItems[bagId] = bagSlots
    end
  end
  
  return bankItems
end

-- Get player currency information
local function GetCurrencyInfo()
  local currency = {
    money = GetMoney(),
  }
  return currency
end

-- Get player level and experience
local function GetLevelAndExperience()
  return {
    level = UnitLevel('player'),
    currentXP = UnitXP('player'),
  }
end

-- Get player location
local function GetPlayerLocation()
  local zoneName = GetZoneText()
  local subZoneName = GetSubZoneText()
  
  return {
    zoneName = zoneName,
    subZoneName = subZoneName,
  }
end

-- Simple hash function for data integrity
-- Combines important values (items, money, level) into a hash to detect tampering
local function GenerateStateHash(state)
  if not state or type(state) ~= "table" then
    return 0
  end
  
  local hash = 0
  
  -- Hash equipped items
  if state.equippedItems then
    for slotId = 0, 19 do
      local itemId = state.equippedItems[slotId] or 0
      hash = hash + (slotId * 1000000) + itemId
    end
  end
  
  -- Hash inventory items
  if state.inventoryItems then
    for bagId = 0, 4 do
      if state.inventoryItems[bagId] then
        for slotId, itemId in pairs(state.inventoryItems[bagId]) do
          hash = hash + (bagId * 100000) + (slotId * 10000) + itemId
        end
      end
    end
  end
  
  -- Hash bank items
  if state.bankItems then
    for bagId = -1, 11 do
      if state.bankItems[bagId] then
        for slotId, itemId in pairs(state.bankItems[bagId]) do
          hash = hash + ((bagId + 100) * 100000) + (slotId * 10000) + itemId
        end
      end
    end
  end
  
  -- Hash money
  if state.currency then
    hash = hash + (state.currency.money or 0)
  end
  
  -- Hash level
  if state.levelInfo then
    hash = hash + ((state.levelInfo.level or 0) * 1000000000)
  end
  
  -- Simple modulo to keep hash reasonable size
  return hash % 2147483647
end

-- Serialize any table using AceSerializer (makes data non-human-readable)
local function SerializeData(data)
  if not data or not AceSerializer then
    return nil
  end
  
  -- AceSerializer.Serialize can throw errors, so we wrap it in pcall
  local success, serialized = pcall(AceSerializer.Serialize, AceSerializer, data)
  if success and serialized then
    return serialized
  end
  
  return nil
end

-- Deserialize data using AceSerializer
local function DeserializeData(serializedData)
  if not serializedData or not AceSerializer then
    return nil
  end
  
  -- AceSerializer.Deserialize already uses pcall internally and returns (success, data, ...) or (false, error)
  -- So we should NOT wrap it in another pcall
  local success, data = AceSerializer:Deserialize(serializedData)
  
  if success and data then
    return data
  end
  
  return nil
end

-- Get deserialized player snapshot from state
local function GetDeserializedSnapshot(state)
  if not state or not state.playerSnapshotSerialized then
    return nil
  end
  
  local snapshot = DeserializeData(state.playerSnapshotSerialized)
  if snapshot and type(snapshot) == "table" then
    return snapshot
  end
  
  return nil
end

-- Verify hash matches state data
-- Returns true if valid, false if tampered
local function VerifyStateHash(state)
  if not state or not state.playerSnapshotSerialized or not state.playerSnapshotHash then
    return false
  end
  
  local snapshot = DeserializeData(state.playerSnapshotSerialized)
  if not snapshot or type(snapshot) ~= "table" then
    return false -- Deserialization failed or invalid data type
  end
  
  -- Calculate expected hash from deserialized data
  local expectedHash = GenerateStateHash(snapshot)
  
  -- Compare stored hash with calculated hash
  return state.playerSnapshotHash == expectedHash
end

local function CollectTrackedItemIds(equippedItems, inventoryItems, bankItems, previousCounts)
  local ids = {}
  
  if inventoryItems then
    for _, bagSlots in pairs(inventoryItems) do
      for _, itemId in pairs(bagSlots) do
        if itemId then
          ids[itemId] = true
        end
      end
    end
  end
  
  if bankItems then
    for _, bagSlots in pairs(bankItems) do
      for _, itemId in pairs(bagSlots) do
        if itemId then
          ids[itemId] = true
        end
      end
    end
  end
  
  if equippedItems then
    for _, itemId in pairs(equippedItems) do
      if itemId then
        ids[itemId] = true
      end
    end
  end
  
  if previousCounts then
    for itemId in pairs(previousCounts) do
      if itemId then
        ids[itemId] = true
      end
    end
  end
  
  return ids
end

-- Build item count map from bags and bank (items can move between them)
local function BuildItemCountMap(inventoryItems, bankItems)
  local itemCounts = {}
  
  -- Count items in bags
  if inventoryItems then
    for bagId = 0, 4 do
      if inventoryItems[bagId] then
        for slotId, itemId in pairs(inventoryItems[bagId]) do
          itemCounts[itemId] = (itemCounts[itemId] or 0) + 1
        end
      end
    end
  end
  
  -- Count items in bank
  if bankItems then
    for bagId = -1, 11 do
      if bankItems[bagId] then
        for slotId, itemId in pairs(bankItems[bagId]) do
          itemCounts[itemId] = (itemCounts[itemId] or 0) + 1
        end
      end
    end
  end
  
  return itemCounts
end

-- Capture complete player state snapshot
function PlayerStateSnapshot:CapturePlayerState()
  local characterGUID = UnitGUID('player')
  
  if not characterGUID then
    return nil -- Player GUID not available yet
  end

  if not UltraHardcoreDB then
    UltraHardcoreDB = {}
  end
  
  -- Initialize player state database if it doesn't exist
  if not UltraHardcoreDB.playerState then
    UltraHardcoreDB.playerState = {}
  end
  
  -- Preserve existing tamper flags (don't overwrite them)
  local existingState = UltraHardcoreDB.playerState[characterGUID] or {}
  local existingTamperHash = existingState.playerHash
  local existingTamperTimestamp = existingState.playerTimestamp
  
  -- Get previous snapshot if it exists (for bank items and item counts)
  local previousSnapshot = GetDeserializedSnapshot(existingState)
  
  local equippedItems = GetEquippedItems()
  local inventoryItems = GetInventoryItems()
  local bankItems = bankIsOpen and GetBankItems() or (previousSnapshot and previousSnapshot.bankItems)
  local previousItemCounts = previousSnapshot and previousSnapshot.itemCounts
  local trackedItemIds = CollectTrackedItemIds(equippedItems, inventoryItems, bankItems, previousItemCounts)
  
  -- Capture remaining state information
  local timestamp = time()
  local currency = GetCurrencyInfo()
  local levelInfo = GetLevelAndExperience()
  local location = GetPlayerLocation()
  
  -- Build item counts using the same method as comparison (BuildItemCountMap)
  -- This ensures consistency between capture and comparison
  local itemCounts = BuildItemCountMap(inventoryItems, bankItems)
  -- Also include equipped items in counts
  if equippedItems then
    for _, itemId in pairs(equippedItems) do
      if itemId then
        itemCounts[itemId] = (itemCounts[itemId] or 0) + 1
      end
    end
  end
  
  -- Create player snapshot bundle (all state data)
  local playerSnapshot = {
    timestamp = timestamp,
    equippedItems = equippedItems,
    inventoryItems = inventoryItems,
    bankItems = bankItems,
    itemCounts = itemCounts,
    currency = currency,
    levelInfo = levelInfo,
    location = location,
  }
  
  -- Generate and store hash for integrity checking (one-line verification)
  local stateHash = GenerateStateHash(playerSnapshot)
  
  -- Preserve tamper flags (don't overwrite persistent tamper detection)
  if existingTamperHash then
    existingState.playerHash = existingTamperHash
  end
  if existingTamperTimestamp then
    existingState.playerTimestamp = existingTamperTimestamp
  end
  
    -- Serialize the entire player snapshot (non-human-readable)
    local snapshotSerialized = SerializeData(playerSnapshot)
    if not snapshotSerialized then
      -- Serialization failed - this shouldn't happen
      return nil
    end
    
    existingState.playerSnapshotSerialized = snapshotSerialized
    existingState.playerSnapshotHash = stateHash
  
  -- Store the state
  UltraHardcoreDB.playerState[characterGUID] = existingState
  
  -- Save to database
  SaveDBData('playerState', UltraHardcoreDB.playerState)
  
  -- Return deserialized state for compatibility
  return playerSnapshot
end

local function BuildStoredItemCounts(state)
  local counts = BuildItemCountMap(state.inventoryItems, state.bankItems)
  
  if state.equippedItems then
    for _, itemId in pairs(state.equippedItems) do
      if itemId then
        counts[itemId] = (counts[itemId] or 0) + 1
      end
    end
  end
  
  return counts
end

local function CompareStates(oldState, newState)
  if not oldState or not newState then
    return true
  end
  
  -- Compare equipped items (check all slots 0-19)
  for slotId = 0, 19 do
    local oldItemId = oldState.equippedItems and oldState.equippedItems[slotId] or nil
    local newItemId = newState.equippedItems and newState.equippedItems[slotId] or nil
    if oldItemId ~= newItemId then
      return true -- Equipped item changed
    end
  end
  
  -- Compare items by count (allowing movement between bags and bank)
  local oldItemCounts = BuildItemCountMap(oldState.inventoryItems, oldState.bankItems)
  local newItemCounts = BuildItemCountMap(newState.inventoryItems, newState.bankItems)
  
  local allItemIds = {}
  for itemId in pairs(oldItemCounts) do
    allItemIds[itemId] = true
  end
  for itemId in pairs(newItemCounts) do
    allItemIds[itemId] = true
  end
  
  for itemId in pairs(allItemIds) do
    local oldCount = oldItemCounts[itemId] or 0
    local newCount = newItemCounts[itemId] or 0
    if newCount > oldCount then
      return true -- New stack appeared
    end
  end
  
  return false
end

local function GatherObservedItemIds()
  local ids = {}
  local inventoryItems = GetInventoryItems()
  if inventoryItems then
    for _, bagSlots in pairs(inventoryItems) do
      for _, itemId in pairs(bagSlots) do
        if itemId then
          ids[itemId] = true
        end
      end
    end
  end
  
  local equippedItems = GetEquippedItems()
  if equippedItems then
    for _, itemId in pairs(equippedItems) do
      if itemId then
        ids[itemId] = true
      end
    end
  end
  
  return ids
end

-- Build a detailed table of what changed between two states
local function BuildChangeTable(oldState, newState)
  local changes = {
    xp = {},
    items = {},
    currency = {},
    equipment = {},
    hashMismatch = false,
  }
  
  if not oldState or not newState then
    return changes
  end
  
  -- Check XP/Level changes
  local oldLevel = oldState.levelInfo and oldState.levelInfo.level or 0
  local oldXP = oldState.levelInfo and oldState.levelInfo.currentXP or 0
  local newLevel = newState.levelInfo and newState.levelInfo.level or 0
  local newXP = newState.levelInfo and newState.levelInfo.currentXP or 0
  
  if oldLevel ~= newLevel or oldXP ~= newXP then
    changes.xp = {
      level = { old = oldLevel, new = newLevel },
      currentXP = { old = oldXP, new = newXP },
      xpGained = (newLevel > oldLevel) and ((newLevel - oldLevel) * 1000000 + newXP - oldXP) or (newXP - oldXP),
    }
  end
  
  -- Check currency changes
  local oldMoney = oldState.currency and oldState.currency.money or 0
  local newMoney = newState.currency and newState.currency.money or 0
  
  if oldMoney ~= newMoney then
    changes.currency = {
      money = { old = oldMoney, new = newMoney, delta = newMoney - oldMoney },
    }
  end
  
  -- Check equipment changes
  for slotId = 0, 19 do
    local oldItemId = oldState.equippedItems and oldState.equippedItems[slotId] or nil
    local newItemId = newState.equippedItems and newState.equippedItems[slotId] or nil
    if oldItemId ~= newItemId then
      changes.equipment[slotId] = { old = oldItemId, new = newItemId }
    end
  end
  
  -- Check item count changes (inventory + bank)
  -- Use itemCounts from snapshot if available (already includes equipped items), otherwise build from inventory/bank
  local oldItemCounts = {}
  if oldState.itemCounts then
    -- Snapshot itemCounts already includes equipped items, use as-is
    for itemId, count in pairs(oldState.itemCounts) do
      oldItemCounts[itemId] = count
    end
  else
    -- Build from inventory/bank and add equipped items
    oldItemCounts = BuildItemCountMap(oldState.inventoryItems, oldState.bankItems)
    if oldState.equippedItems then
      for _, itemId in pairs(oldState.equippedItems) do
        if itemId then
          oldItemCounts[itemId] = (oldItemCounts[itemId] or 0) + 1
        end
      end
    end
  end
  
  -- Build new counts from inventory/bank and add equipped items (same method as capture)
  local newItemCounts = BuildItemCountMap(newState.inventoryItems, newState.bankItems)
  if newState.equippedItems then
    for _, itemId in pairs(newState.equippedItems) do
      if itemId then
        newItemCounts[itemId] = (newItemCounts[itemId] or 0) + 1
      end
    end
  end
  
  -- Find all item IDs that changed
  local allItemIds = {}
  for itemId in pairs(oldItemCounts) do
    allItemIds[itemId] = true
  end
  for itemId in pairs(newItemCounts) do
    allItemIds[itemId] = true
  end
  
  -- Track item changes
  for itemId in pairs(allItemIds) do
    local oldCount = oldItemCounts[itemId] or 0
    local newCount = newItemCounts[itemId] or 0
    if oldCount ~= newCount then
      changes.items[itemId] = { old = oldCount, new = newCount, delta = newCount - oldCount }
    end
  end
  
  -- Check for hash mismatch (tampering indicator)
  -- Note: oldState here is the stored state object, not the deserialized snapshot
  if oldState and oldState.playerSnapshotSerialized and oldState.playerSnapshotHash then
    local snapshot = DeserializeData(oldState.playerSnapshotSerialized)
    if snapshot and type(snapshot) == "table" then
      local expectedHash = GenerateStateHash(snapshot)
      if oldState.playerSnapshotHash ~= expectedHash then
        changes.hashMismatch = true
      end
    else
      changes.hashMismatch = true -- Deserialization failed or invalid data type
    end
  end
  
  return changes
end

-- Hash a change table for integrity
local function HashChangeTable(changes)
  if not changes or type(changes) ~= "table" or not next(changes) then
    return 0
  end
  
  local hash = 0
  
  -- Hash XP changes
  if changes.xp and next(changes.xp) then
    if changes.xp.level then
      hash = hash + (changes.xp.level.old or 0) * 1000000
      hash = hash + (changes.xp.level.new or 0) * 10000
    end
    if changes.xp.currentXP then
      hash = hash + (changes.xp.currentXP.old or 0) * 1000
      hash = hash + (changes.xp.currentXP.new or 0)
    end
    if changes.xp.xpGained then
      hash = hash + changes.xp.xpGained * 10000000
    end
  end
  
  -- Hash currency changes
  if changes.currency and changes.currency.money then
    hash = hash + (changes.currency.money.delta or 0) * 1000000000
  end
  
  -- Hash item changes
  if changes.items and next(changes.items) then
    for itemId, change in pairs(changes.items) do
      hash = hash + (itemId * 100000) + ((change.delta or 0) * 1000) + (change.new or 0)
    end
  end
  
  -- Hash equipment changes
  if changes.equipment and next(changes.equipment) then
    for slotId, change in pairs(changes.equipment) do
      hash = hash + (slotId * 10000000) + ((change.old or 0) * 10000) + (change.new or 0)
    end
  end
  
  -- Hash mismatch flag
  if changes.hashMismatch then
    hash = hash + 999999999
  end
  
  return hash % 2147483647
end

-- Serialize change table (wrapper for consistency)
local function SerializeChangeTable(changeTable)
  return SerializeData(changeTable)
end

-- Deserialize change table (wrapper for consistency)
local function DeserializeChangeTable(serializedData)
  local changeTable = DeserializeData(serializedData)
  if changeTable and type(changeTable) == "table" then
    return changeTable
  end
  
  return nil
end

-- Verify change table hash matches the actual change table data
-- Returns true if valid, false if tampered
local function VerifyChangeTableHash(changeTable, storedHash)
  if not changeTable or type(changeTable) ~= "table" or not storedHash then
    return false -- No change table or hash to verify
  end
  
  -- Calculate expected hash from current change table
  local expectedHash = HashChangeTable(changeTable)
  
  -- Compare stored hash with calculated hash
  return storedHash == expectedHash
end

-- Compare two states and return true if anything changed
-- Check if player state has changed since last snapshot
function PlayerStateSnapshot:HasPlayerStateChanged()
  local characterGUID = UnitGUID('player')
  
  if not characterGUID then
    return false
  end
  
  -- Ensure database is loaded
  if not UltraHardcoreDB then
    return false
  end
  
  if not UltraHardcoreDB.playerState then
    UltraHardcoreDB.playerState = {}
  end
  
  -- Get last known state
  local lastState = nil
  local lastSnapshot = nil
  if UltraHardcoreDB.playerState[characterGUID] then
    lastState = UltraHardcoreDB.playerState[characterGUID]
    
    -- Deserialize the stored snapshot
    lastSnapshot = GetDeserializedSnapshot(lastState)
    
    -- Only treat it as a valid previous state if it has a serialized snapshot and hash
    -- An empty state entry doesn't count as a previous state
    if not lastState.playerSnapshotSerialized or not lastState.playerSnapshotHash then
      return false -- No valid previous state (empty entry, first time)
    end
    
    -- Only verify hash if we have a valid deserialized snapshot to compare against
    -- If deserialization fails, don't treat it as tampering (might be corrupted data)
    if not lastSnapshot or type(lastSnapshot) ~= "table" then
      return false -- Can't verify without valid snapshot
    end
    
    -- Verify hash integrity - if hash doesn't match, data was tampered with
    local hashValid = VerifyStateHash(lastState)
    if not hashValid then
      -- Build change table for hash mismatch
      local currentState = {
        equippedItems = GetEquippedItems(),
        inventoryItems = GetInventoryItems(),
        bankItems = bankIsOpen and GetBankItems() or (lastSnapshot and lastSnapshot.bankItems),
        currency = GetCurrencyInfo(),
        levelInfo = GetLevelAndExperience(),
      }
      local changes = BuildChangeTable(lastSnapshot, currentState)
      changes.hashMismatch = true
      -- Serialize change table before storing (non-human-readable)
      local serialized = SerializeChangeTable(changes)
      if serialized then
        lastState.changeTableSerialized = serialized
        lastState.changeTableHash = HashChangeTable(changes)
        SaveDBData('playerState', UltraHardcoreDB.playerState)
      end
      return true -- Hash mismatch indicates tampering
    end
    -- Hash matches - data integrity is good, but we still need to check for state changes
    -- (changes could have happened while addon was off)
  end
  
  -- If no previous state exists, we can't compare
  if not lastState or not lastSnapshot or type(lastSnapshot) ~= "table" then
    return false -- No previous state to compare against
  end
  
  -- Build current state for comparison
  local currentState = {
    equippedItems = GetEquippedItems(),
    inventoryItems = GetInventoryItems(),
    bankItems = bankIsOpen and GetBankItems() or (lastSnapshot and lastSnapshot.bankItems),
    currency = GetCurrencyInfo(),
    levelInfo = GetLevelAndExperience(),
  }
  
  -- Check for changes using item counts if available (from deserialized snapshot)
  local storedItemCounts = lastSnapshot.itemCounts
  local hasChanges = false
  
  if storedItemCounts and next(storedItemCounts) then
    local observedIds = GatherObservedItemIds()
    
    for itemId in pairs(observedIds) do
      if itemId and storedItemCounts[itemId] == nil then
        hasChanges = true
        break
      end
    end
    
    if not hasChanges then
      -- Check item count changes
      local currentItemCounts = BuildItemCountMap(currentState.inventoryItems, currentState.bankItems)
      if currentState.equippedItems then
        for _, itemId in pairs(currentState.equippedItems) do
          if itemId then
            currentItemCounts[itemId] = (currentItemCounts[itemId] or 0) + 1
          end
        end
      end
      
      for itemId, newCount in pairs(currentItemCounts) do
        local oldCount = storedItemCounts[itemId] or 0
        if newCount ~= oldCount then
          hasChanges = true
          break
        end
      end
      
      -- Also check for items that were in stored but not in current
      for itemId, oldCount in pairs(storedItemCounts) do
        local newCount = currentItemCounts[itemId] or 0
        if newCount ~= oldCount then
          hasChanges = true
          break
        end
      end
    end
  else
    if CompareStates(lastSnapshot, currentState) then
      hasChanges = true
    end
  end
  
  -- Compare currency (from deserialized snapshot)
  local oldMoney = lastSnapshot.currency and lastSnapshot.currency.money or 0
  local newMoney = currentState.currency and currentState.currency.money or 0
  if oldMoney ~= newMoney then
    hasChanges = true
  end
  
  -- Compare XP/level (from deserialized snapshot)
  local oldLevel = lastSnapshot.levelInfo and lastSnapshot.levelInfo.level or 0
  local oldXP = lastSnapshot.levelInfo and lastSnapshot.levelInfo.currentXP or 0
  local newLevel = currentState.levelInfo and currentState.levelInfo.level or 0
  local newXP = currentState.levelInfo and currentState.levelInfo.currentXP or 0
  if oldLevel ~= newLevel or oldXP ~= newXP then
    hasChanges = true
  end
  
  -- If changes detected, build and store change table
  if hasChanges then
    local changes = BuildChangeTable(lastSnapshot, currentState)
    -- Serialize change table before storing (non-human-readable)
    local serialized = SerializeChangeTable(changes)
    if serialized then
      lastState.changeTableSerialized = serialized
      lastState.changeTableHash = HashChangeTable(changes)
      SaveDBData('playerState', UltraHardcoreDB.playerState)
    end
  end
  
  return hasChanges
end

-- Verify integrity of stored state (returns true if valid, false if tampered)
function PlayerStateSnapshot:VerifyStateIntegrity()
  local characterGUID = UnitGUID('player')
  
  if not characterGUID then
    return true -- Can't verify without GUID, but not tampered (no evidence)
  end
  
  local state = nil
  if UltraHardcoreDB.playerState and UltraHardcoreDB.playerState[characterGUID] then
    state = UltraHardcoreDB.playerState[characterGUID]
  end
  
  -- If no state exists, there's nothing to verify - this is normal for new databases
  -- Return true (not tampered) because there's no evidence of tampering
  if not state then
    return true -- No state to verify, but not tampered (normal for new database)
  end
  
  -- If state exists but has no serialized snapshot or hash, it's invalid
  if not state.playerSnapshotSerialized or not state.playerSnapshotHash then
    return false -- State exists but corrupted (no serialized snapshot or hash)
  end
  
  local hashValid = VerifyStateHash(state)
  
  -- If hash is invalid, build and store change table
  if not hashValid then
    local lastSnapshot = GetDeserializedSnapshot(state)
    
    -- Even if deserialization fails, we should create a change table to explain the issue
    if not lastSnapshot or type(lastSnapshot) ~= "table" then
      -- Create a minimal change table indicating deserialization failure
      local changes = {
        hashMismatch = true,
        deserializationFailed = true,
        xp = {},
        items = {},
        currency = {},
        equipment = {},
      }
      local serialized = SerializeChangeTable(changes)
      if serialized then
        state.changeTableSerialized = serialized
        state.changeTableHash = HashChangeTable(changes)
        SaveDBData('playerState', UltraHardcoreDB.playerState)
      end
      return false
    end
    
    local currentState = {
      equippedItems = GetEquippedItems(),
      inventoryItems = GetInventoryItems(),
      bankItems = bankIsOpen and GetBankItems() or (lastSnapshot and lastSnapshot.bankItems),
      currency = GetCurrencyInfo(),
      levelInfo = GetLevelAndExperience(),
    }
    local changes = BuildChangeTable(lastSnapshot, currentState)
    changes.hashMismatch = true
    -- Serialize change table before storing (non-human-readable)
    local serialized = SerializeChangeTable(changes)
    if serialized then
      state.changeTableSerialized = serialized
      state.changeTableHash = HashChangeTable(changes)
      SaveDBData('playerState', UltraHardcoreDB.playerState)
    end
  end
  
  -- Also verify change table hash if it exists
  if state.changeTableSerialized and state.changeTableHash then
    local changeTable = DeserializeChangeTable(state.changeTableSerialized)
    if not changeTable then
      -- Deserialization failed - data corrupted
      PlayerStateSnapshot:SetTampered(true)
      return false
    end
    
    if not VerifyChangeTableHash(changeTable, state.changeTableHash) then
      -- Change table was tampered with - set tamper flag
      PlayerStateSnapshot:SetTampered(true)
      return false -- State is invalid due to tampered change table
    end
  end
  
  return hashValid
end

-- Get last captured state for current player (returns deserialized snapshot)
function PlayerStateSnapshot:GetLastState()
  local characterGUID = UnitGUID('player')
  
  if not characterGUID then
    return nil
  end
  
  if UltraHardcoreDB.playerState and UltraHardcoreDB.playerState[characterGUID] then
    local state = UltraHardcoreDB.playerState[characterGUID]
    -- Return deserialized snapshot
    return GetDeserializedSnapshot(state)
  end
  
  return nil
end

-- Get the change table for the current player (what changed when tampering was detected)
-- Automatically verifies hash integrity - if tampered, returns nil and sets tamper flag
-- Deserializes the change table from stored serialized data
function PlayerStateSnapshot:GetChangeTable()
  local characterGUID = UnitGUID('player')
  
  if not characterGUID then
    return nil
  end
  
  if UltraHardcoreDB.playerState and UltraHardcoreDB.playerState[characterGUID] then
    local state = UltraHardcoreDB.playerState[characterGUID]
    
    -- Check for serialized change table (new format)
    if state.changeTableSerialized and state.changeTableHash then
      -- Deserialize the change table
      local changeTable = DeserializeChangeTable(state.changeTableSerialized)
      if not changeTable or type(changeTable) ~= "table" then
        -- Deserialization failed - data corrupted
        -- Create a fallback change table so user can see something
        changeTable = {
          hashMismatch = true,
          deserializationFailed = true,
          xp = {},
          items = {},
          currency = {},
          equipment = {},
        }
        -- Don't set tamper flag again (already set)
        return changeTable, state.changeTableHash
      end
      
      -- Verify hash integrity - if hash doesn't match, change table was tampered with
      local hashValid = VerifyChangeTableHash(changeTable, state.changeTableHash)
      if not hashValid then
        -- Hash mismatch indicates tampering - set tamper flag
        -- Return the table anyway so user can see what was detected
        -- Don't set tamper flag again (already set)
        return changeTable, state.changeTableHash
      end
      
      -- Hash is valid, return the deserialized change table
      return changeTable, state.changeTableHash
    end
  end
  
  return nil
end

-- Format change table into an ordered list of readable strings
-- Returns an array of formatted change messages in order: XP, Currency, Items, Equipment, Hash Mismatch
function PlayerStateSnapshot:FormatChangeTable(changeTable)
  if not changeTable or type(changeTable) ~= "table" then
    return {}
  end
  
  local changes = {}
  
  -- Check for hash mismatch first (highest priority indicator)
  if changeTable.hashMismatch then
    if changeTable.deserializationFailed then
      table.insert(changes, 'State data corruption detected (deserialization failed)')
    else
      table.insert(changes, 'State hash mismatch detected (possible tampering)')
    end
  end
  
  -- 1. XP Changes (highest priority)
  if changeTable.xp and next(changeTable.xp) then
    if changeTable.xp.level and changeTable.xp.level.old ~= changeTable.xp.level.new then
      table.insert(changes, string.format(
        'Level changed from %d to %d',
        changeTable.xp.level.old,
        changeTable.xp.level.new
      ))
    end
    
    if changeTable.xp.xpGained and changeTable.xp.xpGained > 0 then
      -- Format XP gained nicely
      local xpGained = changeTable.xp.xpGained
      if xpGained >= 1000000 then
        -- Level up + XP
        local levels = math.floor(xpGained / 1000000)
        local xp = xpGained % 1000000
        if levels > 0 and xp > 0 then
          table.insert(changes, string.format(
            '%d level(s) gained and %s XP gained',
            levels,
            formatNumberWithCommas and formatNumberWithCommas(xp) or tostring(xp)
          ))
        elseif levels > 0 then
          table.insert(changes, string.format('%d level(s) gained', levels))
        else
          table.insert(changes, string.format(
            '%s XP gained',
            formatNumberWithCommas and formatNumberWithCommas(xpGained) or tostring(xpGained)
          ))
        end
      else
        table.insert(changes, string.format(
          '%s XP gained',
          formatNumberWithCommas and formatNumberWithCommas(xpGained) or tostring(xpGained)
        ))
      end
    elseif changeTable.xp.currentXP then
      local xpDelta = changeTable.xp.currentXP.new - changeTable.xp.currentXP.old
      if xpDelta ~= 0 then
        table.insert(changes, string.format(
          'XP changed from %s to %s',
          formatNumberWithCommas and formatNumberWithCommas(changeTable.xp.currentXP.old) or tostring(changeTable.xp.currentXP.old),
          formatNumberWithCommas and formatNumberWithCommas(changeTable.xp.currentXP.new) or tostring(changeTable.xp.currentXP.new)
        ))
      end
    end
  end
  
  -- 2. Currency Changes
  if changeTable.currency and changeTable.currency.money then
    local money = changeTable.currency.money
    if money.delta > 0 then
      table.insert(changes, string.format(
        'Currency increased from %s to %s (+%s)',
        formatNumberWithCommas and formatNumberWithCommas(money.old) or tostring(money.old),
        formatNumberWithCommas and formatNumberWithCommas(money.new) or tostring(money.new),
        formatNumberWithCommas and formatNumberWithCommas(money.delta) or tostring(money.delta)
      ))
    elseif money.delta < 0 then
      table.insert(changes, string.format(
        'Currency decreased from %s to %s (%s)',
        formatNumberWithCommas and formatNumberWithCommas(money.old) or tostring(money.old),
        formatNumberWithCommas and formatNumberWithCommas(money.new) or tostring(money.new),
        formatNumberWithCommas and formatNumberWithCommas(math.abs(money.delta)) or tostring(math.abs(money.delta))
      ))
    else
      table.insert(changes, string.format(
        'Currency changed from %s to %s',
        formatNumberWithCommas and formatNumberWithCommas(money.old) or tostring(money.old),
        formatNumberWithCommas and formatNumberWithCommas(money.new) or tostring(money.new)
      ))
    end
  end
  
  -- 3. Item Changes
  if changeTable.items and next(changeTable.items) then
    local itemChanges = {}
    for itemId, change in pairs(changeTable.items) do
      local itemName = GetItemInfo and GetItemInfo(itemId)
      local itemDisplay = itemName or ('Item ' .. tostring(itemId))
      
      if change.delta > 0 then
        table.insert(itemChanges, {
          itemId = itemId,
          msg = string.format(
            '%s added (count: %d → %d, +%d)',
            itemDisplay,
            change.old,
            change.new,
            change.delta
          )
        })
      elseif change.delta < 0 then
        table.insert(itemChanges, {
          itemId = itemId,
          msg = string.format(
            '%s removed (count: %d → %d, %d)',
            itemDisplay,
            change.old,
            change.new,
            change.delta
          )
        })
      else
        table.insert(itemChanges, {
          itemId = itemId,
          msg = string.format(
            '%s changed (count: %d → %d)',
            itemDisplay,
            change.old,
            change.new
          )
        })
      end
    end
    
    -- Sort item changes by item ID for consistent ordering
    table.sort(itemChanges, function(a, b) return a.itemId < b.itemId end)
    for _, itemChange in ipairs(itemChanges) do
      table.insert(changes, itemChange.msg)
    end
  end
  
  -- 4. Equipment Changes
  if changeTable.equipment and next(changeTable.equipment) then
    local EQUIPMENT_SLOT_NAMES = {
      [0] = 'Ammo',
      [1] = 'Head',
      [2] = 'Neck',
      [3] = 'Shoulder',
      [4] = 'Shirt',
      [5] = 'Chest',
      [6] = 'Waist',
      [7] = 'Legs',
      [8] = 'Feet',
      [9] = 'Wrist',
      [10] = 'Hands',
      [11] = 'Finger 1',
      [12] = 'Finger 2',
      [13] = 'Trinket 1',
      [14] = 'Trinket 2',
      [15] = 'Back',
      [16] = 'Main Hand',
      [17] = 'Off Hand',
      [18] = 'Ranged',
      [19] = 'Tabard',
    }
    
    -- Sort equipment changes by slot ID for consistent ordering
    local sortedSlots = {}
    for slotId in pairs(changeTable.equipment) do
      table.insert(sortedSlots, slotId)
    end
    table.sort(sortedSlots)
    
    for _, slotId in ipairs(sortedSlots) do
      local change = changeTable.equipment[slotId]
      local slotName = EQUIPMENT_SLOT_NAMES[slotId] or ('Slot ' .. tostring(slotId))
      local oldItemName = GetItemInfo and GetItemInfo(change.old)
      local newItemName = GetItemInfo and GetItemInfo(change.new)
      
      local oldDisplay = oldItemName or ('Item ' .. tostring(change.old))
      local newDisplay = newItemName or ('Item ' .. tostring(change.new))
      
      if change.old == nil then
        table.insert(changes, string.format(
          '%s slot: %s equipped',
          slotName,
          newDisplay
        ))
      elseif change.new == nil then
        table.insert(changes, string.format(
          '%s slot: %s unequipped',
          slotName,
          oldDisplay
        ))
      else
        table.insert(changes, string.format(
          '%s slot: %s → %s',
          slotName,
          oldDisplay,
          newDisplay
        ))
      end
    end
  end
  
  -- Hash Mismatch is already added at the beginning for priority
  
  return changes
end

-- Generate tamper flag hash (prevents players from editing the database)
-- Uses player GUID + tamper status + passkey to create a unique hash
local function GenerateTamperFlagHash(characterGUID, isTampered)
  local passkey = "UHCTMPKEY" -- Secret passkey (not easily guessable)
  local status = isTampered and "1" or "0"
  local data = characterGUID .. status .. passkey
  
  -- Simple hash function
  local hash = 0
  for i = 1, #data do
    hash = ((hash * 31) + string.byte(data, i)) % 2147483647
  end
  
  return hash
end

-- Verify tamper flag hash matches expected value
local function VerifyTamperFlagHash(characterGUID, storedHash, isTampered)
  if not characterGUID or not storedHash then
    return false
  end
  
  local expectedHash = GenerateTamperFlagHash(characterGUID, isTampered)
  return storedHash == expectedHash
end

-- Check if player has been flagged for tampering (persistent hashed flag)
-- Returns true if tampered, false if clean
function PlayerStateSnapshot:IsTampered()
  local characterGUID = UnitGUID('player')
  
  if not characterGUID then
    return false
  end
  
  if not UltraHardcoreDB or not UltraHardcoreDB.playerState or not UltraHardcoreDB.playerState[characterGUID] then
    return false
  end
  
  local state = UltraHardcoreDB.playerState[characterGUID]
  
  -- If no tamper hash exists, assume clean
  if not state.playerHash then
    return false
  end
  
  -- Check hash first - this is the source of truth
  -- Verify hash matches expected value for tampered=true
  local isValidTampered = false
  local success, result = pcall(function()
    return VerifyTamperFlagHash(characterGUID, state.playerHash, true)
  end)
  if success then
    isValidTampered = result
  else
    isValidTampered = false
  end
  
  if isValidTampered then
    -- Hash matches tampered state - player is tampered
    return true
  end
  
  -- Hash doesn't match tampered=true, so player is NOT tampered
  -- Clear any invalid timestamp (from old bug or corruption)
  local needsSave = false
  if state.playerTimestamp then
    state.playerTimestamp = nil
    needsSave = true
  end
  
  -- Verify hash matches expected value for tampered=false
  local isValidClean = false
  success, result = pcall(function()
    return VerifyTamperFlagHash(characterGUID, state.playerHash, false)
  end)
  if success then
    isValidClean = result
  else
    isValidClean = false
  end
  
  -- If hash doesn't match clean state, update it to match clean state
  if not isValidClean then
    -- Hash is corrupted or invalid - update it to match clean state
    local cleanHash = GenerateTamperFlagHash(characterGUID, false)
    state.playerHash = cleanHash
    needsSave = true
  end
  
  -- Save if we made any changes
  if needsSave then
    SaveDBData('playerState', UltraHardcoreDB.playerState)
  end
  
  -- Player is clean
  return false
end

-- Set tamper flag (creates hashed value that's hard to fake)
function PlayerStateSnapshot:SetTampered(isTampered)
  local characterGUID = UnitGUID('player')
  
  if not characterGUID then
    return false
  end
  
  if not UltraHardcoreDB.playerState then
    UltraHardcoreDB.playerState = {}
  end
  
  if not UltraHardcoreDB.playerState[characterGUID] then
    UltraHardcoreDB.playerState[characterGUID] = {}
  end
  
  -- Generate and store hashed tamper flag
  local tamperHash = GenerateTamperFlagHash(characterGUID, isTampered)
  UltraHardcoreDB.playerState[characterGUID].playerHash = tamperHash
  
  -- If setting tampered=true, store timestamp (one-way flag)
  -- This prevents clearing by editing hash to "false" value
  if isTampered then
    UltraHardcoreDB.playerState[characterGUID].playerTimestamp = time()
  else
    -- Only clear timestamp if explicitly clearing via function (appeals)
    UltraHardcoreDB.playerState[characterGUID].playerTimestamp = nil
  end
  
  SaveDBData('playerState', UltraHardcoreDB.playerState)
  return true
end

-- Clear tamper flag (for appeals/manual override)
function PlayerStateSnapshot:ClearTamperFlag()
  return self:SetTampered(false)
end

-- Helper function for login: Check for changes and set persistent hashed tamper flag
-- Returns true if changes were detected, false otherwise
function PlayerStateSnapshot:OnLogin()
  local characterGUID = UnitGUID('player')
  
  if not characterGUID then
    return false
  end
  
  -- Initialize player state database if it doesn't exist
  if not UltraHardcoreDB then
    return false
  end
  
  if not UltraHardcoreDB.playerState then
    UltraHardcoreDB.playerState = {}
  end
  
  if not UltraHardcoreDB.playerState[characterGUID] then
    UltraHardcoreDB.playerState[characterGUID] = {}
  end
  
  -- Check if we have a valid previous state before checking for changes
  -- Don't check for changes on first login (when there's no previous state)
  local previousStateExists = UltraHardcoreDB.playerState[characterGUID] and 
                              UltraHardcoreDB.playerState[characterGUID].playerSnapshotSerialized ~= nil and
                              UltraHardcoreDB.playerState[characterGUID].playerSnapshotHash ~= nil
  
  local hasChanged = false
  if previousStateExists then
    hasChanged = self:HasPlayerStateChanged()
    
    -- If tampering detected, set persistent hashed flag (one-way, never clears)
    if hasChanged then
      self:SetTampered(true)
    end
    
    -- Also check hash integrity and set flag if invalid (one-way, never clears)
    local isValid = self:VerifyStateIntegrity()
    if not isValid then
      self:SetTampered(true)
      hasChanged = true
    end
  end
  -- If no previous state exists, this is the first login - don't check for changes
  
  return hasChanged
end

-- Helper function for logout: Capture final state before logout
function PlayerStateSnapshot:OnLogout()
  self:CapturePlayerState()
end

-- Event frame for automatic state capture
local eventFrame = CreateFrame('Frame')

local function CaptureOnEvent()
  if not UnitGUID('player') then
    return
  end
  
  PlayerStateSnapshot:CapturePlayerState()
end

-- Event handler
local function OnStateChangeEvent(self, event, ...)
  if event == 'BANKFRAME_OPENED' then
    bankIsOpen = true
    CaptureOnEvent()
    return
  elseif event == 'BANKFRAME_CLOSED' then
    bankIsOpen = false
    return
  elseif event == 'PLAYERBANKSLOTS_CHANGED' or event == 'PLAYERBANKBAGSLOTS_CHANGED' then
    bankIsOpen = true
  elseif event == 'PLAYER_ENTERING_WORLD' then
    if not UltraHardcoreDB then
      UltraHardcoreDB = {}
    end
  end
  
  CaptureOnEvent()
end

-- Register events for state changes
eventFrame:RegisterEvent('BAG_UPDATE') -- Triggered when bag contents change
eventFrame:RegisterEvent('BAG_UPDATE_DELAYED')
eventFrame:RegisterEvent('BANKFRAME_OPENED') -- Triggered when bank is opened
eventFrame:RegisterEvent('BANKFRAME_CLOSED')
eventFrame:RegisterEvent('PLAYERBANKSLOTS_CHANGED')
eventFrame:RegisterEvent('PLAYERBANKBAGSLOTS_CHANGED')
eventFrame:RegisterEvent('PLAYER_MONEY') -- Triggered when money changes
eventFrame:RegisterEvent('PLAYER_XP_UPDATE') -- Triggered when XP changes
eventFrame:RegisterEvent('PLAYER_LEVEL_UP') -- Triggered when player levels up
eventFrame:RegisterEvent('PLAYER_EQUIPMENT_CHANGED')
eventFrame:RegisterEvent('ZONE_CHANGED')
eventFrame:RegisterEvent('ZONE_CHANGED_INDOORS')
eventFrame:RegisterEvent('ZONE_CHANGED_NEW_AREA')
eventFrame:RegisterEvent('PLAYER_ENTERING_WORLD')

-- Set event handler
eventFrame:SetScript('OnEvent', function(self, event, ...)
  OnStateChangeEvent(self, event, ...)
end)

-- Helper function to initialize player state (checks for changes and captures state)
local function InitializePlayerState()
  -- Wait for player GUID to be available
  if not UnitGUID('player') then
    return false
  end
  
  local characterGUID = UnitGUID('player')
  
  -- Ensure database is loaded (SavedVariables should be loaded by now, but double-check)
  if not UltraHardcoreDB then
    return false -- Database not loaded yet
  end
  
  -- Initialize player state database if it doesn't exist
  if not UltraHardcoreDB.playerState then
    UltraHardcoreDB.playerState = {}
  end
  
  -- Wait for bags to be loaded before capturing state
  -- Check if at least one bag has slots (indicating bags are loaded)
  local bagsReady = false
  for bagId = 0, 4 do
    local numSlots = C_Container.GetContainerNumSlots(bagId)
    if numSlots and numSlots >= 0 then -- Even 0 slots means the bag is "loaded"
      bagsReady = true
      break
    end
  end
  
  if not bagsReady then
    return false -- Bags not ready yet
  end
  
  -- Add a delay to ensure all data is fully loaded and database is ready
  -- This is especially important when re-enabling the addon
  C_Timer.After(1.0, function()
    if not UnitGUID('player') then
      return
    end
    
    -- Double-check database is loaded
    if not UltraHardcoreDB then
      return
    end
    
    if not UltraHardcoreDB.playerState then
      UltraHardcoreDB.playerState = {}
    end
    
    -- Check for changes FIRST (for addon re-enable detection)
    -- This compares the old state (from SavedVariables) to the current state
    PlayerStateSnapshot:OnLogin()
    
    -- Then capture current state after checking for changes
    -- This updates the saved state with the current state
    PlayerStateSnapshot:CapturePlayerState()
  end)
  
  return true
end

-- Initialize event frame after player is in world
local initFrame = CreateFrame('Frame')
local hasInitialized = false
local initializationScheduled = false
local addonLoaded = false

initFrame:RegisterEvent('PLAYER_ENTERING_WORLD')
initFrame:RegisterEvent('BAG_UPDATE')
initFrame:RegisterEvent('ADDON_LOADED')

initFrame:SetScript('OnEvent', function(self, event, addonName)
  -- Track when addon is loaded
  if event == 'ADDON_LOADED' and addonName == 'UltraHardcore' then
    addonLoaded = true
    -- Ensure database exists
    if not UltraHardcoreDB then
      UltraHardcoreDB = {}
    end
    if not UltraHardcoreDB.playerState then
      UltraHardcoreDB.playerState = {}
    end
  end
  
  -- Only handle ADDON_LOADED for this addon
  if event == 'ADDON_LOADED' and addonName ~= 'UltraHardcore' then
    return
  end
  
  -- Only initialize once per session
  if hasInitialized then
    return
  end
  
  if initializationScheduled then
    return
  end
  
  -- Wait for addon to be loaded before trying to initialize
  if event == 'ADDON_LOADED' and not addonLoaded then
    return
  end
  
  -- Try to initialize
  if InitializePlayerState() then
    initializationScheduled = true
    -- Mark as initialized after the delay completes
    C_Timer.After(2.0, function()
      hasInitialized = true
    end)
  end
end)

-- Login event frame
local loginLogoutFrame = CreateFrame('Frame')
loginLogoutFrame:RegisterEvent('PLAYER_LOGIN')
loginLogoutFrame:SetScript('OnEvent', function(self, event)
  if event == 'PLAYER_LOGIN' then
    -- Check for changes on login (tampering detection)
    PlayerStateSnapshot:OnLogin()
    -- Capture a fresh snapshot immediately after login baseline
    PlayerStateSnapshot:CapturePlayerState()
  end
end)

-- Export the PlayerStateSnapshot object (optional - for manual access if needed)
-- eg. /dump PlayerStateSnapshot:VerifyStateIntegrity()
_G.PlayerStateSnapshot = PlayerStateSnapshot
