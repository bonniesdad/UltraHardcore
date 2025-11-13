-- Table to store original frame show functions
local ORIGINAL_FRAME_SHOW_FUNCTIONS = {}

---Forcefully hides a frame and prevents it from being shown
---@param frame Frame The frame to hide
function ForceHideFrame(frame)
    if type(frame) ~= "table" or not frame.Show then
        return
    end

    -- Check if we're in combat lockdown before hiding protected frames
    if InCombatLockdown() then
        -- Defer hiding until combat ends
        local eventFrame = CreateFrame("Frame")
        eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
        eventFrame:SetScript("OnEvent", function(self, event)
            if event == "PLAYER_REGEN_ENABLED" then
                -- Combat ended, now safe to hide
                ForceHideFrame(frame)
                self:UnregisterAllEvents()
            end
        end)
        return
    end

    -- Store original function only if not already stored
    if not ORIGINAL_FRAME_SHOW_FUNCTIONS[frame] then
        ORIGINAL_FRAME_SHOW_FUNCTIONS[frame] = frame.Show
    end

    -- Use pcall to safely attempt hiding protected frames
    local success, err = pcall(function()
        frame.Show = function() end -- Prevent others from showing the frame
        frame:Hide()
    end)
    
    -- If the operation failed (protected frame in protected context), defer it
    if not success then
        C_Timer.After(0.5, function()
            if not InCombatLockdown() then
                ForceHideFrame(frame)
            end
        end)
    end
end

---Restores and shows a previously hidden frame
---@param frame Frame The frame to restore and show
function RestoreAndShowFrame(frame)
    if type(frame) ~= "table" or not frame.Show then
        return
    end

    -- Check if we're in combat lockdown before showing protected frames
    if InCombatLockdown() then
        -- Defer showing until combat ends
        local eventFrame = CreateFrame("Frame")
        eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
        eventFrame:SetScript("OnEvent", function(self, event)
            if event == "PLAYER_REGEN_ENABLED" then
                -- Combat ended, now safe to show
                RestoreAndShowFrame(frame)
                self:UnregisterAllEvents()
            end
        end)
        return
    end

    if ORIGINAL_FRAME_SHOW_FUNCTIONS[frame] then
        local success, err = pcall(function()
            frame.Show = ORIGINAL_FRAME_SHOW_FUNCTIONS[frame]
            frame:Show()
        end)
        
        -- If the operation failed, defer it
        if not success then
            C_Timer.After(0.5, function()
                if not InCombatLockdown() then
                    RestoreAndShowFrame(frame)
                end
            end)
        end
    end
end
