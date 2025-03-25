ORIGINAL_FRAME_SHOW_FUNCTIONS = {}

function ForceHideFrame(frame)
  if not frame then
    return -- Avoid errors if the frame is nil
  end

  -- store original function for restore later
  ORIGINAL_FRAME_SHOW_FUNCTIONS[frame] = frame.Show

  frame.Show = function(_) end -- noop; block others from showing the frame again

  -- actually hide it now
  frame:Hide()
end
  
function RestoreAndShowFrame(frame)
  if not frame then
    return -- Avoid errors if the frame is nil
  end

  -- restore original show function if stored earlier
  if ORIGINAL_FRAME_SHOW_FUNCTIONS[frame] ~= nil then
    frame.Show = ORIGINAL_FRAME_SHOW_FUNCTIONS[frame]
  end

  frame:Show()
end
