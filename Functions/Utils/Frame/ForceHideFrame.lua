local driverQueue = {}
local inCombat = false

-- A dummy frame we can re-parent other frames to when hiding
local UltraHiddenParent = CreateFrame('Frame', 'UltraHiddenParent', UIParent)
UltraHiddenParent:Hide() -- fully hidden
UltraHiddenParent:SetAlpha(0) -- invisible
UltraHiddenParent:EnableMouse(false) -- can't be interacted with
UltraHiddenParent:EnableMouseWheel(false)
UltraHiddenParent:SetIgnoreParentScale(true)
UltraHiddenParent:SetIgnoreParentAlpha(true)

local function SnapshotFramePoints(frame)
  if not frame or type(frame.GetNumPoints) ~= 'function' or type(
    frame.GetPoint
  ) ~= 'function' then return end

  local numPoints = frame:GetNumPoints() or 0
  if numPoints <= 0 then
    frame._UltraOriginalPoints = nil
    return
  end

  local points = frame._UltraOriginalPoints or {}
  -- clear any previous snapshot
  for i = 1, #points do
    points[i] = nil
  end

  for i = 1, numPoints do
    local point, relativeTo, relativePoint, xOfs, yOfs = frame:GetPoint(i)
    points[i] = { point, relativeTo, relativePoint, xOfs, yOfs }
  end

  frame._UltraOriginalPoints = points
end

local function RestoreFramePoints(frame)
  local points = frame and frame._UltraOriginalPoints
  if not points then return end
  if type(frame.ClearAllPoints) ~= 'function' or type(frame.SetPoint) ~= 'function' then return end

  frame:ClearAllPoints()
  for _, p in ipairs(points) do
    -- Be defensive: some anchor frames can disappear across loads; pcall avoids hard errors.
    pcall(frame.SetPoint, frame, p[1], p[2], p[3], p[4], p[5])
  end
end

local function ApplyDriver(frame, state)
  if not frame then return end

  -- Reparent-hide: safest way to kill visibility & mouse input
  if state == 'hide' then
    -- Snapshot the current layout every time we hide. This matters for clients with Edit Mode
    -- where action bars can be moved while the addon is running.
    local currentParent = frame.GetParent and frame:GetParent() or nil
    if currentParent and currentParent ~= UltraHiddenParent then
      frame._UltraOriginalParent = currentParent
    end
    SnapshotFramePoints(frame)

    -- Detach from all secure visibility systems
    UnregisterStateDriver(frame, 'visibility')

    -- Reparent to the hidden dummy
    frame:SetParent(UltraHiddenParent)
    frame:Hide()
    return
  end

  -- Restore original parent
  if state == 'show' then
    if frame._UltraOriginalParent then
      frame:SetParent(frame._UltraOriginalParent)
    end

    -- Restore anchor points (best-effort). This helps keep Edit Mode bar positions stable.
    RestoreFramePoints(frame)

    frame:Show()
    return
  end
end

local function QueueDriver(frame, state)
  table.insert(driverQueue, {
    frame = frame,
    state = state,
  })
end

local function ProcessQueuedDrivers()
  for _, job in ipairs(driverQueue) do
    ApplyDriver(job.frame, job.state)
  end
  driverQueue = {}
end

-- Event handler for combat state
local combatWatcher = CreateFrame('Frame')
combatWatcher:RegisterEvent('PLAYER_REGEN_DISABLED')
combatWatcher:RegisterEvent('PLAYER_REGEN_ENABLED')

combatWatcher:SetScript('OnEvent', function(_, event)
  if event == 'PLAYER_REGEN_DISABLED' then
    inCombat = true
  elseif event == 'PLAYER_REGEN_ENABLED' then
    inCombat = false
    ProcessQueuedDrivers()
  end
end)

-- Safely hides ANY frame
function ForceHideFrame(frame)
  if not frame then return end

  if inCombat then
    QueueDriver(frame, 'hide')
  else
    ApplyDriver(frame, 'hide')
  end
end

-- Safely shows ANY frame
function RestoreAndShowFrame(frame)
  if not frame then return end

  if inCombat then
    QueueDriver(frame, 'show')
  else
    ApplyDriver(frame, 'show')
  end
end
