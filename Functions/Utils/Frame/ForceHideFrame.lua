local driverQueue = {}
local inCombat = false

-- A dummy frame we can re-parent other frames to when hiding
local UltraHiddenParent = CreateFrame("Frame", "UltraHiddenParent", UIParent)
UltraHiddenParent:Hide()                 -- fully hidden
UltraHiddenParent:SetAlpha(0)            -- invisible
UltraHiddenParent:EnableMouse(false)     -- can't be interacted with
UltraHiddenParent:EnableMouseWheel(false)
UltraHiddenParent:SetIgnoreParentScale(true)
UltraHiddenParent:SetIgnoreParentAlpha(true)


local function ApplyDriver(frame, state)
    if not frame then return end

    -- Reparent-hide: safest way to kill visibility & mouse input
    if state == "hide" then
        if not frame._UltraOriginalParent then
            frame._UltraOriginalParent = frame:GetParent()
        end

        -- Detach from all secure visibility systems
        UnregisterStateDriver(frame, "visibility")

        -- Reparent to the hidden dummy
        frame:SetParent(UltraHiddenParent)
        frame:Hide()
        return
    end

    -- Restore original parent
    if state == "show" then
        if frame._UltraOriginalParent then
            frame:SetParent(frame._UltraOriginalParent)
        end

        frame:Show()
        return
    end

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