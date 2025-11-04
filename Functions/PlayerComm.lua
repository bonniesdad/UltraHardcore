-- Player Communication Handler
-- Handles player-to-player communication for addon features
-- Uses AceComm and AceSerializer for secure communication
-- Can be extended for various communication needs

local AceComm = LibStub("AceComm-3.0")
local AceSerializer = LibStub("AceSerializer-3.0")

local PlayerComm = {}

-- Communication prefix (max 16 characters)
local COMM_PREFIX = "UHC"

-- Storage for player tamper status (cache)
local playerTamperStatus = {}

-- Request timeout (seconds)
local REQUEST_TIMEOUT = 1.0

-- Pending requests (requestId -> {callback, timestamp, playerName, messageType})
local pendingRequests = {}

-- Generate unique request ID
local function GenerateRequestId()
  return time() .. "_" .. math.random(1000, 9999)
end

-- Clean up expired requests
local function CleanupExpiredRequests()
  local currentTime = GetTime()
  for requestId, request in pairs(pendingRequests) do
    if currentTime - request.timestamp > REQUEST_TIMEOUT then
      pendingRequests[requestId] = nil
    end
  end
end

-- Request tamper status from another player
-- playerName: Name of player to check
-- callback: Function to call with result (isTampered, playerName, success)
--   isTampered: true if tampered, false if clean
--   playerName: Name of player checked
--   success: true if got response, false if timeout/failed
function PlayerComm:RequestTamperStatus(playerName, callback)
  if not playerName or not callback then
    return false
  end
  
  -- Clean up expired requests
  CleanupExpiredRequests()
  
  -- Generate unique request ID (ensure uniqueness)
  local requestId = GenerateRequestId()
  local attempts = 0
  while pendingRequests[requestId] and attempts < 10 do
    requestId = GenerateRequestId()
    attempts = attempts + 1
  end
  
  -- Store request info
  local requestStartTime = GetTime()
  pendingRequests[requestId] = {
    callback = callback,
    timestamp = requestStartTime,
    playerName = playerName,
    messageType = "TAMPER_STATUS",
    requestId = requestId,
  }
  
  -- Create request message
  local message = {
    type = "REQUEST",
    messageType = "TAMPER_STATUS",
    requestId = requestId,
  }
  
  -- Serialize and send
  local success, serialized = pcall(AceSerializer.Serialize, AceSerializer, message)
  if not success or not serialized then
    -- Serialization failed - call callback with failure
    pendingRequests[requestId] = nil
    callback(false, playerName, false)
    return false
  end
  
  AceComm:SendCommMessage(COMM_PREFIX, serialized, "WHISPER", playerName, "NORMAL")
  
  -- Set up timeout check
  C_Timer.After(REQUEST_TIMEOUT, function()
    local request = pendingRequests[requestId]
    if request and request.playerName == playerName then
      -- Request timed out - call callback with failure
      pendingRequests[requestId] = nil
      request.callback(false, playerName, false)
    end
  end)
  
  return true
end

-- Send tamper status response to requesting player
local function SendTamperStatusResponse(playerName, requestId, isTampered)
  local message = {
    type = "RESPONSE",
    messageType = "TAMPER_STATUS",
    requestId = requestId,
    isTampered = isTampered,
  }
  
  local serialized = AceSerializer:Serialize(message)
  AceComm:SendCommMessage(COMM_PREFIX, serialized, "WHISPER", playerName, "NORMAL")
end

-- Handle incoming communication
local function OnCommReceived(prefix, message, distribution, sender)
  if prefix ~= COMM_PREFIX then
    return
  end
  
  -- Normalize sender name (remove server name if present)
  sender = Ambiguate(sender, "none")
  
  -- Deserialize message (with error handling)
  local success, data = pcall(AceSerializer.Deserialize, AceSerializer, message)
  if not success or not data or not data.type then
    return -- Invalid or corrupted message
  end
  
  -- Handle tamper status requests
  if data.messageType == "TAMPER_STATUS" then
    -- Handle request (someone asking for our tamper status)
    if data.type == "REQUEST" and data.requestId then
      -- Validate request ID exists
      if not data.requestId or type(data.requestId) ~= "string" then
        return -- Invalid request ID
      end
      
      -- Get our tamper status (double-check for robustness)
      local isTampered = false
      if PlayerStateSnapshot and PlayerStateSnapshot.IsTampered then
        isTampered = PlayerStateSnapshot:IsTampered()
      end
      
      -- Send response
      SendTamperStatusResponse(sender, data.requestId, isTampered)
      
    -- Handle response (someone responded to our request)
    elseif data.type == "RESPONSE" and data.requestId and data.isTampered ~= nil then
      -- Find pending request
      local request = pendingRequests[data.requestId]
      if request then
        -- Validate response matches request (prevent spoofing)
        -- Verify sender matches requested player name
        local senderNormalized = string.lower(sender or "")
        local requestedPlayerNormalized = string.lower(request.playerName or "")
        
        if senderNormalized == requestedPlayerNormalized then
          -- Valid response - cache the result
          playerTamperStatus[sender] = {
            isTampered = data.isTampered,
            timestamp = time(),
          }
          
          -- Call callback with success
          request.callback(data.isTampered, sender, true)
          
          -- Remove from pending (only remove valid responses)
          pendingRequests[data.requestId] = nil
        else
          -- Response from wrong player - ignore it
          -- Don't remove request, might still get valid response from correct player
        end
      end
    end
  end
  
  -- Extend here for other message types
  -- if data.messageType == "OTHER_TYPE" then
  --   -- Handle other message types
  -- end
end

-- Get cached tamper status for a player
-- Returns isTampered (boolean), hasCachedData (boolean)
function PlayerComm:GetCachedTamperStatus(playerName)
  if not playerName then
    return false, false
  end
  
  local cached = playerTamperStatus[playerName]
  if cached then
    -- Cache is valid for 5 minutes
    local cacheAge = time() - cached.timestamp
    if cacheAge < 300 then
      return cached.isTampered, true
    else
      -- Expired cache
      playerTamperStatus[playerName] = nil
    end
  end
  
  return false, false
end

-- Clear cached status for a player (force refresh)
function PlayerComm:ClearCachedStatus(playerName)
  if playerName then
    playerTamperStatus[playerName] = nil
  end
end

-- Clear all cached statuses
function PlayerComm:ClearAllCachedStatuses()
  playerTamperStatus = {}
end

-- Register for communication
AceComm:RegisterComm(COMM_PREFIX, OnCommReceived)

-- Export (for backward compatibility)
_G.TamperStatusComm = PlayerComm
_G.PlayerComm = PlayerComm

