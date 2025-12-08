local driverQueue = {}
local inCombat = false

local function ApplyDriver(frame, state)
    if type(frame.SetAttribute) ~= "function" then
        -- not a secure frame, safe fallback to standard hide/show
        if state == "hide" then 
            frame:Hide()
        else
            frame:Show()
        end
        return
    end

    -- Change visiblity of a secure frame
    UnregisterStateDriver(frame, "visibility")
    RegisterStateDriver(frame, "visibility", state)
end

local function QueueDriver(frame, state)
    table.insert(driverQueue, {frame = frame, state = state})
end

local function ProcessQueuedDrivers()
    for _, job in ipairs(driverQueue) do
        ApplyDriver(job.frame, job.state)
    end
    driverQueue = {}
end

-- Event handler for combat state
local combatWatcher = CreateFrame("Frame")
combatWatcher:RegisterEvent("PLAYER_REGEN_DISABLED")
combatWatcher:RegisterEvent("PLAYER_REGEN_ENABLED")

combatWatcher:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_REGEN_DISABLED" then
        inCombat = true
    elseif event == "PLAYER_REGEN_ENABLED" then
        inCombat = false
        ProcessQueuedDrivers()
    end
end)

-- Safely hides ANY frame
function ForceHideFrame(frame)
    if not frame then return end

    if inCombat then
        QueueDriver(frame, "hide")
    else
        ApplyDriver(frame, "hide")
    end
end

-- Safely shows ANY frame
function RestoreAndShowFrame(frame)
    if not frame then return end

    if inCombat then
        QueueDriver(frame, "show")
    else
        ApplyDriver(frame, "show")
    end
end