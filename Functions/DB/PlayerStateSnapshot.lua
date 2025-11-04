-- Player State Snapshot
-- Captures and stores player information to detect cheating by turning addon off/on
--
-- Usage:
--   On LOGOUT Call PlayerStateSnapshot:OnLogout() to save final state
--   On LOGIN Call PlayerStateSnapshot:OnLogin() to check for changes
--     - Returns true if changes were detected (possible cheating)
--     - Returns false if no changes detected

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
    local numSlots = GetContainerNumSlots(bagId)
    
    if numSlots and numSlots > 0 then
      for slotId = 1, numSlots do
        local itemId = GetContainerItemID(bagId, slotId)
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
    maxXP = UnitXPMax('player'),
    restedXP = GetXPExhaustion() or 0,
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
  
  -- Capture all state information
  local state = {
    timestamp = time(),
    equippedItems = GetEquippedItems(),
    inventoryItems = GetInventoryItems(),
    currency = GetCurrencyInfo(),
    levelInfo = GetLevelAndExperience(),
    location = GetPlayerLocation(),
  }
  
  -- Store the state
  UltraHardcoreDB.playerState[characterGUID] = state
  
  -- Save to database
  SaveDBData('playerState', UltraHardcoreDB.playerState)
  
  return state
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
  
  -- Compare inventory items
  -- Check all possible bags (0-4)
  for bagId = 0, 4 do
    local oldBagSlots = oldState.inventoryItems and oldState.inventoryItems[bagId] or nil
    local newBagSlots = newState.inventoryItems and newState.inventoryItems[bagId] or nil
    
    -- If one exists but not the other, they're different
    if (oldBagSlots and not newBagSlots) or (not oldBagSlots and newBagSlots) then
      return true
    end
    
    -- If both exist, compare all slots
    if oldBagSlots and newBagSlots then
      -- Get all slot IDs from both bags
      local allSlotIds = {}
      for slotId in pairs(oldBagSlots) do
        allSlotIds[slotId] = true
      end
      for slotId in pairs(newBagSlots) do
        allSlotIds[slotId] = true
      end
      
      -- Compare each slot
      for slotId in pairs(allSlotIds) do
        local oldItemId = oldBagSlots[slotId]
        local newItemId = newBagSlots[slotId]
        if oldItemId ~= newItemId then
          return true -- Inventory item changed
        end
      end
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
  
  -- Get last known state
  local lastState = nil
  if UltraHardcoreDB.playerState and UltraHardcoreDB.playerState[characterGUID] then
    lastState = UltraHardcoreDB.playerState[characterGUID]
  end
  
  -- Get current state
  local currentState = {
    equippedItems = GetEquippedItems(),
    inventoryItems = GetInventoryItems(),
    currency = GetCurrencyInfo(),
    levelInfo = GetLevelAndExperience(),
    location = GetPlayerLocation(),
  }
  
  -- Compare states
  return CompareStates(lastState, currentState)
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

-- Helper function for login: Check for changes
-- Returns true if changes were detected, false otherwise
function PlayerStateSnapshot:OnLogin()
  local hasChanged = self:HasPlayerStateChanged()
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
eventFrame:RegisterEvent('PLAYER_MONEY') -- Triggered when money changes
eventFrame:RegisterEvent('PLAYER_XP_UPDATE') -- Triggered when XP changes
eventFrame:RegisterEvent('PLAYER_LEVEL_UP') -- Triggered when player levels up
eventFrame:RegisterEvent('PLAYER_EQUIPMENT_CHANGED')

-- Set event handler
eventFrame:SetScript('OnEvent', function(self, event, ...)
  OnStateChangeEvent(self, event, ...)
end)

-- Initialize event frame after player is in world
local initFrame = CreateFrame('Frame')
initFrame:RegisterEvent('PLAYER_ENTERING_WORLD')
initFrame:SetScript('OnEvent', function(self, event)
  -- Initial capture when entering world
  if UnitGUID('player') then
    PlayerStateSnapshot:CapturePlayerState()
  end
  self:UnregisterEvent('PLAYER_ENTERING_WORLD')
end)

-- Export the PlayerStateSnapshot object
_G.PlayerStateSnapshot = PlayerStateSnapshot
