local enabled = false
local ticker  = nil
local TICK_INTERVAL = 1  -- seconds

local function zoomInHard()
  CameraZoomIn(50)
end

local function zoomOutHard()
  CameraZoomOut(50)
end


local function startTicker()
  if ticker then return end
  ticker = C_Timer.NewTicker(TICK_INTERVAL, function()
    if not enabled then return end
    if GetCameraZoom and GetCameraZoom() > 0.01 then
      zoomInHard()
    end
  end)
end

local function stopTicker()
  if ticker then
    ticker:Cancel()
    ticker = nil
  end
end


local function enableLock()
  enabled = true
  zoomInHard()
  startTicker()
end

local function disableLock()
  enabled = false
  stopTicker()
  zoomOutHard()
end

-- PUBLIC API (unchanged)
function ForceFirstPersonCamera(forceFirstPerson)
  if forceFirstPerson then
    enableLock()
  else
    disableLock()
  end
end