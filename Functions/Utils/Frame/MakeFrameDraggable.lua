-- Make a frame draggable
function MakeFrameDraggable(frame)
  if not frame or type(frame) ~= 'table' then
    print('UltraHardcore: Invalid frame provided to MakeFrameDraggable')
    return
  end

  frame:SetMovable(true)
  frame:EnableMouse(true)
  frame:RegisterForDrag('LeftButton')
  frame:SetScript('OnDragStart', frame.StartMoving)
  frame:SetScript('OnDragStop', frame.StopMovingOrSizing)
end
