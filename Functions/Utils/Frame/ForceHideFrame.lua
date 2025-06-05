-- Table to store original frame show functions
local ORIGINAL_FRAME_SHOW_FUNCTIONS = {}

---Forcefully hides a frame and prevents it from being shown
---@param frame Frame The frame to hide
function ForceHideFrame(frame)
    if type(frame) ~= "table" or not frame.Show then
        return
    end

    -- Store original function only if not already stored
    if not ORIGINAL_FRAME_SHOW_FUNCTIONS[frame] then
        ORIGINAL_FRAME_SHOW_FUNCTIONS[frame] = frame.Show
    end

    frame.Show = function() end -- Prevent others from showing the frame
    frame:Hide()
end

---Restores and shows a previously hidden frame
---@param frame Frame The frame to restore and show
function RestoreAndShowFrame(frame)
    if type(frame) ~= "table" or not frame.Show then
        return
    end

    if ORIGINAL_FRAME_SHOW_FUNCTIONS[frame] then
        frame.Show = ORIGINAL_FRAME_SHOW_FUNCTIONS[frame]
        frame:Show()
    end
end
