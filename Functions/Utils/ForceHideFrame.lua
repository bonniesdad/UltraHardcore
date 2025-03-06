ORIGINAL_FRAME_SHOW_FUNCTIONS = {}

function ForceHideFrame(frame)
  -- store original function for restore later
  ORIGINAL_FRAME_SHOW_FUNCTIONS[frame] = frame.Show

  frame.Show = function(_)
    -- noop; block others from show the frame again; do nothing
  end

  -- actually hide it now
  frame:Hide()
end
  
function RestoreAndShowFrame(frame)
  -- restore original show function if stored earlier
  if ORIGINAL_FRAME_SHOW_FUNCTIONS[frame] ~= nil then
    frame.Show = ORIGINAL_FRAME_SHOW_FUNCTIONS[frame]
  end

  frame:Show()
end
