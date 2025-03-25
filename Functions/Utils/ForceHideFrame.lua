ORIGINAL_FRAME_SHOW_FUNCTIONS = {}

function ForceHideFrame(frame)

  if not frame then
    return
  end

  -- Store original function only if not already stored
  if ORIGINAL_FRAME_SHOW_FUNCTIONS[frame] == nil then
    ORIGINAL_FRAME_SHOW_FUNCTIONS[frame] = frame.Show
  end

  frame.Show = function(_) end -- Prevent others from showing the frame
  frame:Hide()
end

  
function RestoreAndShowFrame(frame)

  if not frame then
    return
  end

  if ORIGINAL_FRAME_SHOW_FUNCTIONS[frame] ~= nil then
    frame.Show = ORIGINAL_FRAME_SHOW_FUNCTIONS[frame]
  end

  frame:Show()
end
