-- Target Tamper Check
-- Simple helper to check if target player is tampered

-- Target Specific Example:
-- local isTampered = GetTargetTamper(function(isTampered)
--   if isTampered then
--     print("Target is tampered")
--   else
--     print("Target is clean")
--   end
-- end)
--
-- Player Specific Example:
-- GetPlayerTamper(playerName, function(isTampered)
--   if isTampered then
--     print("Player is tampered")
--   else
--     print("Player is clean")
--   end
-- end)

-- Check target's tamper status
-- isTampered: true = player is tampered (block), false = player is clean (allow)
-- success: true if got response, false if timeout/failed
function GetTargetTamper(callback)
  if not callback then
    return false
  end
  
  local targetName = GetUnitName("target", true)
  
  if not targetName then
    callback(false) -- No target, allow
    return false
  end
  
  -- Always request fresh data
  if PlayerComm and PlayerComm.RequestTamperStatus then
    PlayerComm:RequestTamperStatus(targetName, function(isTampered, playerName, success)
      if success then
        -- Got valid response - use it
        callback(isTampered)
      else
        -- Timeout or failed - fail-safe: block if we can't verify
        callback(true) -- Assume tampered if we can't verify (fail-safe)
      end
    end)
    return true
  end
  
  -- Failed to request - fail-safe: block if communication unavailable
  callback(true) -- Assume tampered if communication unavailable (fail-safe)
  return false
end

-- Check specific player's tamper status
-- isTampered: true = player is tampered (block), false = player is clean (allow)
function GetPlayerTamper(playerName, callback)
  if not playerName or not callback then
    return false
  end
  
  -- Always request fresh data
  if PlayerComm and PlayerComm.RequestTamperStatus then
    PlayerComm:RequestTamperStatus(playerName, function(isTampered, playerName, success)
      if success then
        -- Got valid response - use it
        callback(isTampered)
      else
        -- Timeout or failed - fail-safe: block if we can't verify
        callback(true) -- Assume tampered if we can't verify (fail-safe)
      end
    end)
    return true
  end
  
  -- Failed to request - fail-safe: block if communication unavailable
  callback(true) -- Assume tampered if communication unavailable (fail-safe)
  return false
end

