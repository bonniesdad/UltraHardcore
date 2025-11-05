-- Player State Snapshot
-- Captures and stores player information to detect cheating by turning addon off/on

local PlayerStateSnapshot = {}

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
    else
      equippedItems[slotId] = nil
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
        else
          bagSlots[slotId] = nil
        end
      end
    end
    
    if next(bagSlots) then -- Only store if bag has items
      inventoryItems[bagId] = bagSlots
    else
      inventoryItems[bagId] = nil
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
    else
      mainBankSlots[slotId] = nil
    end
  end
  
  if next(mainBankSlots) then
    bankItems[-1] = mainBankSlots
  else
    bankItems[-1] = nil
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
        else
          bagSlots[slotId] = nil
        end
      end
    end
    
    if next(bagSlots) then
      bankItems[bagId] = bagSlots
    else
      bankItems[bagId] = nil
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

-- Verify hash matches state data
-- Returns true if valid, false if tampered
local function VerifyStateHash(state)
  if not state or not state.hash then
    return false -- No state or no hash
  end
  
  -- Calculate expected hash from current state data
  local expectedHash = GenerateStateHash(state)
  
  -- Compare stored hash with calculated hash
  return state.hash == expectedHash
end

-- Capture complete player state snapshot
function PlayerStateSnapshot:CapturePlayerState()
  local characterGUID = UnitGUID('player')
  
  if not characterGUID then
    return nil -- Player GUID not available yet
  end
  
  -- Initialize player state database if it doesn't exist
  if not UltraHardcoreDB.playerState then
    UltraHardcoreDB.playerState = {}
  end
  
  -- Preserve existing tamper flags (don't overwrite them)
  local existingState = UltraHardcoreDB.playerState[characterGUID] or {}
  local existingTamperHash = existingState.tamperHash
  local existingTamperTimestamp = existingState.tamperTimestamp
  
  -- Capture all state information
  local state = {
    timestamp = time(),
    equippedItems = GetEquippedItems(),
    inventoryItems = GetInventoryItems(),
    bankItems = GetBankItems(),
    currency = GetCurrencyInfo(),
    levelInfo = GetLevelAndExperience(),
    location = GetPlayerLocation(),
  }
  
  -- Generate and store hash for integrity checking
  state.hash = GenerateStateHash(state)
  
  -- Preserve tamper flags (don't overwrite persistent tamper detection)
  if existingTamperHash then
    state.tamperHash = existingTamperHash
  end
  if existingTamperTimestamp then
    state.tamperTimestamp = existingTamperTimestamp
  end
  
  -- Store the state
  UltraHardcoreDB.playerState[characterGUID] = state
  
  -- Save to database
  SaveDBData('playerState', UltraHardcoreDB.playerState)
  
  return state
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

-- Compare two states and return true if anything changed
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
  -- Build item count maps from both bags and bank combined
  local oldItemCounts = BuildItemCountMap(oldState.inventoryItems, oldState.bankItems)
  local newItemCounts = BuildItemCountMap(newState.inventoryItems, newState.bankItems)
  
  -- Get all unique item IDs
  local allItemIds = {}
  for itemId in pairs(oldItemCounts) do
    allItemIds[itemId] = true
  end
  for itemId in pairs(newItemCounts) do
    allItemIds[itemId] = true
  end
  
  -- Compare counts
  for itemId in pairs(allItemIds) do
    local oldCount = oldItemCounts[itemId] or 0
    local newCount = newItemCounts[itemId] or 0
    if oldCount ~= newCount then
      return true -- Item count changed (item added or removed)
    end
  end
  
  -- Compare currency
  local oldMoney = oldState.currency and oldState.currency.money or 0
  local newMoney = newState.currency and newState.currency.money or 0
  if oldMoney ~= newMoney then
    return true -- Money changed
  end
  
  -- Compare level (shouldn't change during a session, but good to check)
  local oldLevel = oldState.levelInfo and oldState.levelInfo.level or 0
  local newLevel = newState.levelInfo and newState.levelInfo.level or 0
  if oldLevel ~= newLevel then
    return true -- Level changed
  end
  
  return false -- No changes detected
end

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
  if UltraHardcoreDB.playerState[characterGUID] then
    lastState = UltraHardcoreDB.playerState[characterGUID]
    
    -- Only treat it as a valid previous state if it has a hash (meaning it was captured before)
    -- An empty state entry doesn't count as a previous state
    if not lastState.hash then
      return false -- No valid previous state (empty entry, first time)
    end
    
    -- Verify hash integrity - if hash doesn't match, data was tampered with
    if not VerifyStateHash(lastState) then
      return true -- Hash mismatch indicates tampering
    end
  end
  
  -- If no previous state exists, we can't compare
  if not lastState then
    return false -- No previous state to compare against
  end
  
  -- Get current state
  local currentState = {
    equippedItems = GetEquippedItems(),
    inventoryItems = GetInventoryItems(),
    bankItems = GetBankItems(),
    currency = GetCurrencyInfo(),
    levelInfo = GetLevelAndExperience(),
    location = GetPlayerLocation(),
  }
  
  -- Compare states
  return CompareStates(lastState, currentState)
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
  
  -- If state exists but has no hash, it's invalid (shouldn't happen normally)
  if not state.hash then
    return false -- State exists but corrupted (no hash)
  end
  
  local hashValid = VerifyStateHash(state)
  return hashValid
end

-- Get last captured state for current player
function PlayerStateSnapshot:GetLastState()
  local characterGUID = UnitGUID('player')
  
  if not characterGUID then
    return nil
  end
  
  if UltraHardcoreDB.playerState and UltraHardcoreDB.playerState[characterGUID] then
    return UltraHardcoreDB.playerState[characterGUID]
  end
  
  return nil
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
  if not state.tamperHash then
    return false
  end
  
  -- Check hash first - this is the source of truth
  -- Verify hash matches expected value for tampered=true
  local isValidTampered = false
  local success, result = pcall(function()
    return VerifyTamperFlagHash(characterGUID, state.tamperHash, true)
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
  if state.tamperTimestamp then
    state.tamperTimestamp = nil
    needsSave = true
  end
  
  -- Verify hash matches expected value for tampered=false
  local isValidClean = false
  success, result = pcall(function()
    return VerifyTamperFlagHash(characterGUID, state.tamperHash, false)
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
    state.tamperHash = cleanHash
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
  UltraHardcoreDB.playerState[characterGUID].tamperHash = tamperHash
  
  -- If setting tampered=true, store timestamp (one-way flag)
  -- This prevents clearing by editing hash to "false" value
  if isTampered then
    UltraHardcoreDB.playerState[characterGUID].tamperTimestamp = time()
  else
    -- Only clear timestamp if explicitly clearing via function (appeals)
    UltraHardcoreDB.playerState[characterGUID].tamperTimestamp = nil
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
  
  local hasChanged = self:HasPlayerStateChanged()
  
  -- If tampering detected, set persistent hashed flag (one-way, never clears)
  if hasChanged then
    self:SetTampered(true)
  end
  
  -- Also check hash integrity and set flag if invalid (one-way, never clears)
  -- Only check if we have a previous state - if no state exists, there's nothing to verify
  local previousStateExists = UltraHardcoreDB.playerState[characterGUID] and UltraHardcoreDB.playerState[characterGUID].hash ~= nil
  if previousStateExists then
    local isValid = self:VerifyStateIntegrity()
    if not isValid then
      self:SetTampered(true)
      hasChanged = true
    end
  end
  
  return hasChanged
end

-- Helper function for logout: Capture final state before logout
function PlayerStateSnapshot:OnLogout()
  self:CapturePlayerState()
end

-- Event frame for automatic state capture
local eventFrame = CreateFrame('Frame')
local lastCaptureTime = 0
local CAPTURE_THROTTLE = 2.0 -- Minimum seconds between captures (prevents spam)

-- Throttled capture function
local function ThrottledCapture()
  local currentTime = GetTime()
  if currentTime - lastCaptureTime >= CAPTURE_THROTTLE then
    PlayerStateSnapshot:CapturePlayerState()
    lastCaptureTime = currentTime
  end
end

-- Event handler
local function OnStateChangeEvent(self, event, ...)
  -- Only capture if player GUID is available
  if not UnitGUID('player') then
    return
  end
  
  ThrottledCapture()
end

-- Register events for state changes
eventFrame:RegisterEvent('BAG_UPDATE') -- Triggered when bag contents change
eventFrame:RegisterEvent('BANKFRAME_OPENED') -- Triggered when bank is opened
eventFrame:RegisterEvent('PLAYER_MONEY') -- Triggered when money changes
eventFrame:RegisterEvent('PLAYER_XP_UPDATE') -- Triggered when XP changes
eventFrame:RegisterEvent('PLAYER_LEVEL_UP') -- Triggered when player levels up
eventFrame:RegisterEvent('PLAYER_EQUIPMENT_CHANGED')

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

-- Login/Logout event frame
local loginLogoutFrame = CreateFrame('Frame')
loginLogoutFrame:RegisterEvent('PLAYER_LOGIN')
loginLogoutFrame:RegisterEvent('PLAYER_LOGOUT')
loginLogoutFrame:SetScript('OnEvent', function(self, event)
  if event == 'PLAYER_LOGIN' then
    -- Check for changes on login (tampering detection)
    PlayerStateSnapshot:OnLogin()
  elseif event == 'PLAYER_LOGOUT' then
    -- Capture final state before logout
    PlayerStateSnapshot:OnLogout()
  end
end)

-- Export the PlayerStateSnapshot object (optional - for manual access if needed)
-- eg. /dump PlayerStateSnapshot:VerifyStateIntegrity()
_G.PlayerStateSnapshot = PlayerStateSnapshot
