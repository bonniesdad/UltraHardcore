local originalBindings = {}
local swappedBindings = {}
local isKeybindingsCurrentlyUpdated = false

local function saveAndSwapBindings()
  wipe(originalBindings)
  wipe(swappedBindings)

  local swapMap = {
    MOVEFORWARD = 'MOVEBACKWARD',
    MOVEBACKWARD = 'MOVEFORWARD',
    STRAFELEFT = 'STRAFERIGHT',
    STRAFERIGHT = 'STRAFELEFT',
    TURNLEFT = 'TURNRIGHT',
    TURNRIGHT = 'TURNLEFT',
  }

  for action, swappedAction in pairs(swapMap) do
    local keys = { GetBindingKey(action) }
    for _, key in ipairs(keys) do
      if key then
        originalBindings[key] = action
        swappedBindings[key] = swappedAction
      end
    end
  end

  for key, newAction in pairs(swappedBindings) do
    SetBinding(key, newAction)
  end
  SaveBindings(2)
end

local function restoreBindings()
  for key, action in pairs(originalBindings) do
    SetBinding(key, action)
  end
  SaveBindings(2)
  isKeybindingsCurrentlyUpdated = false
end

function UpdateKeyBindings()
  if isKeybindingsCurrentlyUpdated then return end
  isKeybindingsCurrentlyUpdated = true

  saveAndSwapBindings()
  C_Timer.After(1, restoreBindings)
end
